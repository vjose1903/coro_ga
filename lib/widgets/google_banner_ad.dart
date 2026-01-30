import 'dart:async';

import 'package:flutter/material.dart';
import '../helpers/helpers.dart';
import '../providers/premium_provider.dart';
import '../services/banner_prefetch_service.dart';
import '../services/ad_ids_service.dart';
import '../shared_preferences/preferences.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
  bool _isRequesting = false;
  bool _retryScheduled = false;
  late final BannerPrefetchService _bannerService;
  StreamSubscription<void>? _idsUpdatedSub;
  static const Duration _retryDelay = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _bannerService = context.read<BannerPrefetchService>();
    _idsUpdatedSub = AdIdsService.idsUpdatedStream.listen((_) {
      if (!mounted || _bannerAd != null) return;
      _requestBanner();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bannerService.ensurePrefetched(widget.location);
      _requestBanner();
      _startSkeletonTimer();
    });
  }

  @override
  void didUpdateWidget(covariant GoogleBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      if (_bannerAd != null) {
        _bannerService.releaseBanner(oldWidget.location, _bannerAd!);
        _bannerAd = null;
      }
      _bannerService.ensurePrefetched(widget.location);
      _requestBanner();
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

  void _requestBanner() {
    if (_isRequesting || _bannerAd != null) return;
    _isRequesting = true;
    final readyAd = _bannerService.leaseReadyBanner(widget.location);
    if (readyAd != null) {
      setState(() {
        _bannerAd = readyAd;
        _isHideSkeleton = false;
      });
      _retryScheduled = false;
      _isRequesting = false;
      return;
    }

    _bannerService.acquireBannerAd(widget.location).then((ad) {
      if (!mounted) {
        ad.dispose();
        return;
      }
      setState(() {
        _bannerAd = ad;
        _isHideSkeleton = false;
      });
      _retryScheduled = false;
    }).catchError((_) {
      _scheduleRetry();
    }).whenComplete(() {
      _isRequesting = false;
      if (_bannerAd == null) {
        _scheduleRetry();
      }
    });
  }

  void _scheduleRetry() {
    if (_retryScheduled || _bannerAd != null || !mounted) return;
    _retryScheduled = true;
    Future.delayed(_retryDelay, () {
      if (!mounted || _bannerAd != null) return;
      _retryScheduled = false;
      _requestBanner();
    });
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
    if (_bannerAd != null) {
      _bannerService.releaseBanner(widget.location, _bannerAd!);
      _bannerAd = null;
    }
    super.dispose();
  }
}
