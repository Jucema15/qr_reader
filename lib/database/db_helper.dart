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
      version: 2, // sube versión si cambias estructura
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
            origen_lat REAL NOT NULL,
            origen_lng REAL NOT NULL,
            destino_lat REAL NOT NULL,
            destino_lng REAL NOT NULL,
            fecha TEXT,
            FOREIGN KEY(usuario_id) REFERENCES usuario(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Si ya tienes la tabla y quieres migrar
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE geolocalizacion ADD COLUMN origen_lat REAL;
          ''');
          await db.execute('''
            ALTER TABLE geolocalizacion ADD COLUMN origen_lng REAL;
          ''');
          await db.execute('''
            ALTER TABLE geolocalizacion ADD COLUMN destino_lat REAL;
          ''');
          await db.execute('''
            ALTER TABLE geolocalizacion ADD COLUMN destino_lng REAL;
          ''');
        }
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

  static Future<int?> getUsuarioIdByNombre(String nombre) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'usuario',
      where: 'nombre = ?',
      whereArgs: [nombre],
      limit: 1,
    );
    if (result.isNotEmpty) return result.first['id'] as int;
    return null;
  }

  static Future<int> insertGeolocalizacion({
    required int usuarioId,
    required double origenLat,
    required double origenLng,
    required double destinoLat,
    required double destinoLng,
    required String fecha,
  }) async {
    final dbClient = await db;
    return await dbClient.insert('geolocalizacion', {
      'usuario_id': usuarioId,
      'origen_lat': origenLat,
      'origen_lng': origenLng,
      'destino_lat': destinoLat,
      'destino_lng': destinoLng,
      'fecha': fecha,
    });
  }

  static Future<List<Map<String, dynamic>>> getGeolocalizacionesByUsuario(int usuarioId) async {
    final dbClient = await db;
    return await dbClient.query(
      'geolocalizacion',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha DESC',
    );
  }
}