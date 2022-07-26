// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:reactive_forms/reactive_forms.dart';

class PartidasProvider extends ChangeNotifier {
  List<Partida> partidas = [];
  Partida? partidaEnTurno;
  FormGroup? formPartida;

  FormGroup formAddJugador = fb.group({
    'nombre': ['', Validators.required]
  });

  void navigateToPartida({required Partida partida, required BuildContext context}) {
    partidaEnTurno = partida;
    Navigator.pushNamed(context, 'partida');
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
    final response = await Partida.createPartida(context, partida: partida);
    Partida newPartida = response.data;

    partidas.add(newPartida);
    notifyListeners();

    return response;
  }

  Future<Partida> addJugadorToPartida(BuildContext context, {required Partida partida, required Jugador jugador}) async {
    final response = await Partida.addNewJugador(context, partida: partida, jugador: jugador);

    notifyListeners();

    return response.data;
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
