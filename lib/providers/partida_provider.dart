import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/utils/utils.dart';

class PartidasProvider extends ChangeNotifier {
  List<Partida> partidas = [];
  // final partidaClass = Partida();
  // final jugadorClass = Jugador();

  // Future<SqlResponse> newPartida(Partida partida) async {
  //   final SqlResponse response = SqlResponse();
  //   List<Jugador>? jugadores = partida.jugadores;

  //   if (jugadores == null) {
  //     response.addMsg('Debe de agregar almenos 2 jugadores a la partida');
  //     response.hasError = true;
  //     return response;
  //   }

  //   Map<String, dynamic> tempPartidaMap = partida.toMap();

  //   Fun.removeKeys(tempPartidaMap, ['id', 'jugadores']);

  //   final partidaId = await partida.insert(body: tempPartidaMap);

  //   for (var jugador in jugadores) {
  //     //
  //     jugador.partidaId = partidaId;

  //     Map<String, dynamic> tempJugadorMap = jugador.toMap();
  //     Fun.removeKeys(tempJugadorMap, ['id']);

  //     final int jugadorId = await jugador.insert(body: tempJugadorMap);
  //     jugador.id = jugadorId;
  //   }

  //   partida.id = partidaId;

  //   response.data = partida;
  //   partidas.add(partida);
  //   notifyListeners();

  //   return response;
  // }

  getPartidas() async {
    final partidasFuture = Partida.getPartidas();

    partidas = await partidasFuture;

    notifyListeners();
    return partidasFuture;
  }

  Future<Partida?> getPartidaById(int? id) async {
    await Future.delayed(const Duration(seconds: 1));

    late Partida? partida;

    if (id == null) {
      partida = Partida(nombre: '', jugadores: [Jugador(nombre: ''), Jugador(nombre: '')]);
    } else {
      partida = await Partida.getPartidaById(id);
    }

    return partida;
  }
}
