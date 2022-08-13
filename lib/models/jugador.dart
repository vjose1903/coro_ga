import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';

class Jugador extends DynamicClass {
  Jugador({this.id, this.nombre, this.puntuacion = 0, this.partidaId, this.historialJugadas});

  static String tableName = "Jugador";
  int? id;
  int? partidaId;
  String? nombre;
  int? puntuacion;
  List<HistorialJugada>? historialJugadas;

  factory Jugador.fromJson(String str) => Jugador.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  @override
  Jugador getClassInstance(Map<String, dynamic> json) {
    return Jugador.fromMap(json);
  }

  @override
  Map<String, dynamic> getMapInstance(Jugador model) {
    return model.toMap();
  }

  factory Jugador.fromMap(Map<String, dynamic> json) => Jugador(
        id: json["id"],
        partidaId: json["partida_id"],
        nombre: json["nombre"],
        puntuacion: json["puntuacion"] ?? 0,
        historialJugadas:
            json["historial_jugadas"] != null ? List<HistorialJugada>.from(json["historial_jugadas"].map((x) => HistorialJugada.fromMap(x))) : [],
      );

  Map<String, dynamic> toMap() => {"id": id, "nombre": nombre, "puntuacion": puntuacion, "partida_id": partidaId};

  Map<String, dynamic> toUpdateMap() => {"nombre": nombre};

  @override
  String toString() {
    return '{"nombre": "$nombre", "puntuacion": $puntuacion, "partidaId": $partidaId, "historialJugadas": $historialJugadas}';
  }

  addHistorial(HistorialJugada historial) {
    historialJugadas ??= [];
    historialJugadas!.add(historial);
  }

  addHistoriales(List<HistorialJugada?> historiales) {
    for (var historial in historiales) {
      addHistorial(historial!);
    }
  }

  static Future<SqlResponse> edit({required Jugador jugador, required String newNombreJugador}) async {
    Map<String, dynamic> tempJugadorMap = jugador.toUpdateMap();
    tempJugadorMap["nombre"] = newNombreJugador;

    final response = await CrudHelper.updateOne(tableName: Jugador.tableName, id: jugador.id, newData: tempJugadorMap, isLoading: true);

    if (response.hasError!) response.addMsg('No se pudo editar el jugador seleccionado.');

    return response;
  }

  static Future<SqlResponse> changePuntuacion(
      {required Jugador jugador, required int newPuntuacion, required String tipo, required bool isLoading}) async {
    //
    final SqlResponse response = SqlResponse();
    Map body = jugador.toMap();

    if (tipo == "aumentar") body["puntuacion"] = body["puntuacion"] + newPuntuacion;
    if (tipo == "reducir") body["puntuacion"] = body["puntuacion"] - newPuntuacion;

    final res = await CrudHelper.updateOne(tableName: Jugador.tableName, id: jugador.id!, newData: body, isLoading: isLoading);

    if (!res.hasError!) {
      final resHistorial = await HistorialJugada.newHistorial(jugadorId: jugador.id!, puntuacion: newPuntuacion, tipo: tipo);

      jugador.addHistorial(resHistorial.data);
      jugador.puntuacion = body["puntuacion"];
      response.data = jugador;
    } else {
      response.addMsgs(res.messages);
    }

    return response;
  }

  static findHistorial({required Jugador jugador, required bool isLoading}) async {
    final response = await CrudHelper.getAll(
      tableName: HistorialJugada.tableName,
      where_: "jugador_id = ?",
      whereArgs_: [jugador.id],
      isLoading: isLoading,
    );

    if (!response.hasError!) {
      final historialesParsed = List<HistorialJugada>.from(response.data.map((x) => HistorialJugada.fromMap(x)));
      jugador.addHistoriales(historialesParsed);
    } else {
      response.addMsg('Partida ingresada no tiene historiales.');
    }
  }

  Future<SqlResponse> delete({required bool isLoading}) async {
    SqlResponse response = SqlResponse();

    response = await CrudHelper.deleteOne(tableName: Jugador.tableName, id: id!, isLoading: isLoading);
    if (!response.hasError!) {
      if (historialJugadas != null && historialJugadas!.isNotEmpty) {
        for (var historial in historialJugadas!) {
          final responseHistorial = await CrudHelper.deleteOne(tableName: HistorialJugada.tableName, id: historial.id!, isLoading: isLoading);

          if (responseHistorial.hasError! && response.messages == null) {
            response.addMsg('Algunos historiales de jugadas, no pudieron ser eliminados');
          }
        }
      }
    } else {
      response.addMsg("Error eliminando al jugador: $nombre");
    }

    return response;
  }
}
