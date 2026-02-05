import 'package:flutter/material.dart';
import '../helpers/helpers.dart';
import '../utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../shared_preferences/preferences.dart';

class GoogleAdsProvider extends ChangeNotifier {
  InterstitialAd? interstitialAd;
  Function? onCloseFunction_;
  bool _showOnLoad = false;

  RewardedAd? rewardedAd;
  Function? onRewardedCloseFunction_;
  Function? onRewardEarnedFunction_;

  loadInterstitialAd() {
    if (Preferences.isPremium) return;
    if (interstitialAd == null) {
      final adUnitId = AdHelper.getInterstitialAdUnitId();
      if (adUnitId.isEmpty) {
        return;
      }
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdFailedToShowFullScreenContent: (ad, error) {
                onCloseFunction_ != null ? onCloseFunction_!() : null;
                cleanInterstitialAd();
              },
              onAdDismissedFullScreenContent: (ad) {
                onCloseFunction_ != null ? onCloseFunction_!() : null;

                cleanInterstitialAd();
              },
            );

            interstitialAd = ad;
            if (_showOnLoad) {
              _showOnLoad = false;
              interstitialAd!.show();
            }
          },
          onAdFailedToLoad: (err) {
            Fun.logColor(color: Colores.red, body: 'Failed to load an interstitial ad: ${err.message}');
            onCloseFunction_ != null ? onCloseFunction_!() : null;
            _showOnLoad = false;
            cleanInterstitialAd();
          },
        ),
      );
    }
  }

  showInterstitialAd({required Function onCloseFunction}) {
    if (Preferences.isPremium) {
      onCloseFunction();
      return;
    }
    onCloseFunction_ = onCloseFunction;
    if (interstitialAd != null) {
      interstitialAd!.show();
      return;
    }
    _showOnLoad = true;
    loadInterstitialAd();
  }

  cleanInterstitialAd() {
    if (interstitialAd != null) interstitialAd!.dispose();
    if (interstitialAd != null) interstitialAd = null;
  }

  loadRewardedAd(RewardedAdLocation location) {
    if (Preferences.isPremium) return;
    if (rewardedAd == null) {
      final adUnitId = AdHelper.getRewardedAdUnitId(location);
      if (adUnitId.isEmpty) {
        return;
      }
      RewardedAd.load(
        adUnitId: adUnitId,
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
    if (Preferences.isPremium) {
      onCloseFunction();
      return;
    }
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
