import 'package:flutter/material.dart';

class AppThemes {
  static const Color primary = Color(0xFF0E1265);

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: primary,
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primary,
  );
}
