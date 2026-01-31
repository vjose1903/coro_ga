import 'dart:io';
import 'package:flutter/foundation.dart';
import 'ad_locations.dart';

enum RewardedAdLocation {
  revancha,
}

class AdHelper {
  // IDs de prueba de Google (solo para desarrollo)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  static final Map<String, String> _remoteIds = {};

  /// Recibe el mapa de IDs obtenido desde Remote Config.
  static void setRemoteIds(Map<String, dynamic> ids) {
    // Mergea solo valores no vacíos para no borrar IDs válidos con datos parciales.
    for (final entry in ids.entries) {
      final value = entry.value.toString();
      if (value.isNotEmpty) {
        _remoteIds[entry.key] = value;
      }
    }
  }

  /// Retorna el Ad Unit ID correcto según el entorno (debug/release)
  static String getBannerAdUnitId(AdLocation location) {
    // En modo debug usa IDs de prueba
    if (kDebugMode) return _testBannerId;

    final productionId = _getProductionBannerId(location);
    return productionId;
  }

  /// Retorna el Interstitial Ad Unit ID correcto según el entorno
  static String getInterstitialAdUnitId() {
    if (kDebugMode) return _testInterstitialId;
    final productionId = _getRemoteValue(
        Platform.isIOS ? 'AD_IOS_INTERSTITIAL' : 'AD_INTERSTITIAL');
    return productionId;
  }

  /// Retorna el Rewarded Ad Unit ID correcto según el entorno y ubicación
  static String getRewardedAdUnitId(RewardedAdLocation location) {
    if (kDebugMode) return _testRewardedId;

    final productionId = _getProductionRewardedId(location);
    return productionId;
  }

  static String _getProductionRewardedId(RewardedAdLocation location) {
    if (location == RewardedAdLocation.revancha) {
      return _getRemoteValue(
          Platform.isIOS ? 'AD_IOS_REWARDED_REVANCHA' : 'AD_REWARDED_REVANCHA');
    }
    throw UnimplementedError('RewardedAdLocation $location is not mapped');
  }

  static String _getProductionBannerId(AdLocation location) {
    if (location == AdLocation.home) {
      return _getRemoteValue(
          Platform.isIOS ? 'AD_IOS_BANNER_HOME' : 'AD_BANNER_HOME');
    }
    if (location == AdLocation.partida) {
      return _getRemoteValue(
          Platform.isIOS ? 'AD_IOS_BANNER_PARTIDA' : 'AD_BANNER_PARTIDA');
    }
    if (location == AdLocation.puntuacion) {
      return _getRemoteValue(
          Platform.isIOS ? 'AD_IOS_BANNER_PUNTUACION' : 'AD_BANNER_PUNTUACION');
    }
    if (location == AdLocation.agregarJugador) {
      return _getRemoteValue(Platform.isIOS
          ? 'AD_IOS_BANNER_AGREGAR_JUGADOR'
          : 'AD_BANNER_AGREGAR_JUGADOR');
    }
    if (location == AdLocation.editarEntidad) {
      return _getRemoteValue(Platform.isIOS
          ? 'AD_IOS_BANNER_EDITAR_ENTIDAD'
          : 'AD_BANNER_EDITAR_ENTIDAD');
    }
    throw UnimplementedError('AdLocation $location is not mapped');
  }

  static String _getRemoteValue(String key) {
    return _remoteIds[key] ?? '';
  }
}
