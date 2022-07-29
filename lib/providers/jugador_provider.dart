import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:we_slide/we_slide.dart';

class JugadorProvider extends ChangeNotifier {
  Jugador? jugadorEnTurno;

  String get nombreJugador {
    if (jugadorEnTurno == null) return "";

    return jugadorEnTurno!.nombre!;
  }

  void changeJugadorEnTurno(Jugador jugador) {
    jugadorEnTurno = jugador;
    notifyListeners();
  }

  void deleteJugador(BuildContext context, {required Jugador jugador, WeSlideController? weSlideController}) {
    final partidaProvider = context.read<PartidasProvider>();
    final WeSlideProvider weSlideProvider = context.read<WeSlideProvider>();

    CustomAlertDialog.show(context,
        menssage: "Seguro que desea eliminar el jugador: ${jugador.nombre}",
        title: "Confirmar",
        dialogType: DialogType.error,
        buttonsList: [
          CustomActionsButtons.cancelButton({"onTap": () => Navigator.pop(context)}),
          CustomActionsButtons.aceptarButton({
            "onTap": () async {
              Navigator.pop(context);

              final response = await jugador.delete(context, isLoading: true);

              if (!response.hasError!) {
                Fun.logColor(color: Colores.magenta, body: "Jugador borrado correctamente");
                if (weSlideController != null) weSlideProvider.closeWeSlide(controller: weSlideController);

                partidaProvider.removeJugador(jugador);
                Fun.logColor(color: Colores.yellow, body: "$response");
                if (response.messages != null && response.messages!.isNotEmpty) {
                  Fun.toast(type: ToasType.warning, context: context, message: response.messages!.first);
                }
              } else {
                Fun.toast(type: ToasType.error, context: context, message: response.messages!.first);
              }
            }
          })
        ]);
  }
}
