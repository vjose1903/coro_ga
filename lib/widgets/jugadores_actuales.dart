import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';

class JugadoresActuales extends StatelessWidget {
  const JugadoresActuales({Key? key, required this.pageController, required this.jugadoresController}) : super(key: key);
  final PageController pageController;
  final ScrollController jugadoresController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        shadowColor: AppThemes.colorQuinto.withOpacity(0.3),
        elevation: 7,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
              color: AppThemes.themeColor_1, child: ListJugadores(pageController: pageController, jugadoresController: jugadoresController)),
        ),
      ),
    );
  }
}

class ListJugadores extends StatelessWidget {
  const ListJugadores({Key? key, required this.pageController, required this.jugadoresController}) : super(key: key);
  final PageController pageController;
  final ScrollController jugadoresController;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();

    List<Jugador> jugadores = partidaProvider.partidaEnTurno!.jugadores!;
    jugadores.sort((a, b) => a.id!.compareTo(b.id!));

    Color nombreColor = AppThemes.currentTheme == Themes.dark ? Colors.white.withOpacity(0.8) : AppThemes.colorQuinto.withOpacity(0.7);
    Color puntuacionColor = AppThemes.currentTheme == Themes.dark ? AppThemes.colorSegundo : AppThemes.colorQuinto.withOpacity(0.7);
    final Color iconsColor = AppThemes.currentTheme == Themes.dark ? Colors.grey.withOpacity(0.9) : AppThemes.colorQuinto.withOpacity(0.7);

    return ListView.separated(
        controller: jugadoresController,
        padding: const EdgeInsets.all(5),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: jugadores.length,
        itemBuilder: (context, index) {
          Jugador jugador = jugadores[index];

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 5),
                  CustomIconButtom(
                    onTap: () async {
                      jugadorProvider.jugadorEditar = jugador;
                      nextPage();
                      await Future.delayed(const Duration(milliseconds: 150));
                      jugadorProvider.formJugador.patchValue(jugadorProvider.jugadorEditar!.toMap());
                    },
                    icon: Icons.edit_outlined,
                    size: IconSize.min,
                    iconSize: 20,
                    iconColor: iconsColor,
                    splashColor: AppThemes.colorCuarto,
                  ),
                  const SizedBox(width: 10),
                  Text(jugador.puntuacion.toString(), style: TextStyle(color: puntuacionColor, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Text(jugador.nombre!, style: TextStyle(color: nombreColor)),
                ],
              ),
              Visibility(
                visible: partidaProvider.partidaEnTurno!.jugadores!.length > 2,
                child: CustomIconButtom(
                    onTap: () => jugadorProvider.deleteJugador(context, jugador: jugador),
                    icon: Icons.delete_forever,
                    size: IconSize.min,
                    iconSize: 20,
                    iconColor: iconsColor,
                    splashColor: Colors.red[900]),
              )
            ],
          );
        });
  }

  nextPage() {
    pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }
}
