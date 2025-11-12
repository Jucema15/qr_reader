import 'package:flutter/material.dart';
import 'package:qr_reader/database/user_session.dart';
import '../database/data_provider.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String _error = '';

  String hashContrasena(String contrasena) {
    final bytes = utf8.encode(contrasena);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _login() async {
  final usuario = _userCtrl.text.trim();
  final contrasena = _passCtrl.text;
  if (usuario.isEmpty || contrasena.isEmpty) {
    setState(() => _error = 'Completa todos los campos');
    return;
  }
  final contrasenaCifrada = hashContrasena(contrasena);
  final user = await DataProvider.findUsuario(usuario, contrasenaCifrada);
  if (user != null) {
    UserSession.setUsername(usuario); 
    setState(() => _error = '');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage())
    );
  } else {
    setState(() => _error = 'Usuario o contraseña incorrectos');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _userCtrl,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(child: Text('Iniciar sesión'), onPressed: _login),
            TextButton(
              child: Text('¿No tienes cuenta? Regístrate'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RegisterPage())
              ),
            ),
            SizedBox(height: 10),
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}