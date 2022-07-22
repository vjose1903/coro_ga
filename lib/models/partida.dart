// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/utils/utils.dart';

class Partida extends DynamicClass {
  Partida({this.nombre, this.jugadores, this.id, this.activo = true, this.createdAt, this.tipo});

  static String tableName = "Partida";

  int? id;
  String? nombre;
  String? tipo;
  bool? activo;
  List<Jugador>? jugadores;
  DateTime? createdAt;

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

  getGandorOrPerdedor({required String tipo, bool isEstado = true}) {
    List<Jugador> sortedArray = ordenarPorPuntuacion();
    Jugador selected = tipo == Estado.ganador ? sortedArray.last : sortedArray.first;

    List<Jugador> empatados = jugadores!.where((judador) {
      return judador.id != selected.id && judador.puntuacion == selected.puntuacion;
    }).toList();
    String? empate = isEstado ? Estado.empate : selected.nombre;

    return empatados.isNotEmpty ? empate : selected.nombre;
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
        activo: Fun.toBoolean(json["activo"]),
        createdAt: json["created_at"],
        jugadores: json["jugadores"] != null ? List<Jugador>.from(json["jugadores"].map((x) => Jugador.fromMap(x))) : null,
      );

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "nombre": nombre,
        "tipo": tipo,
        "created_at": createdAt != null ? createdAt!.toIso8601String() : null,
        "activo": "$activo",
        "jugadores": jugadores != null ? List<dynamic>.from(jugadores!.map((x) => x.toMap())) : [],
      };

  @override
  String toString() {
    return '{"id": $id, "nombre": "$nombre", "activo": $activo, "tipo": "$tipo", "jugadores": $jugadores}';
  }

  // ==================================================================================================================================
  // ==================================================================================================================================
  // ==================================================================================================================================

  static getPartidas(BuildContext context, {required bool isLoading}) async {
    final response = await CrudHelper.getAll(tableName: Partida.tableName, context: context, isLoading: isLoading);

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
