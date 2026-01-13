import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class JugadorProvider extends ChangeNotifier {
  Jugador? jugadorEnTurno;
  Jugador? _jugadorEditar;

  FormGroup formJugador = fb.group({
    'nombre': ['', Validators.required]
  });

  String get nombreJugador {
    if (jugadorEnTurno == null) return "";

    return jugadorEnTurno!.nombre!;
  }

  set jugadorEditar(Jugador? jugador) {
    _jugadorEditar = jugador;

    notifyListeners();
  }

  Jugador? get jugadorEditar {
    return _jugadorEditar;
  }

  void changeJugadorEnTurno(Jugador jugador) {
    jugadorEnTurno = jugador;
    notifyListeners();
  }

  Future<SqlResponse> editJugador(BuildContext context, {required Jugador jugador, required String newNombreJugador}) async {
    final responseFuture = Jugador.edit(jugador: jugador, newNombreJugador: newNombreJugador);
    final response = await responseFuture;

    if (!response.hasError!) {
      notifyListeners();
      return responseFuture;
    } else {
      Toast.show(type: ToastType.error, context: context, message: response.messages!.first);
      return responseFuture;
    }
  }

  Future<SqlResponse> changePuntuacion({required Jugador jugador, required int newPuntuacion, required String tipo}) async {
    Map body = jugador.toMap();

    if (tipo == "aumentar") body["puntuacion"] = body["puntuacion"] + newPuntuacion;
    if (tipo == "reducir") body["puntuacion"] = body["puntuacion"] - newPuntuacion;

    SqlResponse response = await Jugador.changePuntuacion(jugador: jugador, newPuntuacion: newPuntuacion, tipo: tipo, newData: body);

    if (!response.hasError!) {
      jugadorEnTurno!.addHistorial(response.data["historial"]);
      jugadorEnTurno!.puntuacion = response.data["newPuntuacion"];
      response.data = jugadorEnTurno;
      notifyListeners();
    }

    return response;
  }

  Future<SqlResponse> deleteHistorial({required HistorialJugada historial}) async {
    SqlResponse response = await Jugador.deleteHistorial(jugador: jugadorEnTurno!, historial: historial);

    if (!response.hasError!) {
      jugadorEnTurno!.puntuacion = response.data["newPuntuacion"];
      notifyListeners();
    }

    return response;
  }

  Future<dynamic> deleteJugador(BuildContext context,
      {required Jugador jugador, SlidingUpPanelController? panelController, required Function callBack}) async {
    final PartidaProvider partidaProvider = context.read<PartidaProvider>();
    final SlideUpProvider slideUpProvider = context.read<SlideUpProvider>();

    CustomAlertDialog.show(context,
        menssage: "Seguro que desea eliminar el jugador: ${jugador.nombre}",
        title: "Confirmar",
        dialogType: DialogType.error,
        buttonsList: [
          CustomActionsButtons.cancelButton({
            "onTap": () {
              Navigator.pop(context);
              callBack({"tipo": "cancelar"});
            }
          }),
          CustomActionsButtons.aceptarButton({
            "onTap": () async {
              Navigator.pop(context);

              final response = await jugador.delete();

              if (!response.hasError!) {
                if (panelController != null) slideUpProvider.closeSlideUp(controller: panelController);

                partidaProvider.removeJugador(jugador);
                if (response.messages != null && response.messages!.isNotEmpty) {
                  Toast.show(type: ToastType.warning, context: context, message: response.messages!.first);
                }
              } else {
                Toast.show(type: ToastType.error, context: context, message: response.messages!.first);
              }
              callBack({"tipo": "aceptar"});
            }
          })
        ]);
  }
}
