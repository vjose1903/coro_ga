import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/utils/utils.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:skeletons/skeletons.dart';

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

    if (!AppEnvironment.isPro) _loadBannerAd();
  }

  @override
  void dispose() {
    widget.disposeBannerAd();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
