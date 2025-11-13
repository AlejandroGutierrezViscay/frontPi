import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resena.dart';
import '../config/api_config.dart';

class ResenaService {
  static final ResenaService _instance = ResenaService._internal();
  factory ResenaService() => _instance;
  ResenaService._internal();

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _authHeaders {
    if (_authToken != null) {
      return ApiConfig.headersWithAuth(_authToken!);
    }
    return ApiConfig.headers;
  }

  // ==================== CRUD DE RESEÑAS ====================

  /// Crear nueva reseña
  Future<Resena?> crearResena({
    required int usuarioId,
    required int fincaId,
    int? reservaId,
    required int calificacion,
    required String comentario,
  }) async {
    print('🔧 ResenaService.crearResena()');
    print(
      '  Usuario ID: $usuarioId, Finca ID: $fincaId, Reserva ID: $reservaId',
    );
    print('  Calificación: $calificacion estrellas');

    try {
      final body = jsonEncode({
        'usuario': {'id': usuarioId},
        'finca': {'id': fincaId},
        if (reservaId != null) 'reserva': {'id': reservaId},
        'calificacion': calificacion,
        'comentario': comentario,
      });

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/resenas'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(ApiConfig.connectTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('✅ Reseña creada exitosamente');
        return Resena.fromJson(json);
      }

      print('❌ Error al crear reseña: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  /// Obtener todas las reseñas
  Future<List<Resena>> obtenerTodasResenas() async {
    print('🔧 ResenaService.obtenerTodasResenas()');

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/resenas'),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resenas = data.map((json) => Resena.fromJson(json)).toList();
        print('✅ ${resenas.length} reseñas obtenidas');
        return resenas;
      }

      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  /// Obtener reseñas de una finca
  Future<List<Resena>> obtenerResenasPorFinca(int fincaId) async {
    print('🔧 ResenaService.obtenerResenasPorFinca($fincaId)');

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/resenas/finca/$fincaId'),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resenas = data.map((json) => Resena.fromJson(json)).toList();
        print('✅ ${resenas.length} reseñas de la finca $fincaId');
        return resenas;
      }

      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  /// Obtener reseñas de un usuario
  Future<List<Resena>> obtenerResenasPorUsuario(int usuarioId) async {
    print('🔧 ResenaService.obtenerResenasPorUsuario($usuarioId)');

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/resenas/usuario/$usuarioId'),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resenas = data.map((json) => Resena.fromJson(json)).toList();
        print('✅ ${resenas.length} reseñas del usuario');
        return resenas;
      }

      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  /// Obtener reseña de una reserva específica
  Future<Resena?> obtenerResenaPorReserva(int reservaId) async {
    print('🔧 ResenaService.obtenerResenaPorReserva($reservaId)');

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/resenas/reserva/$reservaId'),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Resena.fromJson(json);
      }

      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  /// Filtrar reseñas por calificación mínima
  Future<List<Resena>> obtenerResenasPorCalificacionMinima({
    required int fincaId,
    required int calificacionMinima,
  }) async {
    print('🔧 ResenaService.obtenerResenasPorCalificacionMinima()');
    print('  Finca: $fincaId, Calificación mínima: $calificacionMinima');

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/finca/$fincaId/calificacion-minima/$calificacionMinima',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resenas = data.map((json) => Resena.fromJson(json)).toList();
        print(
          '✅ ${resenas.length} reseñas con mínimo $calificacionMinima estrellas',
        );
        return resenas;
      }

      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  /// Actualizar reseña
  Future<bool> actualizarResena({
    required String resenaId,
    required int usuarioId,
    required int calificacion,
    required String comentario,
  }) async {
    print('🔧 ResenaService.actualizarResena()');

    try {
      final body = jsonEncode({
        'calificacion': calificacion,
        'comentario': comentario,
      });

      final response = await http
          .put(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/$resenaId/usuario/$usuarioId',
            ),
            headers: _authHeaders,
            body: body,
          )
          .timeout(ApiConfig.connectTimeout);

      final success = response.statusCode == 200;
      print(success ? '✅ Reseña actualizada' : '❌ Error al actualizar');
      return success;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Eliminar reseña
  Future<bool> eliminarResena(String resenaId, int usuarioId) async {
    print('🔧 ResenaService.eliminarResena($resenaId)');

    try {
      final response = await http
          .delete(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/$resenaId/usuario/$usuarioId',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.connectTimeout);

      final success = response.statusCode == 200 || response.statusCode == 204;
      print(success ? '✅ Reseña eliminada' : '❌ Error al eliminar');
      return success;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  // ==================== RESPUESTAS DEL PROPIETARIO ====================

  /// Agregar respuesta del propietario
  Future<bool> agregarRespuesta({
    required String resenaId,
    required int propietarioId,
    required String respuesta,
  }) async {
    print('🔧 ResenaService.agregarRespuesta()');

    try {
      final body = jsonEncode({'respuesta': respuesta});

      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/$resenaId/respuesta/propietario/$propietarioId',
            ),
            headers: _authHeaders,
            body: body,
          )
          .timeout(ApiConfig.connectTimeout);

      final success = response.statusCode == 200;
      print(success ? '✅ Respuesta agregada' : '❌ Error al agregar respuesta');
      return success;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Actualizar respuesta del propietario
  Future<bool> actualizarRespuesta({
    required String resenaId,
    required int propietarioId,
    required String respuesta,
  }) async {
    print('🔧 ResenaService.actualizarRespuesta()');

    try {
      final body = jsonEncode({'respuesta': respuesta});

      final response = await http
          .put(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/$resenaId/respuesta/propietario/$propietarioId',
            ),
            headers: _authHeaders,
            body: body,
          )
          .timeout(ApiConfig.connectTimeout);

      final success = response.statusCode == 200;
      print(
        success ? '✅ Respuesta actualizada' : '❌ Error al actualizar respuesta',
      );
      return success;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Eliminar respuesta del propietario
  Future<bool> eliminarRespuesta(String resenaId, int propietarioId) async {
    print('🔧 ResenaService.eliminarRespuesta()');

    try {
      final response = await http
          .delete(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/$resenaId/respuesta/propietario/$propietarioId',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.connectTimeout);

      final success = response.statusCode == 200 || response.statusCode == 204;
      print(
        success ? '✅ Respuesta eliminada' : '❌ Error al eliminar respuesta',
      );
      return success;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Obtener reseñas con respuesta del propietario
  Future<List<Resena>> obtenerResenasConRespuesta(int fincaId) async {
    print('🔧 ResenaService.obtenerResenasConRespuesta($fincaId)');

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/finca/$fincaId/con-respuesta',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resenas = data.map((json) => Resena.fromJson(json)).toList();
        print('✅ ${resenas.length} reseñas con respuesta');
        return resenas;
      }

      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  /// Obtener reseñas sin respuesta del propietario
  Future<List<Resena>> obtenerResenasSinRespuesta(int fincaId) async {
    print('🔧 ResenaService.obtenerResenasSinRespuesta($fincaId)');

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/finca/$fincaId/sin-respuesta',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final resenas = data.map((json) => Resena.fromJson(json)).toList();
        print('✅ ${resenas.length} reseñas sin respuesta');
        return resenas;
      }

      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  // ==================== ESTADÍSTICAS ====================

  /// Obtener estadísticas de reseñas de una finca
  Future<EstadisticasResenas?> obtenerEstadisticas(int fincaId) async {
    print('🔧 ResenaService.obtenerEstadisticas($fincaId)');

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/finca/$fincaId/estadisticas',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final stats = EstadisticasResenas.fromJson(json);
        print(
          '✅ Promedio: ${stats.promedioCalificacion}, Total: ${stats.totalResenas}',
        );
        return stats;
      }

      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  /// Obtener promedio de calificación
  Future<double?> obtenerPromedioCalificacion(int fincaId) async {
    print('🔧 ResenaService.obtenerPromedioCalificacion($fincaId)');

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/finca/$fincaId/promedio',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final promedio = double.parse(response.body);
        print('✅ Promedio: $promedio');
        return promedio;
      }

      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  // ==================== VALIDACIONES ====================

  /// Verificar si un usuario puede reseñar una finca
  Future<bool> puedeResenar({
    required int usuarioId,
    required int fincaId,
  }) async {
    print('🔧 ResenaService.puedeResenar()');
    print('  Usuario: $usuarioId, Finca: $fincaId');

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/puede-resenar?usuarioId=$usuarioId&fincaId=$fincaId',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final puede = response.body.toLowerCase() == 'true';
        print(puede ? '✅ Puede reseñar' : '❌ No puede reseñar');
        return puede;
      }

      return false;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Verificar si una reserva ya tiene reseña
  Future<bool> reservaTieneResena(int reservaId) async {
    print('🔧 ResenaService.reservaTieneResena($reservaId)');

    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/resenas/reserva/$reservaId/tiene-resena',
            ),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final tiene = response.body.toLowerCase() == 'true';
        print(tiene ? '✅ Ya tiene reseña' : '❌ No tiene reseña');
        return tiene;
      }

      return false;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }
}
