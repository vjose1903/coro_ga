import 'package:flutter/material.dart';
import 'package:game_score/providers/providers.dart';

import 'package:game_score/routes/app_routes.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PartidasProvider()),
          ChangeNotifierProvider(create: (_) => FormPartidaProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Games Score',
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.getAppRoutes(),
          theme: AppThemes.currentTheme == 'light' ? AppThemes.lightTheme : AppThemes.darkTheme,
        ));
  }
}
