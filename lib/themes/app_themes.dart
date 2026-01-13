import 'package:flutter/material.dart';
import 'package:game_score/shared_preferences/preferences.dart';

class AppThemes {
  static Color get colorPrimero => const Color(0xFF4D73EF);
  static Color get colorSegundo => const Color(0xFF2D57E2);
  static Color get colorTercero => const Color(0xFF0F309C);
  static Color get colorCuarto => const Color(0xFF0B129F);
  static Color get colorQuinto => const Color(0xFF0E1265);
  static Color get colorSexto => const Color(0xFF0E1265);

  static Color get themeColor_1 => Preferences.isDarkMode ? const Color(0xFF27292B) : const Color(0xFFE6EBED);
  static Color get themeColor_2 => Preferences.isDarkMode ? Colors.grey[800]! : Colors.white;

  static Color get themeColor_3 => Preferences.isDarkMode ? const Color(0xff727272) : const Color(0xFFE7E7E7);
  static Color get themeColor_4 => Preferences.isDarkMode ? const Color(0xFF898989) : const Color(0xFFF0F0F0);

  static Color get inputColor => Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.3) : Colors.blueGrey.withValues(alpha: 0.2);
  static Color get inputDisabledColor => Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.blueGrey[200]!.withValues(alpha: 0.8);

  static Color get labelInputColor => Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.7) : Colors.blueGrey[600]!.withValues(alpha: 0.7);
  static Color get labelInputDisabledColor => Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.3) : Colors.blueGrey.withValues(alpha: 0.6);

  static ThemeData get lightTheme => ThemeData.light().copyWith(
        primaryColor: colorCuarto,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: colorCuarto, elevation: 8),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: colorCuarto)),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            border: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
            enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
            focusedBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
            errorBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(15))),
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: colorCuarto, selectionColor: const Color(0x5E0C249C), selectionHandleColor: const Color(0x5E0C249C)),
      );

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        primaryColor: colorCuarto,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: colorTercero, elevation: 8),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: colorTercero,
        )),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
          enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
          focusedBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
          errorBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(15)),
        ),
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: colorCuarto, selectionColor: const Color(0x5E0C249C), selectionHandleColor: const Color(0x5E0C249C)),
      );
}
