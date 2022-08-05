import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:game_score/providers/partida_provider.dart';
import 'package:game_score/screens/screens.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class GanadorScreen extends StatelessWidget {
  const GanadorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map;
    final String partida = routeArgs['partida'];
    final String jugador = routeArgs['jugador'];

    final Color ganadorColor = AppThemes.currentTheme == Themes.dark ? Colors.white.withOpacity(0.7) : const Color(0xFF06187E);
    final Color partidaColor = AppThemes.currentTheme == Themes.dark ? AppThemes.colorSegundo : Colors.grey[700]!;

    final boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.5, 0.99],
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
                  // onTap: () => Navigator.pushReplacementNamed(context, 'home'),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: const HomeScreen(),
                            alignment: Alignment.center,
                            duration: const Duration(milliseconds: 500)));

                    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
                    partidaProvider.deletePartida(context, partida: partidaProvider.partidaEnTurno!);
                  })),
          Container(
              margin: const EdgeInsets.only(top: 200),
              width: double.infinity,
              child: Column(
                children: [
                  Text("GANADOR",
                      style: TextStyle(color: ganadorColor, fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 3)),
                  Text(partida, style: TextStyle(color: partidaColor, fontFamily: 'Poppins', fontSize: 20)),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 300,
                    child: Bounce(
                        delay: const Duration(seconds: 1),
                        infinite: true,
                        child: const LottieAnimation(animationJson: 'assets/animations/trophy.json')),
                  ),
                  const SizedBox(height: 10),
                  Text(jugador,
                      style: TextStyle(color: ganadorColor, fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 3)),
                ],
              )),
        ],
      ),
    );
  }
}
