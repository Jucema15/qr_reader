import 'package:flutter/material.dart';
import '../database/data_provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String _error = '';
  String _success = '';

  bool validarUsuario(String usuario) {
    final regex = RegExp(r'^[a-zA-Z0-9]{4,}$');
    return regex.hasMatch(usuario);
  }

  bool validarContrasena(String contrasena) {
    final longitudOK = contrasena.length >= 6;
    final mayusculaOK = contrasena.contains(RegExp(r'[A-Z]'));
    final numeroOK = contrasena.contains(RegExp(r'[0-9]'));
    return longitudOK && mayusculaOK && numeroOK;
  }

  String hashContrasena(String contrasena) {
    final bytes = utf8.encode(contrasena);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _register() async {
    final usuario = _userCtrl.text.trim();
    final contrasena = _passCtrl.text;

    if (usuario.isEmpty || contrasena.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    if (!validarUsuario(usuario)) {
      setState(() => _error = 'El usuario debe tener mínimo 4 caracteres alfanuméricos.');
      return;
    }
    if (!validarContrasena(contrasena)) {
      setState(() => _error = 'La contraseña debe tener mínimo 6 caracteres, una mayúscula y un número.');
      return;
    }

    final usuarios = await DataProvider.getUsuarios();
    if (usuarios.any((u) => u['nombre'] == usuario)) {
      setState(() {
        _error = 'Nombre de usuario ya existe';
        _success = '';
      });
      return;
    }

    final contrasenaCifrada = hashContrasena(contrasena);
    await DataProvider.insertUsuario({
      'nombre': usuario,
      'contrasena': contrasenaCifrada,
    });

    setState(() {
      _success = 'Usuario registrado correctamente';
      _error = '';
    });
    await Future.delayed(Duration(seconds: 2));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: EdgeInsets.all(20),
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
            ElevatedButton(child: Text('Registrarse'), onPressed: _register),
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            if (_success.isNotEmpty)
              Text(_success, style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}