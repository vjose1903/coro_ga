import 'package:game_score/providers/premium_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PrefsType { bool, string, int, double, undefined }

class Preferences {
  static late SharedPreferences _prefs;

  static bool _isFirstTimeOpen = true;
  static bool _isTutorialDone = false;

  static bool _isDarkMode = false;
  static bool _isSystemMode = false;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isDarkMode {
    return _prefs.getBool('isDarkMode') ?? _isDarkMode;
  }

  static set isDarkMode(bool value) {
    _isDarkMode = value;
    _prefs.setBool('isDarkMode', value);
  }
  // ==============================================================
  // ==============================================================

  static bool get isFirstTimeOpen {
    return _prefs.getBool('isFirstTimeOpen') ?? _isFirstTimeOpen;
  }

  static set isFirstTimeOpen(bool value) {
    _isFirstTimeOpen = value;
    _prefs.setBool('isFirstTimeOpen', value);
  }

  // ==============================================================
  // ==============================================================

  static bool get isTutorialDone {
    return _prefs.getBool('isTutorialDone') ?? _isTutorialDone;
  }

  static set isTutorialDone(bool value) {
    _isTutorialDone = value;
    _prefs.setBool('isTutorialDone', value);
  }

  // ==============================================================
  // ==============================================================

  static bool get isSystemMode {
    return _prefs.getBool('isSystemMode') ?? _isSystemMode;
  }

  static set isSystemMode(bool value) {
    _isSystemMode = value;
    _prefs.setBool('isSystemMode', value);
  }

  // ==============================================================
  // ==============================================================

  static bool get isPremium {
    return PremiumProvider.kTestPremium || (_prefs.getBool('isPremium') ?? false);
  }

  static set isPremium(bool value) {
    _prefs.setBool('isPremium', value);
  }
}
