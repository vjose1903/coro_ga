import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:game_score/l10n/app_localizations.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/routes/app_routes.dart';
import 'package:game_score/screens/screens.dart';
import 'package:game_score/services/app_integrity_service.dart';
import 'package:game_score/services/purchase_service.dart';
import 'package:game_score/widgets/piracy_blocker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'shared_preferences/preferences.dart';

void main() async {
  // Preservar el splash nativo mientras inicializamos
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ⚡ OPTIMIZACIÓN: Ejecutar operaciones críticas en paralelo
  final results = await Future.wait<bool>([
    Preferences.init().then((_) => true),
    AppIntegrityService.instance.verifyIntegrity(),
  ]);

  final isLegit = results[1];

  if (!isLegit) {
    FlutterNativeSplash.remove();
    runApp(const PiracyBlocker());
    return;
  }

  final isPlatformDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  bool initInDarkMode = Preferences.isSystemMode ? isPlatformDark : Preferences.isDarkMode;

  final premiumProvider = PremiumProvider();

  // ⚡ Inicializar ads y compras de forma DIFERIDA (no bloquear el arranque)
  _initializeServicesDeferred(premiumProvider);

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
    ChangeNotifierProvider(create: (_) => LocaleProvider()),
    ChangeNotifierProvider.value(value: premiumProvider),
  ], child: const MyApp()));
}

/// Inicializa servicios pesados de forma diferida (sin bloquear el arranque)
void _initializeServicesDeferred(PremiumProvider premiumProvider) {
  // Ejecutar en paralelo después de que la UI se muestre
  Future.wait([
    MobileAds.instance.initialize(),
    PurchaseService.instance.initialize(
      onPurchaseComplete: (success) {
        if (success) premiumProvider.setPremium(true);
      },
    ),
  ]);
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
    
    // Remover splash nativo cuando la UI esté lista (solo una vez)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
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
    LocaleProvider localeProvider = context.watch<LocaleProvider>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coro Games',
          // Configuración de idiomas
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es'),
            Locale('en'),
          ],
          locale: localeProvider.locale,
          home: const HomeScreen(),
          builder: EasyLoading.init(
            builder: (context, child) => child ?? const SizedBox.shrink(),
          ),
          routes: AppRoutes.getAppRoutes(),
          theme: themeProvider.getCurrentTheme),
    );
  }
}
