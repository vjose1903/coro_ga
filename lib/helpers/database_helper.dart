import 'dart:io';

import 'package:game_score/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const dbFileName = 'GameScore.db';
  static const sbCurrentVersion = 1;

  static final DatabaseHelper db = DatabaseHelper._();


  factory DatabaseHelper() {
    return db;
  }

  DatabaseHelper._();

  static Database? _database;
  
  static Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  static Future<Database> initializeDatabase() async {
    Directory applicationDocumentDirectory = await getApplicationDocumentsDirectory();

    String path = join(applicationDocumentDirectory.path, dbFileName);
    Fun.logColor(color: Colores.green, body: 'path: $path');
    var myDatabase = await openDatabase(path, version: sbCurrentVersion, onCreate: _createDb);
    return myDatabase;
  }

  static void _createDb(Database db, int newVersion) async {
    await db.execute(''' 
        CREATE TABLE Partida(
          id INTEGER PRIMARY KEY,
          nombre TEXT,
          activo TEXT DEFAULT true,

          createdAt timestamp DEFAULT current_timestamp
        );
      ''');

    await db.execute('''
      CREATE TRIGGER tg_somethings_updated_at
        AFTER UPDATE
        ON Partida FOR EACH ROW
        BEGIN
          UPDATE somethings SET updated_at = current_timestamp
            WHERE id = old.id;
        END;
      ''');

    await db.execute('''
        CREATE TABLE Jugador(
          id INTEGER PRIMARY KEY,
          partida_id INTEGER NOT NULL,
          nombre TEXT,
          puntucacion INTEGER
        );
      ''');

    await db.execute('''
      CREATE TABLE HistorialJugadas(
        id INTEGER PRIMARY KEY,
        jugador_id INTEGER NOT NULL,
        puntucacion INTEGER
      );
    ''');
  }
}
