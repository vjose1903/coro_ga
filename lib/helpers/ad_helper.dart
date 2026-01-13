import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:game_score/widgets/widgets.dart';

class AdHelper {
  // IDs de prueba de Google (solo para desarrollo)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  // IDs de producción desde variables de entorno (--dart-define)
  static const String _bannerHome = String.fromEnvironment('AD_BANNER_HOME');
  static const String _bannerPartida = String.fromEnvironment('AD_BANNER_PARTIDA');
  static const String _bannerPuntuacion = String.fromEnvironment('AD_BANNER_PUNTUACION');
  static const String _bannerAgregarJugador = String.fromEnvironment('AD_BANNER_AGREGAR_JUGADOR');
  static const String _bannerEditarEntidad = String.fromEnvironment('AD_BANNER_EDITAR_ENTIDAD');
  static const String _bannerPageTransition = String.fromEnvironment('AD_BANNER_PAGE_TRANSITION');
  static const String _interstitial = String.fromEnvironment('AD_INTERSTITIAL');

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
    return _interstitial.isNotEmpty ? _interstitial : _testInterstitialId;
  }

  static String _getProductionBannerId(AdLocation location) {
    if (Platform.isAndroid) {
      switch (location) {
        case AdLocation.home:
          return _bannerHome;
        case AdLocation.partida:
          return _bannerPartida;
        case AdLocation.puntuacion:
          return _bannerPuntuacion;
        case AdLocation.agregarJugador:
          return _bannerAgregarJugador;
        case AdLocation.editarEntidad:
          return _bannerEditarEntidad;
        case AdLocation.pageTransition:
          return _bannerPageTransition;
      }
    } else if (Platform.isIOS) {
      return '';
    }
    return '';
  }
}
