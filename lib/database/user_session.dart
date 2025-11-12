class UserSession {
  static String? _username;
  static final List<Map<String, dynamic>> _recientes = [];

  static String? get username => _username;
  static void setUsername(String username) => _username = username;
  static void clear() {
    _username = null;
    _recientes.clear();
  }

  static void addReciente({
    required double origenLat,
    required double origenLng,
    required double destinoLat,
    required double destinoLng,
    required String fecha,
  }) {
    _recientes.add({
      'origen_lat': origenLat,
      'origen_lng': origenLng,
      'destino_lat': destinoLat,
      'destino_lng': destinoLng,
      'fecha': fecha,
    });
  }

  static void removeRecienteByIndex(int index) {
    if (index >= 0 && index < _recientes.length) {
      _recientes.removeAt(index);
    }
  }

  static List<Map<String, dynamic>> get recientes => List.unmodifiable(_recientes);
}