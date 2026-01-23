import 'package:flutter/material.dart';

enum Env { free, pro }

class AppConfig extends InheritedWidget {

  const AppConfig({Key? key, required Widget child, required this.environment, required this.appName}) : super(key: key, child: child);
  final Env environment;
  final String appName;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
