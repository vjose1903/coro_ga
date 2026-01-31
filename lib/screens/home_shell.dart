import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import 'home_screen.dart';
import 'partida_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final Widget _home = const HomeScreen();
  late final Widget _partida = const PartidaScreen();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppNavigationProvider>();
    final partidaProvider = context.watch<PartidaProvider>();
    final googleAdsProvider = context.read<GoogleAdsProvider>();
    final premiumProvider = context.read<PremiumProvider>();
    var displayIndex = nav.index;
    if (displayIndex == 1 && partidaProvider.partidaEnTurno == null) {
      displayIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) nav.showHome();
      });
    }
    if (googleAdsProvider.showAdAfterNavigation) {
      if (premiumProvider.isPremium) {
        googleAdsProvider.clearAdAfterNavigation();
      } else if (displayIndex == 0 || displayIndex == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (!googleAdsProvider.showAdAfterNavigation) return;
          googleAdsProvider.clearAdAfterNavigation();
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted) return;
            googleAdsProvider.showInterstitialAd(onCloseFunction: () {
              googleAdsProvider.loadInterstitialAd();
            });
          });
        });
      }
    }
    return WillPopScope(
      onWillPop: () async {
        if (nav.index != 0) {
          nav.showHome();
          return false;
        }
        return true;
      },
      child: IndexedStack(
        index: displayIndex,
        children: [
          _home,
          _partida,
        ],
      ),
    );
  }
}
