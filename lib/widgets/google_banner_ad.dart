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
  bool _isLoading = false;
  bool _retryScheduled = false;
  Timer? _retryTimer;
  int _retryCount = 0;
  DateTime? _lastLogAt;
  DateTime? _lastRetryLogAt;
  StreamSubscription<void>? _idsUpdatedSub;
  static const Duration _baseRetryDelay = Duration(seconds: 8);
  static const Duration _maxRetryDelay = Duration(seconds: 60);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBanner();
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
    _disposeBanner();
    _isLoading = true;
    final adUnitId = AdHelper.getBannerAdUnitId(widget.location);
    if (adUnitId.isEmpty) {
      _isLoading = false;
      _logThrottled(
        'GoogleBannerAd: empty adUnitId for ${widget.location}',
      );
      FirebaseCrashlytics.instance.log(
        'GoogleBannerAd: empty adUnitId for ${widget.location}',
      );
      _scheduleRetry();
      return;
    }

    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
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
    ).load();
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
    final multiplier = 1.7 * (_retryCount - 1);
    final baseMs = _baseRetryDelay.inMilliseconds;
    var delayMs = (baseMs * (1 + multiplier)).round();
    if (delayMs > _maxRetryDelay.inMilliseconds) {
      delayMs = _maxRetryDelay.inMilliseconds;
    }
    final jitterMs = DateTime.now().microsecondsSinceEpoch % 2000;
    return Duration(milliseconds: delayMs + jitterMs);
  }

  @override
  Widget build(BuildContext context) {
    final premiumProvider = context.watch<PremiumProvider>();
    final double width = _bannerAd?.size.width.toDouble() ?? 300;
    final double height = _bannerAd?.size.height.toDouble() ?? 50;

    // No mostrar anuncios si es premium
    if (premiumProvider.isPremium) {
      return const SizedBox.shrink();
    }

    return Container(
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
