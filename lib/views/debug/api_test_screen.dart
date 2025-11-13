import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../services/user_api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _resultText = 'Presiona un botón para probar la conexión API';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Probando conexión con ${ApiConfig.baseUrl}...';
    });

    try {
      final userApiService = UserApiService();
      final connected = await userApiService.probarConexion();

      setState(() {
        _isLoading = false;
        if (connected) {
          _resultText =
              '✅ CONEXIÓN EXITOSA\n\n'
              'Backend Spring Boot disponible en:\n'
              '${ApiConfig.baseUrl}\n\n'
              'PostgreSQL conectado correctamente';
        } else {
          _resultText =
              '❌ CONEXIÓN FALLIDA\n\n'
              'No se pudo conectar con:\n'
              '${ApiConfig.baseUrl}\n\n'
              'Verifica que Spring Boot esté corriendo';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultText = '❌ ERROR DE CONEXIÓN\n\n$e';
      });
    }
  }

  Future<void> _testCreateUser() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Creando usuario de prueba...';
    });

    try {
      final userApiService = UserApiService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final user = await userApiService.crearUsuario(
        nombre: 'Usuario Test',
        email: 'test$timestamp@fincasmart.com',
        telefono: '3001234567',
        password: 'password123',
      );

      setState(() {
        _isLoading = false;
        _resultText =
            '✅ USUARIO CREADO EXITOSAMENTE\n\n'
            'ID: ${user.id}\n'
            'Email: ${user.email}\n'
            'Nombre: ${user.nombre}\n'
            'Activo: ${user.activo}\n\n'
            '🎯 El usuario fue guardado en PostgreSQL';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultText = '❌ ERROR CREANDO USUARIO\n\n$e';
      });
    }
  }

  Future<void> _testAuthRegister() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Probando registro completo con AuthService...';
    });

    try {
      final authService = AuthService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final request = RegisterRequest(
        email: 'auth$timestamp@fincasmart.com',
        password: 'password123',
        nombre: 'Auth Test',
        telefono: '3001234567',
      );

      final result = await authService.register(request);

      setState(() {
        _isLoading = false;
        if (result.success) {
          _resultText =
              '✅ REGISTRO COMPLETO EXITOSO\n\n'
              'Email: ${result.user?.email}\n'
              'Nombre: ${result.user?.nombre}\n'
              'ID: ${result.user?.id}\n\n'
              '🎯 AuthService + UserApiService + PostgreSQL\n'
              'Todo funcionando correctamente!';
        } else {
          _resultText = '❌ ERROR EN REGISTRO\n\n${result.error}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultText = '❌ EXCEPCIÓN EN REGISTRO\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API Conexión'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info del backend
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔧 Configuración Backend:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('URL: ${ApiConfig.baseUrl}'),
                  Text('Usuarios: ${ApiConfig.usersUrl}'),
                  Text('Database: PostgreSQL'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resultado
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _resultText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botones de prueba
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                '1. Probar Conexión Backend',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCreateUser,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                '2. Crear Usuario API',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAuthRegister,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                '3. Test Registro Completo',
                style: TextStyle(color: Colors.white),
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
