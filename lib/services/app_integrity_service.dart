import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Servicio para verificar la integridad de la app
/// Detecta si la app fue modificada o instalada desde fuentes no autorizadas
class AppIntegrityService {
  static final AppIntegrityService _instance = AppIntegrityService._();
  static AppIntegrityService get instance => _instance;
  AppIntegrityService._();

  bool _isVerified = false;
  bool _hasChecked = false;
  String _failureReason = '';

  bool get isAppLegit => _isVerified;
  bool get hasChecked => _hasChecked;
  String get failureReason => _failureReason;

  // Package names permitidos (tu app normal y versión pro si la tienes)
  static const List<String> _allowedPackageNames = [
    'com.inSpot.coro_games',      // App principal
    'com.inSpot.coro_games.pro',  // Versión pro si existe
  ];

  // Instaladores permitidos
  static const List<String> _allowedInstallers = [
    'com.android.vending',           // Google Play Store
    'com.google.android.feedback',   // Google Play Store (alternativo)
    'com.amazon.venezia',            // Amazon App Store (si publicas ahí)
  ];

  // ⚠️ SOLO PARA PRUEBAS - Cambiar a true para simular piratería
  static const bool _simulatePiracy = false;

  /// Verifica la integridad de la app
  /// Retorna true si la app es legítima
  Future<bool> verifyIntegrity() async {
    // Para probar el bloqueador, cambia _simulatePiracy a true
    if (_simulatePiracy) {
      debugPrint('🏴‍☠️ AppIntegrity: SIMULANDO PIRATERÍA');
      _failureReason = 'Simulación de prueba';
      _isVerified = false;
      _hasChecked = true;
      return false;
    }

    // En modo debug, siempre permitir (para desarrollo)
    if (kDebugMode) {
      _isVerified = true;
      _hasChecked = true;
      debugPrint('🔓 AppIntegrity: Modo DEBUG - verificación omitida');
      return true;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      // 1. Verificar package name
      if (!_verifyPackageName(packageInfo.packageName)) {
        _failureReason = 'Package name no autorizado';
        _isVerified = false;
        _hasChecked = true;
        return false;
      }

      // 2. Verificar instalador (solo Android)
      if (Platform.isAndroid) {
        final isValidInstaller = await _verifyInstaller();
        if (!isValidInstaller) {
          _failureReason = 'Instalación no autorizada';
          _isVerified = false;
          _hasChecked = true;
          return false;
        }
      }

      // 3. Verificar que no sea un emulador en producción
      if (await _isEmulator()) {
        _failureReason = 'Emulador detectado';
        _isVerified = false;
        _hasChecked = true;
        return false;
      }

      _isVerified = true;
      _hasChecked = true;
      return true;

    } catch (e) {
      // Si hay error en la verificación, asumir que está bien
      // (mejor que bloquear usuarios legítimos)
      debugPrint('⚠️ AppIntegrity: Error en verificación - $e');
      _isVerified = true;
      _hasChecked = true;
      return true;
    }
  }

  bool _verifyPackageName(String packageName) {
    return _allowedPackageNames.contains(packageName);
  }

  Future<bool> _verifyInstaller() async {
    try {
      const platform = MethodChannel('com.inSpot.coro_games/integrity');
      final String? installer = await platform.invokeMethod('getInstaller');
      
      if (installer == null || installer.isEmpty) {
        // Si no se puede obtener el instalador, podría ser:
        // - Instalación via ADB (desarrollo)
        // - Instalación manual de APK
        // En producción, esto es sospechoso
        return false;
      }

      return _allowedInstallers.contains(installer);
    } catch (e) {
      // Si el método nativo no está implementado, usar alternativa
      return await _verifyInstallerFallback();
    }
  }

  Future<bool> _verifyInstallerFallback() async {
    // Fallback: verificar si existe el archivo de Play Store
    // Esto es menos confiable pero funciona sin código nativo
    try {
      final result = await Process.run('pm', ['list', 'packages', 'com.android.vending']);
      return result.stdout.toString().contains('com.android.vending');
    } catch (e) {
      return true; // En caso de error, no bloquear
    }
  }

  Future<bool> _isEmulator() async {
    if (!Platform.isAndroid) return false;

    try {
      // Verificar propiedades comunes de emuladores
      final checks = <bool>[
        Platform.environment.containsKey('ANDROID_EMULATOR'),
      ];

      // Si alguna verificación indica emulador
      return checks.any((isEmulator) => isEmulator);
    } catch (e) {
      return false;
    }
  }
}

