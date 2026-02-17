import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'helpers/helpers.dart';
import 'l10n/app_localizations.dart';
import 'providers/providers.dart';
import 'routes/app_routes.dart';
import 'routes/route_observer.dart';
import 'screens/screens.dart';
import 'shared_preferences/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences.init();

  final isPlatformDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  final bool initInDarkMode = Preferences.isSystemMode ? isPlatformDark : Preferences.isDarkMode;

  final premiumProvider = PremiumProvider();
  final localeProvider = LocaleProvider();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PartidaProvider()),
    ChangeNotifierProvider(create: (_) => FormPartidaProvider()),
    ChangeNotifierProvider(create: (_) => SlideUpProvider()),
    ChangeNotifierProvider(create: (_) => JugadorProvider()),
    ChangeNotifierProvider(create: (_) => GoogleAdsProvider()),
    ChangeNotifierProvider(create: (_) => ReorderableProvider()),
    ChangeNotifierProvider(create: (_) => PartidaPredefinidaProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode_: initInDarkMode)),
    ChangeNotifierProvider.value(value: premiumProvider),
    ChangeNotifierProvider.value(value: localeProvider),
  ], child: const MyApp()));
}

/// Consistent, glow-free physics so scrolls feel snappier across the app.
class SmoothScrollBehavior extends MaterialScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  bool _isReapplyingSystemUi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _configureSystemUiCallback();
    _applyImmersiveMode();
  }

  @override
  void dispose() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      SystemChrome.setSystemUIChangeCallback(null);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      final ThemeProvider themeProvider = context.read<ThemeProvider>();
      _lastLifecycleState = state;

      if (_lastLifecycleState == AppLifecycleState.resumed) {
        _applyImmersiveMode();
      }

      if (Preferences.isSystemMode && _lastLifecycleState == AppLifecycleState.resumed) {
        final bool isActualSystemDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

        if (isActualSystemDark != Preferences.isDarkMode) {
          Preferences.isDarkMode = isActualSystemDark;
          themeProvider.changeCurrentTheme();
        }
      }
    });
  }

  void _applyImmersiveMode() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  void _configureSystemUiCallback() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    SystemChrome.setSystemUIChangeCallback((bool systemOverlaysAreVisible) async {
      if (!mounted || !systemOverlaysAreVisible || _isReapplyingSystemUi) {
        return;
      }

      _isReapplyingSystemUi = true;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      _applyImmersiveMode();
      _isReapplyingSystemUi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Coro Games',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          home: const SplashLoadingScreen(),
          scrollBehavior: const SmoothScrollBehavior(),
          builder: EasyLoading.init(
            builder: (context, child) {
              ResponsiveApp.setMq(context);
              return child ?? const SizedBox.shrink();
            },
          ),
          routes: AppRoutes.getAppRoutes(),
          navigatorObservers: [routeObserver],
          theme: themeProvider.getCurrentTheme),
    );
  }
}
