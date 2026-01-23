import 'package:flutter/material.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required bool isDarkMode_}) : isDarkMode = isDarkMode_;
  bool isDarkMode;

  ThemeData get getCurrentTheme {
    return isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
  }

  changeCurrentTheme() {
    isDarkMode = Preferences.isDarkMode;

    notifyListeners();
  }
}
