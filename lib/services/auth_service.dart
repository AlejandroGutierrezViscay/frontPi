import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/api_config.dart';
import 'user_api_service.dart';

class AuthService {
  // URL base de la API - cambiar por tu URL real
  static const String baseUrl =
      'https://api.fincarent.com'; // TODO: Actualizar con URL real

  // Headers por defecto
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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
    final headers = Map<String, String>.from(_headers);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Login con email y contraseña
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _authToken = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Guardar token en almacenamiento local si es necesario
        // await _saveTokenToStorage(_authToken!);

        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.error(
          data['message'] ?? 'Error en el inicio de sesión',
        );
      }
    } catch (e) {
      return AuthResult.error('Error de conexión: ${e.toString()}');
    }
  }

  // Registro de nuevo usuario
  Future<AuthResult> register(RegisterRequest request) async {
    print('🔧 AuthService.register() - Iniciando registro');
    print('  Email: ${request.email}');
    print('  Nombre: ${request.nombre}');

    try {
      // Usar UserApiService en lugar de llamada HTTP directa
      final userApiService = UserApiService();

      print('🔄 Usando UserApiService para crear usuario...');

      final user = await userApiService.crearUsuario(
        nombre: request.nombre,
        email: request.email,
        telefono: request.telefono ?? '',
        password: request.password,
        apellido: request.apellido,
      );

      print('✅ Usuario creado con API: ${user.email}');

      // Guardar usuario actual
      _currentUser = user;

      // TODO: En una implementación real, aquí se obtendría el token del backend
      _authToken = 'token-simulado-${user.id}';

      print('✅ AuthService.register() completado exitosamente');
      return AuthResult.success(user);
    } catch (e) {
      print('❌ Error en AuthService.register(): $e');
      return AuthResult.error('Error en el registro: ${e.toString()}');
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
        // Notificar al servidor sobre el logout
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: _authHeaders,
        );
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
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data['user']);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Recuperar contraseña
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Actualizar perfil de usuario
  Future<AuthResult> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _authHeaders,
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(data['user']);
        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.error(
          data['message'] ?? 'Error al actualizar perfil',
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
      final response = await http.put(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: _authHeaders,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Eliminar cuenta
  Future<bool> deleteAccount(String password) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/account'),
        headers: _authHeaders,
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 200) {
        await logout();
        return true;
      }
      return false;
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

  // Método de desarrollo para simular respuestas
  Future<AuthResult> _simulateLogin(String email, String password) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 2));

    // Simular validación
    if (email == 'demo@fincarent.com' && password == '123456') {
      _currentUser = const User(
        id: 'demo-user-id',
        nombre: 'Usuario Demo',
        apellido: 'FincaRent',
        email: 'demo@fincarent.com',
        telefono: '+57 300 123 4567',
        fechaNacimiento: '1990-01-01',
        genero: Genero.masculino,
        tipoUsuario: TipoUsuario.huesped,
        fechaRegistro: '2024-01-01T00:00:00Z',
        verificado: true,
        activo: true,
      );
      _authToken = 'demo-auth-token';
      return AuthResult.success(_currentUser!);
    } else {
      return AuthResult.error('Credenciales incorrectas');
    }
  }

  // Método de desarrollo para simular registro
  Future<AuthResult> _simulateRegister(RegisterRequest request) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 2));

    // Simular validación de email único
    if (request.email == 'existing@email.com') {
      return AuthResult.error('Este email ya está registrado');
    }

    _currentUser = User(
      id: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
      nombre: request.nombre,
      apellido: request.apellido,
      email: request.email,
      telefono: request.telefono,
      fechaNacimiento: request.fechaNacimiento,
      genero: request.genero,
      tipoUsuario: TipoUsuario.huesped,
      fechaRegistro: DateTime.now().toIso8601String(),
      verificado: false,
      activo: true,
    );
    _authToken = 'new-user-auth-token';
    return AuthResult.success(_currentUser!);
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
  // Verificar si el usuario es propietario
  bool get isOwner => currentUser?.tipoUsuario == TipoUsuario.propietario;

  // Verificar si el usuario es huésped
  bool get isGuest => currentUser?.tipoUsuario == TipoUsuario.huesped;

  // Obtener nombre completo del usuario
  String get userFullName {
    final user = currentUser;
    return user != null ? '${user.nombre} ${user.apellido}' : '';
  }

  // Verificar si el email está verificado
  bool get isEmailVerified => currentUser?.verificado ?? false;
}
