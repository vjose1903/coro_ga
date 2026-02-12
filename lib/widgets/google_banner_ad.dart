import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../helpers/helpers.dart';
import '../providers/premium_provider.dart';

class GoogleBannerAd extends StatefulWidget {
  const GoogleBannerAd({required this.location, this.onCloseAd, super.key});

  final AdLocation location;
  final Function? onCloseAd;

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

  Future<void> _loadBanner({int? width}) async {
    if (_isLoading || !mounted || _bannerAd != null) return;
    _isLoading = true;
    _loadScheduled = false;

    final adUnitId = AdHelper.getBannerAdUnitId(widget.location);
    debugPrint('BannerAd load start: location=${widget.location}, unitId=$adUnitId');
    if (adUnitId.isEmpty) {
      debugPrint('BannerAd load aborted: empty adUnitId for location=${widget.location}');
      _isLoading = false;
      return;
    }

    final mediaSize = MediaQuery.of(context).size;
    final shortestSide = mediaSize.shortestSide;
    final isLargeDevice = shortestSide >= 600;
    final int resolvedWidth = width ?? mediaSize.width.truncate();
    final adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(resolvedWidth);
    if (!mounted || adaptiveSize == null) {
      debugPrint('BannerAd load aborted: adaptive size null for width=$resolvedWidth');
      _isLoading = false;
      return;
    }

    // In larger devices anchored adaptive can be too tall; cap to full banner height.
    final AdSize chosenSize = isLargeDevice && adaptiveSize.height > 60 ? AdSize.fullBanner : adaptiveSize;
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
          debugPrint('BannerAd loaded: location=${widget.location}, unitId=$adUnitId, size=${_bannerAd?.size}');

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
      final width = (MediaQuery.of(context).size.width - (_horizontalPadding * 2)).truncate();
      _loadBanner(width: width);
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

    final double width = _bannerAd?.size.width.toDouble() ?? _adSize?.width.toDouble() ?? 320;
    final double height = _bannerAd?.size.height.toDouble() ?? _adSize?.height.toDouble() ?? 50;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Container(
        key: _bannerAd != null ? ObjectKey(_bannerAd) : null,
        width: width,
        alignment: Alignment.topCenter,
        child: _bannerAd == null ? SizedBox(width: width, height: height) : SizedBox(width: width, height: height, child: AdWidget(ad: _bannerAd!)),
      ),
    );
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
    final delay = Duration(seconds: (_retryAttempt >= 3) ? 30 : 10 * (_retryAttempt + 1));
    _retryAttempt += 1;
    debugPrint('BannerAd retry scheduled: location=${widget.location}, attempt=$_retryAttempt, in=${delay.inSeconds}s');
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      if (!mounted) return;
      final width = (MediaQuery.of(context).size.width - (_horizontalPadding * 2)).truncate();
      _loadBanner(width: width);
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
