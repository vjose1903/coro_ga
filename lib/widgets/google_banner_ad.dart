import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/providers/premium_provider.dart';
import 'package:game_score/shared_preferences/preferences.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

enum AdLocation { partida, puntuacion, agregarJugador, editarEntidad, pageTransition }

class GoogleBannerAd extends StatefulWidget {
  GoogleBannerAd({Key? key, required this.location, this.onCloseAd}) : super(key: key);

  final AdLocation location;
  final Function? onCloseAd;

  @override
  State<GoogleBannerAd> createState() => _GoogleBannerAdState();

  BannerAd? _bannerAd;
  bool isHideSkeleton = false;

  disposeBannerAd() {
    if (_bannerAd != null) _bannerAd?.dispose();
    _bannerAd = null;
  }
}

class _GoogleBannerAdState extends State<GoogleBannerAd> {
  @override
  void initState() {
    super.initState();

    _loadBannerAd();
  }

  @override
  void dispose() {
    widget.disposeBannerAd();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumProvider = context.watch<PremiumProvider>();
    
    // No mostrar anuncios si es premium
    if (premiumProvider.isPremium || widget.isHideSkeleton) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: 300,
      alignment: Alignment.topCenter,
      child: widget._bannerAd == null
          ? Shimmer.fromColors(
              baseColor: Preferences.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: Preferences.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: widget._bannerAd!.size.width.toDouble(),
                    height: widget._bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: widget._bannerAd!)),
              ],
            ),
    );
  }

  void _loadBannerAd() {
    BannerAd(
      // adUnitId: AdHelper.getBannerAdUnitId(widget.location),
      adUnitId: AdHelper.getTestingId("banner"),
      request: const AdRequest(),

      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            widget._bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();

    Future.delayed(const Duration(seconds: 33)).then((value) {
      if (widget._bannerAd == null) {
        widget.disposeBannerAd();
        setState(() => widget.isHideSkeleton = true);
      }
    });
  }
}
