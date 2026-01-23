import 'dart:ui';
import 'package:flutter/material.dart';
import '../shared_preferences/preferences.dart';

class LocaleProvider extends ChangeNotifier {

  LocaleProvider() {
    _loadSavedLocale();
  }
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  /// Carga el idioma guardado en preferencias o detecta del dispositivo
  void _loadSavedLocale() {
    final savedCode = Preferences.languageCode;
    if (savedCode == 'es' || savedCode == 'en') {
      _locale = Locale(savedCode);
    } else {
      // Detectar idioma del dispositivo
      final systemLocale = PlatformDispatcher.instance.locale;
      final code = (systemLocale.languageCode == 'en') ? 'en' : 'es';
      _locale = Locale(code);
      Preferences.languageCode = code;
    }
  }

  /// Cambia el idioma de la app
  void setLocale(String code) {
    Preferences.languageCode = code;
    _locale = Locale(code);
    notifyListeners();
  }

  /// Obtiene el código actual ('es', 'en')
  String get currentCode {
    final code = _locale.languageCode;
    return (code == 'es' || code == 'en') ? code : 'es';
  }
}

