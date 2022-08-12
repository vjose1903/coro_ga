import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/utils/utils.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:skeletons/skeletons.dart';

enum AdLocation { partida, puntuacion, agregarJugador, editarEntidad, pageTransition }

enum AdType { banner, completo }

class GoogleAds extends StatefulWidget {
  GoogleAds({Key? key, required this.location, required this.tipo, this.onCloseAd}) : super(key: key);

  final AdType tipo;
  final AdLocation location;
  final Function? onCloseAd;

  @override
  State<GoogleAds> createState() => _GoogleAdsState();

  BannerAd? _bannerAd;
  bool isHideSkeleton = false;

  disposeBannerAd() {
    if (_bannerAd != null) _bannerAd?.dispose();
    _bannerAd = null;
  }
}

class _GoogleAdsState extends State<GoogleAds> {
  @override
  void initState() {
    super.initState();

    Fun.logColor(color: Colores.yellow, body: "widget.tipo: ${widget.tipo}");

    if (widget.tipo == AdType.banner) _loadBannerAd();
  }

  @override
  void dispose() {
    widget.disposeBannerAd();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tipo == AdType.completo) return Container();

    if (widget.isHideSkeleton) {
      return Container();
    } else {
      return Container(
        width: 300,
        alignment: Alignment.topCenter,
        child: Skeleton(
            themeMode: Preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            isLoading: widget._bannerAd == null,
            skeleton: const SkeletonLine(style: SkeletonLineStyle(height: 50)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget._bannerAd != null)
                  SizedBox(
                      width: widget._bannerAd!.size.width.toDouble(),
                      height: widget._bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: widget._bannerAd!)),
              ],
            )),
      );
    }
  }

  void _loadBannerAd() {
    BannerAd(
      // adUnitId: AdHelper.getBannerAdUnitId(widget.location),
      adUnitId: AdHelper.getTestingId(AdType.banner),
      request: const AdRequest(),

      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            widget._bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          Fun.logColor(color: Colores.red, body: "Failed to load a banner ad: ${err.message}");

          ad.dispose();
        },
      ),
    ).load();

    Future.delayed(const Duration(seconds: 10)).then((value) {
      if (widget._bannerAd == null) {
        widget.disposeBannerAd();
        setState(() => widget.isHideSkeleton = true);
      }
    });
  }
}
