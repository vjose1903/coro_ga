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
  bool _isHideSkeleton = false;
  bool _timerStarted = false;
  bool _isLoading = false;
  bool _retryScheduled = false;
  Timer? _retryTimer;
  int _retryCount = 0;
  StreamSubscription<void>? _idsUpdatedSub;
  static const Duration _baseRetryDelay = Duration(seconds: 8);
  static const Duration _maxRetryDelay = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    _idsUpdatedSub = AdIdsService.idsUpdatedStream.listen((_) {
      if (!mounted || _bannerAd != null) return;
      _loadBanner();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBanner();
      _startSkeletonTimer();
    });
  }

  @override
  void didUpdateWidget(covariant GoogleBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
      }
      _timerStarted = false;
      _isHideSkeleton = false;
      _retryScheduled = false;
      _isLoading = false;
      _retryTimer?.cancel();
      _retryCount = 0;
      _loadBanner();
      _startSkeletonTimer();
    }
  }

  void _startSkeletonTimer() {
    if (_timerStarted || _bannerAd != null) return;
    _timerStarted = true;
    Future.delayed(const Duration(seconds: 30)).then((_) {
      if (!mounted) return;
      if (_bannerAd == null) setState(() => _isHideSkeleton = true);
    });
  }

  void _loadBanner() {
    if (_isLoading || _bannerAd != null || !mounted) return;
    _isLoading = true;
    final adUnitId = AdHelper.getBannerAdUnitId(widget.location);
    if (adUnitId.isEmpty) {
      _isLoading = false;
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
            _isHideSkeleton = false;
          });
          _retryScheduled = false;
          _retryTimer?.cancel();
          _retryCount = 0;
          _isLoading = false;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoading = false;
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
    if (premiumProvider.isPremium || (_isHideSkeleton && _bannerAd == null)) {
      return const SizedBox.shrink();
    }

    if (_bannerAd != null && _isHideSkeleton) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isHideSkeleton) setState(() => _isHideSkeleton = false);
      });
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

  @override
  void dispose() {
    _idsUpdatedSub?.cancel();
    _retryTimer?.cancel();
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
    _isLoading = false;
    _retryScheduled = false;
    _retryCount = 0;
    super.dispose();
  }
}
