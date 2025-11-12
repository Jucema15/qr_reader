import 'package:flutter/material.dart';
import 'package:qr_reader/providers/db_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(BuildContext context, ScanModel scan) async {
  final url = scan.valor;

  final Uri uriUrl = Uri.parse(url);

  if (scan.tipo == 'http') {

    if (!await launchUrl(uriUrl)) {
      throw Exception('Could not launch $uriUrl');
    }
    
  } else {
    Navigator.pushNamed(context, 'mapa', arguments: scan);
  }
}
