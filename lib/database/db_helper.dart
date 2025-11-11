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
            usuario_id INTEGER,
            latitud REAL NOT NULL,
            longitud REAL NOT NULL,
            fecha TEXT,
            FOREIGN KEY(usuario_id) REFERENCES usuario(id)
          )
        ''');
      },
    );
  }

  static Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    final dbClient = await db;
    return await dbClient.insert('usuario', usuario);
  }

  static Future<List<Map<String, dynamic>>> getUsuarios() async {
    final dbClient = await db;
    return await dbClient.query('usuario');
  }

  static Future<Map<String, dynamic>?> findUsuario(
      String nombre, String contrasena) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'usuario',
      where: 'nombre = ? AND contrasena = ?',
      whereArgs: [nombre, contrasena],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}