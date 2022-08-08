import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:skeletons/skeletons.dart';

enum AdLocation { partida, puntuacion, agregarJugador , editarEntidad}

class BannerAds extends StatefulWidget {
  const BannerAds({Key? key, required this.location}) : super(key: key);

  final AdLocation location;

  @override
  State<BannerAds> createState() => _BannerAdsState();
}

class _BannerAdsState extends State<BannerAds> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    BannerAd(
      // adUnitId: AdHelper.getBannerAdUnitId(widget.location),
      adUnitId: AdHelper.testing,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            Fun.logColor(color: Colores.green, body: "===> $ad");
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print("::::::: $err");
          Fun.logColor(color: Colores.red, body: "Failed to load a banner ad: ${err.message}");

          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      alignment: Alignment.topCenter,
      child: Skeleton(
          themeMode: Preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          isLoading: _bannerAd == null,
          skeleton: const SkeletonLine(style: SkeletonLineStyle(height: 50)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_bannerAd != null)
                SizedBox(width: _bannerAd!.size.width.toDouble(), height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!)),
            ],
          )),
    );
  }
}
