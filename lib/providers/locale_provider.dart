import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:game_score/shared_preferences/preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  /// Carga el idioma guardado en preferencias o detecta del dispositivo
  void _loadSavedLocale() {
    final savedCode = Preferences.languageCode;
    if (savedCode == 'system') {
      // Primera vez: detectar idioma del dispositivo
      final systemLocale = PlatformDispatcher.instance.locale;
      final code = (systemLocale.languageCode == 'es') ? 'es' : 'en';
      _locale = Locale(code);
      Preferences.languageCode = code; // Guardar para futuras sesiones
    } else {
      _locale = Locale(savedCode);
    }
  }

  /// Cambia el idioma de la app
  /// code: 'es', 'en'
  void setLocale(String code) {
    Preferences.languageCode = code;
    _locale = Locale(code);
    notifyListeners();
  }

  /// Obtiene el código actual ('es', 'en')
  String get currentCode => Preferences.languageCode == 'system' ? _locale.languageCode : Preferences.languageCode;
}

