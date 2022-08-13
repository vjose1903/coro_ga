import 'package:flutter/material.dart';
import 'package:game_score/providers/providers.dart';

import 'package:game_score/routes/app_routes.dart';
import 'package:game_score/screens/screens.dart';
import 'package:game_score/utils/utils.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:flutter/services.dart';

import 'shared_preferences/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initGoogleMobileAds() => MobileAds.instance.initialize();

  await Preferences.init();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PartidaProvider()),
    ChangeNotifierProvider(create: (_) => FormPartidaProvider()),
    ChangeNotifierProvider(create: (_) => SlideUpProvider()),
    ChangeNotifierProvider(create: (_) => JugadorProvider()),
    ChangeNotifierProvider(create: (_) => LoadingProvider()),
    ChangeNotifierProvider(create: (_) => GoogleAdsProvider()),
    ChangeNotifierProvider(create: (_) => ReorderableProvider()),
    ChangeNotifierProvider(create: (_) => PartidaPredefinidaProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode_: Preferences.isDarkMode)),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GetIt.I.allowReassignment = true;
    GetIt.I.registerSingleton<LoadingProvider>(LoadingProvider());

    ThemeProvider themeProvider = context.watch<ThemeProvider>();

    Widget myAppWithSplash = SplashScreenView(
      pageRouteTransition: PageRouteTransition.CupertinoPageRoute,
      navigateRoute: const HomeScreen(),
      duration: 3000,
      imageSize: 290,
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

    Fun.logColor(color: Colores.red, body: "ANDO AQUI");
    // if (Preferences.isFirstTimeOpen) PartidaPredefinidaProvider.seed();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coro Games',
          home: myAppWithSplash,
          routes: AppRoutes.getAppRoutes(),
          theme: themeProvider.getCurrentTheme),
    );
  }
}
