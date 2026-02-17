// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';

import '../helpers/helpers.dart';
import '../utils/utils.dart';
import 'models.dart';

class Partida extends DynamicClass {
  Partida({this.nombre, this.jugadores, this.id, this.activo = true, this.createdAt, this.tipo, this.maxPuntuacion});

  factory Partida.fromJson(String str) => Partida.fromMap(json.decode(str));

  factory Partida.fromMap(Map<String, dynamic> json) => Partida(
        id: json['id'],
        nombre: json['nombre'],
        tipo: json['tipo'],
        maxPuntuacion: json['maxPuntuacion'],
        activo: Fun.toBoolean(json['activo']),
        createdAt: json['created_at'],
        jugadores: json['jugadores'] != null ? List<Jugador>.from(json['jugadores'].map((x) => Jugador.fromMap(x))) : null,
      );

  static String tableName = 'Partida';

  int? id;
  String? nombre;
  String? tipo;
  bool? activo;
  List<Jugador>? jugadores;
  DateTime? createdAt;
  int? maxPuntuacion;

  bool get tieneMaxPuntuacion => (maxPuntuacion ?? 0) > 0;
  bool get esSinMaxPuntuacion => !tieneMaxPuntuacion;

  int get cantJugadores {
    if (jugadores == null) return 0;

    return jugadores!.length;
  }

  bool get isSinIniciar {
    final bool inicida = jugadores!.every((jugador) => jugador.puntuacion == 0);
    return inicida;
  }

  bool get isEmpate {
    bool estado = true;
    if (cantJugadores > 2) {
      estado = jugadores!.every((jugador) => jugador.puntuacion == jugadores!.first.puntuacion);
    }
    if (cantJugadores == 2) {
      estado = jugadores![0].puntuacion == jugadores![1].puntuacion;
    }
    return estado;
  }

  List<dynamic> get jugadoresMap {
    return jugadores != null ? List<dynamic>.from(jugadores!.map((x) => x.toMap())) : [];
  }

  List<Jugador> get jugadoresSort {
    final List<Jugador> currentJugadores = jugadores ?? <Jugador>[];
    if (!Fun.arraySortedOrNot(jugadoresMap, 'id')) {
      currentJugadores.sort((a, b) => a.id!.compareTo(b.id!));
    }

    return currentJugadores;
  }

  List<Jugador> ordenarPorPuntuacion() {
    final List<Jugador> currentJugadores = jugadores ?? <Jugador>[];
    if (currentJugadores.isEmpty) return <Jugador>[];
    currentJugadores.sort((a, b) => a.puntuacion!.compareTo(b.puntuacion!));
    return currentJugadores;
  }

  String getJugadorEstatus(Jugador jugador) {
    String estado = '';

    if (jugador.nombre == getGandorOrPerdedorName(tipo: Estado.ganador)) {
      estado = Estado.ganador;
    } else if (jugador.nombre == getGandorOrPerdedorName(tipo: Estado.perdedor)) {
      estado = Estado.perdedor;
    } else {
      final List<Jugador> empatados = jugadores!.where((judadorEnTurno) => judadorEnTurno.puntuacion == jugador.puntuacion).toList();

      estado = empatados.length > 1 ? Estado.empate : Estado.not;
    }
    return estado;
  }

  String getGandorOrPerdedorName({required String tipo}) {
    final List<Jugador> sortedArray = ordenarPorPuntuacion();
    final Jugador selected = tipo == Estado.ganador ? sortedArray.last : sortedArray.first;

    final List<Jugador> empatados = jugadores!.where((judador) {
      return judador.id != selected.id && judador.puntuacion == selected.puntuacion;
    }).toList();

    return empatados.isNotEmpty ? Estado.empate : (selected.nombre ?? '');
  }

  /// Retorna {nombre, puntuacion} del ganador/perdedor o del empate
  Map<String, dynamic> getGanadorOrPerdedor({required String tipo}) {
    final List<Jugador> sortedArray = ordenarPorPuntuacion();
    final Jugador selected = tipo == Estado.ganador ? sortedArray.last : sortedArray.first;

    final List<Jugador> empatados = jugadores!.where((judador) {
      return judador.id != selected.id && judador.puntuacion == selected.puntuacion;
    }).toList();

    return {
      'nombre': empatados.isNotEmpty ? Estado.empate : selected.nombre,
      'puntuacion': selected.puntuacion,
    };
  }

  Future<void> restartPartida() async {
    if (jugadores == null) return;
    for (final jugador in jugadores!) {
      jugador.puntuacion = 0;
      if (jugador.historialJugadas != null && jugador.historialJugadas!.isNotEmpty) {
        for (final historial in jugador.historialJugadas!) {
          await CrudHelper.deleteOne(tableName: HistorialJugada.tableName, id: historial.id!);
        }
        jugador.historialJugadas!.clear();
      }
      await CrudHelper.updateOne(tableName: Jugador.tableName, id: jugador.id!, newData: {'puntuacion': 0});
    }
  }

