import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';

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
}
