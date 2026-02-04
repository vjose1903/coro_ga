import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'helpers/helpers.dart';
import 'package:provider/provider.dart';
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
    ChangeNotifierProvider(create: (_) => PageEditarProvider()),
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
      final ThemeProvider themeProvider = context.read<ThemeProvider>();
      _lastLifecycleState = state;

      if (Preferences.isSystemMode && _lastLifecycleState == AppLifecycleState.resumed) {
        final bool isActualSystemDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

        if (isActualSystemDark != Preferences.isDarkMode) {
          Preferences.isDarkMode = isActualSystemDark;
          themeProvider.changeCurrentTheme();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
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
