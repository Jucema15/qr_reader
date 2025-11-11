import 'package:flutter/material.dart';
import 'package:qr_reader/pages/login_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'App QR Login',
    home: LoginPage(),
  ));
}