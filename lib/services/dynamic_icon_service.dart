import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DynamicIconService {
  static final DynamicIconService instance = DynamicIconService._();
  DynamicIconService._();

  static const _channel = MethodChannel('com.inSpot.coro_games/icon');

  /// Cambia al icono Premium
  Future<bool> setIconPremium() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('setIcon', {'iconName': 'MainActivityPremium'});
        return true;
      }
      // iOS requiere configuración adicional en Xcode
      return false;
    } catch (e) {
      debugPrint('Error cambiando a icono premium: $e');
      return false;
    }
  }

  /// Cambia al icono por defecto (FREE)
  Future<bool> setIconDefault() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('setIcon', {'iconName': 'MainActivity'});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error cambiando a icono default: $e');
      return false;
    }
  }

  /// Cambia el icono según el estado premium
  Future<void> updateIconForPremiumStatus(bool isPremium) async {
    if (isPremium) {
      await setIconPremium();
    } else {
      await setIconDefault();
    }
  }

  /// Verifica si el cambio de icono está soportado
  Future<bool> isSupported() async {
    return Platform.isAndroid;
  }
}

