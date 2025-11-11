import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String _error = '';

  Future<void> _login() async {
    final usuarios = await DBHelper.getUsuarios();
    final user = usuarios.firstWhere(
      (u) => u['nombre'] == _userCtrl.text && u['contrasena'] == _passCtrl.text,
      orElse: () => {},
    );
    if (user.isNotEmpty) {
      setState(() => _error = '');
      // Navega a la pantalla principal o dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(username: user['nombre']))
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

// Página de ejemplo de bienvenida
class HomePage extends StatelessWidget {
  final String username;
  const HomePage({required this.username});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido')),
      body: Center(
        child: Text('Bienvenido, $username!', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}