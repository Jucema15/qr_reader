import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_reader/database/data_provider.dart';
import 'package:qr_reader/database/user_session.dart';

class MapaPage extends StatefulWidget {
  final LatLng? latLng; // ubicación destino (por QR)
  final LatLng? origen; // opcional: para historial (guardar la ruta real)
  const MapaPage({Key? key, this.latLng, this.origen}) : super(key: key);

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  Completer<GoogleMapController> _controller = Completer();
  MapType mapType = MapType.normal;
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String? _errorMsg;
  bool _isLoadingRoute = false;

  final String googleAPIKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  bool _rutaHistorial = false;

  @override
  void initState() {
    super.initState();
    // Si la página se usa para mostrar una ruta guardada, utiliza los datos del historial
    if (widget.origen != null && widget.latLng != null) {
      _currentLocation = widget.origen;
      _rutaHistorial = true;
      _setMarkers();
      _loadRouteReal(useOrigin: true);
    } else {
      _getCurrentLocation();
    }
  }

  void _setMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('actual-location'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Origen'),
      ),
      Marker(
        markerId: const MarkerId('qr-location'),
        position: widget.latLng!,
        infoWindow: const InfoWindow(title: 'Destino'),
      ),
    };
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMsg = 'Debes permitir el acceso a la ubicación para ver la ruta en el mapa';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMsg =
              'Permiso de ubicación denegado permanentemente. Ve a ajustes del dispositivo para habilitarlo.';
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);

        _markers = {
          Marker(
            markerId: const MarkerId('actual-location'),
            position: _currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Tu ubicación'),
          ),
        };

        if (widget.latLng != null) {
          _markers.add(Marker(
            markerId: const MarkerId('qr-location'),
            position: widget.latLng!,
            infoWindow: const InfoWindow(title: 'Destino QR'),
          ));
        }
        // Guarda la ruta tras trazarla si vienes de escaneo
        _loadRouteReal();
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'No se pudo obtener ubicación: ${e.toString()}';
      });
    }
  }

  Future<void> _loadRouteReal({bool useOrigin = false}) async {
    final origen = useOrigin ? _currentLocation : _currentLocation;
    final destino = widget.latLng;
    if (origen == null || destino == null) return;

    setState(() {
      _isLoadingRoute = true;
      _errorMsg = null;
    });

    try {
      List<LatLng> routePoints = await getRouteCoordinates(
        origen,
        destino,
        googleAPIKey,
      );
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route_real'),
            points: routePoints,
            color: Colors.blue,
            width: 6,
          ),
        };
        _isLoadingRoute = false;
      });
      // Si es un escaneo (no historial), guarda registro
      if (!_rutaHistorial) await _saveGeoLog();
    } catch (e) {
      setState(() {
        _errorMsg = 'No se pudo obtener la ruta real: ${e.toString()}';
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _saveGeoLog() async {
    final username = UserSession.username;
    if (username != null && _currentLocation != null && widget.latLng != null) {
      final usuarioId = await DataProvider.getUsuarioIdByNombre(username);
      if (usuarioId != null) {
        await DataProvider.insertGeolocalizacion(
          usuarioId: usuarioId,
          origenLat: _currentLocation!.latitude,
          origenLng: _currentLocation!.longitude,
          destinoLat: widget.latLng!.latitude,
          destinoLng: widget.latLng!.longitude,
          fecha: DateTime.now().toIso8601String(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.latLng == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: const Center(child: Text('Sin coordenadas')),
      );
    }
    if (_errorMsg != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: Center(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red))),
      );
    }
    if (_currentLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final CameraPosition puntoInicial = CameraPosition(
      target: _currentLocation!,
      zoom: 14,
      tilt: 50,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_rutaHistorial ? 'Ruta Guardada' : 'Ruta QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_disabled),
            onPressed: () async {
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(puntoInicial),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: !_rutaHistorial,
            myLocationEnabled: !_rutaHistorial,
            mapType: mapType,
            markers: _markers,
            polylines: _polylines,
            initialCameraPosition: puntoInicial,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          if (_isLoadingRoute)
            const Positioned(
              top: 10,
              left: 0, right: 0,
              child: Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Cargando ruta...', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.layers),
        onPressed: () {
          setState(() {
            mapType = mapType == MapType.normal
                ? MapType.satellite
                : MapType.normal;
          });
        },
      ),
    );
  }
}

// Consulta Directions API (modo walking, puedes cambiar a driving)
Future<List<LatLng>> getRouteCoordinates(LatLng origin, LatLng destination, String apiKey) async {
  String url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}&key=$apiKey&mode=walking';

  final response = await http.get(Uri.parse(url));
  final data = json.decode(response.body);

  if (data['status'] != 'OK') throw Exception('Error consultando rutas: ${data['status']}');

  final overviewPolyline = data['routes'][0]['overview_polyline']['points'];
  return decodePolyline(overviewPolyline);
}

// Decodifica la polilínea generada por la Directions API
List<LatLng> decodePolyline(String polyline) {
  List<LatLng> points = [];
  int index = 0, len = polyline.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return points;
}