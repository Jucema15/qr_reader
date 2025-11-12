import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db_helper.dart';

class DataProvider {
  static Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
      await Hive.openBox('usuarios');
    }
  }

  static Future<void> insertUsuario(Map<String, dynamic> usuario) async {
    if (kIsWeb) {
      final box = Hive.box('usuarios');
      await box.put(usuario['nombre'], usuario['contrasena']);
    } else {
      await DBHelper.insertUsuario(usuario);
    }
  }

  static Future<List<Map<String, dynamic>>> getUsuarios() async {
    if (kIsWeb) {
      final box = Hive.box('usuarios');
      return box.keys
          .map((key) => {'nombre': key, 'contrasena': box.get(key)})
          .toList();
    } else {
      return await DBHelper.getUsuarios();
    }
  }

  static Future<Map<String, dynamic>?> findUsuario(
      String nombre, String contrasena) async {
    if (kIsWeb) {
      final box = Hive.box('usuarios');
      if (box.containsKey(nombre) && box.get(nombre) == contrasena) {
        return {'nombre': nombre, 'contrasena': contrasena};
      } else {
        return null;
      }
    } else {
      return await DBHelper.findUsuario(nombre, contrasena);
    }
  }

  static Future<int?> getUsuarioIdByNombre(String nombre) async {
    if (kIsWeb) return null;
    return await DBHelper.getUsuarioIdByNombre(nombre);
  }

  static Future<int?> insertGeolocalizacion({
    required int usuarioId,
    required double origenLat,
    required double origenLng,
    required double destinoLat,
    required double destinoLng,
    required String fecha,
  }) async {
    if (kIsWeb) return null;
    return await DBHelper.insertGeolocalizacion(
      usuarioId: usuarioId,
      origenLat: origenLat,
      origenLng: origenLng,
      destinoLat: destinoLat,
      destinoLng: destinoLng,
      fecha: fecha,
    );
  }

  static Future<List<Map<String, dynamic>>> getGeolocalizacionesByUsuario(int usuarioId) async {
    if (kIsWeb) return [];
    return await DBHelper.getGeolocalizacionesByUsuario(usuarioId);
  }
}