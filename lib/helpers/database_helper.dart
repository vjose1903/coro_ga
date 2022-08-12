import 'dart:io';
import 'package:game_score/models/models.dart';
import 'package:game_score/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const dbFileName = 'GameScore.db';
  static const dbCurrentVersion = 3;

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
        await openDatabase(path, version: dbCurrentVersion, onOpen: (db) {}, onConfigure: _onConfigure, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return myDatabase;
  }

  static void _onCreate(Database db, int version) async {
    _databaseV1(db);
  }

  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Fun.logColor(color: Colores.red, body: "::::::: oldVersion ==> $oldVersion");
    Fun.logColor(color: Colores.green, body: "::::::: newVersion ==> $newVersion");
    if (newVersion >= 2) await _databaseV2(db);
    if (newVersion >= 3) await _databaseV3(db);
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

  static _databaseV1(Database db) async {
    Fun.logColor(color: Colores.yellow, body: "=========== BASE DE DATOS V1 ===========");
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
  }
  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

  static _databaseV2(Database db) async {
    Fun.logColor(color: Colores.yellow, body: "=========== BASE DE DATOS V2 ===========");
    await db.execute('''
      CREATE TABLE ${PartidaPredefinida.tableName}(
        id INTEGER PRIMARY KEY,
        nombre TEXT,
        tipo TEXT,
        maxPuntuacion INTEGER,
        orden INTEGER
      );
    ''');
  }

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

  static _databaseV3(Database db) async {
    Fun.logColor(color: Colores.yellow, body: "=========== BASE DE DATOS V3 ===========");
    await db.execute("ALTER TABLE ${PartidaPredefinida.tableName} ADD COLUMN cantidadJugadores INTEGER;");
  }
}
