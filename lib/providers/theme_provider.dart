import 'package:flutter/material.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode;
  ThemeProvider({required bool isDarkMode_}) : isDarkMode = isDarkMode_;

  ThemeData get getCurrentTheme {
    return isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
  }

  changeCurrentTheme() {
    isDarkMode = Preferences.isDarkMode;

    notifyListeners();
  }
}
