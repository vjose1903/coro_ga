import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/providers/providers.dart';
import 'package:game_score/utils/utils.dart';

class JugadorProvider extends ChangeNotifier {
  List<Partida> partidas = [];

  // getPartidas() async {
  //   // final SqlResponse response = SqlResponse();

  //   partidas = await getAll();

  //   for (var partida in partidas) {
  //     final jugadores = await getAll(where_: "partida_id = ?", whereArgs_: [partida.id]);
  //     partida.key = UniqueKey();
  //     print(partida);
  //     partida.addJugadores(jugadores);
  //   }

  //   notifyListeners();
  //   // return response;
  //   // partidas
  // }

  // Future<List<Jugador>> getAllJugadores({List? whereArgs_, String? where_}) async {
  //   final db = await CrudHelper.database;
  //   final List<dynamic> res;

  //   if (where_ != null && whereArgs_ != null) {
  //     res = await db.query('Jugador', where: where_, whereArgs: whereArgs_);
  //   } else {
  //     res = await db.query('Jugador');
  //   }

  //   final List<Jugador> decodedRes = res.isNotEmpty ? res.map((item) => Jugador.fromMap(item)).toList() : [];

  //   return decodedRes;
  // }
}
