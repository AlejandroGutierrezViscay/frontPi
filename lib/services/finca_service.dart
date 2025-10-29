import '../models/finca.dart';
import '../models/reserva.dart';
import 'finca_storage.dart';

class FincaService {
  // URL base de la API - cambiar por tu URL real
  static const String baseUrl =
      'https://api.fincarent.com'; // TODO: Actualizar con URL real

  // Headers por defecto
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Singleton
  static final FincaService _instance = FincaService._internal();
  factory FincaService() => _instance;
  FincaService._internal();

  // Token de autenticación (se obtiene del AuthService)
  String? _authToken;

  // Storage local
  final FincaStorage _storage = FincaStorage();

  // Setter para el token de autenticación
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Headers con autenticación
  Map<String, String> get _authHeaders {
    final headers = Map<String, String>.from(_headers);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Obtener todas las fincas con filtros opcionales
  Future<List<Finca>> obtenerFincas({FiltrosBusqueda? filtros}) async {
    try {
      // Inicializar fincas de ejemplo si es la primera vez
      _storage.inicializarFincasEjemplo();

      // En desarrollo, usar storage local
      List<Finca> fincas = _storage.obtenerTodasLasFincas();

      // Aplicar filtros si existen
      if (filtros != null) {
        fincas = _storage.filtrarFincas(
          precioMaximo: filtros.precioMax,
          capacidadMinima: filtros.capacidadMinima,
          servicios: filtros.servicios,
        );
      }

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));
      return fincas;
    } catch (e) {
      // En caso de error, retornar lista vacía
      return [];
    }
  }

  // Buscar fincas por texto
  Future<List<Finca>> buscarFincas(String query) async {
    try {
      // Inicializar fincas de ejemplo si es la primera vez
      _storage.inicializarFincasEjemplo();

      // En desarrollo, usar storage local
      final fincas = _storage.buscarFincas(query);

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));
      return fincas;
    } catch (e) {
      return [];
    }
  }

  // Crear nueva finca
  Future<Finca> crearFinca({
    required String titulo,
    required String descripcion,
    required double precio,
    required String ubicacion,
    required String ciudad,
    required String departamento,
    required int capacidadMaxima,
    required int numeroHabitaciones,
    required int numeroBanos,
    required TipoFinca tipo,
    required List<String> servicios,
    required List<String> actividades,
    List<String> imagenes = const [],
    List<ReglaFinca> reglas = const [],
    double? area,
  }) async {
    try {
      // Simular creación exitosa con storage local
      await Future.delayed(const Duration(seconds: 1));

      final nuevaFinca = Finca(
        id: 'finca-${DateTime.now().millisecondsSinceEpoch}',
        titulo: titulo,
        descripcion: descripcion,
        precio: precio,
        ubicacion: ubicacion,
        ciudad: ciudad,
        departamento: departamento,
        latitud: 4.5709, // Coordenadas de ejemplo (Bogotá)
        longitud: -74.2973,
        imagenes: imagenes,
        propietarioId: 'user-current', // Usuario actual
        capacidadMaxima: capacidadMaxima,
        numeroHabitaciones: numeroHabitaciones,
        numeroBanos: numeroBanos,
        servicios: servicios,
        actividades: actividades,
        disponible: true,
        calificacion: 0.0,
        numeroReviews: 0,
        fechaCreacion: DateTime.now(),
        tipo: tipo,
        reglas: reglas,
      );

      // Agregar al storage local
      _storage.agregarFinca(nuevaFinca);
      return nuevaFinca;
    } catch (e) {
      throw Exception('Error al crear finca: $e');
    }
  }

  // Obtener fincas del usuario actual
  Future<List<Finca>> obtenerMisFincas() async {
    try {
      // Inicializar fincas de ejemplo si es la primera vez
      _storage.inicializarFincasEjemplo();

      // En desarrollo, usar storage local
      final fincas = _storage.obtenerMisFincas();

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));
      return fincas;
    } catch (e) {
      return [];
    }
  }

  // Eliminar finca del usuario
  Future<bool> eliminarFinca(String fincaId) async {
    try {
      _storage.eliminarMiFinca(fincaId);
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Métodos adicionales que pueden ser útiles más adelante
  Future<List<Finca>> obtenerFincasFavoritas() async {
    // TODO: Implementar cuando se agregue funcionalidad de favoritos
    return [];
  }

  Future<List<Reserva>> obtenerReservas() async {
    // TODO: Implementar cuando se agregue funcionalidad de reservas
    return [];
  }
}
