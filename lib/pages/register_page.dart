import 'package:flutter/material.dart';
import 'package:qr_reader/database/db_helper.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String _error = '';
  String _success = '';

  Future<void> _register() async {
    if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    final usuarios = await DBHelper.getUsuarios();
    if (usuarios.any((u) => u['nombre'] == _userCtrl.text)) {
      setState(() {
        _error = 'Nombre de usuario ya existe';
        _success = '';
      });
      return;
    }
    await DBHelper.insertUsuario({
      'nombre': _userCtrl.text,
      'contrasena': _passCtrl.text,
    });
    setState(() {
      _success = 'Usuario registrado correctamente';
      _error = '';
    });
    Future.delayed(Duration(seconds: 2), () => Navigator.of(context).pop());
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