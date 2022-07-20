import 'dart:convert';
import 'package:game_score/models/models.dart';
import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/utils/utils.dart';

class Partida extends DynamicClass {
  Partida({this.nombre, this.jugadores, this.id, this.activo = true, this.createdAt});

  int? id;
  String? nombre;
  bool? activo;
  List<Jugador>? jugadores;
  DateTime? createdAt;

  get cantJugadores {
    if (jugadores == null) return 0;
    return jugadores!.length;
  }

  get isSinIniciar {
    bool inicida = jugadores!.every((jugador) => jugador.puntucacion == 0);
    return inicida;
  }

  get isEmpate {
    bool estado = true;
    if (cantJugadores > 2) estado = jugadores!.every((jugador) => jugador.puntucacion == jugadores!.first.puntucacion);
    if (cantJugadores == 2) estado = jugadores![0].puntucacion == jugadores![1].puntucacion;
    return estado;
  }

  ordenarPorPuntuacion() {
    if (jugadores!.isEmpty) return [];
    jugadores!.sort((a, b) => a.puntucacion!.compareTo(b.puntucacion!));
    return jugadores;
  }

  String getJugadorEstatus(Jugador jugador) {
    String estado = "";

    if (jugador.nombre == getGandorOrPerdedor(tipo: Estado.ganador)) {
      estado = Estado.ganador;
    } else if (jugador.nombre == getGandorOrPerdedor(tipo: Estado.perdedor)) {
      estado = Estado.perdedor;
    } else {
      List<Jugador> empatados = jugadores!.where((judadorEnTurno) => judadorEnTurno.puntucacion == jugador.puntucacion).toList();

      estado = empatados.length > 1 ? Estado.empate : Estado.not;
    }
    return estado;
  }

  getGandorOrPerdedor({required String tipo, bool isEstado = true}) {
    List<Jugador> sortedArray = ordenarPorPuntuacion();
    Jugador selected = tipo == Estado.ganador ? sortedArray.last : sortedArray.first;

    List<Jugador> empatados = jugadores!.where((judador) {
      return judador.id != selected.id && judador.puntucacion == selected.puntucacion;
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
        activo: Fun.toBoolean(json["activo"]),
        createdAt: json["created_at"],
        jugadores: json["jugadores"] != null ? List<Jugador>.from(json["jugadores"].map((x) => Jugador.fromMap(x))) : null,
      );

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "nombre": nombre,
        "created_at": createdAt != null ? createdAt!.toIso8601String() : null,
        "activo": "$activo",
        "jugadores": jugadores != null ? List<dynamic>.from(jugadores!.map((x) => x.toMap())) : [],
      };

  @override
  String toString() {
    return '{"id": $id, "nombre": "$nombre", "activo": $activo, "jugadores": $jugadores}';
  }

  // ==================================================================================================================================
  // ==================================================================================================================================
  // ==================================================================================================================================

  static getPartidas() async {
    final response = await CrudHelper.getAll(tableName: "Partida");

    if (!response.hasError!) {
      final partidasParsed = List<Partida>.from(response.data.map((x) => Partida.fromMap(x)));

      for (var partida in partidasParsed) {
        await findJugadores(partida);
      }
      return partidasParsed;
    } else {
      response.addMsg('No existen partidas registradas.');
      return List<Partida>.from([]);
    }
  }

  static Future<Partida?> getPartidaById(int id) async {
    final response = await CrudHelper.getOne(tableName: "Partida", id: id);

    if (!response.hasError!) {
      final partidaParsed = Partida.fromMap(response.data);

      await findJugadores(partidaParsed);
      return partidaParsed;
    } else {
      response.addMsg('Partida buscada no existe.');
      return null;
    }
  }

  static findJugadores(Partida partida) async {
    final response = await CrudHelper.getAll(tableName: "Jugador", where_: "partida_id = ?", whereArgs_: [partida.id]);
    if (!response.hasError!) {
      final jugadoresParsed = List<Jugador>.from(response.data.map((x) => Jugador.fromMap(x)));
      partida.addJugadores(jugadoresParsed);
    } else {
      response.addMsg('Partida ingresada no tiene jugadores.');
    }
  }
}
