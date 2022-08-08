import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/screens/ganador.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class PuntuacionForm extends StatelessWidget {
  const PuntuacionForm({Key? key, required this.panelController}) : super(key: key);
  final SlidingUpPanelController panelController;
  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return index == 0
              ? PuntuacionPage(panelController: panelController, pageController: pageController)
              : EditarEntidad(pageController: pageController);
        });
  }
}

class PuntuacionPage extends StatelessWidget {
  const PuntuacionPage({Key? key, required this.panelController, required this.pageController}) : super(key: key);
  final SlidingUpPanelController panelController;
  final PageController pageController;
  @override
  Widget build(BuildContext context) {
    String? puntuacion;
    TextEditingController puntuacionController = TextEditingController();

    final Color titleColor = Preferences.isDarkMode ? Colors.grey.withOpacity(0.9) : AppThemes.colorQuinto.withOpacity(0.7);
    final Color subTitleColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.8) : AppThemes.colorQuinto.withOpacity(0.9);
    GoogleAds anuncio = GoogleAds(tipo: AdType.banner, location: AdLocation.puntuacion);

    return Consumer(
      builder: (BuildContext context, value, Widget? child) {
        final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
        final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Jugador:", style: TextStyle(fontFamily: "Poppins", fontSize: 16, color: titleColor)),
                    const SizedBox(width: 7),
                    Row(
                      children: [
                        Text(jugadorProvider.nombreJugador,
                            style: TextStyle(fontFamily: "Poppins", fontSize: 15, color: subTitleColor, fontWeight: FontWeight.bold)),
                        CustomIconButtom(
                          onTap: () {
                            jugadorProvider.jugadorEditar = jugadorProvider.jugadorEnTurno;
                            jugadorProvider.formJugador.patchValue(jugadorProvider.jugadorEnTurno!.toMap());

                            nextPage();
                          },
                          icon: Icons.edit_outlined,
                          size: IconSize.min,
                          iconSize: 20,
                          iconColor: titleColor,
                          splashColor: AppThemes.colorTercero,
                        ),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible: partidaProvider.partidaEnTurno!.jugadores!.length > 2,
                  child: CustomIconButtom(
                      onTap: () {
                        Jugador jugador = jugadorProvider.jugadorEnTurno!;
                        jugadorProvider.deleteJugador(context, jugador: jugador, panelController: panelController);
                      },
                      icon: Icons.delete_forever,
                      size: IconSize.min,
                      iconSize: 20,
                      iconColor: titleColor,
                      splashColor: Colors.red[900]),
                )
              ],
            ),
            const SizedBox(height: 10),

            // CAMPO PUNTUACION
            //
            CustomInputField(
              key: UniqueKey(),
              enabled: false,
              controller: puntuacionController,
              initialValueFn: () => puntuacion,
              onChanged: (value) => puntuacion = value,
              inputType: TextInputType.number,
              labelText: 'Puntuación',
            ),
            const SizedBox(height: 10),
            // CUADRO OSCURO
            //
            Expanded(
              flex: 2,
              child: Material(
                borderRadius: BorderRadius.circular(10),
                shadowColor: AppThemes.colorQuinto.withOpacity(0.3),
                elevation: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(color: AppThemes.themeColor_1, child: const _ListHistorial()),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // TECLADO
            //
            _Keyboard(puntuacionController: puntuacionController),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // AUMENTAR ==========================================
                ExpandedButtom(
                    backgroundColor: Colors.green[400],
                    label: "Aumentar",
                    textColor: Colors.white,
                    onTap: () {
                      changePuntuacion(jugadorProvider: jugadorProvider, puntuacion: puntuacionController.text, tipo: "aumentar", context: context)
                          .then((newPuntuacion) {
                        if (newPuntuacion != 0) {
                          if (newPuntuacion >= partidaProvider.partidaEnTurno!.maxPuntuacion!.toInt()) {
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    settings: RouteSettings(arguments: {
                                      "partida": partidaProvider.partidaEnTurno!.nombre,
                                      "jugador": jugadorProvider.jugadorEnTurno!.nombre,
                                    }),
                                    child: const GanadorScreen(),
                                    alignment: Alignment.center,
                                    duration: const Duration(milliseconds: 500)));
                          }
                        }
                      });
                    }),

                const SizedBox(width: 10),
                // REDUCIR ==========================================
                ExpandedButtom(
                    backgroundColor: Colors.red[400],
                    label: "Reducir",
                    textColor: Colors.white,
                    onTap: () =>
                        changePuntuacion(jugadorProvider: jugadorProvider, puntuacion: puntuacionController.text, tipo: "reducir", context: context)),
              ],
            ),
            const SizedBox(height: 10),
            // ANUNCIOS ==========================================
            anuncio
          ],
        );
      },
    );
  }

  nextPage() {
    pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart);
  }

  Future<int> changePuntuacion(
      {required String puntuacion, required String tipo, required JugadorProvider jugadorProvider, required BuildContext context}) async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();

    if (puntuacion.isNotEmpty && puntuacion != "0") {
      int puntuacionInt = int.parse(puntuacion);

      Jugador jugador = jugadorProvider.jugadorEnTurno!;
      SqlResponse response =
          await Jugador.changePuntuacion(jugador: jugador, newPuntuacion: puntuacionInt, tipo: tipo, context: context, isLoading: true);
      partidaProvider.refresh();
      jugadorProvider.changeJugadorEnTurno(response.data);
      return response.data.puntuacion;
    } else {
      String msg = puntuacion == "0" ? "Puntuación debe de ser mayor a 0" : "Debe introducir una puntutación para continuar";

      Fun.toast(type: ToasType.warning, context: context, title: "AVISO", message: msg);
      return 0;
    }
  }
}

