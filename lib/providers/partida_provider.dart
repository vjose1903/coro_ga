import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';
import 'package:we_slide/we_slide.dart';

class PartidasProvider extends ChangeNotifier {
  List<Partida> partidas = [];
  Partida? partidaEnTurno;
  final WeSlideController weSlideController = WeSlideController();

  void openWeSlide() {
    weSlideController.show();
    notifyListeners();
  }

  void closeWeSlide() {
    weSlideController.hide();
    notifyListeners();
  }

  void navigateToPartida({required Partida partida, required BuildContext context}) {
    partidaEnTurno = partida;
    Navigator.pushNamed(context, 'partida');
    notifyListeners();
  }

  void changePartidaEnTurno(Partida partida) {
    partidaEnTurno = partida;
    notifyListeners();
  }

  Future<SqlResponse> newPartida(Partida partida) async {
    final SqlResponse response = SqlResponse();
    List<Jugador>? jugadores = partida.jugadores;

    if (jugadores == null) {
      response.addMsg('Debe de agregar almenos 2 jugadores a la partida');
      response.hasError = true;
      return response;
    }

    Map<String, dynamic> tempPartidaMap = partida.toMap();

    Fun.removeKeys(tempPartidaMap, ['id', 'jugadores', 'created_at']);
    print("tempPartidaMap: $tempPartidaMap ");

    final SqlResponse partidaRes = await CrudHelper.insert(tableName: 'Partida', body: tempPartidaMap);

    for (var jugador in jugadores) {
      //
      jugador.partidaId = partidaRes.data;

      Map<String, dynamic> tempJugadorMap = jugador.toMap();
      Fun.removeKeys(tempJugadorMap, ['id']);

      final SqlResponse jugadorRes = await CrudHelper.insert(tableName: 'Jugador', body: tempJugadorMap);
      jugador.id = jugadorRes.data;
    }

    partida.id = partidaRes.data;

    response.data = partida;

    partidas.add(partida);
    notifyListeners();

    return response;
  }

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
