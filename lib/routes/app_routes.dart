import 'package:flutter/material.dart';
import '../screens/screens.dart';
import '../models/menu_option.dart';

class AppRoutes {
  static final menuOptions = <MenuOption>[
    MenuOption(route: 'home', screen: const HomeShell()),
    MenuOption(route: 'formulario', screen: const FormularioScreen()),
    MenuOption(route: 'ganador', screen: const GanadorScreen()),
    MenuOption(route: 'premium', screen: const PremiumScreen()),
    MenuOption(route: 'about', screen: const AboutScreen()),
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    final Map<String, Widget Function(BuildContext)> appRoutes = {};

    for (final option in menuOptions) {
      appRoutes.addAll({option.route: (BuildContext context) => option.screen});
    }

    return appRoutes;
  }
}
