import 'dart:convert';

import '../helpers/helpers.dart';
import 'models.dart';

class PartidaFinalizada {
  PartidaFinalizada({
    this.id,
    this.nombre,
    this.tipo,
    this.maxPuntuacion,
    this.jugadoresFinales,
    this.ganador,
    this.motivo,
    this.finalizadaAt,
  });

  factory PartidaFinalizada.fromMap(Map<String, dynamic> json) {
    final jugadoresRaw = json['jugadoresFinales'] ?? json['jugadores_finales'];
    List<Map<String, dynamic>> jugadoresParsed = [];
    if (jugadoresRaw is String && jugadoresRaw.isNotEmpty) {
      final decoded = jsonDecode(jugadoresRaw);
      if (decoded is List) {
        jugadoresParsed =
            decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } else if (jugadoresRaw is List) {
      jugadoresParsed =
          jugadoresRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    final finalizadaAtRaw =
        json['finalizadaAt'] ?? json['finalizada_at'] ?? json['finalizadaAt'];
    return PartidaFinalizada(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      maxPuntuacion: json['maxPuntuacion'] ?? json['max_puntuacion'],
      jugadoresFinales: jugadoresParsed,
      ganador: json['ganador'],
      motivo: json['motivo'],
      finalizadaAt: finalizadaAtRaw != null
          ? DateTime.tryParse(finalizadaAtRaw.toString())
          : null,
    );
  }

  static String tableName = 'PartidaFinalizada';

  int? id;
  String? nombre;
  String? tipo;
  int? maxPuntuacion;
  List<Map<String, dynamic>>? jugadoresFinales;
  String? ganador;
  String? motivo;
  DateTime? finalizadaAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'maxPuntuacion': maxPuntuacion,
        'jugadoresFinales': jsonEncode(jugadoresFinales ?? []),
        'ganador': ganador,
        'motivo': motivo,
        'finalizadaAt': finalizadaAt?.toIso8601String(),
      };

  Map<String, dynamic> toInsertMap() => {
        'nombre': nombre,
        'tipo': tipo,
        'maxPuntuacion': maxPuntuacion,
        'jugadoresFinales': jsonEncode(jugadoresFinales ?? []),
        'ganador': ganador,
        'motivo': motivo,
      };

  String? getGanadorFromJugadores() {
    if (jugadoresFinales == null || jugadoresFinales!.isEmpty) return null;
    final sorted = List<Map<String, dynamic>>.from(jugadoresFinales!)
      ..sort((a, b) => ((a['puntuacion'] ?? 0) as num)
          .compareTo((b['puntuacion'] ?? 0) as num));
    return sorted.last['nombre']?.toString();
  }

  Partida toPartidaForRematch() {
    final jugadores = (jugadoresFinales ?? [])
        .map(
          (item) => Jugador(
            nombre: item['nombre']?.toString(),
            historialJugadas: [],
          ),
        )
        .toList();
    return Partida(
      nombre: nombre,
      tipo: tipo,
      maxPuntuacion: maxPuntuacion,
      jugadores: jugadores,
    );
  }

  static Future<SqlResponse> createFromPartida({
    required Partida partida,
    String? ganadorNombre,
    String? motivo,
  }) async {
    final response = SqlResponse();

    final jugadores = (partida.jugadores ?? [])
        .map(
          (jugador) => {
            'id': jugador.id,
            'nombre': jugador.nombre,
            'puntuacion': jugador.puntuacion ?? 0,
          },
        )
        .toList();

    final snapshot = PartidaFinalizada(
      nombre: partida.nombre ?? 'Partida',
      tipo: partida.tipo,
      maxPuntuacion: partida.maxPuntuacion,
      jugadoresFinales: jugadores,
      ganador: ganadorNombre,
      motivo: motivo,
    );

    final insertRes = await CrudHelper.insert(
      tableName: PartidaFinalizada.tableName,
      body: snapshot.toInsertMap(),
    );

    if (insertRes.hasError!) {
      response.hasError = true;
      response.addMsgs(insertRes.messages);
      return response;
    }

    final getRes = await CrudHelper.getOne(
      tableName: PartidaFinalizada.tableName,
      id: insertRes.data as int,
    );

    if (getRes.hasError!) {
      response.hasError = true;
      response.addMsg('No se pudo obtener la partida finalizada guardada.');
      return response;
    }

    response.data = PartidaFinalizada.fromMap(getRes.data);
    return response;
  }

  static Future<PartidaFinalizada?> findById(int id) async {
    final response =
        await CrudHelper.getOne(tableName: PartidaFinalizada.tableName, id: id);
    if (response.hasError!) return null;
    return PartidaFinalizada.fromMap(response.data);
  }
}
