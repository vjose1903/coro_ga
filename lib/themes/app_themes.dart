import 'package:flutter/material.dart';

class AppThemes {
  static const String currentTheme = "dark";
  // static const String currentTheme = "light";

  static const Color colorPrimero = Color(0xFF0F309C);
  static const Color colorSegundo = Color(0xFF0B129F);
  static const Color colorTercero = Color(0xFF0E1265);

  static Color themeColor_1 = AppThemes.currentTheme == "dark" ? const Color(0xFF27292B) : const Color(0xFFE6EBED);
  static Color? themeColor_2 = AppThemes.currentTheme == "dark" ? Colors.grey[800] : Colors.white;
  static Color themeColor_3 = AppThemes.currentTheme == "dark" ? const Color(0xff727272) : const Color(0xFFE7E7E7);
  static Color themeColor_4 = AppThemes.currentTheme == "dark" ? const Color(0xFF898989) : const Color(0xFFF0F0F0);

  static Color inputColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.3) : Colors.blueGrey.withOpacity(0.2);
  static Color inputDisabledColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.1) : Colors.blueGrey[200]!.withOpacity(0.8);

  static Color? labelInputColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.7) : Colors.blueGrey[600]!.withOpacity(0.7);
  static Color labelInputDisabledColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.3) : Colors.blueGrey.withOpacity(0.6);

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: colorSegundo,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: colorSegundo, elevation: 8),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: colorSegundo)),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        focusedBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(15))),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: colorSegundo, selectionColor: Color(0x5E0C249C), selectionHandleColor: Color(0x5E0C249C)),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: colorSegundo,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: colorPrimero, elevation: 8),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      primary: colorPrimero,
    )),
    inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        border: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        focusedBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(15))),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: colorSegundo, selectionColor: Color(0x5E0C249C), selectionHandleColor: Color(0x5E0C249C)),
  );
}
