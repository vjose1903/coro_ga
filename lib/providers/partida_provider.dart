// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/utils/utils.dart';
import 'package:provider/provider.dart';

class PartidasProvider extends ChangeNotifier {
  List<Partida> partidas = [];
  Partida? partidaEnTurno;

  void navigateToPartida({required Partida partida, required BuildContext context}) {
    partidaEnTurno = partida;
    Navigator.pushNamed(context, 'partida').then((value) {
      final WeSlideProvider WeSliderProvider = context.read<WeSlideProvider>();
      WeSliderProvider.refresh();
    });
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  void changePartidaEnTurno(Partida partida) {
    partidaEnTurno = partida;
    notifyListeners();
  }

  Future<SqlResponse> newPartida(Partida partida, BuildContext context) async {
    final SqlResponse response = SqlResponse();
    List<Jugador>? jugadores = partida.jugadores;

    if (jugadores == null) {
      response.addMsg('Debe de agregar almenos 2 jugadores a la partida');
      response.hasError = true;
      return response;
    }

    Map<String, dynamic> tempPartidaMap = partida.toMap();

    Fun.removeKeys(tempPartidaMap, ['id', 'jugadores', 'created_at']);

    final SqlResponse partidaRes = await CrudHelper.insert(tableName: Partida.tableName, body: tempPartidaMap, context: context);

    for (var jugador in jugadores) {
      //
      jugador.partidaId = partidaRes.data;

      Map<String, dynamic> tempJugadorMap = jugador.toMap();
      Fun.removeKeys(tempJugadorMap, ['id']);

      final SqlResponse jugadorRes = await CrudHelper.insert(tableName: Jugador.tableName, body: tempJugadorMap, context: context);
      jugador.id = jugadorRes.data;
    }

    partida.id = partidaRes.data;

    response.data = partida;

    partidas.add(partida);
    notifyListeners();

    return response;
  }

  getPartidas(BuildContext context, {required bool isLoading}) async {
    await Future.delayed(const Duration(microseconds: 100));

    final partidasFuture = Partida.getPartidas(context, isLoading: isLoading);

    partidas = await partidasFuture;

    notifyListeners();
    return partidasFuture;
  }

  Future<Partida?> getPartidaById(int? id, BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    late Partida? partida;

    if (id == null) {
      partida = Partida(nombre: '', jugadores: [Jugador(nombre: ''), Jugador(nombre: '')]);
    } else {
      partida = await Partida.getPartidaById(id, context: context, isLoading: false);
    }

    return partida;
  }
}
