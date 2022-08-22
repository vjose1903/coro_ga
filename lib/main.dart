import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/routes/app_routes.dart';
import 'package:game_score/screens/screens.dart';
import 'package:game_score/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:flutter/services.dart';

import 'shared_preferences/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();

  await Preferences.init();

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

    Widget myAppWithSplash = SplashScreenView(
      pageRouteTransition: PageRouteTransition.CupertinoPageRoute,
      navigateRoute: const HomeScreen(),
      // navigateRoute: const GanadorScreen(),
      duration: 2500,
      imageSize: 280,
      imageSrc: "assets/img/${Preferences.isDarkMode ? "logo_dark" : "logo_light"}.png",
      text: "CARGANDO...",
      textType: TextType.TyperAnimatedText,
      textStyle: const TextStyle(fontSize: 30.0, fontFamily: "Poppins"),
      backgroundColor: Preferences.isDarkMode ? const Color(0xff020036) : const Color(0xFFF0F0F0),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // if (Preferences.isFirstTimeOpen) PartidaPredefinidaProvider.seed();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coro Games',
          home: myAppWithSplash,
          builder: EasyLoading.init(),
          routes: AppRoutes.getAppRoutes(),
          theme: themeProvider.getCurrentTheme),
    );
  }
}
