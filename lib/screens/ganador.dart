// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/models/partida.dart';
import 'package:game_score/providers/partida_provider.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/screens/screens.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class GanadorScreen extends StatefulWidget {
  const GanadorScreen({Key? key}) : super(key: key);

  @override
  State<GanadorScreen> createState() => _GanadorScreenState();
}

class _GanadorScreenState extends State<GanadorScreen> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));

      final PartidaProvider partidaProvider = context.read<PartidaProvider>();
      partidaProvider.deletePartida(context, partida: partidaProvider.partidaEnTurno!);
    });
  }

  @override
  Widget build(BuildContext context) {
    GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();
    googleAdsProvider.loadInterstitialAd();

    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map;
    final String partida = routeArgs['partida'];
    final String jugador = routeArgs['jugador'];
    // final String partida = "Domino";
    // final String jugador = "Pedro";

    final Color ganadorColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF06187E);
    final Color partidaColor = Preferences.isDarkMode ? AppThemes.colorSegundo : Colors.grey[700]!;

    final boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.3, 1],
        colors: [AppThemes.themeColor_1, const Color(0xFF08134F)],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: boxDecoration),
          Container(
              alignment: Alignment.topRight,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 70, right: 30),
              child: CustomIconButtom(
                  iconSize: 40,
                  iconColor: ganadorColor,
                  icon: Icons.close,
                  onTap: () {
                    goToHome() {
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: const HomeScreen(),
                              alignment: Alignment.center,
                              duration: const Duration(milliseconds: 500)));
                    }

                    if (AppEnvironment.isPro) {
                      goToHome();
                    } else {
                      googleAdsProvider.showInterstitialAd(onCloseFunction: () => goToHome());
                    }
                  })),
          Container(
              margin: const EdgeInsets.only(top: 150),
              width: double.infinity,
              child: Column(
                children: [
                  TextAnimator("GANADOR",
                      initialDelay: const Duration(seconds: 1),
                      incomingEffect: WidgetTransitionEffects.incomingOffsetThenScaleAndStep(duration: const Duration(milliseconds: 800)),
                      style: TextStyle(color: ganadorColor, fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 3)),
                  TextAnimator(partida,
                      initialDelay: const Duration(seconds: 1, milliseconds: 800),
                      incomingEffect: WidgetTransitionEffects.incomingScaleDown(duration: const Duration(seconds: 1)),
                      style: TextStyle(color: partidaColor, fontFamily: 'Poppins', fontSize: 20)),
                  //
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 300,
                    child: Bounce(
                        delay: const Duration(seconds: 1),
                        infinite: true,
                        child: const LottieAnimation(animationJson: 'assets/animations/trophy.json')),
                  ),

                  const SizedBox(height: 10),

                  TextAnimator(jugador,
                      spaceDelay: const Duration(milliseconds: 0),
                      characterDelay: const Duration(milliseconds: 180),
                      incomingEffect: WidgetTransitionEffects.incomingScaleUp(),
                      atRestEffect: WidgetRestingEffects.pulse(effectStrength: 0.8),
                      initialDelay: const Duration(seconds: 2),
                      style: TextStyle(color: ganadorColor, fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 3)),

                  const SizedBox(height: 40),

                  WidgetAnimator(
                    incomingEffect: WidgetTransitionEffects.outgoingScaleUp(
                        delay: const Duration(seconds: 2, milliseconds: 800), duration: const Duration(seconds: 1)),
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green[400])),
                      onPressed: () => revanchaFunction(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text("Revancha", style: TextStyle(fontSize: 15, fontFamily: 'Poppins', fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  revanchaFunction() async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    GoogleAdsProvider googleAdsProvider = context.read<GoogleAdsProvider>();
    MyLoading.show();
    for (Jugador jugador in partidaProvider.partidaEnTurno!.jugadores!) {
      jugador.puntuacion = 0;
    }

    final response = await partidaProvider.newPartida(partidaProvider.partidaEnTurno!, context);
    MyLoading.close();
    if (!response.hasError!) {
      goToPartida() {
        final newPartida = response.data;
        partidaProvider.changePartidaEnTurno(newPartida);
        Navigator.pushReplacementNamed(context, 'partida');
      }

      if (AppEnvironment.isPro) {
        goToPartida();
      } else {
        googleAdsProvider.showInterstitialAd(onCloseFunction: () => goToPartida());
      }
    } else {
      Fun.toast(type: ToasType.error, context: context, message: "Error renovando partida.");
      Navigator.pushReplacementNamed(context, 'home');
    }
  }
}
