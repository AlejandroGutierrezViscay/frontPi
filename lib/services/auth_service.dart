import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/api_config.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Token de autenticación actual
  String? _authToken;
  User? _currentUser;

  // Getters
  String? get authToken => _authToken;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _authToken != null && _currentUser != null;

  // Headers con autenticación
  Map<String, String> get _authHeaders {
    if (_authToken != null) {
      return ApiConfig.headersWithAuth(_authToken!);
    }
    return ApiConfig.headers;
  }

  // Login con email y contraseña
  Future<AuthResult> login(String email, String password) async {
    print('🔧 AuthService.login() - Iniciando sesión');
    print('  URL: ${ApiConfig.loginUrl}');
    print('  Email: $email');

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: ApiConfig.headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiConfig.connectTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];

        // El backend devuelve los datos del usuario en el mismo nivel del token
        _currentUser = User.fromJson(data);

        print('✅ Login exitoso: ${_currentUser!.email}');
        return AuthResult.success(_currentUser!);
      } else {
        final data = jsonDecode(response.body);
        print('❌ Login fallido: ${data['message']}');
        return AuthResult.error(
          data['message'] ?? 'Error en el inicio de sesión',
        );
      }
    } catch (e) {
      print('❌ Error de conexión en login: $e');
      return AuthResult.error('Error de conexión: ${e.toString()}');
    }
  }

  // Registro de nuevo usuario
  Future<AuthResult> register(RegisterRequest request) async {
    print('🔧 AuthService.register() - Iniciando registro');
    print('  URL: ${ApiConfig.registerUrl}');
    print('  Email: ${request.email}');
    print('  Nombre: ${request.nombre}');

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.registerUrl),
            headers: ApiConfig.headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];

        // El backend devuelve token y datos del usuario en el mismo nivel
        _currentUser = User.fromJson(data);

        print('✅ Registro exitoso: ${_currentUser!.email}');
        return AuthResult.success(_currentUser!);
      } else {
        final data = jsonDecode(response.body);
        print('❌ Registro fallido: ${data['message']}');
        return AuthResult.error(data['message'] ?? 'Error en el registro');
      }
    } catch (e) {
      print('❌ Error de conexión en registro: $e');
      return AuthResult.error('Error de conexión: ${e.toString()}');
    }
  }

  // Login con Google (placeholder para implementación futura)
  Future<AuthResult> loginWithGoogle() async {
    try {
      // TODO: Implementar autenticación con Google
      // Aquí irían las llamadas a Google Sign In

      return AuthResult.error('Autenticación con Google no implementada aún');
    } catch (e) {
      return AuthResult.error(
        'Error en autenticación con Google: ${e.toString()}',
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_authToken != null) {
        // Notificar al servidor sobre el logout (endpoint futuro)
        // await http.post(
        //   Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
        //   headers: _authHeaders,
        // );
      }
    } catch (e) {
      // Ignorar errores de red en logout
      print('Error en logout: $e');
    } finally {
      // Limpiar datos locales
      _authToken = null;
      _currentUser = null;
      // await _removeTokenFromStorage();
    }
  }

  // Verificar token actual
  Future<bool> verifyToken() async {
    if (_authToken == null) return false;

    try {
      // TODO: Implementar endpoint de verificación en el backend
      // final response = await http.get(
      //   Uri.parse('${ApiConfig.baseUrl}/api/auth/verify'),
      //   headers: _authHeaders,
      // );

      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   _currentUser = User.fromJson(data['user']);
      //   return true;
      // } else {
      //   await logout();
      //   return false;
      // }

      // Por ahora, simular verificación exitosa
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Recuperar contraseña
  Future<bool> forgotPassword(String email) async {
    try {
      // TODO: Implementar endpoint en el backend
      // final response = await http.post(
      //   Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
      //   headers: ApiConfig.headers,
      //   body: jsonEncode({'email': email}),
      // );
      // return response.statusCode == 200;

      // Simular por ahora
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Actualizar perfil de usuario (usando PUT /api/users/{id})
  Future<AuthResult> updateProfile({
    required String nombre,
    required String email,
    required String telefono,
    String? password,
  }) async {
    if (_currentUser == null) {
      return AuthResult.error('No hay usuario autenticado');
    }

    try {
      final Map<String, dynamic> data = {
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      final response = await http
          .put(
            Uri.parse('${ApiConfig.usersUrl}/${_currentUser!.id}'),
            headers: _authHeaders,
            body: jsonEncode(data),
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(jsonDecode(response.body));
        return AuthResult.success(_currentUser!);
      } else {
        final errorData = jsonDecode(response.body);
        return AuthResult.error(
          errorData['message'] ?? 'Error al actualizar perfil',
        );
      }
    } catch (e) {
      return AuthResult.error('Error de conexión: ${e.toString()}');
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // TODO: Implementar endpoint en el backend
      // final response = await http.put(
      //   Uri.parse('${ApiConfig.baseUrl}/api/auth/change-password'),
      //   headers: _authHeaders,
      //   body: jsonEncode({
      //     'currentPassword': currentPassword,
      //     'newPassword': newPassword,
      //   }),
      // );
      // return response.statusCode == 200;

      // Simular por ahora
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Eliminar cuenta
  Future<bool> deleteAccount(String password) async {
    try {
      // TODO: Implementar endpoint en el backend
      // final response = await http.delete(
      //   Uri.parse('${ApiConfig.baseUrl}/api/auth/account'),
      //   headers: _authHeaders,
      //   body: jsonEncode({'password': password}),
      // );

      // if (response.statusCode == 200) {
      //   await logout();
      //   return true;
      // }
      // return false;

      // Simular por ahora
      await Future.delayed(const Duration(seconds: 1));
      await logout();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Métodos privados para almacenamiento local (implementar según necesidades)
  // Future<void> _saveTokenToStorage(String token) async {
  //   // Implementar con SharedPreferences o similar
  // }

  // Future<void> _removeTokenFromStorage() async {
  //   // Implementar con SharedPreferences o similar
  // }

  // Future<String?> _getTokenFromStorage() async {
  //   // Implementar con SharedPreferences o similar
  //   return null;
  // }

  // Inicializar servicio (llamar al inicio de la app)
  Future<void> initialize() async {
    // Intentar cargar token guardado
    // _authToken = await _getTokenFromStorage();

    if (_authToken != null) {
      // Verificar si el token sigue siendo válido
      await verifyToken();
    }
  }
}

// Clase para el resultado de autenticación
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  const AuthResult._({required this.success, this.user, this.error});

  factory AuthResult.success(User user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(success: false, error: error);
  }
}

// Extensión para facilitar el uso
extension AuthServiceHelpers on AuthService {
  // Obtener nombre completo del usuario
  String get userFullName {
    final user = currentUser;
    return user?.nombre ?? '';
  }

  // Verificar si el usuario está activo
  bool get isUserActive => currentUser?.activo ?? false;
}
