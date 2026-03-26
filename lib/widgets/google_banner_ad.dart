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
  static final Map<AdLocation, int> _locationLoadOwner = <AdLocation, int>{};
  static final Map<AdLocation, int> _locationRetryAttempt = <AdLocation, int>{};
  static final Map<AdLocation, DateTime> _locationNextAllowedLoadAt = <AdLocation, DateTime>{};
  static const double _horizontalPadding = 16;
  static const double _bannerMinWidth = 320;
  static const double _bannerHeight = 50;
  String get _instanceTag => 'GoogleBannerAd#${identityHashCode(this)}(${widget.location.name})';
  int get _instanceId => identityHashCode(this);
  bool get _hasActiveLocationOwner => _locationLoadOwner[widget.location] != null;
  bool get _isLocationOwner => _locationLoadOwner[widget.location] == _instanceId;

  @override
  void initState() {
    super.initState();
    debugPrint('$_instanceTag init');
    _scheduleBannerLoad();
  }

  @override
  void didUpdateWidget(covariant GoogleBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      debugPrint('$_instanceTag location changed ${oldWidget.location.name} -> ${widget.location.name}');
      _retryTimer?.cancel();
      _retryTimer = null;
      _disposeBanner();
      _isLoading = false;
      _scheduleBannerLoad();
    }
  }

  Future<void> _loadBanner() async {
    if (_isLoading || !mounted || _bannerAd != null || _retryTimer != null) {
      debugPrint(
        '$_instanceTag load skipped isLoading=$_isLoading mounted=$mounted hasBanner=${_bannerAd != null} hasRetry=${_retryTimer != null}',
      );
      return;
    }
    _loadScheduled = false;

    final now = DateTime.now();
    final nextAllowedLoadAt = _locationNextAllowedLoadAt[widget.location];
    if (nextAllowedLoadAt != null && nextAllowedLoadAt.isAfter(now)) {
      final wait = nextAllowedLoadAt.difference(now);
      debugPrint('$_instanceTag global cooldown active wait=${wait.inMilliseconds}ms');
      _scheduleRetry(delayOverride: wait, incrementGlobalAttempt: false);
      return;
    }

    if (_hasActiveLocationOwner && !_isLocationOwner) {
      debugPrint('$_instanceTag load skipped because another instance owns loading for ${widget.location.name}');
      _scheduleRetry(delayOverride: const Duration(seconds: 1), incrementGlobalAttempt: false);
      return;
    }

    final availableWidth = _availableBannerWidth(context);
    if (availableWidth < _bannerMinWidth) {
      debugPrint(
        '$_instanceTag width skipped availableWidth=$availableWidth < $_bannerMinWidth',
      );
      return;
    }

    _isLoading = true;
    _locationLoadOwner[widget.location] = _instanceId;

    final adUnitId = AdHelper.getBannerAdUnitId(widget.location);
    debugPrint('$_instanceTag load start unitId=$adUnitId');
    if (adUnitId.isEmpty) {
      debugPrint('BannerAd load aborted: empty adUnitId for location=${widget.location}');
      _isLoading = false;
      _releaseLocationOwnerIfNeeded();
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
          _releaseLocationOwnerIfNeeded();
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _retryAttempt = 0;
          });
          _locationRetryAttempt[widget.location] = 0;
          _locationNextAllowedLoadAt.remove(widget.location);
          _retryTimer?.cancel();
          _isLoading = false;

          debugPrint('   ');
          debugPrint('   ');
          debugPrint('   ');
          debugPrint('   ');
          debugPrint('Loaded');
          debugPrint('   ');
          debugPrint('   ');
          debugPrint('$_instanceTag loaded unitId=$adUnitId size=${_bannerAd?.size}');

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
          _releaseLocationOwnerIfNeeded();
          if (!mounted) return;
          _isLoading = false;
          debugPrint(
            '$_instanceTag failed unitId=$adUnitId code=${error.code} message=${error.message} domain=${error.domain}',
          );
          FirebaseCrashlytics.instance.log(
            '$_instanceTag failed unitId=$adUnitId code=${error.code} message=${error.message} domain=${error.domain}',
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
          _scheduleRetry(incrementGlobalAttempt: true);
        },
      ),
    );
    unawaited(ad.load());
  }

  void _scheduleBannerLoad() {
    if (_loadScheduled || !mounted || _retryTimer != null) {
      debugPrint(
        '$_instanceTag schedule skipped loadScheduled=$_loadScheduled mounted=$mounted hasRetry=${_retryTimer != null}',
      );
      return;
    }
    debugPrint('$_instanceTag schedule load');
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
            _retryTimer?.cancel();
            _retryTimer = null;
            _disposeBanner();
            _isLoading = false;
            setState(() {});
          }
        });
      }
      return const SizedBox.shrink();
    }

    if (_bannerAd == null && !_isLoading && _retryTimer == null) {
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

    final double width = _bannerAd?.size.width.toDouble() ?? _adSize?.width.toDouble() ?? _bannerMinWidth;
    final double height = _bannerAd?.size.height.toDouble() ?? _adSize?.height.toDouble() ?? _bannerHeight;

    final banner = Container(
      width: width,
      alignment: Alignment.topCenter,
      child: _bannerAd == null ? SizedBox(width: width, height: height) : SizedBox(width: width, height: height, child: AdWidget(ad: _bannerAd!)),
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

  void _releaseLocationOwnerIfNeeded() {
    if (_isLocationOwner) {
      _locationLoadOwner.remove(widget.location);
    }
  }

  void _scheduleRetry({required bool incrementGlobalAttempt, Duration? delayOverride}) {
    if (!mounted) return;
    _retryTimer?.cancel();
    int globalAttempt = _locationRetryAttempt[widget.location] ?? 0;
    if (incrementGlobalAttempt) {
      globalAttempt += 1;
      _locationRetryAttempt[widget.location] = globalAttempt;
    }
    _retryAttempt = globalAttempt;

    final attemptForDelay = globalAttempt <= 0 ? 1 : globalAttempt;
    final delay = delayOverride ?? Duration(seconds: 10 + ((attemptForDelay - 1) * 5));
    final normalizedDelay = delay < const Duration(milliseconds: 300) ? const Duration(milliseconds: 300) : delay;
    _locationNextAllowedLoadAt[widget.location] = DateTime.now().add(normalizedDelay);

    debugPrint(
      '$_instanceTag retry scheduled attempt=$_retryAttempt in=${normalizedDelay.inMilliseconds}ms increment=$incrementGlobalAttempt',
    );
    _retryTimer = Timer(normalizedDelay, () {
      _retryTimer = null;
      if (!mounted) return;
      debugPrint('$_instanceTag retry fired');
      _loadBanner();
    });
  }

  @override
  void dispose() {
    debugPrint('$_instanceTag dispose');
    _retryTimer?.cancel();
    _releaseLocationOwnerIfNeeded();
    _disposeBanner();
    _isLoading = false;
    super.dispose();
  }
}
