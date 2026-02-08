import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../helpers/helpers.dart';
import '../firebase_options.dart';
import '../l10n/app_localizations.dart';
import '../themes/app_themes.dart';
import '../providers/premium_provider.dart';
import '../services/purchase_service.dart';
import '../shared_preferences/preferences.dart';
import '../widgets/widgets.dart';

class SplashLoadingScreen extends StatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen> {
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  Future<void> _startInitialization() async {
    setState(() {
      _progress = 0;
      _hasError = false;
    });

    final steps = _buildSteps();
    final totalWeight = steps.fold<double>(0, (sum, step) => sum + step.weight);
    double completedWeight = 0;

    for (final step in steps) {
      if (!mounted) return;
      try {
        await step.action();
      } catch (e) {
        if (!mounted) return;
        debugPrint('Init step failed: ${step.label} -> $e');
        if (step.isRequired) {
          setState(() {
            _hasError = true;
          });
          return;
        }
      }
      completedWeight += step.weight;
      if (!mounted) return;
      setState(() => _progress = (completedWeight / totalWeight).clamp(0, 1));
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('home');
  }

  List<_InitStep> _buildSteps() {
    final premiumProvider = context.read<PremiumProvider>();
    final steps = <_InitStep>[
      _InitStep(
        label: 'Inicializando Firebase',
        weight: 1,
        action: _initializeFirebase,
      ),
      _InitStep(
        label: 'Cargando compras',
        weight: 1,
        action: () => PurchaseService.instance.initialize(
          onPurchaseComplete: (success) {
            if (success) premiumProvider.setPremium(true);
          },
        ),
        isRequired: false,
      ),
    ];

    if (!Preferences.isPremium) {
      steps.add(_InitStep(
        label: 'Configurando anuncios',
        weight: 1,
        action: _initializeMobileAds,
        isRequired: false,
      ));
    }

    return steps;
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  Future<void> _initializeMobileAds() async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.85);
    final backgroundColor = Preferences.isDarkMode ? AppThemes.themeColor_1 : Colors.white;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ResponsiveLayoutBuilder(
                useMediaQuery: true,
                builder: (context, constraints, info) {
                  final isLandscape = info.isLandscape;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      isLandscape
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      'assets/icon/icon.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coro Games',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      LinearProgressIndicator(
                                        value: _hasError ? null : _progress,
                                        color: AppThemes.colorPrimero,
                                        backgroundColor: AppThemes.themeColor_3,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _hasError ? l10n.loadingDataError : l10n.loadingData,
                                        textAlign: TextAlign.left,
                                        style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                                      ),
                                      if (_hasError) ...[
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _startInitialization,
                                          child: Text(l10n.loading),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 12),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      'assets/icon/icon.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Coro Games',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                LinearProgressIndicator(
                                  value: _hasError ? null : _progress,
                                  color: AppThemes.colorPrimero,
                                  backgroundColor: AppThemes.themeColor_3,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _hasError ? l10n.loadingDataError : l10n.loadingData,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                                ),
                                if (_hasError) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _startInitialization,
                                    child: Text(l10n.loading),
                                  ),
                                ],
                              ],
                            ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InitStep {
  _InitStep({
    required this.label,
    required this.weight,
    required this.action,
    this.isRequired = true,
  });

  final String label;
  final double weight;
  final Future<void> Function() action;
  final bool isRequired;
}
