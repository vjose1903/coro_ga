import 'dart:convert';
import '../helpers/helpers.dart';
import '../utils/utils.dart';
import 'models.dart';

class HistorialJugada extends DynamicClass {

  factory HistorialJugada.fromJson(String str) => HistorialJugada.fromMap(json.decode(str));

  factory HistorialJugada.fromMap(Map<String, dynamic> json) => HistorialJugada(
        id: json['id'],
        jugadorId: json['jugador_id'],
        tipo: json['tipo'],
        puntuacion: json['puntuacion'],
      );
  HistorialJugada({this.id, this.jugadorId, this.puntuacion, this.tipo});
  static String tableName = 'HistorialJugadas';
  int? id;
  int? jugadorId;
  int? puntuacion;
  String? tipo;

  String toJson() => json.encode(toMap());

  @override
  Map<String, dynamic> toMap() => {'id': id, 'jugador_id': jugadorId, 'puntuacion': puntuacion, 'tipo': tipo};

  @override
  String toString() {
    return '{"id": "$id", "jugador_id": $jugadorId, "puntuacion": $puntuacion, "tipo": "$tipo"}';
  }

  static Future<SqlResponse> newHistorial({required int jugadorId, required int puntuacion, required String tipo}) async {
    final SqlResponse response = SqlResponse();

    final HistorialJugada historialJugada = HistorialJugada(jugadorId: jugadorId, puntuacion: puntuacion, tipo: tipo);
    final Map body = historialJugada.toMap();
    Fun.removeKeys(body, ['id']);

    final res = await CrudHelper.insert(tableName: HistorialJugada.tableName, body: body);

    if (!response.hasError!) {
      historialJugada.id = res.data;
      response.data = historialJugada;
    } else {
      response.addMsg(L10n.errorInsertingHistory);
      response.hasError = true;
    }

    return response;
  }
}
