import 'dart:io';
import 'package:flutter/foundation.dart';
import 'ad_locations.dart';

enum RewardedAdLocation {
  revancha,
}

class AdHelper {
  // IDs de prueba de Google (solo para desarrollo)
  // Android
  static const String _testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testAndroidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  // iOS
  static const String _testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testIosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  static String _testBannerId() => Platform.isIOS ? _testIosBannerId : _testAndroidBannerId;
  static String _testInterstitialId() => Platform.isIOS ? _testIosInterstitialId : _testAndroidInterstitialId;
  static String _testRewardedId() => Platform.isIOS ? _testIosRewardedId : _testAndroidRewardedId;

  static const Map<String, String> _androidIds = {
    'AD_BANNER_HOME': 'ca-app-pub-7138392349989063/3603900094',
    'AD_BANNER_PARTIDA': 'ca-app-pub-7138392349989063/9555188441',
    'AD_INTERSTITIAL': 'ca-app-pub-7138392349989063/3081850257',
    'AD_REWARDED_REVANCHA': 'ca-app-pub-7138392349989063/4035569961',
  };

  static const Map<String, String> _iosIds = {
    'AD_IOS_BANNER_HOME': 'ca-app-pub-7138392349989063/9551604617',
    'AD_IOS_BANNER_PARTIDA': 'ca-app-pub-7138392349989063/9259976480',
    'AD_IOS_INTERSTITIAL': 'ca-app-pub-7138392349989063/9475598904',
    'AD_IOS_REWARDED_REVANCHA': 'ca-app-pub-7138392349989063/7709067573',
  };

  /// Retorna el Ad Unit ID correcto según el entorno (debug/release)
  static String getBannerAdUnitId(AdLocation location) {
    // En modo debug usa IDs de prueba
    if (kDebugMode) return _testBannerId();

    final productionId = _getProductionBannerId(location);
    return productionId;
  }

  /// Retorna el Interstitial Ad Unit ID correcto según el entorno
  static String getInterstitialAdUnitId() {
    if (kDebugMode) return _testInterstitialId();
    final productionId = _getRemoteValue(Platform.isIOS ? 'AD_IOS_INTERSTITIAL' : 'AD_INTERSTITIAL');
    return productionId;
  }

  /// Retorna el Rewarded Ad Unit ID correcto según el entorno y ubicación
  static String getRewardedAdUnitId(RewardedAdLocation location) {
    if (kDebugMode) return _testRewardedId();

    final productionId = _getProductionRewardedId(location);
    return productionId;
  }

  static String _getProductionRewardedId(RewardedAdLocation location) {
    if (location == RewardedAdLocation.revancha) {
      return _getRemoteValue(Platform.isIOS ? 'AD_IOS_REWARDED_REVANCHA' : 'AD_REWARDED_REVANCHA');
    }
    throw UnimplementedError('RewardedAdLocation $location is not mapped');
  }

  static String _getProductionBannerId(AdLocation location) {
    if (location == AdLocation.home) {
      return _getRemoteValue(Platform.isIOS ? 'AD_IOS_BANNER_HOME' : 'AD_BANNER_HOME');
    }

    if (location == AdLocation.partida) {
      return _getRemoteValue(Platform.isIOS ? 'AD_IOS_BANNER_PARTIDA' : 'AD_BANNER_PARTIDA');
    }
    throw UnimplementedError('AdLocation $location is not mapped');
  }

  static String _getRemoteValue(String key) {
    if (Platform.isIOS) {
      return _iosIds[key] ?? '';
    }
    return _androidIds[key] ?? '';
  }
}
