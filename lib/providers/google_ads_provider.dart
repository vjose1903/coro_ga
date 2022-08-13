import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdsProvider extends ChangeNotifier {
  InterstitialAd? interstitialAd;
  Function? onCloseFunction_;

  loadInterstitialAd() {
    if (interstitialAd == null) {
      Fun.logColor(color: Colores.magenta, body: "_loadInterstitialAd");
      InterstitialAd.load(
        // adUnitId: AdHelper.interstitialAdUnitId,
        adUnitId: AdHelper.getTestingId("completo"),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, error) {
                cleanInterstitialAd();
              },
              onAdDismissedFullScreenContent: (ad) {
                onCloseFunction_ != null ? onCloseFunction_!() : null;

                cleanInterstitialAd();
              },
            );

            interstitialAd = ad;
          },
          onAdFailedToLoad: (err) {
            print('Failed to load an interstitial ad: ${err.message}');
            onCloseFunction_ != null ? onCloseFunction_!() : null;
            cleanInterstitialAd();
          },
        ),
      );
    }
  }

  showInterstitialAd({required Function onCloseFunction}) {
    if (interstitialAd != null) {
      onCloseFunction_ = onCloseFunction;
      interstitialAd!.show();
    } else {
      onCloseFunction();
    }
  }

  cleanInterstitialAd() {
    if (interstitialAd != null) interstitialAd!.dispose();
    if (interstitialAd != null) interstitialAd = null;
  }
}
