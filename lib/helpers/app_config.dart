import 'package:flutter/material.dart';

enum Env { free, pro }

class AppConfig extends InheritedWidget {
  final Env environment;
  final String appName;

  const AppConfig({Key? key, required Widget child, required this.environment, required this.appName}) : super(key: key, child: child);

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
