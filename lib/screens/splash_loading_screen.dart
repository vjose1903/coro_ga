import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import '../providers/premium_provider.dart';
import '../services/ad_ids_service.dart';
import '../services/purchase_service.dart';
import '../shared_preferences/preferences.dart';

class SplashLoadingScreen extends StatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen> {
  double _progress = 0;
  String _status = 'Inicializando...';
  bool _hasError = false;
  String _errorMessage = '';

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
      _status = 'Inicializando...';
      _hasError = false;
      _errorMessage = '';
    });

    final steps = _buildSteps();
    final totalWeight = steps.fold<double>(0, (sum, step) => sum + step.weight);
    double completedWeight = 0;

    for (final step in steps) {
      if (!mounted) return;
      setState(() => _status = step.label);
      try {
        await step.action();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _errorMessage = 'Error al ${step.label.toLowerCase()}.';
        });
        return;
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
        label: 'Configurando anuncios',
        weight: 1,
        action: _initializeMobileAds,
      ),
      _InitStep(
        label: 'Cargando compras',
        weight: 1,
        action: () => PurchaseService.instance.initialize(
          onPurchaseComplete: (success) {
            if (success) premiumProvider.setPremium(true);
          },
        ),
      ),
    ];

    if (!Preferences.isPremium) {
      steps.add(_InitStep(
        label: 'Cargando IDs de anuncios',
        weight: 1,
        action: () => AdIdsService.instance.initialize(),
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
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Icon(Icons.sports_esports, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Coro Games',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(value: _hasError ? null : _progress),
                  const SizedBox(height: 12),
                  Text(
                    _hasError ? _errorMessage : _status,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (_hasError) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startInitialization,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ],
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
  });

  final String label;
  final double weight;
  final Future<void> Function() action;
}
