import 'package:flutter/material.dart';
import 'package:game_score/routes/app_routes.dart';
import 'package:game_score/themes/app_themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Games Score',
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getAppRoutes(),
      theme: AppThemes.lightTheme,
    );
  }
}