class _ListHistorial extends StatelessWidget {
  const _ListHistorial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final JugadorProvider? jugadorProvider = context.watch<JugadorProvider?>();
    final Jugador? jugador = jugadorProvider?.jugadorEnTurno;

    if (jugador == null) return Container();

    if (jugador.historialJugadas != null && jugador.historialJugadas!.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 40, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text('No hay puntuaciónes registradas', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: Colors.grey[500]!.withOpacity(0.4)))
        ],
      ));
    } else {
      Map iconHistorial = {
        "aumentar": {"icon": Icons.arrow_upward_rounded, "color": Colors.green[400]},
        "reducir": {"icon": Icons.arrow_downward_rounded, "color": Colors.red[400]}
      };

      Color historialColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.8) : AppThemes.colorQuinto.withOpacity(0.7);
      Color tipoColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.5);

      Color totalLabelColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.7) : AppThemes.colorQuinto.withOpacity(0.7);
      Color totalContainerColor = Preferences.isDarkMode ? Colors.white.withOpacity(0.25) : Colors.blueGrey.withOpacity(0.3);

      return Column(
        children: [
          Expanded(
            child: ListView.separated(
                controller: ScrollController(),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(5),
                separatorBuilder: (_, __) => const Divider(),
                itemCount: jugador.historialJugadas!.length,
                itemBuilder: (context, index) {
                  HistorialJugada historial = jugador.historialJugadas![index];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(historial.puntuacion.toString(), style: TextStyle(color: historialColor))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(historial.tipo!.capitalize(),
                              style: TextStyle(fontFamily: "Poppins", fontSize: 12, color: tipoColor, letterSpacing: 1)),
                          Icon(iconHistorial[historial.tipo]["icon"], color: iconHistorial[historial.tipo]["color"], size: 25),
                        ],
                      ),
                    ],
                  );
                }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: totalContainerColor),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("TOTAL", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, color: totalLabelColor, letterSpacing: 2)),
              Text(jugador.puntuacion.toString(),
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: totalLabelColor,
                  )),
            ]),
          )
        ],
      );
    }
  }
}

class _Keyboard extends StatelessWidget {
  const _Keyboard({Key? key, required this.puntuacionController}) : super(key: key);

  final TextEditingController puntuacionController;

  void changePuntuacionValue(String value) {
    if (value != "DEL") {
      if (puntuacionController.text == "0" && value == "0") return;
      if (puntuacionController.text == "0" && value != "0") {
        puntuacionController.text = value;
      } else {
        puntuacionController.text = puntuacionController.text += value;
      }
    } else {
      if (puntuacionController.text.isNotEmpty) {
        String texto = puntuacionController.text;
        texto = texto.substring(0, texto.length - 1);
        puntuacionController.text = texto;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Preferences.isDarkMode ? const Color(0xff505050) : const Color(0xffF1F1F1);
    return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 1, color: AppThemes.colorQuinto.withOpacity(0.2), offset: const Offset(0, 4))],
        ),
        child: CustomKeyboard(onChanged: (value) => changePuntuacionValue(value), tipo: KeyboardType.number));
  }
}
