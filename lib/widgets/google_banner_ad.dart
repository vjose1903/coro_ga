import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/providers/premium_provider.dart';
import 'package:game_score/shared_preferences/preferences.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

enum AdLocation {
  home,
  partida,
  puntuacion,
  agregarJugador,
  editarEntidad,
  pageTransition
}

class GoogleBannerAd extends StatefulWidget {
  const GoogleBannerAd({Key? key, required this.location, this.onCloseAd})
      : super(key: key);

  final AdLocation location;
  final Function? onCloseAd;

  @override
  State<GoogleBannerAd> createState() => _GoogleBannerAdState();
}

class _GoogleBannerAdState extends State<GoogleBannerAd> {
  BannerAd? _bannerAd;
  bool _isHideSkeleton = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _disposeBannerAd();
    super.dispose();
  }

  void _disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void _loadBannerAd() {
    // Evitar cargar múltiples veces
    if (_isLoading || _bannerAd != null) return;
    _isLoading = true;

    BannerAd(
      adUnitId: AdHelper.getBannerAdUnitId(widget.location),
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      ),
    ).load();

    // Timeout: si no carga en 30s, ocultar skeleton
    Future.delayed(const Duration(seconds: 30)).then((_) {
      if (mounted && _bannerAd == null) {
        setState(() => _isHideSkeleton = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final premiumProvider = context.watch<PremiumProvider>();

    // No mostrar anuncios si es premium
    if (premiumProvider.isPremium || _isHideSkeleton) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 300,
      alignment: Alignment.topCenter,
      child: _bannerAd == null
          ? Shimmer.fromColors(
              baseColor: Preferences.isDarkMode
                  ? Colors.grey[800]!
                  : Colors.grey[300]!,
              highlightColor: Preferences.isDarkMode
                  ? Colors.grey[700]!
                  : Colors.grey[100]!,
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          : SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
    );
  }
}
