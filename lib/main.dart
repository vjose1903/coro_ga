import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/routes/app_routes.dart';
import 'package:game_score/screens/screens.dart';
import 'package:game_score/services/purchase_service.dart';
import 'package:game_score/widgets/custom_splash_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'shared_preferences/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  await Preferences.init();

  final isPlatformDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  bool initInDarkMode = Preferences.isSystemMode ? isPlatformDark : Preferences.isDarkMode;

  // Crear PremiumProvider primero para pasarlo al PurchaseService
  final premiumProvider = PremiumProvider();
  
  // Inicializar servicio de compras
  await PurchaseService.instance.initialize(
    onPurchaseComplete: (success) {
      if (success) premiumProvider.setPremium(true);
    },
  );

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
    ChangeNotifierProvider.value(value: premiumProvider),
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
        bool isActualSystemDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

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

    // Determinar qué logo usar
    String logoPath;
    if (Preferences.isPremium) {
      logoPath = "assets/img/logo_pro.png";
    } else {
      logoPath = "assets/img/${Preferences.isDarkMode ? "logo_dark" : "logo_light"}.png";
    }

    Widget myAppWithSplash = CustomSplashScreen(
      navigateRoute: const HomeScreen(),
      duration: 1500, // Reducido de 2500ms a 1500ms
      imageSize: 280,
      imageSrc: logoPath,
      text: "CARGANDO...",
      textStyle: const TextStyle(fontSize: 30.0, fontFamily: "Poppins"),
      backgroundColor: Preferences.isDarkMode ? const Color(0xff020036) : const Color(0xFFF0F0F0),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coro Games',
          home: myAppWithSplash,
          builder: EasyLoading.init(
            builder: (context, child) => child ?? const SizedBox.shrink(),
          ),
          routes: AppRoutes.getAppRoutes(),
          theme: themeProvider.getCurrentTheme),
    );
  }
}
