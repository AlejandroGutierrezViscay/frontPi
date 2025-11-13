import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reserva.dart';
import '../config/api_config.dart';

class ReservaService {
  static final ReservaService _instance = ReservaService._internal();
  factory ReservaService() => _instance;
  ReservaService._internal();

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

  Future<List<Reserva>> obtenerMisReservas(int usuarioId) async {
    print('🔧 ReservaService.obtenerMisReservas($usuarioId)');
    try {
      final url = '${ApiConfig.reservasUrl}/usuario/$usuarioId';
      final response = await http
          .get(Uri.parse(url), headers: _authHeaders)
          .timeout(ApiConfig.receiveTimeout);
      print('  Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final reservas = data.map((json) => _parseReserva(json)).toList();
        print('✅ ${reservas.length} reservas obtenidas');
        return reservas;
      }
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  Future<Reserva?> obtenerReservaPorId(String id) async {
    print('�� ReservaService.obtenerReservaPorId($id)');
    try {
      final url = '${ApiConfig.reservasUrl}/$id';
      final response = await http
          .get(Uri.parse(url), headers: _authHeaders)
          .timeout(ApiConfig.receiveTimeout);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return _parseReserva(json);
      }
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  Future<Reserva?> crearReserva({
    required int usuarioId,
    required int fincaId,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    print('🔧 ReservaService.crearReserva()');
    try {
      final body = jsonEncode({
        'usuario': {'id': usuarioId},
        'finca': {'id': fincaId},
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'estado': 'PENDIENTE',
      });
      final response = await http
          .post(
            Uri.parse(ApiConfig.reservasUrl),
            headers: _authHeaders,
            body: body,
          )
          .timeout(ApiConfig.connectTimeout);
      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        print('✅ Reserva creada');
        return _parseReserva(json);
      }
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  Future<bool> cancelarReserva(String id) async {
    try {
      final url = '${ApiConfig.reservasUrl}/$id/cancelar';
      final response = await http
          .patch(Uri.parse(url), headers: _authHeaders)
          .timeout(ApiConfig.connectTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si una finca está disponible en un rango de fechas
  /// Retorna true si está disponible, false si ya hay reservas en esas fechas
  Future<bool> verificarDisponibilidad({
    required int fincaId,
    required String fechaInicio, // Formato: YYYY-MM-DD
    required String fechaFin, // Formato: YYYY-MM-DD
  }) async {
    print('🔍 ReservaService.verificarDisponibilidad()');
    print('  Finca ID: $fincaId');
    print('  Fechas: $fechaInicio a $fechaFin');

    try {
      final url =
          '${ApiConfig.reservasUrl}/disponibilidad?fincaId=$fincaId&fechaInicio=$fechaInicio&fechaFin=$fechaFin';
      print('  URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _authHeaders)
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bool disponible = jsonDecode(response.body) as bool;
        print(
          disponible
              ? '✅ Fechas disponibles'
              : '❌ Fechas NO disponibles (ya reservadas)',
        );
        return disponible;
      }

      print('❌ Error al verificar disponibilidad');
      return false;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  Reserva _parseReserva(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'].toString(),
      finca: json['finca'] ?? {},
      usuario: json['usuario'] ?? {},
      fechaInicio: DateTime.parse(json['fechaInicio'] ?? ''),
      fechaFin: DateTime.parse(json['fechaFin'] ?? ''),
      precioTotal: (json['precioTotal'] ?? 0.0).toDouble(),
      estado: _parseEstadoReserva(json['estado']),
    );
  }

  EstadoReserva _parseEstadoReserva(String? estado) {
    if (estado == null) return EstadoReserva.PENDIENTE;
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return EstadoReserva.PENDIENTE;
      case 'CONFIRMADA':
        return EstadoReserva.CONFIRMADA;
      case 'CANCELADA':
        return EstadoReserva.CANCELADA;
      case 'COMPLETADA':
        return EstadoReserva.COMPLETADA;
      default:
        return EstadoReserva.PENDIENTE;
    }
  }
}
