import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/providers.dart';
import 'routes/app_routes.dart';
import 'screens/screens.dart';
import 'services/banner_prefetch_service.dart';
import 'services/consent_service.dart';
import 'services/purchase_service.dart';
import 'shared_preferences/preferences.dart';

void main() async {
  // Preservar el splash nativo mientras inicializamos
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Preferences.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final isPlatformDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  bool initInDarkMode = Preferences.isSystemMode ? isPlatformDark : Preferences.isDarkMode;

  final premiumProvider = PremiumProvider();
  final localeProvider = LocaleProvider();

  // ⚡ Inicializar ads y compras de forma DIFERIDA (no bloquear el arranque)
  _initializeServicesDeferred(premiumProvider);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PartidaProvider()),
    ChangeNotifierProvider(create: (_) => FormPartidaProvider()),
    ChangeNotifierProvider(create: (_) => SlideUpProvider()),
    ChangeNotifierProvider(create: (_) => JugadorProvider()),
    ChangeNotifierProvider(create: (_) => GoogleAdsProvider()),
    Provider(create: (_) => BannerPrefetchService()),
    ChangeNotifierProvider(create: (_) => ReorderableProvider()),
    ChangeNotifierProvider(create: (_) => PageEditarProvider()),
    ChangeNotifierProvider(create: (_) => PartidaPredefinidaProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode_: initInDarkMode)),
    ChangeNotifierProvider.value(value: premiumProvider),
    ChangeNotifierProvider.value(value: localeProvider),
  ], child: const MyApp()));
}

/// Inicializa servicios pesados de forma diferida (sin bloquear el arranque)
void _initializeServicesDeferred(PremiumProvider premiumProvider) {
  // Ejecutar en paralelo después de que la UI se muestre
  Future.wait([
    _initializeMobileAds(),
    PurchaseService.instance.initialize(
      onPurchaseComplete: (success) {
        if (success) premiumProvider.setPremium(true);
      },
    ),
  ]);
}

/// Inicializa MobileAds con configuración COPPA y contenido apropiado
Future<void> _initializeMobileAds() async {
  await MobileAds.instance.initialize();

  // IMPORTANTE: Inicializar consentimiento GDPR/UMP ANTES de configurar/cargar anuncios
  await ConsentService.instance.initialize();

  // Configurar restricciones de contenido para todos los anuncios
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      // El dominó es un juego familiar atractivo para niños -> marcar como sí
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      // Clasificación máxima de contenido: G = General (apto para todos)
      maxAdContentRating: MaxAdContentRating.g,
    ),
  );
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
    final localeProvider = context.watch<LocaleProvider>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coro Games',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          home: const HomeScreen(),
          builder: EasyLoading.init(
            builder: (context, child) {
              ResponsiveApp.setMq(context);
              return child ?? const SizedBox.shrink();
            },
          ),
          routes: AppRoutes.getAppRoutes(),
          theme: themeProvider.getCurrentTheme),
    );
  }
}
