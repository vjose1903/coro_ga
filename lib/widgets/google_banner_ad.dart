import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../helpers/helpers.dart';
import '../providers/premium_provider.dart';

class GoogleBannerAd extends StatefulWidget {
  const GoogleBannerAd({
    required this.location,
    this.onCloseAd,
    this.usePadding = true,
    super.key,
  });

  final AdLocation location;
  final Function? onCloseAd;
  final bool usePadding;

  @override
  State<GoogleBannerAd> createState() => _GoogleBannerAdState();
}

class _GoogleBannerAdState extends State<GoogleBannerAd> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _isLoading = false;
  bool _loadScheduled = false;
  Timer? _retryTimer;
  int _retryAttempt = 0;
  static const double _horizontalPadding = 16;
  static const double _bannerMinWidth = 320;
  static const double _bannerHeight = 50;

  @override
  void initState() {
    super.initState();
    _scheduleBannerLoad();
  }

  @override
  void didUpdateWidget(covariant GoogleBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _disposeBanner();
      _isLoading = false;
      _scheduleBannerLoad();
    }
  }

  Future<void> _loadBanner() async {
    if (_isLoading || !mounted || _bannerAd != null) return;

    final availableWidth = _availableBannerWidth(context);
    if (availableWidth < _bannerMinWidth) {
      debugPrint(
        'BannerAd skipped: location=${widget.location}, availableWidth=$availableWidth < $_bannerMinWidth',
      );
      return;
    }

    _isLoading = true;
    _loadScheduled = false;

    final adUnitId = AdHelper.getBannerAdUnitId(widget.location);
    debugPrint(
        'BannerAd load start: location=${widget.location}, unitId=$adUnitId');
    if (adUnitId.isEmpty) {
      debugPrint(
          'BannerAd load aborted: empty adUnitId for location=${widget.location}');
      _isLoading = false;
      return;
    }

    // Use a fixed size banner to avoid rotation/layout width mismatches.
    const AdSize chosenSize = AdSize.banner;
    _adSize = chosenSize;

    _disposeBanner();

    final ad = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: chosenSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _retryAttempt = 0;
          });
          _retryTimer?.cancel();
          _isLoading = false;

          debugPrint('   ');
          debugPrint('   ');
          debugPrint('   ');
          debugPrint('   ');
          debugPrint('Loaded');
          debugPrint('   ');
          debugPrint('   ');
          debugPrint(
              'BannerAd loaded: location=${widget.location}, unitId=$adUnitId, size=${_bannerAd?.size}');

          final info = (ad as BannerAd).responseInfo;
          debugPrint('Winner adapter: ${info?.mediationAdapterClassName}');
          debugPrint('ResponseInfo: $info');
          debugPrint('   ');
          debugPrint('   ');
          debugPrint('   ');
          debugPrint('   ');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          _isLoading = false;
          debugPrint(
            'BannerAd failed: location=${widget.location}, unitId=$adUnitId, code=${error.code}, message=${error.message}, domain=${error.domain}',
          );
          FirebaseCrashlytics.instance.log(
            'BannerAd failed: location=${widget.location}, unitId=$adUnitId, code=${error.code}, message=${error.message}, domain=${error.domain}',
          );
          FirebaseCrashlytics.instance.recordError(
            error,
            StackTrace.current,
            reason: 'BannerAd failed to load',
            information: [
              'location=${widget.location}',
              'unitId=$adUnitId',
              'code=${error.code}',
              'message=${error.message}',
              'domain=${error.domain}',
            ],
          );
          _scheduleRetry();
        },
      ),
    );
    unawaited(ad.load());
  }

  void _scheduleBannerLoad() {
    if (_loadScheduled || !mounted) return;
    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos watch para reconstruir cuando cambie el estado premium
    final premiumProvider = context.watch<PremiumProvider>();
    final isPremium = premiumProvider.isPremium;

    if (isPremium) {
      if (_bannerAd != null || _isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _disposeBanner();
            _isLoading = false;
            setState(() {});
          }
        });
      }
      return const SizedBox.shrink();
    }

    if (_bannerAd == null && !_isLoading) {
      _scheduleBannerLoad();
    }

    final availableWidth = _availableBannerWidth(context);
    if (availableWidth < _bannerMinWidth) {
      if (_bannerAd != null || _isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _retryTimer?.cancel();
          _disposeBanner();
          _isLoading = false;
          setState(() {});
        });
      }
      return const SizedBox.shrink();
    }

    final double width = _bannerAd?.size.width.toDouble() ??
        _adSize?.width.toDouble() ??
        _bannerMinWidth;
    final double height = _bannerAd?.size.height.toDouble() ??
        _adSize?.height.toDouble() ??
        _bannerHeight;

    final banner = Container(
      key: _bannerAd != null ? ObjectKey(_bannerAd) : null,
      width: width,
      alignment: Alignment.topCenter,
      child: _bannerAd == null
          ? SizedBox(width: width, height: height)
          : SizedBox(
              width: width, height: height, child: AdWidget(ad: _bannerAd!)),
    );

    if (!widget.usePadding) return banner;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: banner,
    );
  }

  double _availableBannerWidth(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final horizontalInsets = widget.usePadding ? _horizontalPadding * 2 : 0;
    final available = mediaWidth - horizontalInsets;
    return available > 0 ? available : 0;
  }

  void _disposeBanner() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
  }

  void _scheduleRetry() {
    if (!mounted) return;
    _retryTimer?.cancel();
    final delay =
        Duration(seconds: (_retryAttempt >= 3) ? 30 : 10 * (_retryAttempt + 1));
    _retryAttempt += 1;
    debugPrint(
        'BannerAd retry scheduled: location=${widget.location}, attempt=$_retryAttempt, in=${delay.inSeconds}s');
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      if (!mounted) return;
      _loadBanner();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _disposeBanner();
    _isLoading = false;
    super.dispose();
  }
}
