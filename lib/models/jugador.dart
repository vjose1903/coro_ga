import 'dart:convert';
import '../helpers/helpers.dart';
import 'models.dart';
import '../utils/utils.dart';

class Jugador extends DynamicClass {
  factory Jugador.fromJson(String str) => Jugador.fromMap(json.decode(str));

  factory Jugador.fromMap(Map<String, dynamic> json) => Jugador(
        id: json["id"],
        partidaId: json["partida_id"],
        nombre: json["nombre"],
        puntuacion: json["puntuacion"] ?? 0,
        historialJugadas: json["historial_jugadas"] != null ? List<HistorialJugada>.from(json["historial_jugadas"].map((x) => HistorialJugada.fromMap(x))) : [],
      );
  Jugador({this.id, this.nombre, this.puntuacion = 0, this.partidaId, this.historialJugadas});

  static String tableName = 'Jugador';
  int? id;
  int? partidaId;
  String? nombre;
  int? puntuacion;
  List<HistorialJugada>? historialJugadas;

  String toJson() => json.encode(toMap());

  @override
  Jugador getClassInstance(Map<String, dynamic> json) {
    return Jugador.fromMap(json);
  }

  @override
  Map<String, dynamic> getMapInstance(Jugador model) {
    return model.toMap();
  }

  @override
  Map<String, dynamic> toMap() => {'id': id, 'nombre': nombre, 'puntuacion': puntuacion, 'partida_id': partidaId};

  Map<String, dynamic> toUpdateMap() => {'nombre': nombre};

  @override
  String toString() {
    return '{"id": $id, "nombre": "$nombre", "puntuacion": $puntuacion, "partidaId": $partidaId, "historialJugadas": $historialJugadas}';
  }

  addHistorial(HistorialJugada historial) {
    historialJugadas ??= [];
    historialJugadas!.add(historial);
  }

  addHistoriales(List<HistorialJugada?> historiales) {
    for (final historial in historiales) {
      addHistorial(historial!);
    }
  }

  static Future<SqlResponse> edit({required Jugador jugador, required String newNombreJugador}) async {
    final Map<String, dynamic> tempJugadorMap = jugador.toUpdateMap();
    tempJugadorMap['nombre'] = newNombreJugador;

    final response = await CrudHelper.updateOne(tableName: Jugador.tableName, id: jugador.id, newData: tempJugadorMap);

    if (response.hasError!) response.addMsg(L10n.errorEditingPlayer);

    return response;
  }

  static Future<SqlResponse> changePuntuacion({required Jugador jugador, required int newPuntuacion, required String tipo, required Map newData}) async {
    //
    final SqlResponse response = SqlResponse();

    final res = await CrudHelper.updateOne(tableName: Jugador.tableName, id: jugador.id!, newData: newData);

    if (!res.hasError!) {
      final resHistorial = await HistorialJugada.newHistorial(jugadorId: jugador.id!, puntuacion: newPuntuacion, tipo: tipo);

      response.data = {'historial': resHistorial.data, 'newPuntuacion': newData['puntuacion']};
    } else {
      response.addMsgs(res.messages);
    }

    return response;
  }

  static Future<SqlResponse> deleteHistorial({required Jugador jugador, required HistorialJugada historial}) async {
    final SqlResponse response = SqlResponse();

    final res = await CrudHelper.deleteOne(tableName: HistorialJugada.tableName, id: historial.id!);

    if (!res.hasError!) {
      jugador.historialJugadas!.remove(historial);
      final int newPuntuacion = historial.tipo == 'aumentar' ? jugador.puntuacion! - historial.puntuacion! : jugador.puntuacion! + historial.puntuacion!;

      await CrudHelper.updateOne(tableName: Jugador.tableName, id: jugador.id!, newData: {'puntuacion': newPuntuacion});

      response.data = {'newPuntuacion': newPuntuacion};
    } else {
      response.hasError = true;
      response.addMsg(L10n.errorDeletingHistory);
    }

    return response;
  }

  static findHistorial({required Jugador jugador}) async {
    final response = await CrudHelper.getAll(
      tableName: HistorialJugada.tableName,
      where_: 'jugador_id = ?',
      whereArgs_: [jugador.id],
    );

    if (!response.hasError!) {
      final historialesParsed = List<HistorialJugada>.from(response.data.map((x) => HistorialJugada.fromMap(x)));
      jugador.addHistoriales(historialesParsed);
    } else {
      response.addMsg(L10n.noHistoryForGame);
    }
  }

  Future<SqlResponse> delete() async {
    SqlResponse response = SqlResponse();

    response = await CrudHelper.deleteOne(tableName: Jugador.tableName, id: id!);
    if (!response.hasError!) {
      if (historialJugadas != null && historialJugadas!.isNotEmpty) {
        for (final historial in historialJugadas!) {
          final responseHistorial = await CrudHelper.deleteOne(tableName: HistorialJugada.tableName, id: historial.id!);

          if (responseHistorial.hasError! && response.messages == null) {
            response.addMsg(L10n.someHistoryNotDeleted);
          }
        }
      }
    } else {
      response.addMsg(L10n.errorDeletingPlayerName(nombre!));
    }

    return response;
  }
}
