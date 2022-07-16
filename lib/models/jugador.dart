import 'dart:convert';
import 'package:game_score/helpers/helpers.dart';

class Jugador {
  Jugador({this.id, this.nombre, this.puntucacion = 0, this.partidaId});

  int? id;
  int? partidaId;
  String? nombre;
  int? puntucacion;

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
      );

  Map<String, dynamic> toMap() => {"id": id, "nombre": nombre, "puntucacion": puntucacion, "partida_id": partidaId};

  @override
  String toString() {
    return "nombre: $nombre, puntucacion:$puntucacion, partidaId:$partidaId";
  }
}
