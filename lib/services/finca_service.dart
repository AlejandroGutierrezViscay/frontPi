import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/finca.dart';
import '../models/reserva.dart';
import '../config/api_config.dart';

class FincaService {
  // Singleton
  static final FincaService _instance = FincaService._internal();
  factory FincaService() => _instance;
  FincaService._internal();

  // Token de autenticación (se obtiene del AuthService)
  String? _authToken;

  // Setter para el token de autenticación
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Headers con autenticación
  Map<String, String> get _authHeaders {
    if (_authToken != null) {
      return ApiConfig.headersWithAuth(_authToken!);
    }
    return ApiConfig.headers;
  }

  // Obtener todas las fincas disponibles
  Future<List<Finca>> obtenerFincas({FiltrosBusqueda? filtros}) async {
    print('🔧 FincaService.obtenerFincas()');
    print('  URL: ${ApiConfig.fincasUrl}');

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.fincasUrl),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Finca> fincas = data.map((json) => _parseFinca(json)).toList();

        print('✅ ${fincas.length} fincas obtenidas');

        // Aplicar filtros si existen
        if (filtros != null) {
          fincas = _aplicarFiltros(fincas, filtros);
          print('  Después de filtros: ${fincas.length} fincas');
        }

        return fincas;
      } else {
        print('❌ Error ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return [];
    }
  }

  // Obtener finca por ID
  Future<Finca?> obtenerFincaPorId(String id) async {
    print('🔧 FincaService.obtenerFincaPorId($id)');

    try {
      final url = '${ApiConfig.fincasUrl}/$id';
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final finca = _parseFinca(json);
        print('✅ Finca obtenida: ${finca.titulo}');
        return finca;
      } else {
        print('❌ Finca no encontrada');
        return null;
      }
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  // Buscar fincas por nombre
  Future<List<Finca>> buscarFincas(String query) async {
    print('🔧 FincaService.buscarFincas("$query")');

    try {
      final url = '${ApiConfig.fincasUrl}/buscar/nombre?nombre=$query';
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fincas = data.map((json) => _parseFinca(json)).toList();
        print('✅ ${fincas.length} fincas encontradas');
        return fincas;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  // Buscar fincas por ubicación
  Future<List<Finca>> buscarPorUbicacion(String ubicacion) async {
    print('🔧 FincaService.buscarPorUbicacion("$ubicacion")');

    try {
      final url =
          '${ApiConfig.fincasUrl}/buscar/ubicacion?ubicacion=$ubicacion';
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fincas = data.map((json) => _parseFinca(json)).toList();
        print('✅ ${fincas.length} fincas encontradas');
        return fincas;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  // Buscar fincas por precio máximo
  Future<List<Finca>> buscarPorPrecioMax(double precioMax) async {
    print('🔧 FincaService.buscarPorPrecioMax($precioMax)');

    try {
      final url = '${ApiConfig.fincasUrl}/buscar/precio-max?maxPrecio=$precioMax';
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fincas = data.map((json) => _parseFinca(json)).toList();
        print('✅ ${fincas.length} fincas encontradas');
        return fincas;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  // Crear nueva finca
  Future<Finca?> crearFinca({
    required String nombre,
    required String descripcion,
    required double precioPorNoche,
    required String ubicacion,
    required int propietarioId,
  }) async {
    print('🔧 FincaService.crearFinca()');

    try {
      final body = jsonEncode({
        'nombre': nombre,
        'ubicacion': ubicacion,
        'precioPorNoche': precioPorNoche,
        'descripcion': descripcion,
        'propietario': {'id': propietarioId},
      });

      final response = await http
          .post(
            Uri.parse(ApiConfig.fincasUrl),
            headers: _authHeaders,
            body: body,
          )
          .timeout(ApiConfig.connectTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final finca = _parseFinca(json);
        print('✅ Finca creada: ${finca.titulo}');
        return finca;
      } else {
        print('❌ Error al crear finca');
        return null;
      }
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  // Obtener fincas del propietario actual
  Future<List<Finca>> obtenerMisFincas(int propietarioId) async {
    print('🔧 FincaService.obtenerMisFincas($propietarioId)');

    try {
      final url = '${ApiConfig.fincasUrl}/propietario/$propietarioId';
      final response = await http
          .get(
            Uri.parse(url),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fincas = data.map((json) => _parseFinca(json)).toList();
        print('✅ ${fincas.length} fincas del propietario');
        return fincas;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  // Eliminar finca
  Future<bool> eliminarFinca(String fincaId) async {
    print('🔧 FincaService.eliminarFinca($fincaId)');

    try {
      final url = '${ApiConfig.fincasUrl}/$fincaId';
      final response = await http
          .delete(
            Uri.parse(url),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.connectTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Finca eliminada');
        return true;
      } else {
        print('❌ Error al eliminar finca');
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  // Actualizar precio de una finca
  Future<bool> actualizarPrecio(String fincaId, double nuevoPrecio) async {
    print('🔧 FincaService.actualizarPrecio($fincaId, $nuevoPrecio)');

    try {
      final url = '${ApiConfig.fincasUrl}/$fincaId/precio?precio=$nuevoPrecio';
      final response = await http
          .patch(
            Uri.parse(url),
            headers: _authHeaders,
          )
          .timeout(ApiConfig.connectTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Precio actualizado');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  // Obtener fincas disponibles
  Future<List<Finca>> obtenerFincasDisponibles() async {
    print('🔧 FincaService.obtenerFincasDisponibles()');

    try {
      final url = '${ApiConfig.fincasUrl}/disponibles';
      final response = await http
          .get(
            Uri.parse(url),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fincas = data.map((json) => _parseFinca(json)).toList();
        print('✅ ${fincas.length} fincas disponibles');
        return fincas;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  // Métodos privados auxiliares

  // Parser para convertir JSON del backend a modelo Finca del frontend
  Finca _parseFinca(Map<String, dynamic> json) {
    return Finca(
      id: json['id'].toString(),
      titulo: json['nombre'] ?? 'Sin título',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precioPorNoche'] ?? 0).toDouble(),
      ubicacion: json['ubicacion'] ?? '',
      ciudad: json['ciudad'] ?? _extraerCiudad(json['ubicacion']),
      departamento:
          json['departamento'] ?? _extraerDepartamento(json['ubicacion']),
      latitud: (json['latitud'] ?? 0.0).toDouble(),
      longitud: (json['longitud'] ?? 0.0).toDouble(),
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : [],
      propietarioId: json['propietario']?['id']?.toString() ?? '',
      capacidadMaxima: json['capacidadMaxima'] ?? 1,
      numeroHabitaciones: json['numeroHabitaciones'] ?? 1,
      numeroBanos: json['numeroBanos'] ?? 1,
      servicios:
          json['servicios'] != null ? List<String>.from(json['servicios']) : [],
      actividades: json['actividades'] != null
          ? List<String>.from(json['actividades'])
          : [],
      disponible: json['disponible'] ?? true,
      calificacion: (json['calificacion'] ?? 0.0).toDouble(),
      numeroReviews: json['numeroReviews'] ?? 0,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : DateTime.now(),
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.parse(json['fechaActualizacion'])
          : null,
      tipo: _parseTipoFinca(json['tipo']),
      reglas: json['reglas'] != null
          ? (json['reglas'] as List)
              .map((r) => ReglaFinca.fromJson(r))
              .toList()
          : [],
    );
  }

  // Extraer ciudad de ubicación (formato: "Ciudad, Departamento")
  String _extraerCiudad(String? ubicacion) {
    if (ubicacion == null || !ubicacion.contains(',')) return '';
    return ubicacion.split(',').first.trim();
  }

  // Extraer departamento de ubicación
  String _extraerDepartamento(String? ubicacion) {
    if (ubicacion == null || !ubicacion.contains(',')) return '';
    final partes = ubicacion.split(',');
    return partes.length > 1 ? partes[1].trim() : '';
  }

  // Parser para tipo de finca
  TipoFinca _parseTipoFinca(String? tipo) {
    if (tipo == null) return TipoFinca.casa;

    switch (tipo.toLowerCase()) {
      case 'finca':
        return TipoFinca.finca;
      case 'casa':
      case 'casa de campo':
        return TipoFinca.casa;
      case 'cabana':
      case 'cabaña':
        return TipoFinca.cabana;
      case 'hacienda':
        return TipoFinca.hacienda;
      case 'lodge':
        return TipoFinca.lodge;
      case 'camping':
        return TipoFinca.camping;
      case 'glamping':
        return TipoFinca.glamping;
      default:
        return TipoFinca.casa;
    }
  }

  // Aplicar filtros localmente a la lista de fincas
  List<Finca> _aplicarFiltros(List<Finca> fincas, FiltrosBusqueda filtros) {
    return fincas.where((finca) {
      // Filtro por precio máximo
      if (filtros.precioMax != null && finca.precio > filtros.precioMax!) {
        return false;
      }

      // Filtro por capacidad mínima
      if (filtros.capacidadMinima != null &&
          finca.capacidadMaxima < filtros.capacidadMinima!) {
        return false;
      }

      // Filtro por servicios (debe tener todos los servicios solicitados)
      if (filtros.servicios != null && filtros.servicios!.isNotEmpty) {
        final tieneServicios = filtros.servicios!.every(
          (servicio) => finca.servicios.contains(servicio),
        );
        if (!tieneServicios) return false;
      }

      // Filtro por tipo de finca
      if (filtros.tipo != null && finca.tipo != filtros.tipo) {
        return false;
      }

      return true;
    }).toList();
  }

  // Métodos de placeholder para funcionalidades futuras
  Future<List<Finca>> obtenerFincasFavoritas() async {
    // TODO: Implementar cuando se agregue funcionalidad de favoritos
    return [];
  }

  Future<List<Reserva>> obtenerReservas() async {
    // TODO: Implementar cuando se agregue funcionalidad de reservas
    return [];
  }
}
