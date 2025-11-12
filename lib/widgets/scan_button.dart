import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/pages/qr_scanner_page.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';
import 'package:qr_reader/utils/utils.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      child: const Icon(Icons.filter_center_focus),

      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QRScannerPage()),
        );

        if (result == null) return;

        if (result is! String) return;

        if (result == '-1') return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned value: $result'))
        );

        final scanListProvider = Provider.of<ScanListProvider>(
          context,
          listen: false,
        );

        final nuevoScan = await scanListProvider.nuevoScan(result);

        launchURL(context, nuevoScan);
      },
    );
  }
}