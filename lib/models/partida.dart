// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/utils/utils.dart';


class Partida extends DynamicClass {
  Partida({this.nombre, this.jugadores, this.id, this.activo = true, this.createdAt, this.tipo, this.maxPuntuacion});

  static String tableName = "Partida";

  int? id;
  String? nombre;
  String? tipo;
  bool? activo;
  List<Jugador>? jugadores;
  DateTime? createdAt;
  int? maxPuntuacion;

  get cantJugadores {
    if (jugadores == null) return 0;

    return jugadores!.length;
  }

  get isSinIniciar {
    bool inicida = jugadores!.every((jugador) => jugador.puntuacion == 0);
    return inicida;
  }

  get isEmpate {
    bool estado = true;
    if (cantJugadores > 2) estado = jugadores!.every((jugador) => jugador.puntuacion == jugadores!.first.puntuacion);
    if (cantJugadores == 2) estado = jugadores![0].puntuacion == jugadores![1].puntuacion;
    return estado;
  }

  ordenarPorPuntuacion() {
    if (jugadores!.isEmpty) return [];
    jugadores!.sort((a, b) => a.puntuacion!.compareTo(b.puntuacion!));
    return jugadores;
  }

  String getJugadorEstatus(Jugador jugador) {
    String estado = "";

    if (jugador.nombre == getGandorOrPerdedor(tipo: Estado.ganador)) {
      estado = Estado.ganador;
    } else if (jugador.nombre == getGandorOrPerdedor(tipo: Estado.perdedor)) {
      estado = Estado.perdedor;
    } else {
      List<Jugador> empatados = jugadores!.where((judadorEnTurno) => judadorEnTurno.puntuacion == jugador.puntuacion).toList();

      estado = empatados.length > 1 ? Estado.empate : Estado.not;
    }
    return estado;
  }

  getGandorOrPerdedor({required String tipo}) {
    List<Jugador> sortedArray = ordenarPorPuntuacion();
    Jugador selected = tipo == Estado.ganador ? sortedArray.last : sortedArray.first;

    List<Jugador> empatados = jugadores!.where((judador) {
      return judador.id != selected.id && judador.puntuacion == selected.puntuacion;
    }).toList();

    return empatados.isNotEmpty ? Estado.empate : selected.nombre;
  }

  addJugador(Jugador jugador) {
    jugadores ??= [];
    jugadores!.add(jugador);
  }

  addJugadores(List<Jugador?> jugadores) {
    for (var jugador in jugadores) {
      addJugador(jugador!);
    }
  }

  factory Partida.fromJson(String str) => Partida.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  @override
  Partida getClassInstance(Map<String, dynamic> json) {
    return Partida.fromMap(json);
  }

  @override
  Map<String, dynamic> getMapInstance(Partida model) {
    return model.toMap();
  }

