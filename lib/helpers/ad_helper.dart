import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:game_score/widgets/widgets.dart';

enum RewardedAdLocation {
  revancha,
}

class AdHelper {
  // IDs de prueba de Google (solo para desarrollo)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // IDs de producción Android desde variables de entorno (--dart-define)
  static const String _bannerHome = String.fromEnvironment('AD_BANNER_HOME');
  static const String _bannerPartida = String.fromEnvironment('AD_BANNER_PARTIDA');
  static const String _bannerPuntuacion = String.fromEnvironment('AD_BANNER_PUNTUACION');
  static const String _bannerAgregarJugador = String.fromEnvironment('AD_BANNER_AGREGAR_JUGADOR');
  static const String _bannerEditarEntidad = String.fromEnvironment('AD_BANNER_EDITAR_ENTIDAD');
  static const String _interstitial = String.fromEnvironment('AD_INTERSTITIAL');
  static const String _rewardedRevancha = String.fromEnvironment('AD_REWARDED_REVANCHA');

  // IDs de producción iOS desde variables de entorno (--dart-define)
  static const String _iosBannerHome = String.fromEnvironment('AD_IOS_BANNER_HOME');
  static const String _iosBannerPartida = String.fromEnvironment('AD_IOS_BANNER_PARTIDA');
  static const String _iosBannerPuntuacion = String.fromEnvironment('AD_IOS_BANNER_PUNTUACION');
  static const String _iosBannerAgregarJugador = String.fromEnvironment('AD_IOS_BANNER_AGREGAR_JUGADOR');
  static const String _iosBannerEditarEntidad = String.fromEnvironment('AD_IOS_BANNER_EDITAR_ENTIDAD');
  static const String _iosInterstitial = String.fromEnvironment('AD_IOS_INTERSTITIAL');
  static const String _iosRewardedRevancha = String.fromEnvironment('AD_IOS_REWARDED_REVANCHA');

  /// Retorna el Ad Unit ID correcto según el entorno (debug/release)
  static String getBannerAdUnitId(AdLocation location) {
    // En modo debug usa IDs de prueba
    if (kDebugMode) return _testBannerId;

    final productionId = _getProductionBannerId(location);
    return productionId.isNotEmpty ? productionId : _testBannerId;
  }

  /// Retorna el Interstitial Ad Unit ID correcto según el entorno
  static String getInterstitialAdUnitId() {
    if (kDebugMode) return _testInterstitialId;
    final productionId = Platform.isIOS ? _iosInterstitial : _interstitial;
    return productionId.isNotEmpty ? productionId : _testInterstitialId;
  }

  /// Retorna el Rewarded Ad Unit ID correcto según el entorno y ubicación
  static String getRewardedAdUnitId(RewardedAdLocation location) {
    if (kDebugMode) return _testRewardedId;

    final productionId = _getProductionRewardedId(location);
    return productionId.isNotEmpty ? productionId : _testRewardedId;
  }

  static String _getProductionRewardedId(RewardedAdLocation location) {
    switch (location) {
      case RewardedAdLocation.revancha:
        return Platform.isIOS ? _iosRewardedRevancha : _rewardedRevancha;
    }
  }

  static String _getProductionBannerId(AdLocation location) {
    switch (location) {
      case AdLocation.home:
        return Platform.isIOS ? _iosBannerHome : _bannerHome;
      case AdLocation.partida:
        return Platform.isIOS ? _iosBannerPartida : _bannerPartida;
      case AdLocation.puntuacion:
        return Platform.isIOS ? _iosBannerPuntuacion : _bannerPuntuacion;
      case AdLocation.agregarJugador:
        return Platform.isIOS ? _iosBannerAgregarJugador : _bannerAgregarJugador;
      case AdLocation.editarEntidad:
        return Platform.isIOS ? _iosBannerEditarEntidad : _bannerEditarEntidad;
    }
  }
}
