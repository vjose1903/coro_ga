import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/routes/app_routes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'shared_preferences/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS || Platform.isMacOS) {
    StoreConfig(store: Store.appleStore, apiKey: appleApiKey);
  } else if (Platform.isAndroid) {
    StoreConfig(store: Store.googlePlay, apiKey: googleApiKey);
  }

  await PurchaseHelper.init();
  await Preferences.init();
  AppEnvironment.initialize();

  final isPlatformDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
  bool initInDarkMode = Preferences.isSystemMode ? isPlatformDark : Preferences.isDarkMode;

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PartidaProvider()),
    ChangeNotifierProvider(create: (_) => FormPartidaProvider()),
    ChangeNotifierProvider(create: (_) => SlideUpProvider()),
    ChangeNotifierProvider(create: (_) => JugadorProvider()),
    ChangeNotifierProvider(create: (_) => GoogleAdsProvider()),
    ChangeNotifierProvider(create: (_) => ReorderableProvider()),
    ChangeNotifierProvider(create: (_) => PageEditarProvider()),
    ChangeNotifierProvider(create: (_) => PartidaPredefinidaProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode_: initInDarkMode)),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      ThemeProvider themeProvider = context.read<ThemeProvider>();
      _lastLifecycleState = state;

      if (Preferences.isSystemMode && _lastLifecycleState == AppLifecycleState.resumed) {
        bool isActualSystemDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

        if (isActualSystemDark != Preferences.isDarkMode) {
          Preferences.isDarkMode = isActualSystemDark;
          themeProvider.changeCurrentTheme();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = context.watch<ThemeProvider>();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coro Games',
          initialRoute: AppRoutes.initialRoute,
          builder: EasyLoading.init(),
          routes: AppRoutes.getAppRoutes(),
          theme: themeProvider.getCurrentTheme),
    );
  }
}
