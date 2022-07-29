import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';
import 'package:game_score/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:we_slide/we_slide.dart';

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
    final responseFuture = Jugador.edit(context, jugador: jugador, newNombreJugador: newNombreJugador);
    final response = await responseFuture;

    if (!response.hasError!) {
      notifyListeners();
      return responseFuture;
    } else {
      Fun.toast(type: ToasType.error, context: context, message: response.messages!.first);
      return responseFuture;
    }
  }

  void deleteJugador(BuildContext context, {required Jugador jugador, WeSlideController? weSlideController}) {
    final partidaProvider = context.read<PartidaProvider>();
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
                if (weSlideController != null) weSlideProvider.closeWeSlide(controller: weSlideController);

                partidaProvider.removeJugador(jugador);
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
