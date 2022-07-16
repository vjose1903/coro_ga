import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/utils/utils.dart';

class FormPartidaProvider extends ChangeNotifier {
  Partida? partida;

  Map? FormPartidaMap;

  void getPartida(int? id) async {
    Fun.logColor(color: Colores.green, body: ' -------- getPartida -------- ');
    await Future.delayed(const Duration(seconds: 2));

    if (id == null) {
      partida = Partida(nombre: '', activo: true, jugadores: [
        Jugador(nombre: ''),
        Jugador(nombre: ''),
      ]);
    } else {
      // TODO: buscar aqui la partida por id
      partida = Partida(nombre: '', activo: true, jugadores: [
        Jugador(nombre: ''),
        Jugador(nombre: ''),
      ]);
    }

    notifyListeners();
  }

  set partidaMap(dynamic value) {
    FormPartidaMap = value;
  }

  get partidaMap {
    return FormPartidaMap;
  }

  void addJugadorToList(Jugador jugador) {
    if (partida == null) return;

    partida!.jugadores!.add(jugador);
    notifyListeners();
  }

  void removeJugadorToList(Jugador jugador) {
    if (partida == null) return;
    
    partida!.jugadores!.remove(jugador);
    notifyListeners();
  }
}