  void addJugador(Jugador jugador) {
    jugadores ??= [];
    jugadores!.add(jugador);
  }

  void addJugadores(List<Jugador?> jugadores) {
    for (final jugador in jugadores) {
      addJugador(jugador!);
    }
  }

  String toJson() => json.encode(toMap());

  Partida getClassInstance(Map<String, dynamic> json) {
    return Partida.fromMap(json);
  }

  Map<String, dynamic> getMapInstance(Partida model) {
    return model.toMap();
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'maxPuntuacion': maxPuntuacion,
        'createdAt': createdAt?.toIso8601String(),
        'activo': '$activo',
        'jugadores': jugadores != null ? List<dynamic>.from(jugadores!.map((x) => x.toMap())) : [],
      };

  Map<String, dynamic> toUpdateMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'maxPuntuacion': maxPuntuacion,
        'activo': '$activo',
      };

  @override
  String toString() {
    return '{"id": $id, "nombre": "$nombre", "activo": $activo, "tipo": "$tipo", "jugadores": $jugadores, "maxPuntuacion": $maxPuntuacion}';
  }

  // ==================================================================================================================================
  // ==================================================================================================================================
  // ==================================================================================================================================

  static Future<SqlResponse> createPartida(BuildContext context, {required Partida partida}) async {
    final SqlResponse response = SqlResponse();
    final List<Jugador>? jugadores = partida.jugadores;

    if (jugadores == null) {
      response.addMsg(L10n.minTwoPlayers);
      response.hasError = true;
      return response;
    }

    final Map<String, dynamic> tempPartidaMap = partida.toMap();

    Fun.removeKeys(tempPartidaMap, ['id', 'jugadores', 'createdAt']);

    final SqlResponse partidaRes = await CrudHelper.insert(tableName: Partida.tableName, body: tempPartidaMap);

    for (final jugador in jugadores) {
      //
      jugador.partidaId = partidaRes.data;

      final Map<String, dynamic> tempJugadorMap = jugador.toMap();
      Fun.removeKeys(tempJugadorMap, ['id', 'historialJugadas']);

      final SqlResponse jugadorRes = await CrudHelper.insert(tableName: Jugador.tableName, body: tempJugadorMap);
      jugador.historialJugadas = [];
      jugador.id = jugadorRes.data;
    }

    partida.id = partidaRes.data;

    response.data = partida;

    return response;
  }

  static Future<SqlResponse> addNewJugador({required Partida partida, required Jugador jugador}) async {
    jugador.partidaId = partida.id;

    final Map<String, dynamic> tempJugadorMap = jugador.toMap();
    Fun.removeKeys(tempJugadorMap, ['id']);

    final SqlResponse response = await CrudHelper.insert(tableName: Jugador.tableName, body: tempJugadorMap);
    jugador.id = response.data;
    partida.addJugador(jugador);
    response.data = partida;
    return response;
  }

  static Future<List<Partida>> getPartidas() async {
    final response = await CrudHelper.getAll(tableName: Partida.tableName, where_: 'activo = ?', whereArgs_: ['true']);

    if (!response.hasError!) {
      final partidasParsed = List<Partida>.from(response.data.map((x) => Partida.fromMap(x)));

      // Ejecutar todas las consultas de jugadores en paralelo
      await Future.wait(partidasParsed.map((partida) => findJugadores(partida: partida)));

      return partidasParsed;
    } else {
      response.addMsg(L10n.noGamesRegistered);
      return List<Partida>.from([]);
    }
  }

  static Future<SqlResponse> delete({required Partida partida}) async {
    final Map<String, dynamic> tempPartidaMap = partida.toUpdateMap();
    tempPartidaMap['activo'] = 'false';

    final response = await CrudHelper.updateOne(tableName: Partida.tableName, id: partida.id, newData: tempPartidaMap);

    if (response.hasError!) response.addMsg(L10n.errorDeletingGame);

    return response;
  }

  static Future<SqlResponse> edit({required Partida partida, required String newNombrePartida}) async {
    final Map<String, dynamic> tempPartidaMap = partida.toUpdateMap();
    tempPartidaMap['nombre'] = newNombrePartida;

    final response = await CrudHelper.updateOne(tableName: Partida.tableName, id: partida.id, newData: tempPartidaMap);

    if (response.hasError!) response.addMsg(L10n.errorEditingGame);

    return response;
  }

  static Future<void> findJugadores({required Partida partida}) async {
    final response = await CrudHelper.getAll(tableName: Jugador.tableName, where_: 'partida_id = ?', whereArgs_: [partida.id]);

    if (!response.hasError!) {
      final jugadoresParsed = List<Jugador>.from(response.data.map((x) => Jugador.fromMap(x)));

      // Ejecutar todas las consultas de historial en paralelo
      await Future.wait(jugadoresParsed.map((jugador) => Jugador.findHistorial(jugador: jugador)));

      partida.addJugadores(jugadoresParsed);
    } else {
      response.addMsg(L10n.noPlayersForGame);
    }
  }
}
