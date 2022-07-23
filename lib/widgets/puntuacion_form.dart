import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';

class PuntuacionForm extends StatelessWidget {
  const PuntuacionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? puntuacion;
    TextEditingController puntuacionController = TextEditingController();

    final PartidasProvider partidaProvider = context.watch<PartidasProvider>();
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();

    final Color titleColor = AppThemes.currentTheme == "dark" ? Colors.grey.withOpacity(0.9) : AppThemes.colorTercero.withOpacity(0.7);
    final Color subTitleColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.8) : AppThemes.colorTercero.withOpacity(0.9);

    return Column(
      children: [
        Row(
          children: [
            Text("Jugador:", style: TextStyle(fontFamily: "Poppins", fontSize: 18, color: titleColor)),
            const SizedBox(width: 5),
            Text(jugadorProvider.nombreJugador,
                style: TextStyle(fontFamily: "Poppins", fontSize: 17, color: subTitleColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
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
        Expanded(
          flex: 2,
          child: Material(
            borderRadius: BorderRadius.circular(10),
            shadowColor: AppThemes.colorTercero.withOpacity(0.3),
            elevation: 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(color: AppThemes.themeColor_1, child: const ListHistorial()),
            ),
          ),
        ),
        const SizedBox(height: 10),
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
                onTap: () =>
                    changePuntuacion(jugadorProvider: jugadorProvider, puntuacion: puntuacionController.text, tipo: "aumentar", context: context)),

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
        const SizedBox(height: 30),
      ],
    );
  }

  changePuntuacion(
      {required String puntuacion, required String tipo, required JugadorProvider jugadorProvider, required BuildContext context}) async {
    if (puntuacion.isNotEmpty && puntuacion != "0") {
      int puntuacionInt = int.parse(puntuacion);

      Jugador jugador = jugadorProvider.jugadorEnTurno!;
      SqlResponse response =
          await Jugador.changePuntuacion(jugador: jugador, newPuntuacion: puntuacionInt, tipo: tipo, context: context, isLoading: true);

      jugadorProvider.changeJugadorEnTurno(response.data);
    } else {
      String msg = puntuacion == "0" ? "Puntuación debe de ser mayor a 0" : "Debe introducir una puntutación para continuar";

      Fun.toast(type: ToasType.warning, context: context, title: "AVISO", message: msg);
    }
  }
}

class ListHistorial extends StatelessWidget {
  const ListHistorial({Key? key}) : super(key: key);

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
          Icon(Icons.history, size: 50, color: Colors.grey.withOpacity(0.3)),
          Text('No hay puntuaciónes registradas', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.grey[500]!.withOpacity(0.4)))
        ],
      ));
    } else {
      Map iconHistorial = {
        "aumentar": {"icon": Icons.arrow_upward_rounded, "color": Colors.green[400]},
        "reducir": {"icon": Icons.arrow_downward_rounded, "color": Colors.red[400]}
      };

      Color historialColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.8) : AppThemes.colorTercero.withOpacity(0.7);
      Color tipoColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.5);

      Color totalLabelColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.7) : AppThemes.colorTercero.withOpacity(0.7);
      Color totalContainerColor = AppThemes.currentTheme == "dark" ? Colors.white.withOpacity(0.25) : Colors.blueGrey.withOpacity(0.3);

      return Column(
        children: [
          Expanded(
            child: ListView.separated(
                controller: ScrollController(),
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
    Color backgroundColor = AppThemes.currentTheme == "dark" ? const Color(0xff505050) : const Color(0xffF1F1F1);
    return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 1, color: AppThemes.colorTercero.withOpacity(0.2), offset: const Offset(0, 4))],
        ),
        child: CustomKeyboard(onChanged: (value) => changePuntuacionValue(value), tipo: KeyboardType.number));
  }
}
