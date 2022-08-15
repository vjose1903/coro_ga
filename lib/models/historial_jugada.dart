import 'dart:convert';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';
import 'package:flutter/material.dart';

class HistorialJugada extends DynamicClass {
  HistorialJugada({this.id, this.jugadorId, this.puntuacion, this.tipo});
  static String tableName = "HistorialJugadas";
  int? id;
  int? jugadorId;
  int? puntuacion;
  String? tipo;

  factory HistorialJugada.fromJson(String str) => HistorialJugada.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory HistorialJugada.fromMap(Map<String, dynamic> json) => HistorialJugada(
        id: json["id"],
        jugadorId: json["jugador_id"],
        tipo: json["tipo"],
        puntuacion: json["puntuacion"],
      );

  Map<String, dynamic> toMap() => {"id": id, "jugador_id": jugadorId, "puntuacion": puntuacion, "tipo": tipo};

  @override
  String toString() {
    return '{"id": "$id", "jugador_id": $jugadorId, "puntuacion": $puntuacion, "tipo": "$tipo"}';
  }

  static Future<SqlResponse> newHistorial({required int jugadorId, required int puntuacion, required String tipo}) async {
    final SqlResponse response = SqlResponse();

    final HistorialJugada historialJugada = HistorialJugada(jugadorId: jugadorId, puntuacion: puntuacion, tipo: tipo);
    Map body = historialJugada.toMap();
    Fun.removeKeys(body, ['id']);

    final res = await CrudHelper.insert(tableName: HistorialJugada.tableName, body: body);

    if (!response.hasError!) {
      historialJugada.id = res.data;
      response.data = historialJugada;
    } else {
      response.addMsg('Error ingresando el historial de la jugada.');
      response.hasError = true;
    }

    return response;
  }
}
