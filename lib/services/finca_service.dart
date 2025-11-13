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
          .get(Uri.parse(ApiConfig.fincasUrl), headers: ApiConfig.headers)
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('  📦 Datos recibidos: ${data.length} fincas en JSON');

        List<Finca> fincas = [];
        for (var i = 0; i < data.length; i++) {
          try {
            final finca = _parseFinca(data[i]);
            fincas.add(finca);
          } catch (e) {
            print('  ⚠️ Error parseando finca ${i + 1}: $e');
          }
        }

        print('✅ ${fincas.length} fincas parseadas correctamente');

        for (var finca in fincas) {
          print(
            '  - "${finca.nombre}" (ID: ${finca.id}) - \$${finca.precioPorNoche}',
          );
        }

        // Aplicar filtros si existen
        if (filtros != null) {
          fincas = _aplicarFiltros(fincas, filtros);
          print('  Después de filtros: ${fincas.length} fincas');
        }

        return fincas;
      } else {
        print('❌ Error ${response.statusCode}');
        print('   Response: ${response.body}');
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
          .get(Uri.parse(url), headers: ApiConfig.headers)
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final finca = _parseFinca(json);
        print('✅ Finca obtenida: ${finca.nombre}');
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
          .get(Uri.parse(url), headers: ApiConfig.headers)
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
          .get(Uri.parse(url), headers: ApiConfig.headers)
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
      final url =
          '${ApiConfig.fincasUrl}/buscar/precio-max?maxPrecio=$precioMax';
      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers)
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
    List<String>? amenidades,
  }) async {
    print('🔧 FincaService.crearFinca()');
    print('  Amenidades: $amenidades');

    try {
      // Construir el mapa de datos
      final Map<String, dynamic> data = {
        'nombre': nombre,
        'ubicacion': ubicacion,
        'precioPorNoche': precioPorNoche,
        'descripcion': descripcion,
        'propietario': {'id': propietarioId},
      };

      // Agregar amenidades si existen
      if (amenidades != null && amenidades.isNotEmpty) {
        data['amenidades'] = amenidades
            .map((nombre) => {'nombre': nombre})
            .toList();
      }

      final body = jsonEncode(data);

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
        print('✅ Finca creada: ${finca.nombre}');
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
          .get(Uri.parse(url), headers: _authHeaders)
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
          .delete(Uri.parse(url), headers: _authHeaders)
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
          .patch(Uri.parse(url), headers: _authHeaders)
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
          .get(Uri.parse(url), headers: ApiConfig.headers)
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
    try {
      return Finca(
        id: json['id']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? 'Sin nombre',
        descripcion: json['descripcion']?.toString() ?? '',
        precioPorNoche: _parseDouble(json['precioPorNoche']),
        ubicacion: json['ubicacion']?.toString() ?? '',
        imagenes: _parseImagenes(json['imagenes']),
        propietario: json['propietario'] is Map<String, dynamic>
            ? json['propietario']
            : {},
        amenidades: _parseAmenidades(json['amenidades']),
      );
    } catch (e) {
      print('❌ Error parseando finca: $e');
      print('   JSON: $json');
      rethrow;
    }
  }

  // Helper para parsear precio de manera segura
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Parser para imágenes
  List<ImagenFinca> _parseImagenes(dynamic imagenesJson) {
    if (imagenesJson == null) {
      print('    ⚠️ No hay imágenes en JSON');
      return [];
    }
    if (imagenesJson is List) {
      print('    📸 Parseando ${imagenesJson.length} imágenes');
      final imagenes = imagenesJson.map((img) {
        if (img is Map<String, dynamic>) {
          final urlImagen = img['urlImagen']?.toString() ?? '';
          print(
            '      - Imagen ID ${img['id']}: ${urlImagen.length > 50 ? "${urlImagen.substring(0, 50)}..." : urlImagen}',
          );
          return ImagenFinca(
            id: img['id']?.toString() ?? '',
            urlImagen: urlImagen,
            esPrincipal: img['esPrincipal'] ?? false,
          );
        }
        return ImagenFinca(
          id: '',
          urlImagen: img.toString(),
          esPrincipal: false,
        );
      }).toList();
      print('    ✅ ${imagenes.length} imágenes parseadas');
      return imagenes;
    }
    return [];
  }

  // Parser para amenidades
  List<Amenidad> _parseAmenidades(dynamic amenidadesJson) {
    if (amenidadesJson == null) return [];
    if (amenidadesJson is List) {
      return amenidadesJson.map((amenidad) {
        if (amenidad is Map<String, dynamic>) {
          return Amenidad(
            id: amenidad['id']?.toString() ?? '',
            nombre: amenidad['nombre']?.toString() ?? '',
            icono: amenidad['icono']?.toString(),
          );
        }
        return Amenidad(id: '', nombre: amenidad.toString());
      }).toList();
    }
    return [];
  }

  // Aplicar filtros localmente a la lista de fincas
  List<Finca> _aplicarFiltros(List<Finca> fincas, FiltrosBusqueda filtros) {
    return fincas.where((finca) {
      // Filtro por precio máximo
      if (filtros.precioMax != null &&
          finca.precioPorNoche > filtros.precioMax!) {
        return false;
      }

      return true;
    }).toList();
  }

  // Agregar amenidades a una finca existente
  Future<bool> agregarAmenidadesAFinca({
    required int fincaId,
    required List<String> nombresAmenidades,
  }) async {
    print('🏷️ FincaService.agregarAmenidadesAFinca()');
    print('  Finca ID: $fincaId');
    print('  Amenidades: $nombresAmenidades');

    try {
      // Paso 1: Obtener todas las amenidades disponibles del backend
      final amenidadesResponse = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/amenidades'),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (amenidadesResponse.statusCode != 200) {
        print(
          '❌ Error al obtener amenidades: ${amenidadesResponse.statusCode}',
        );
        return false;
      }

      final List<dynamic> amenidadesData = jsonDecode(amenidadesResponse.body);

      // Paso 2: Mapear nombres a IDs
      List<int> amenidadesIds = [];
      for (String nombre in nombresAmenidades) {
        // Normalizar el nombre de búsqueda
        String nombreBusqueda = nombre.trim().toLowerCase();

        // Buscar la amenidad por nombre (buscar coincidencias parciales en ambas direcciones)
        final amenidad = amenidadesData.firstWhere((a) {
          String nombreBackend = (a['nombre'] as String).toLowerCase();
          // Buscar si el nombre del backend contiene el de la UI O viceversa
          return nombreBackend.contains(nombreBusqueda) ||
              nombreBusqueda.contains(nombreBackend) ||
              nombreBackend == nombreBusqueda;
        }, orElse: () => null);

        if (amenidad != null && amenidad['id'] != null) {
          amenidadesIds.add(amenidad['id'] as int);
          print(
            '  ✓ "$nombre" → "${amenidad['nombre']}" (ID ${amenidad['id']})',
          );
        } else {
          print('  ⚠️ No se encontró amenidad: "$nombre"');
          print('     Amenidades disponibles en backend:');
          for (var a in amenidadesData.take(5)) {
            print('       - ${a['nombre']}');
          }
        }
      }

      if (amenidadesIds.isEmpty) {
        print('⚠️ No se encontraron IDs de amenidades válidos');
        print('   Nombres recibidos: $nombresAmenidades');
        print('   Total de amenidades en backend: ${amenidadesData.length}');
        return false;
      }

      // Paso 3: Enviar IDs al endpoint batch
      final url = '${ApiConfig.baseUrl}/api/fincas/$fincaId/amenidades/batch';
      final body = jsonEncode(amenidadesIds);

      print('  URL: $url');
      print('  IDs a enviar: $amenidadesIds');
      print('  Body JSON: $body');

      final response = await http
          .post(Uri.parse(url), headers: ApiConfig.headers, body: body)
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Amenidades agregadas exitosamente al backend');
        final responseBody = jsonDecode(response.body);
        if (responseBody['amenidades'] != null) {
          print(
            '   Amenidades en respuesta: ${(responseBody['amenidades'] as List).length}',
          );
        }
        return true;
      } else {
        print('❌ Error ${response.statusCode} al agregar amenidades');
        print('   Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión al agregar amenidades: $e');
      return false;
    }
  }

  // Agregar imagen a una finca existente
  Future<bool> agregarImagenAFinca({
    required int fincaId,
    required String urlImagen,
    required bool esPrincipal,
  }) async {
    print('🖼️ FincaService.agregarImagenAFinca()');
    print('  Finca ID: $fincaId');
    print('  Es Principal: $esPrincipal');

    try {
      final url = '${ApiConfig.baseUrl}/api/imagenes/finca/$fincaId';

      final body = jsonEncode({
        'urlImagen': urlImagen, // Campo correcto del backend
        'esPrincipal': esPrincipal,
        'orden': 0,
      });

      print('  URL: $url');
      print('  Tamaño imagen: ${urlImagen.length} caracteres');
      print(
        '  Primeros 50 chars: ${urlImagen.substring(0, urlImagen.length > 50 ? 50 : urlImagen.length)}...',
      );

      final response = await http
          .post(Uri.parse(url), headers: ApiConfig.headers, body: body)
          .timeout(ApiConfig.receiveTimeout);

      print('  Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Imagen agregada exitosamente');
        final imagenGuardada = jsonDecode(response.body);
        print('   Imagen guardada con ID: ${imagenGuardada['id']}');
        print(
          '   URL guardada: ${imagenGuardada['urlImagen']?.substring(0, 50)}...',
        );
        return true;
      } else {
        print('❌ Error ${response.statusCode} al agregar imagen');
        print('   Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error de conexión al agregar imagen: $e');
      return false;
    }
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
