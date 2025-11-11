import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qr_reader/pages/login_page.dart';
import 'package:qr_reader/providers/ui_provider.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WEB/MÓVIL: usa Hive para persistencia
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await Hive.initFlutter();
    await Hive.openBox('usuarios');
  }
  
  // ESCRITORIO: usa SQLite
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    // Opcional: inicializa otros providers de DB aquí si lo necesitas
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(create: (_) => ScanListProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App QR Login',
        home: LoginPage(),
      ),
    ),
  );
}