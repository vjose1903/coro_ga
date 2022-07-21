import 'dart:convert';
import 'package:game_score/utils/utils.dart';

class HistorialJugada extends DynamicClass {
  HistorialJugada({this.id, this.jugadorId, this.puntucacion});

  int? id;
  int? jugadorId;
  int? puntucacion;

  factory HistorialJugada.fromJson(String str) => HistorialJugada.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory HistorialJugada.fromMap(Map<String, dynamic> json) => HistorialJugada(
        id: json["id"],
        jugadorId: json["jugador_id"],
        puntucacion: json["puntucacion"],
      );

  Map<String, dynamic> toMap() => {"id": id, "jugador_id": jugadorId, "puntucacion": puntucacion};

  @override
  String toString() {
    return '{"id": "$id", "jugador_id": $jugadorId, "puntucacion": $puntucacion}';
  }
}
