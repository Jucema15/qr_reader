import 'package:flutter/material.dart';
import 'package:qr_reader/database/user_session.dart';
import 'package:qr_reader/database/data_provider.dart';
import 'package:qr_reader/pages/mapa_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DireccionesPage extends StatefulWidget {
  const DireccionesPage({super.key});

  @override
  State<DireccionesPage> createState() => _DireccionesPageState();
}

class _DireccionesPageState extends State<DireccionesPage> {

  Future<void> _borrarRuta(int index) async {
    final ruta = UserSession.recientes[index];

    final username = UserSession.username;
    if (username != null) {
      final usuarioId = await DataProvider.getUsuarioIdByNombre(username);
      if (usuarioId != null) {
        await DataProvider.insertGeolocalizacion(
          usuarioId: usuarioId,
          origenLat: ruta['origen_lat'],
          origenLng: ruta['origen_lng'],
          destinoLat: ruta['destino_lat'],
          destinoLng: ruta['destino_lng'],
          fecha: ruta['fecha'],
        );
      }
    }
    setState(() {
      UserSession.removeRecienteByIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rutasTemporales = UserSession.recientes;
    if (rutasTemporales.isEmpty) {
      return const Center(child: Text('No hay rutas exitosas en esta sesión'));
    }

    return ListView.builder(
      itemCount: rutasTemporales.length,
      itemBuilder: (context, index) {
        final naturalIndex = rutasTemporales.length - 1 - index;
        final ruta = rutasTemporales[naturalIndex];
        final fecha = DateTime.tryParse(ruta['fecha']) ?? DateTime.now();
        final origenLat = ruta['origen_lat'] as double;
        final origenLng = ruta['origen_lng'] as double;
        final destinoLat = ruta['destino_lat'] as double;
        final destinoLng = ruta['destino_lng'] as double;
        return ListTile(
          leading: const Icon(Icons.alt_route, color: Colors.green),
          title: Text('Desde: $origenLat, $origenLng\nHacia: $destinoLat, $destinoLng'),
          subtitle: Text(
            'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Borrar este registro',
            onPressed: () async {
              await _borrarRuta(naturalIndex);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registro guardado y borrado correctamente'))
              );
            },
          ),
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
  }
}