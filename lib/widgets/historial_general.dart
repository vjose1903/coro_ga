import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/screens/ganador.dart';
import 'package:game_score/shared_preferences/preferences.dart';
import 'package:game_score/themes/app_themes.dart';
import 'package:game_score/widgets/widgets.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';

class HistorialGeneral extends StatefulWidget {
  const HistorialGeneral({Key? key, required this.panelController}) : super(key: key);
  final SlidingUpPanelController panelController;

  @override
  State<HistorialGeneral> createState() => _HistorialGeneralState();
}

class _HistorialGeneralState extends State<HistorialGeneral> {
  final TextEditingController puntuacionController = TextEditingController();
  final ScrollController historialController = ScrollController();
  Jugador? jugadorSeleccionado;

  @override
  void initState() {
    super.initState();
    // Scroll al final del historial al abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (historialController.hasClients) {
        historialController.jumpTo(historialController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    puntuacionController.dispose();
    historialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PartidaProvider partidaProvider = context.watch<PartidaProvider>();
    final JugadorProvider jugadorProvider = context.watch<JugadorProvider>();
    final Partida partida = partidaProvider.partidaEnTurno!;
    final List<Jugador> jugadores = partida.jugadores ?? [];

    // Inicializar jugador seleccionado
    jugadorSeleccionado ??= jugadores.isNotEmpty ? jugadores.first : null;

    // Combinar todos los historiales con info del jugador
    List<_HistorialConJugador> todosHistoriales = [];
    for (var jugador in jugadores) {
      if (jugador.historialJugadas != null) {
        for (var historial in jugador.historialJugadas!) {
          todosHistoriales.add(_HistorialConJugador(jugador: jugador, historial: historial));
        }
      }
    }

    // Ordenar por id (orden cronológico)
    todosHistoriales.sort((a, b) => a.historial.id!.compareTo(b.historial.id!));

    // Colores
    Color titleColor = Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.8) : AppThemes.colorQuinto;
    Color subTitleColor = Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.5) : AppThemes.colorQuinto.withValues(alpha: 0.7);
    Color dropdownColor = Preferences.isDarkMode ? AppThemes.themeColor_1 : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          // TITULO
          Row(
            children: [
              Icon(Icons.history, color: titleColor, size: 24),
              const SizedBox(width: 10),
              Text("Historial General",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
            ],
          ),
          const SizedBox(height: 15),

          // SELECTOR DE JUGADOR
          Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: Text("Jugador Seleccionado:", style: TextStyle(fontFamily: "Poppins", fontSize: 16, color: subTitleColor))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: dropdownColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(blurRadius: 5, spreadRadius: 1, color: AppThemes.colorQuinto.withValues(alpha: 0.1))],
                ),
                child: DropdownButton<Jugador>(
                  value: jugadorSeleccionado,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: dropdownColor,
                  icon: Icon(Icons.arrow_drop_down, color: titleColor),
                  items: jugadores.map((jugador) {
                    return DropdownMenuItem<Jugador>(
                      value: jugador,
                      child: Text(jugador.nombre!, style: TextStyle(fontFamily: "Poppins", color: titleColor)),
                    );
                  }).toList(),
                  onChanged: (Jugador? newJugador) {
                    setState(() {
                      jugadorSeleccionado = newJugador;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // CAMPO PUNTUACION
          if (partida.tipo == "Puntuación")
            TextField(
              controller: puntuacionController,
              enabled: false,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Puntuación',
                fillColor: AppThemes.inputDisabledColor,
                filled: true,
                labelStyle: TextStyle(color: AppThemes.labelInputDisabledColor, fontFamily: 'Poppins'),
              ),
            ),
          if (partida.tipo == "Puntuación") const SizedBox(height: 10),

          // LISTA DE HISTORIAL GENERAL
          Expanded(
            flex: 2,
            child: Material(
              borderRadius: BorderRadius.circular(10),
              shadowColor: AppThemes.colorQuinto.withValues(alpha: 0.3),
              elevation: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: AppThemes.themeColor_1,
                  child: _ListHistorialGeneral(
                    historiales: todosHistoriales,
                    historialController: historialController,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // TECLADO
          if (partida.tipo == "Puntuación") _Keyboard(puntuacionController: puntuacionController),
          if (partida.tipo == "Puntuación") const SizedBox(height: 10),

          // BOTONES AUMENTAR/REDUCIR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ExpandedButtom(
                backgroundColor: Colors.green[400],
                label: "Aumentar",
                textColor: Colors.white,
                onTap: () => _changePuntuacion(
                  context: context,
                  jugadorProvider: jugadorProvider,
                  partidaProvider: partidaProvider,
                  tipo: "aumentar",
                ),
              ),
              const SizedBox(width: 10),
              ExpandedButtom(
                backgroundColor: Colors.red[400],
                label: "Reducir",
                textColor: Colors.white,
                onTap: () => _changePuntuacion(
                  context: context,
                  jugadorProvider: jugadorProvider,
                  partidaProvider: partidaProvider,
                  tipo: "reducir",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changePuntuacion({
    required BuildContext context,
    required JugadorProvider jugadorProvider,
    required PartidaProvider partidaProvider,
    required String tipo,
  }) async {
    if (jugadorSeleccionado == null) {
      Toast.show(type: ToastType.warning, context: context, message: "Seleccione un jugador");
      return;
    }

    String puntuacion = partidaProvider.partidaEnTurno!.tipo == "Puntuación" ? puntuacionController.text : "1";

    if (puntuacion.isEmpty || puntuacion == "0") {
      String msg = puntuacion == "0" ? "Puntuación debe de ser mayor a 0" : "Debe introducir una puntuación";
      Toast.show(type: ToastType.warning, context: context, title: "AVISO", message: msg);
      return;
    }

    int puntuacionInt = int.parse(puntuacion);
    int puntuacionActual = jugadorSeleccionado!.puntuacion!;

    if (tipo == "reducir" && puntuacionActual - puntuacionInt < 0) {
      String msgError = partidaProvider.partidaEnTurno!.tipo == "Puntuación"
          ? "La puntuación mínima debe de ser 0."
          : "La ronda mínima debe de ser 0.";
      Toast.show(type: ToastType.warning, context: context, title: "AVISO", message: msgError);
      return;
    }

    MyLoading.show();

    // Cambiar temporalmente el jugador en turno para usar el método existente
    Jugador? jugadorAnterior = jugadorProvider.jugadorEnTurno;
    jugadorProvider.changeJugadorEnTurno(jugadorSeleccionado!);

    SqlResponse response = await jugadorProvider.changePuntuacion(
      jugador: jugadorSeleccionado!,
      newPuntuacion: puntuacionInt,
      tipo: tipo,
    );

    partidaProvider.refresh();

    // Restaurar jugador anterior si existía
    if (jugadorAnterior != null && jugadorAnterior.id != jugadorSeleccionado!.id) {
      jugadorProvider.changeJugadorEnTurno(jugadorAnterior);
    }

    MyLoading.close();

    if (!response.hasError!) {
      puntuacionController.text = "";
      setState(() {}); // Refrescar la lista

      int newPuntuacion = response.data.puntuacion;
      if (newPuntuacion >= partidaProvider.partidaEnTurno!.maxPuntuacion!.toInt()) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            settings: RouteSettings(arguments: {
              "partida": partidaProvider.partidaEnTurno!.nombre,
              "jugador": jugadorSeleccionado!.nombre,
            }),
            pageBuilder: (context, animation, secondaryAnimation) => const GanadorScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }

      // Scroll al final
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (historialController.hasClients) {
          historialController.animateTo(
            historialController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }
}

class _HistorialConJugador {
  final Jugador jugador;
  final HistorialJugada historial;

  _HistorialConJugador({required this.jugador, required this.historial});
}

class _ListHistorialGeneral extends StatelessWidget {
  const _ListHistorialGeneral({Key? key, required this.historiales, required this.historialController}) : super(key: key);

  final List<_HistorialConJugador> historiales;
  final ScrollController historialController;

  @override
  Widget build(BuildContext context) {
    if (historiales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 40, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 10),
            Text("No hay puntuaciones registradas",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: Colors.grey[500]!.withValues(alpha: 0.4))),
          ],
        ),
      );
    }

    Map iconHistorial = {
      "aumentar": {"icon": Icons.arrow_upward_rounded, "color": Colors.green[400]},
      "reducir": {"icon": Icons.arrow_downward_rounded, "color": Colors.red[400]}
    };

    Color historialColor = Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.8) : AppThemes.colorQuinto.withValues(alpha: 0.7);
    Color nombreColor = Preferences.isDarkMode ? Colors.white.withValues(alpha: 0.5) : AppThemes.colorTercero.withValues(alpha: 0.8);

    return ListView.separated(
      controller: historialController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(5),
      separatorBuilder: (_, __) => const Divider(),
      itemCount: historiales.length,
      itemBuilder: (context, index) {
        final item = historiales[index];
        final historial = item.historial;
        final jugador = item.jugador;

        return SwipeActionCell(
          key: ValueKey(historial.id),
          backgroundColor: Colors.transparent,
          trailingActions: [
            SwipeAction(
              title: "Borrar",
              onTap: (CompletionHandler handler) async {
                CustomAlertDialog.show(
                  context,
                  title: "Confirmar",
                  menssage: "¿Seguro que desea eliminar la puntuación ${historial.puntuacion} del jugador ${jugador.nombre}?",
                  dialogType: DialogType.error,
                  buttonsList: [
                    CustomActionsButtons.cancelButton({
                      "onTap": () {
                        Navigator.pop(context);
                        handler(false);
                      }
                    }),
                    CustomActionsButtons.aceptarButton({
                      "onTap": () async {
                        Navigator.pop(context);
                        final jugadorProvider = context.read<JugadorProvider>();
                        final partidaProvider = context.read<PartidaProvider>();

                        // Cambiar al jugador correspondiente para eliminar
                        Jugador? jugadorAnterior = jugadorProvider.jugadorEnTurno;
                        jugadorProvider.changeJugadorEnTurno(jugador);

                        await jugadorProvider.deleteHistorial(historial: historial);
                        partidaProvider.refresh();

                        // Restaurar jugador anterior
                        if (jugadorAnterior != null) {
                          jugadorProvider.changeJugadorEnTurno(jugadorAnterior);
                        }

                        await handler(true);
                      }
                    }),
                  ],
                );
              },
              color: Colors.red,
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Puntuación
                Text(historial.puntuacion.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: historialColor)),
                // Nombre del jugador e icono
                Row(
                  children: [
                    Text(jugador.nombre!, style: TextStyle(fontFamily: "Poppins", fontSize: 12, color: nombreColor)),
                    const SizedBox(width: 8),
                    Icon(iconHistorial[historial.tipo]["icon"], color: iconHistorial[historial.tipo]["color"], size: 22),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
        boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 1, color: AppThemes.colorQuinto.withValues(alpha: 0.2), offset: const Offset(0, 4))],
      ),
      child: CustomKeyboard(onChanged: (value) => changePuntuacionValue(value), tipo: KeyboardType.number),
    );
  }
}

