import 'dart:convert';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';

class Jugador extends DynamicClass {
  Jugador({this.id, this.nombre, this.puntucacion = 0, this.partidaId, this.historialJugadas});

  int? id;
  int? partidaId;
  String? nombre;
  int? puntucacion;
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
        puntucacion: json["puntucacion"],
        historialJugadas:
            json["historial_jugadas"] != null ? List<HistorialJugada>.from(json["historial_jugadas"].map((x) => HistorialJugada.fromMap(x))) : [],
      );

  Map<String, dynamic> toMap() => {"id": id, "nombre": nombre, "puntucacion": puntucacion, "partida_id": partidaId};

  @override
  String toString() {
    return '{"nombre": "$nombre", "puntucacion": $puntucacion, "partidaId": $partidaId, "historialJugadas": $historialJugadas}';
  }
}
