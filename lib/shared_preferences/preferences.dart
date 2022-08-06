import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _prefs;

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

  static bool get isSystemMode {
    return _prefs.getBool('isSystemMode') ?? _isSystemMode;
  }

  static set isSystemMode(bool value) {
    _isSystemMode = value;
    _prefs.setBool('isSystemMode', value);
  }
}
