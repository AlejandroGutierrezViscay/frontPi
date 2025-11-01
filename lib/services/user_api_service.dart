import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

/// Servicio para manejar operaciones de usuarios con la API
class UserApiService {
  // Singleton
  static final UserApiService _instance = UserApiService._internal();
  factory UserApiService() => _instance;
  UserApiService._internal();

  /// Crear un nuevo usuario
  /// POST /api/usuarios
  Future<User> crearUsuario({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
  }) async {
    print('📤 UserApiService.crearUsuario() - Iniciando...');
    print('  URL: ${ApiConfig.usersUrl}');
    print('  Email: $email');
    print('  Nombre: $nombre');

    try {
      final body = {
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'password': password,
      };

      print('📤 Datos a enviar: ${json.encode(body)}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.usersUrl),
            headers: ApiConfig.headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Respuesta recibida:');
      print('  Status: ${response.statusCode}');
      print('  Headers: ${response.headers}');
      print('  Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('✅ Usuario creado exitosamente');
        return User.fromJson(userData);
      } else {
        final error = 'Error ${response.statusCode}: ${response.body}';
        print('❌ Error en la respuesta: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('❌ Excepción en crearUsuario: $e');
      rethrow;
    }
  }

  /// Obtener usuario por ID
  /// GET /api/usuarios/{id}
  Future<User?> obtenerUsuario(String id) async {
    print('📤 UserApiService.obtenerUsuario() - ID: $id');

    try {
      final url = '${ApiConfig.usersUrl}/$id';
      print('  URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.receiveTimeout);

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('✅ Usuario obtenido exitosamente');
        return User.fromJson(userData);
      } else if (response.statusCode == 404) {
        print('⚠️ Usuario no encontrado');
        return null;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo usuario: $e');
      rethrow;
    }
  }

  /// Obtener usuario por email
  /// GET /api/usuarios/email/{email}
  Future<User?> obtenerUsuarioPorEmail(String email) async {
    print('📤 UserApiService.obtenerUsuarioPorEmail() - Email: $email');

    try {
      final url = '${ApiConfig.usersUrl}/email/$email';
      print('  URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.receiveTimeout);

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('✅ Usuario encontrado por email');
        return User.fromJson(userData);
      } else if (response.statusCode == 404) {
        print('⚠️ Usuario no encontrado por email');
        return null;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error obteniendo usuario por email: $e');
      rethrow;
    }
  }

  /// Actualizar usuario
  /// PUT /api/usuarios/{id}
  Future<User> actualizarUsuario(String id, Map<String, dynamic> datos) async {
    print('📤 UserApiService.actualizarUsuario() - ID: $id');

    try {
      final url = '${ApiConfig.usersUrl}/$id';
      print('  URL: $url');
      print('  Datos: ${json.encode(datos)}');

      final response = await http
          .put(
            Uri.parse(url),
            headers: ApiConfig.headers,
            body: json.encode(datos),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('✅ Usuario actualizado exitosamente');
        return User.fromJson(userData);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error actualizando usuario: $e');
      rethrow;
    }
  }

  /// Eliminar usuario
  /// DELETE /api/usuarios/{id}
  Future<bool> eliminarUsuario(String id) async {
    print('📤 UserApiService.eliminarUsuario() - ID: $id');

    try {
      final url = '${ApiConfig.usersUrl}/$id';
      print('  URL: $url');

      final response = await http
          .delete(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.connectTimeout);

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Usuario eliminado exitosamente');
        return true;
      } else {
        print('❌ Error eliminando usuario: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error eliminando usuario: $e');
      return false;
    }
  }

  /// Listar todos los usuarios (admin)
  /// GET /api/usuarios
  Future<List<User>> listarUsuarios() async {
    print('📤 UserApiService.listarUsuarios()');

    try {
      final response = await http
          .get(Uri.parse(ApiConfig.usersUrl), headers: ApiConfig.headers)
          .timeout(ApiConfig.receiveTimeout);

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> usersData = json.decode(response.body);
        print('✅ ${usersData.length} usuarios obtenidos');
        return usersData.map((userData) => User.fromJson(userData)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error listando usuarios: $e');
      rethrow;
    }
  }

  /// Probar conectividad con el backend
  Future<bool> probarConexion() async {
    print('🔍 UserApiService.probarConexion() - Probando ${ApiConfig.usersUrl}');

    try {
      final response = await http
          .get(Uri.parse(ApiConfig.usersUrl), headers: ApiConfig.headers)
          .timeout(const Duration(seconds: 5));

      print('📥 Conexión - Status: ${response.statusCode}');

      final conectado = response.statusCode < 500;
      print(conectado ? '✅ Backend disponible' : '❌ Backend no disponible');
      return conectado;
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    }
  }
}
