import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdsProvider extends ChangeNotifier {
  InterstitialAd? interstitialAd;
  Function? onCloseFunction_;
  
  // Flag para mostrar anuncio después de navegación
  bool _showAdAfterNavigation = false;
  bool get showAdAfterNavigation => _showAdAfterNavigation;
  
  void markAdForAfterNavigation() {
    _showAdAfterNavigation = true;
  }
  
  void clearAdAfterNavigation() {
    _showAdAfterNavigation = false;
  }

  RewardedAd? rewardedAd;
  Function? onRewardedCloseFunction_;
  Function? onRewardEarnedFunction_;

  loadInterstitialAd() {
    if (interstitialAd == null) {
      InterstitialAd.load(
        adUnitId: AdHelper.getInterstitialAdUnitId(),
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
            Fun.logColor(color: Colores.red, body: 'Failed to load an interstitial ad: ${err.message}');
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

  loadRewardedAd(RewardedAdLocation location) {
    if (rewardedAd == null) {
      RewardedAd.load(
        adUnitId: AdHelper.getRewardedAdUnitId(location),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, error) {
                cleanRewardedAd();
              },
              onAdDismissedFullScreenContent: (ad) {
                onRewardedCloseFunction_?.call();
                cleanRewardedAd();
              },
            );

            rewardedAd = ad;
          },
          onAdFailedToLoad: (err) {
            Fun.logColor(color: Colores.red, body: 'Failed to load a rewarded ad: ${err.message}');
            onRewardedCloseFunction_?.call();
            cleanRewardedAd();
          },
        ),
      );
    }
  }

  showRewardedAd({
    required Function onCloseFunction,
    required Function onRewardEarned,
  }) {
    if (rewardedAd != null) {
      onRewardedCloseFunction_ = onCloseFunction;
      onRewardEarnedFunction_ = onRewardEarned;
      rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarnedFunction_?.call();
        },
      );
    } else {
      onCloseFunction();
    }
  }

  cleanRewardedAd() {
    if (rewardedAd != null) rewardedAd!.dispose();
    rewardedAd = null;
    onRewardedCloseFunction_ = null;
    onRewardEarnedFunction_ = null;
  }
}
