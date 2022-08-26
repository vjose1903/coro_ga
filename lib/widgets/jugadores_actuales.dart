import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:provider/provider.dart';

class JugadoresActuales extends StatelessWidget {
  const JugadoresActuales({Key? key, required this.pageController, required this.jugadoresController, required this.rebuildWidget}) : super(key: key);
  final PageController pageController;
  final Function rebuildWidget;
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
              color: AppThemes.themeColor_1,
              child: ListJugadores(pageController: pageController, jugadoresController: jugadoresController, rebuildWidget: rebuildWidget)),
        ),
      ),
    );
  }
}

class ListJugadores extends StatelessWidget {
  const ListJugadores({Key? key, required this.pageController, required this.jugadoresController, required this.rebuildWidget}) : super(key: key);
  final PageController pageController;
  final ScrollController jugadoresController;
  final Function rebuildWidget;

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.read<JugadorProvider>();
    final PageEditarProvider pageEditarProvider = context.read<PageEditarProvider>();

    List<Jugador> jugadores = [];
    jugadores = partidaProvider.partidaEnTurno!.jugadoresSort;

    Color nombreColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.8) : AppThemes.colorQuinto.withOpacity(0.7);
    Color puntuacionColor = Preferences.isDarkMode ? AppThemes.colorSegundo : AppThemes.colorQuinto.withOpacity(0.7);
    final Color iconsColor = Preferences.isDarkMode ? Colors.grey.withOpacity(0.9) : AppThemes.colorQuinto.withOpacity(0.7);

    final double actualPage = pageEditarProvider.getActualPage();

    return ListView.separated(
        key: UniqueKey(),
        controller: jugadoresController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(5),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: jugadores.length,
        itemBuilder: (context, index) {
          Jugador jugador = jugadores[index];

          pageController.addListener(() async {
            if (actualPage == 1.0 && pageController.page == 0.0) {
              await Future.delayed(const Duration(milliseconds: 100));
              rebuildWidget();
            }

            pageEditarProvider.setActualPage(pageController.page);
          });

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 5),
                  CustomIconButtom(
                    tooltip: "Editar Jugador",
                    onTap: () async {
                      jugadorProvider.jugadorEditar = jugador;
                      nextPage();
                      await Future.delayed(const Duration(milliseconds: 200));
                      jugadorProvider.formJugador.patchValue(jugadorProvider.jugadorEditar!.toMap());
                    },
                    icon: Icons.edit_outlined,
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
                    tooltip: "Borrar Jugador",
                    onTap: () {
                      jugadorProvider.deleteJugador(context, jugador: jugador, callBack: (value) async {
                        if (value["tipo"] == "aceptar") {
                          double actualPosition = jugadoresController.position.pixels;

                          rebuildWidget();

                          await Future.delayed(const Duration(milliseconds: 50));
                          jugadoresController.jumpTo(actualPosition);
                        }
                      });
                    },
                    icon: Icons.delete_forever,
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
