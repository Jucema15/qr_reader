import 'package:flutter/material.dart';
import 'package:qr_reader/providers/db_provider.dart';

class ScanListProvider extends ChangeNotifier {

  List<ScanModel> scans = [];
  String tipoSeleccionado = 'http';

  Future<ScanModel> nuevoScan( String valor ) async {

    final nuevoScan = ScanModel(valor: valor, id: 0, tipo: '');
    final id = await DBProvider.db.nuevoScan(nuevoScan);
    nuevoScan.id = id;

    if ( tipoSeleccionado == nuevoScan.tipo ) {
      scans.add(nuevoScan);
      notifyListeners();
    }

    return nuevoScan;
  }

  Future<void> cargarScans() async {
    final scans = await DBProvider.db.getTodosLosScans();
    this.scans = [...scans];
    notifyListeners();
  }

  Future<void> cargarScanPorTipo( String tipo ) async {
    final scans = await DBProvider.db.getScansPorTipo(tipo);
    this.scans = [...scans];
    tipoSeleccionado = tipo;
    notifyListeners();
  }

  Future<void> borrarTodos() async {
    await DBProvider.db.deleteAllScans();
    scans = [];
    notifyListeners();
  }

  Future<void> borrarScanPorId( int id ) async {
    await DBProvider.db.deleteScan(id);
  }


}

