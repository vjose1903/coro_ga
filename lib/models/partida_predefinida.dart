import 'dart:convert';
import 'models.dart';
import '../helpers/helpers.dart';
import '../utils/utils.dart';

class PartidaPredefinida extends DynamicClass {
  factory PartidaPredefinida.fromJson(String str) => PartidaPredefinida.fromMap(json.decode(str));

  factory PartidaPredefinida.fromMap(Map<String, dynamic> json) => PartidaPredefinida(
        id: json["id"],
        nombre: json["nombre"],
        tipo: json["tipo"],
        maxPuntuacion: json["maxPuntuacion"],
        cantidadJugadores: json["cantidadJugadores"],
        orden: json["orden"],
      );
  PartidaPredefinida({this.id, this.nombre, this.tipo, this.maxPuntuacion, this.cantidadJugadores, this.orden});

  static String tableName = 'PartidaPredefinida';

  int? id;
  String? nombre;
  String? tipo;
  int? maxPuntuacion;
  int? cantidadJugadores;
  int? orden;

  String toJson() => json.encode(toMap());

  @override
  PartidaPredefinida getClassInstance(Map<String, dynamic> json) {
    return PartidaPredefinida.fromMap(json);
  }

  @override
  Map<String, dynamic> getMapInstance(PartidaPredefinida model) {
    return model.toMap();
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'maxPuntuacion': maxPuntuacion,
        'cantidadJugadores': cantidadJugadores,
        'orden': orden,
      };

  @override
  String toString() {
    return '{"id": $id, "nombre": "$nombre", "tipo": "$tipo", "maxPuntuacion": $maxPuntuacion, "cantidadJugadores": $cantidadJugadores, "orden": $orden}';
  }

  // ==================================================================================================================================
  // ==================================================================================================================================
  // ==================================================================================================================================

  static createPartidaPredefinida({required PartidaPredefinida partida}) async {
    final SqlResponse response = SqlResponse();

    final Map<String, dynamic> tempPartidaMap = partida.toMap();

    Fun.removeKeys(tempPartidaMap, ['id']);

    final SqlResponse partidaRes = await CrudHelper.insert(tableName: PartidaPredefinida.tableName, body: tempPartidaMap);

    partida.id = partidaRes.data;

    response.data = partida;

    return response;
  }

  static getPartidasPredefinidas() async {
    final response = await CrudHelper.getAll(tableName: PartidaPredefinida.tableName);

    if (!response.hasError!) {
      final partidasParsed = List<PartidaPredefinida>.from(response.data.map((x) => PartidaPredefinida.fromMap(x)));

      return partidasParsed;
    } else {
      response.addMsg(L10n.noGamesRegistered);
      return List<PartidaPredefinida>.from([]);
    }
  }

  static Future<SqlResponse> delete({required PartidaPredefinida partida}) async {
    final response = await CrudHelper.deleteOne(tableName: PartidaPredefinida.tableName, id: partida.id!);

    if (response.hasError!) response.addMsg(L10n.errorDeletingPredefined);

    return response;
  }

  static Future<SqlResponse> edit({required int id, required Map<String, dynamic> partidaEdit}) async {
    final response = await CrudHelper.updateOne(tableName: PartidaPredefinida.tableName, id: id, newData: partidaEdit);

    if (response.hasError!) response.addMsg(L10n.errorEditingPredefined);

    return response;
  }
}
