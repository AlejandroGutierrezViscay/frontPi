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
      final response = await http.get(Uri.parse(url), headers: _authHeaders).timeout(ApiConfig.receiveTimeout);
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
      final response = await http.get(Uri.parse(url), headers: _authHeaders).timeout(ApiConfig.receiveTimeout);
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

  Future<Reserva?> crearReserva({required int usuarioId, required int fincaId, required String fechaInicio, required String fechaFin}) async {
    print('🔧 ReservaService.crearReserva()');
    try {
      final body = jsonEncode({'usuario': {'id': usuarioId}, 'finca': {'id': fincaId}, 'fechaInicio': fechaInicio, 'fechaFin': fechaFin, 'estado': 'PENDIENTE'});
      final response = await http.post(Uri.parse(ApiConfig.reservasUrl), headers: _authHeaders, body: body).timeout(ApiConfig.connectTimeout);
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
      final response = await http.patch(Uri.parse(url), headers: _authHeaders).timeout(ApiConfig.connectTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Reserva _parseReserva(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'].toString(),
      fincaId: json['finca']?['id']?.toString() ?? '',
      usuarioId: json['usuario']?['id']?.toString() ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      numeroHuespedes: json['numeroHuespedes'] ?? 1,
      precioTotal: (json['precioTotal'] ?? 0.0).toDouble(),
      precioNoche: (json['precioNoche'] ?? 0.0).toDouble(),
      numeroNoches: json['numeroNoches'] ?? 1,
      estado: _parseEstadoReserva(json['estado']),
      fechaCreacion: json['fechaCreacion'] != null ? DateTime.parse(json['fechaCreacion']) : DateTime.now(),
      fechaCancelacion: json['fechaCancelacion'] != null ? DateTime.parse(json['fechaCancelacion']) : null,
      motivoCancelacion: json['motivoCancelacion'],
      notasEspeciales: json['notasEspeciales'],
      datosContacto: DatosContacto(
        nombreCompleto: json['usuario']?['nombre'] ?? '',
        email: json['usuario']?['email'] ?? '',
        telefono: json['usuario']?['telefono'] ?? '',
      ),
      serviciosAdicionales: json['serviciosAdicionales'] != null ? List<String>.from(json['serviciosAdicionales']) : null,
    );
  }

  EstadoReserva _parseEstadoReserva(String? estado) {
    if (estado == null) return EstadoReserva.pendiente;
    switch (estado.toUpperCase()) {
      case 'PENDIENTE': return EstadoReserva.pendiente;
      case 'CONFIRMADA': return EstadoReserva.confirmada;
      case 'CANCELADA': return EstadoReserva.cancelada;
      case 'COMPLETADA': return EstadoReserva.completada;
      default: return EstadoReserva.pendiente;
    }
  }
}
