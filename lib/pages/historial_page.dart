import 'package:flutter/material.dart';
import 'package:qr_reader/database/data_provider.dart';
import 'package:qr_reader/database/user_session.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_reader/pages/mapa_page.dart';

class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  Future<List<Map<String, dynamic>>> _loadGeoLogs() async {
    final username = UserSession.username;
    if (username == null) return [];
    final usuarioId = await DataProvider.getUsuarioIdByNombre(username);
    if (usuarioId == null) return [];
    return await DataProvider.getGeolocalizacionesByUsuario(usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadGeoLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay rutas guardadas en el historial'));
        }

        final geoLogs = snapshot.data!;
        return ListView.builder(
          itemCount: geoLogs.length,
          itemBuilder: (context, index) {
            final geo = geoLogs[index];
            final fecha = DateTime.tryParse(geo['fecha'] ?? '') ?? DateTime.now();
            final origenLat = geo['origen_lat'] as double;
            final origenLng = geo['origen_lng'] as double;
            final destinoLat = geo['destino_lat'] as double;
            final destinoLng = geo['destino_lng'] as double;
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.amber),
              title: Text('Desde: $origenLat, $origenLng\nHacia: $destinoLat, $destinoLng'),
              subtitle: Text(
                'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
              ),
              trailing: Text('ID: ${geo['id']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapaPage(
                      latLng: LatLng(destinoLat, destinoLng),
                      origen: LatLng(origenLat, origenLng),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}