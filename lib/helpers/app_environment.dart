import 'package:package_info_plus/package_info_plus.dart';

enum Env { free, pro }

class AppEnvironment {

  factory AppEnvironment() {
    return env;
  }

  AppEnvironment._();
  static final AppEnvironment env = AppEnvironment._();

  static PackageInfo? _packageInfo;

  static String get appName {
    return _packageInfo!.appName;
  }

  static String get packageId {
    return _packageInfo!.packageName;
  }

  static bool get isPro {
    return appName.contains('pro');
  }

  static initialize() async {
    _packageInfo ??= await initializePackageInfo();
  }

  static Future<PackageInfo> initializePackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }
}
