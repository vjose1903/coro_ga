import 'package:game_score/helpers/helpers.dart';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';

class CrudHelper {
  static Future<SqlResponse> insert({required String tableName, required dynamic body}) async {
    final response = SqlResponse();
    // obtener instancia de la base de datos
    final db = await DatabaseHelper.database;

    // Inserta en la base de datos
    final res = await db.insert(tableName, body);
    if (res > 0) {
      response.data = res;
    } else {
      response.hasError = true;
      response.addMsg('Error ingresando registro');
    }

    return response;
  }

  static Future<SqlResponse> getOne({required String tableName, required int? id, List? whereArgs_, String? where_ = 'id = ?'}) async {
    final response = SqlResponse();

    whereArgs_ ??= [id];
    // obtener instancia de la base de datos
    final db = await DatabaseHelper.database;

    // Inserta en la base de datos
    final res = await db.query(tableName, where: where_, whereArgs: whereArgs_);

    if (res.isNotEmpty) {
      response.data = res.first;
    } else {
      response.hasError = true;
    }

    return response;
  }

  static Future<SqlResponse> getAll({required String tableName, List? whereArgs_, String? where_}) async {
    final response = SqlResponse();
    response.data = [];

    final db = await DatabaseHelper.database;
    final List<dynamic> res;

    if (where_ != null && whereArgs_ != null) {
      res = await db.query(tableName, where: where_, whereArgs: whereArgs_);
    } else {
      res = await db.query(tableName);
    }

    final List<dynamic> decodedRes = res.isNotEmpty ? res : [];

    response.data = decodedRes;
    if (res.isEmpty) response.hasError = true;

    return response;
  }

  static Future<SqlResponse> updateOne(
      {required String tableName, required int id, required dynamic newData, List? whereArgs_, String? where_ = 'id = ?'}) async {
    final response = SqlResponse();

    whereArgs_ ??= [id];
    final db = await DatabaseHelper.database;

    final int res = await db.update(tableName, newData, where: where_, whereArgs: whereArgs_);

    if (res > 0) {
      response.data = res;
    } else {
      response.hasError = true;
    }

    return response;
  }

  static Future<SqlResponse> deleteOne({required String tableName, required int id, List? whereArgs_, String? where_ = 'id = ?'}) async {
    final response = SqlResponse();

    whereArgs_ ??= [id];
    final db = await DatabaseHelper.database;

    final res = await db.delete(tableName, where: 'id = ?', whereArgs: [id]);

    if (res > 0) {
      response.data = res;
    } else {
      response.hasError = true;
    }

    return response;
  }
}
