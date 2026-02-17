import 'package:flutter/material.dart';

enum Env { free, pro }

class AppConfig extends InheritedWidget {
  const AppConfig({required super.child, required this.environment, required this.appName, super.key});
  final Env environment;
  final String appName;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
