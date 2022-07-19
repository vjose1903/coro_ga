import 'package:flutter/material.dart';

class AppThemes {
  static const String currentTheme = "dark";

  static const Color colorPrimero = Color(0xFF0F309C);
  static const Color colorSegundo = Color(0xFF0B129F);
  static const Color colorTercero = Color(0xFF0E1265);

  static const Map<String, Color> fondos = {"light": Color(0xFFE6EBED), "dark": Color(0xFF27292B)};
  static Map<String, Color?> Cards = {"light": Colors.white, "dark": Colors.grey[800]};

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: colorSegundo,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: colorSegundo, elevation: 8),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: colorSegundo)),
    inputDecorationTheme: InputDecorationTheme(
        // const TextStyle(color: primary),
        floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
          final Color? color = states.contains(MaterialState.error) ? Colors.red[900] : colorSegundo;
          return TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins');
        }),
        // fillColor: Colors.blueGrey.withOpacity(0.2),
        fillColor: Colors.blueGrey.withOpacity(0.2),
        filled: true,
        labelStyle: TextStyle(color: Colors.blueGrey[600], fontFamily: 'Poppins'),
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
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: colorPrimero, )),
    inputDecorationTheme: InputDecorationTheme(
        // const TextStyle(color: primary),
        floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
          final Color? color = states.contains(MaterialState.error) ? Colors.red[900] : colorTercero;
          return TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins');
        }),
        fillColor: Colors.white.withOpacity(0.3),
        filled: true,
        labelStyle: TextStyle(color: Colors.blueGrey[900], fontFamily: 'Poppins'),
        border: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        enabledBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        focusedBorder: UnderlineInputBorder(borderSide: const BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(15)),
        errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(15))),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: colorSegundo, selectionColor: Color(0x5E0C249C), selectionHandleColor: Color(0x5E0C249C)),
  );
}
