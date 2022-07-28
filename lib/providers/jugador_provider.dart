import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';

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

  Future<SqlResponse> deleteJugador(BuildContext context, {required Jugador jugador}) async {
    final response = await jugador.delete(context, isLoading: true);
    if (!response.hasError!) Fun.logColor(color: Colores.magenta, body: "Jugador borrado correctamente");
    return response;
  }
}
