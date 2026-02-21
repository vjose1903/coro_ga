import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/helpers.dart';
import '../shared_preferences/preferences.dart';
import '../utils/utils.dart';

class GoogleAdsProvider extends ChangeNotifier {
  InterstitialAd? interstitialAd;
  Function? onCloseFunction_;
  bool _showOnLoad = false;
  int _interstitialLoadAttempts = 0;
  bool _isInterstitialLoading = false;
  bool _adLoadingVisible = false;

  RewardedAd? rewardedAd;
  Function? onRewardedCloseFunction_;
  Function? onRewardEarnedFunction_;
  Function? onRewardedErrorFunction_;
  int _rewardedLoadAttempts = 0;
  bool _isRewardedLoading = false;

  void _showAdLoading() {
    if (_adLoadingVisible) return;
    _adLoadingVisible = true;
    MyLoading.show();
  }

  void _hideAdLoading() {
    if (!_adLoadingVisible) return;
    _adLoadingVisible = false;
    MyLoading.close();
  }

  void loadInterstitialAd({int attempt = 1}) {
    if (Preferences.isPremium) return;
    if (interstitialAd != null || _isInterstitialLoading) return;

    _isInterstitialLoading = true;
    _interstitialLoadAttempts = attempt;
    final adUnitId = AdHelper.getInterstitialAdUnitId();
    if (adUnitId.isEmpty) {
      _isInterstitialLoading = false;
      return;
    }
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterstitialLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _hideAdLoading();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _hideAdLoading();
              onCloseFunction_ != null ? onCloseFunction_!() : null;
              cleanInterstitialAd();
            },
            onAdDismissedFullScreenContent: (ad) {
              _hideAdLoading();
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
          _isInterstitialLoading = false;
          Fun.logColor(color: Colores.red, body: 'Failed to load an interstitial ad: ${err.message}');
          if (_interstitialLoadAttempts < 2) {
            loadInterstitialAd(attempt: _interstitialLoadAttempts + 1);
            return;
          }
          _hideAdLoading();
          onCloseFunction_ != null ? onCloseFunction_!() : null;
          _showOnLoad = false;
          cleanInterstitialAd();
        },
      ),
    );
  }

  void showInterstitialAd({required Function onCloseFunction}) {
    if (Preferences.isPremium) {
      onCloseFunction();
      return;
    }
    onCloseFunction_ = onCloseFunction;
    if (interstitialAd != null) {
      _showAdLoading();
      interstitialAd!.show();
      return;
    }
    _showAdLoading();
    _showOnLoad = true;
    loadInterstitialAd();
  }

  void cleanInterstitialAd() {
    _isInterstitialLoading = false;
    if (interstitialAd != null) interstitialAd!.dispose();
    if (interstitialAd != null) interstitialAd = null;
  }

  void loadRewardedAd(RewardedAdLocation location, {int attempt = 1}) {
    if (Preferences.isPremium) return;
    if (rewardedAd != null || _isRewardedLoading) return;

    _isRewardedLoading = true;
    _rewardedLoadAttempts = attempt;
    final adUnitId = AdHelper.getRewardedAdUnitId(location);
    if (adUnitId.isEmpty) {
      _isRewardedLoading = false;
      return;
    }
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isRewardedLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _hideAdLoading();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _hideAdLoading();
              onRewardedErrorFunction_?.call();
              cleanRewardedAd();
            },
            onAdDismissedFullScreenContent: (ad) {
              _hideAdLoading();
              onRewardedCloseFunction_?.call();
              cleanRewardedAd();
            },
          );

          rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          _isRewardedLoading = false;
          Fun.logColor(color: Colores.red, body: 'Failed to load a rewarded ad: ${err.message}');
          if (_rewardedLoadAttempts < 2) {
            loadRewardedAd(location, attempt: _rewardedLoadAttempts + 1);
            return;
          }
          _hideAdLoading();
          onRewardedErrorFunction_?.call();
          cleanRewardedAd();
        },
      ),
    );
  }

  void showRewardedAd({
    required Function onCloseFunction,
    required Function onRewardEarned,
    Function? onAdFailed,
  }) {
    if (Preferences.isPremium) {
      onCloseFunction();
      return;
    }
    if (rewardedAd != null) {
      _showAdLoading();
      onRewardedCloseFunction_ = onCloseFunction;
      onRewardEarnedFunction_ = onRewardEarned;
      onRewardedErrorFunction_ = onAdFailed;
      rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarnedFunction_?.call();
        },
      );
    } else {
      onCloseFunction();
    }
  }

  void cleanRewardedAd() {
    _isRewardedLoading = false;
    if (rewardedAd != null) rewardedAd!.dispose();
    rewardedAd = null;
    onRewardedCloseFunction_ = null;
    onRewardEarnedFunction_ = null;
    onRewardedErrorFunction_ = null;
  }
}
