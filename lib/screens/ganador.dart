// ignore_for_file: use_build_context_synchronously
import '../helpers/helpers.dart';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/partida_provider.dart';
import '../providers/providers.dart';
import '../shared_preferences/preferences.dart';
import '../themes/app_themes.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class GanadorScreen extends StatefulWidget {
  const GanadorScreen({super.key});

  @override
  State<GanadorScreen> createState() => _GanadorScreenState();
}

class _GanadorScreenState extends State<GanadorScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();
    final PremiumProvider premiumProvider = context.read<PremiumProvider>();
    googleAdsProvider.loadInterstitialAd();
    if (!premiumProvider.isPremium) googleAdsProvider.loadRewardedAd(RewardedAdLocation.revancha);

    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map;
    final String partida = routeArgs['partida'];
    final String jugador = routeArgs['jugador'];
    // final String partida = "Domino";
    // final String jugador = "Pedro";

    final Color ganadorColor = Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF06187E);
    final Color partidaColor = Preferences.isDarkMode ? AppThemes.colorSegundo : Colors.grey[700]!;

    final boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.3, 1],
        colors: [AppThemes.themeColor_1, const Color(0xFF08134F)],
      ),
    );

    return ScreenTracker(
      screenName: 'GanadorScreen',
      child: Scaffold(
        body: Stack(
          children: [
            Container(decoration: boxDecoration),
            Container(
              alignment: Alignment.topRight,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 70, right: 30),
              child: WidgetAnimator(
                incomingEffect: WidgetTransitionEffects.incomingSlideInFromRight(delay: const Duration(seconds: 2, milliseconds: 500), duration: const Duration(seconds: 1)),
                child: CustomIconButtom(
                    iconSize: 40,
                    iconColor: ganadorColor,
                    icon: Icons.close,
                    onTap: () {
                      void goHome() {
                        final partidaProvider = context.read<PartidaProvider>();
                        if (partidaProvider.partidaEnTurno != null) {
                          partidaProvider.deletePartida(
                            context,
                            partida: partidaProvider.partidaEnTurno!,
                          );
                        }
                        Navigator.of(context).pushReplacementNamed('home');
                      }

                      if (Preferences.isPremium) {
                        goHome();
                      } else {
                        googleAdsProvider.showInterstitialAd(onCloseFunction: () {
                          if (!context.mounted) return;
                          goHome();
                          googleAdsProvider.loadInterstitialAd();
                        });
                      }
                    }),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 150),
                width: double.infinity,
                child: Column(
                  children: [
                    TextAnimator(AppLocalizations.of(context)!.winner,
                        initialDelay: const Duration(seconds: 1), incomingEffect: WidgetTransitionEffects.incomingOffsetThenScaleAndStep(duration: const Duration(milliseconds: 800)), style: TextStyle(color: ganadorColor, fontFamily: 'Poppins', fontSize: ResponsiveApp.scaleText(30), fontWeight: FontWeight.bold, letterSpacing: 3)),
                    TextAnimator(partida, initialDelay: const Duration(seconds: 1, milliseconds: 800), incomingEffect: WidgetTransitionEffects.incomingScaleDown(duration: const Duration(seconds: 1)), style: TextStyle(color: partidaColor, fontFamily: 'Poppins', fontSize: ResponsiveApp.scaleText(20))),
                    //
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 300,
                      child: Bounce(delay: const Duration(seconds: 1), infinite: true, child: const LottieAnimation(animationJson: 'assets/animations/trophy.json')),
                    ),

                    const SizedBox(height: 10),

                    TextAnimator(jugador,
                        spaceDelay: const Duration(),
                        characterDelay: const Duration(milliseconds: 180),
                        incomingEffect: WidgetTransitionEffects.incomingScaleUp(),
                        atRestEffect: WidgetRestingEffects.pulse(effectStrength: 0.8),
                        initialDelay: const Duration(seconds: 2),
                        style: TextStyle(color: ganadorColor, fontFamily: 'Poppins', fontSize: ResponsiveApp.scaleText(30), fontWeight: FontWeight.bold, letterSpacing: 3)),

                    const SizedBox(height: 40),

                    WidgetAnimator(
                      incomingEffect: WidgetTransitionEffects.outgoingScaleUp(delay: const Duration(seconds: 2), duration: const Duration(seconds: 1)),
                      child: ElevatedButton(
                        style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green[400])),
                        onPressed: () => revanchaFunction(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppLocalizations.of(context)!.rematch, style: TextStyle(fontSize: ResponsiveApp.scaleText(15), fontFamily: 'Poppins', fontWeight: FontWeight.bold, letterSpacing: 2)),
                              if (!premiumProvider.isPremium) Text(AppLocalizations.of(context)!.watchAd, style: TextStyle(fontSize: ResponsiveApp.scaleText(10), fontFamily: 'Poppins', fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  revanchaFunction() async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();
    final PremiumProvider premiumProvider = context.read<PremiumProvider>();

    final partida = partidaProvider.partidaEnTurno;
    if (partida == null) {
      Navigator.of(context).pushReplacementNamed('home');
      return;
    }

    Future<void> restartAndGo() async {
      MyLoading.show();
      await partida.restartPartida();
      partidaProvider.refresh();
      MyLoading.close();
      Navigator.pop(context);
    }

    if (!premiumProvider.isPremium) {
      bool rewardEarned = false;
      googleAdsProvider.showRewardedAd(
        onCloseFunction: () {
          if (!context.mounted) return;
          if (rewardEarned) {
            restartAndGo();
            return;
          }
          // No obtuvo recompensa: borrar partida y volver a Home
          if (partidaProvider.partidaEnTurno != null) {
            partidaProvider.deletePartida(
              context,
              partida: partidaProvider.partidaEnTurno!,
            );
          }
          Navigator.of(context).pushReplacementNamed('home');
        },
        onRewardEarned: () {
          rewardEarned = true;
        },
      );
    } else {
      await restartAndGo();
    }
  }
}
