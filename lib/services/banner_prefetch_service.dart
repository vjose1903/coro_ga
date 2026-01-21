import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:game_score/helpers/helpers.dart';

/// Servicio que precarga y mantiene en memoria los banners por ubicación.
class BannerPrefetchService {
  final Duration _cacheDuration = const Duration(minutes: 10);
  final Map<AdLocation, BannerAd?> _readyAds = {};
  final Map<AdLocation, DateTime> _readyAt = {};
  final Map<AdLocation, bool> _isLoading = {};
  final Map<AdLocation, List<Completer<BannerAd>>> _pendingCompleters = {};
  final Map<AdLocation, BannerAd?> _leasedAds = {};

  /// Devuelve un banner ya precargado cuando está disponible.
  BannerAd? getBanner(AdLocation location) {
    _refreshIfStale(location);
    return _readyAds[location];
  }

  /// Indica si ya hay un request en curso para esa ubicación.
  bool isLoading(AdLocation location) => _isLoading[location] ?? false;

  /// Garantiza que la ubicación tenga un banner en caché.
  void ensurePrefetched(AdLocation location) {
    _refreshIfStale(location);
    if (_readyAds[location] != null || _leasedAds[location] != null || _isLoading[location] == true) return;
    _startLoading(location);
  }

  /// Entrega el banner precargado si está listo.
  BannerAd? leaseReadyBanner(AdLocation location) {
    _refreshIfStale(location);
    final readyAd = _readyAds.remove(location);
    if (readyAd != null) {
      _leasedAds[location] = readyAd;
      _readyAt.remove(location);
    }
    return readyAd;
  }

  /// Devuelve un banner listo o espera uno nuevo.
  Future<BannerAd> acquireBannerAd(AdLocation location) {
    final readyAd = leaseReadyBanner(location);
    if (readyAd != null) {
      _startLoading(location);
      return Future.value(readyAd);
    }

    final completer = Completer<BannerAd>();
    _pendingCompleters.putIfAbsent(location, () => []).add(completer);
    ensurePrefetched(location);
    return completer.future;
  }

  /// Libera un banner (por ejemplo cuando el widget es desmontado) para poder reutilizarlo.
  void releaseBanner(AdLocation location, BannerAd ad) {
    final leased = _leasedAds[location];
    if (leased != ad) return;
    _leasedAds.remove(location);
    _readyAds[location] = ad;
    _readyAt[location] = DateTime.now();
  }

  void _refreshIfStale(AdLocation location) {
    final lastLoaded = _readyAt[location];
    if (lastLoaded == null) return;

    if (DateTime.now().difference(lastLoaded) > _cacheDuration) {
      _readyAds.remove(location)?.dispose();
      _readyAt.remove(location);
    }
  }

  void _startLoading(AdLocation location) {
    if (_isLoading[location] == true) return;

    _isLoading[location] = true;
    BannerAd(
      adUnitId: AdHelper.getBannerAdUnitId(location),
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => _onBannerLoaded(location, ad as BannerAd),
        onAdFailedToLoad: (ad, error) => _onBannerFailed(location, ad, error),
      ),
    ).load();
  }

  void _onBannerLoaded(AdLocation location, BannerAd ad) {
    _isLoading[location] = false;
    final pending = _pendingCompleters[location];
    if (pending != null && pending.isNotEmpty) {
      final completer = pending.removeAt(0);
      completer.complete(ad);
      _leasedAds[location] = ad;
      if (pending.isNotEmpty) {
        _startLoading(location);
      }
    } else {
      _readyAds[location] = ad;
      _readyAt[location] = DateTime.now();
    }
  }

  void _onBannerFailed(AdLocation location, Ad ad, LoadAdError error) {
    (ad as BannerAd).dispose();
    _isLoading[location] = false;

    final pending = _pendingCompleters[location];
    if (pending != null && pending.isNotEmpty) {
      final completer = pending.removeAt(0);
      completer.completeError(error);
      if (pending.isNotEmpty) {
        _startLoading(location);
      }
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (_readyAds[location] == null &&
          (_pendingCompleters[location]?.isEmpty ?? true)) {
        _startLoading(location);
      }
    });
  }

  void dispose() {
    for (final ad in _readyAds.values) {
      ad?.dispose();
    }
    for (final ad in _leasedAds.values) {
      ad?.dispose();
    }
    _readyAds.clear();
    _readyAt.clear();
    _isLoading.clear();
    _pendingCompleters.clear();
    _leasedAds.clear();
  }
}
