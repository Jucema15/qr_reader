import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'mapa_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blueAccent,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedData != null ? 'Scanned: $scannedData' : 'Scan a code',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        scannedData = scanData.code;
      });

      LatLng? latLng = parseLatLng(scanData.code ?? "");
      if (latLng != null) {
        controller.pauseCamera();
        // Navegar al mapa con la ubicación recibida por QR
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MapaPage(latLng: latLng),
          ),
        );
      } else {
        // Mostrar error si el QR no contiene coordenadas válidas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR no contiene coordenadas válidas')),
        );
        controller.resumeCamera();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// Función para parsear latitud y longitud desde el QR
LatLng? parseLatLng(String value) {
  final geoPrefix = 'geo:';
  String coords = value.startsWith(geoPrefix) ? value.substring(geoPrefix.length) : value;
  final parts = coords.split(',');
  if (parts.length == 2) {
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat != null && lng != null) return LatLng(lat, lng);
  }
  return null;
}