  factory Partida.fromMap(Map<String, dynamic> json) => Partida(
        id: json["id"],
        nombre: json["nombre"],
        tipo: json["tipo"],
        maxPuntuacion: json["maxPuntuacion"],
        activo: Fun.toBoolean(json["activo"]),
        createdAt: json["created_at"],
        jugadores: json["jugadores"] != null ? List<Jugador>.from(json["jugadores"].map((x) => Jugador.fromMap(x))) : null,
      );

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "nombre": nombre,
        "tipo": tipo,
        "maxPuntuacion": maxPuntuacion,
        "createdAt": createdAt != null ? createdAt!.toIso8601String() : null,
        "activo": "$activo",
        "jugadores": jugadores != null ? List<dynamic>.from(jugadores!.map((x) => x.toMap())) : [],
      };

  Map<String, dynamic> toUpdateMap() => {
        "id": id,
        "nombre": nombre,
        // "tipo": tipo,
        "activo": "$activo",
      };

  @override
  String toString() {
    return '{"id": $id, "nombre": "$nombre", "activo": $activo, "tipo": "$tipo", "jugadores": $jugadores. "maxPuntuacion": $maxPuntuacion}';
  }

  // ==================================================================================================================================
  // ==================================================================================================================================
  // ==================================================================================================================================

  static createPartida(BuildContext context, {required Partida partida}) async {
    final SqlResponse response = SqlResponse();
    List<Jugador>? jugadores = partida.jugadores;

    if (jugadores == null) {
      response.addMsg('Debe de agregar almenos 2 jugadores a la partida');
      response.hasError = true;
      return response;
    }

    Map<String, dynamic> tempPartidaMap = partida.toMap();

    Fun.removeKeys(tempPartidaMap, ['id', 'jugadores', 'createdAt']);

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

    return response;
  }

  static Future<SqlResponse> addNewJugador(BuildContext context, {required Partida partida, required Jugador jugador}) async {
    jugador.partidaId = partida.id;

    Map<String, dynamic> tempJugadorMap = jugador.toMap();
    Fun.removeKeys(tempJugadorMap, ['id']);

    final SqlResponse response = await CrudHelper.insert(tableName: Jugador.tableName, body: tempJugadorMap, context: context);
    jugador.id = response.data;
    partida.addJugador(jugador);
    response.data = partida;
    return response;
  }

  static getPartidas(BuildContext context, {required bool isLoading}) async {
    final response =
        await CrudHelper.getAll(tableName: Partida.tableName, context: context, where_: "activo = ?", whereArgs_: ["true"], isLoading: isLoading);

    if (!response.hasError!) {
      final partidasParsed = List<Partida>.from(response.data.map((x) => Partida.fromMap(x)));

      for (var partida in partidasParsed) {
        await findJugadores(partida: partida, context: context, isLoading: isLoading);
      }
      return partidasParsed;
    } else {
      response.addMsg('No existen partidas registradas.');
      return List<Partida>.from([]);
    }
  }

  static Future<Partida?> getPartidaById(int id, {required BuildContext context, required bool isLoading}) async {
    final response = await CrudHelper.getOne(tableName: Partida.tableName, id: id, context: context);

    if (!response.hasError!) {
      final partidaParsed = Partida.fromMap(response.data);

      await findJugadores(partida: partidaParsed, context: context, isLoading: isLoading);
      return partidaParsed;
    } else {
      response.addMsg('Partida buscada no existe.');
      return null;
    }
  }

  static Future<SqlResponse> delete(BuildContext context, {required Partida partida, required bool isLoading}) async {
    Map<String, dynamic> tempPartidaMap = partida.toUpdateMap();
    tempPartidaMap["activo"] = "false";

    final response =
        await CrudHelper.updateOne(tableName: Partida.tableName, id: partida.id, newData: tempPartidaMap, context: context, isLoading: isLoading);

    if (response.hasError!) response.addMsg('No se pudo borrar la partida seleccionada.');

    return response;
  }

  static Future<SqlResponse> edit(BuildContext context, {required Partida partida, required String newNombrePartida}) async {
    Map<String, dynamic> tempPartidaMap = partida.toUpdateMap();
    tempPartidaMap["nombre"] = newNombrePartida;

    final response =
        await CrudHelper.updateOne(tableName: Partida.tableName, id: partida.id, newData: tempPartidaMap, context: context, isLoading: true);

    if (response.hasError!) response.addMsg('No se pudo editar la partida seleccionada.');

    return response;
  }

  static findJugadores({required Partida partida, required BuildContext context, required bool isLoading}) async {
    final response = await CrudHelper.getAll(
        tableName: Jugador.tableName, where_: "partida_id = ?", whereArgs_: [partida.id], context: context, isLoading: isLoading);

    if (!response.hasError!) {
      final jugadoresParsed = List<Jugador>.from(response.data.map((x) => Jugador.fromMap(x)));

      for (var jugador in jugadoresParsed) {
        await Jugador.findHistorial(jugador: jugador, context: context, isLoading: isLoading);
      }

      partida.addJugadores(jugadoresParsed);
    } else {
      response.addMsg('Partida ingresada no tiene jugadores.');
    }
  }
}
