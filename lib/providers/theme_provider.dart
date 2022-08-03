import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {
  changeCurrentTheme() {
    AppThemes.currentTheme = AppThemes.currentTheme == Themes.dark ? Themes.light : Themes.dark;

    Fun.logColor(color: Colores.green, body: "AppThemes.currentTheme: ${AppThemes.currentTheme}");
    notifyListeners();
  }
}
