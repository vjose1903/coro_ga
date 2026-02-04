import 'package:flutter/material.dart';
import '../helpers/helpers.dart';
import '../providers/premium_provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void didUpdateWidget(covariant GoogleBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _disposeBanner();
      _isLoading = false;
      _loadBanner();
    }
  }

  void _loadBanner() {
    if (_isLoading || !mounted || _bannerAd != null) return;

    final adUnitId = AdHelper.getBannerAdUnitId(widget.location);
    if (adUnitId.isEmpty) {
      return;
    }

    _disposeBanner();
    _isLoading = true;

    final ad = BannerAd(
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
          _isLoading = false;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoading = false;
        },
      ),
    );
    ad.load();
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadBanner();
      });
    }

    final double width = _bannerAd?.size.width.toDouble() ?? 300;
    final double height = _bannerAd?.size.height.toDouble() ?? 50;

    return Container(
      key: _bannerAd != null ? ObjectKey(_bannerAd) : null,
      width: width,
      alignment: Alignment.topCenter,
      child: _bannerAd == null
          ? SizedBox(width: width, height: height)
          : SizedBox(width: width, height: height, child: AdWidget(ad: _bannerAd!)),
    );
  }

  void _disposeBanner() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
  }

  @override
  void dispose() {
    _disposeBanner();
    _isLoading = false;
    super.dispose();
  }
}
