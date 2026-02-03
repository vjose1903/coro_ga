import 'dart:async';

import 'package:flutter/material.dart';
import '../helpers/helpers.dart';
import '../providers/premium_provider.dart';
import '../services/ad_ids_service.dart';
import '../shared_preferences/preferences.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class GoogleBannerAd extends StatefulWidget {
  const GoogleBannerAd({super.key, required this.location, this.onCloseAd});

  final AdLocation location;
  final Function? onCloseAd;

  @override
  State<GoogleBannerAd> createState() => _GoogleBannerAdState();
}

class _GoogleBannerAdState extends State<GoogleBannerAd> {
  BannerAd? _bannerAd;
  BannerAd? _loadingAd;
  bool _isLoading = false;
  bool _retryScheduled = false;
  Timer? _retryTimer;
  int _retryCount = 0;
  DateTime? _lastLogAt;
  DateTime? _lastRetryLogAt;
  StreamSubscription<void>? _idsUpdatedSub;
  static const Duration _baseRetryDelay = Duration(seconds: 2);
  static const Duration _maxRetryDelay = Duration(seconds: 30);
  static const Duration _logCooldown = Duration(minutes: 4);

  @override
  void initState() {
    super.initState();
    if (Preferences.isPremium) {
      return;
    }
    _idsUpdatedSub = AdIdsService.idsUpdatedStream.listen((_) {
      if (!mounted || _bannerAd != null) return;
      _loadBanner();
    });

    // Intentar cargar inmediatamente si ya estamos listos,
    // pero damos un pequeño respiro para que cualquier instancia previa se limpie.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _loadBanner();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant GoogleBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (Preferences.isPremium) {
      _disposeBanner();
      _retryScheduled = false;
      _isLoading = false;
      _retryTimer?.cancel();
      _retryCount = 0;
      return;
    }
    if (oldWidget.location != widget.location) {
      _disposeBanner();
      _retryScheduled = false;
      _isLoading = false;
      _retryTimer?.cancel();
      _retryCount = 0;
      _loadBanner();
    }
  }

  void _loadBanner() {
    if (Preferences.isPremium) return;
    if (_isLoading || !mounted) return;

    // Si ya tenemos un banner mostrado, no cargamos otro sobre él
    if (_bannerAd != null) return;

    final adUnitId = AdHelper.getBannerAdUnitId(widget.location);
    if (adUnitId.isEmpty) {
      if (!AdIdsService.isInitialized) {
        _logThrottled('GoogleBannerAd: Waiting for AdIdsService...');
        return;
      }

      _logThrottled(
        'GoogleBannerAd: empty adUnitId for ${widget.location} but Service is Ready',
      );
      _scheduleRetry();
      return;
    }

    _disposeBanner();
    _isLoading = true;

    _loadingAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _loadingAd = null;
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
          _retryScheduled = false;
          _retryTimer?.cancel();
          _retryCount = 0;
          _isLoading = false;
          _logThrottled('GoogleBannerAd: loaded for ${widget.location}');
        },
        onAdFailedToLoad: (ad, error) {
          _loadingAd = null;
          ad.dispose();
          _isLoading = false;
          _logThrottled(
            'GoogleBannerAd: failed for ${widget.location} code=${error.code}',
          );
          FirebaseCrashlytics.instance.recordError(
            error,
            StackTrace.current,
            fatal: false,
            reason: 'GoogleBannerAd failed for ${widget.location}',
          );
          _scheduleRetry();
        },
      ),
    );
    _loadingAd!.load();
  }

  void _scheduleRetry() {
    if (_retryScheduled || _bannerAd != null || !mounted) return;
    _retryScheduled = true;
    final delay = _nextRetryDelay();
    _logRetryThrottled(
      'GoogleBannerAd: retry in ${delay.inSeconds}s for ${widget.location} (attempt $_retryCount)',
    );
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (!mounted || _bannerAd != null) return;
      _retryScheduled = false;
      _loadBanner();
    });
  }

  Duration _nextRetryDelay() {
    _retryCount = (_retryCount + 1).clamp(1, 10);
    // Crecimiento más suave: 2s, 4s, 6s...
    final multiplier = 1.0 * (_retryCount - 1);
    final baseMs = _baseRetryDelay.inMilliseconds;
    var delayMs = (baseMs * (1 + multiplier)).round();
    if (delayMs > _maxRetryDelay.inMilliseconds) {
      delayMs = _maxRetryDelay.inMilliseconds;
    }
    final jitterMs = DateTime.now().microsecondsSinceEpoch % 1000;
    return Duration(milliseconds: delayMs + jitterMs);
  }

  @override
  Widget build(BuildContext context) {
    // Usamos watch para reconstruir cuando cambie el estado premium
    final premiumProvider = context.watch<PremiumProvider>();
    final isPremium = premiumProvider.isPremium;

    // Gestión reactiva del banner basada en el estado premium
    if (isPremium) {
      // Si nos volvimos premium y tenemos un banner cargado, hay que liberarlo
      if (_bannerAd != null || _isLoading || _retryScheduled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _disposeBanner();
            _retryScheduled = false;
            _isLoading = false;
            _retryTimer?.cancel();
            _retryCount = 0;
            // Forzar rebuild para limpiar UI si es necesario (aunque el if de abajo ya lo oculta)
            setState(() {});
          }
        });
      }
      return const SizedBox.shrink();
    } else {
      // Si NO somos premium y no tenemos banner ni estamos cargando, intentamos cargar
      if (_bannerAd == null && !_isLoading && !_retryScheduled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadBanner();
        });
      }
    }

    final double width = _bannerAd?.size.width.toDouble() ?? 300;
    final double height = _bannerAd?.size.height.toDouble() ?? 50;

    return Container(
      key: _bannerAd != null ? ObjectKey(_bannerAd) : null,
      width: width,
      alignment: Alignment.topCenter,
      child: _bannerAd == null
          ? Shimmer.fromColors(
              baseColor: Preferences.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: Preferences.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          : SizedBox(
              width: width,
              height: height,
              child: AdWidget(ad: _bannerAd!),
            ),
    );
  }

  void _disposeBanner() {
    if (_loadingAd != null) {
      _loadingAd!.dispose();
      _loadingAd = null;
    }
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
  }

  void _logThrottled(String message) {
    final now = DateTime.now();
    if (_lastLogAt != null && now.difference(_lastLogAt!) < _logCooldown) {
      return;
    }
    _lastLogAt = now;
    FirebaseCrashlytics.instance.log(message);
  }

  void _logRetryThrottled(String message) {
    final now = DateTime.now();
    if (_lastRetryLogAt != null && now.difference(_lastRetryLogAt!) < _logCooldown) {
      return;
    }
    _lastRetryLogAt = now;
    FirebaseCrashlytics.instance.log(message);
  }

  @override
  void dispose() {
    _idsUpdatedSub?.cancel();
    _retryTimer?.cancel();
    _disposeBanner();
    _isLoading = false;
    _retryScheduled = false;
    _retryCount = 0;
    super.dispose();
  }
}
