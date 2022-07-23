import 'package:flutter/material.dart';
import 'package:game_score/screens/screens.dart';
import '../models/menu_option.dart';

class AppRoutes {
  static const initialRoute = 'home';

  static final menuOptions = <MenuOption>[
    MenuOption(route: 'home', screen: HomeScreen()),
    MenuOption(route: 'partida', screen: const PartidaScreen()),
    MenuOption(route: 'formulario', screen: const FormularioScreen()),
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};

    for (final option in menuOptions) {
      appRoutes.addAll({option.route: (BuildContext context) => option.screen});
    }

    return appRoutes;
  }

  
}
