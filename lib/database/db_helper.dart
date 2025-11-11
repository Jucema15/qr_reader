import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'qr_reader.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla usuario
        await db.execute('''
          CREATE TABLE usuario (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            contrasena TEXT NOT NULL
          )
        ''');
        
        await db.execute('''
          CREATE TABLE geolocalizacion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            latitud TEXT,
            longitud TEXT,
            fecha TEXT,
            FOREIGN KEY(id_usuario) REFERENCES usuario(id)
          )
        ''');
      },
    );
  }

  // Insertar usuario
  static Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    final dbClient = await db;
    return await dbClient.insert('usuario', usuario);
  }

  // Insertar geolocalización
  static Future<int> insertGeolocalizacion(Map<String, dynamic> geo) async {
    final dbClient = await db;
    return await dbClient.insert('geolocalizacion', geo);
  }

  // Consultar usuarios
  static Future<List<Map<String, dynamic>>> getUsuarios() async {
    final dbClient = await db;
    return await dbClient.query('usuario');
  }

  // Consultar todas las geolocalizaciones de un usuario
  static Future<List<Map<String, dynamic>>> getGeolocalizaciones(int idUsuario) async {
    final dbClient = await db;
    return await dbClient.query('geolocalizacion', where: 'id_usuario = ?', whereArgs: [idUsuario]);
  }
}