import 'dart:io';

import 'package:game_score/models/models.dart';
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

    var myDatabase =
        await openDatabase(path, version: sbCurrentVersion, onOpen: (db) {}, onConfigure: _onConfigure, onCreate: (Database db, int version) async {
      await db.execute(''' 
        CREATE TABLE ${Partida.tableName}(
          id INTEGER PRIMARY KEY,
          nombre TEXT,
          tipo TEXT,
          activo TEXT DEFAULT true,
          maxPuntuacion INTEGER

          createdAt timestamp DEFAULT current_timestamp
        );
      ''');

      await db.execute('''
        CREATE TABLE ${Jugador.tableName}(
          id INTEGER PRIMARY KEY,
          partida_id INTEGER NOT NULL,
          nombre TEXT,
          puntuacion INTEGER
        );
      ''');

      await db.execute('''
      CREATE TABLE ${HistorialJugada.tableName}(
        id INTEGER PRIMARY KEY,
        jugador_id INTEGER NOT NULL,
        tipo TEXT,
        puntuacion INTEGER
      );
    ''');
    });
    return myDatabase;
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
