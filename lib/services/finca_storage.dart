import '../models/finca.dart';

/// Singleton para manejar el estado global de las fincas
/// Simula una base de datos local temporal
class FincaStorage {
  static final FincaStorage _instance = FincaStorage._internal();
  factory FincaStorage() => _instance;
  FincaStorage._internal();

  // Lista de todas las fincas (incluye las del sistema + las del usuario)
  final List<Finca> _todasLasFincas = [];

  // Lista de fincas del usuario actual
  final List<Finca> _misFincas = [];

  // ID del usuario actual (simulado)
  final String _usuarioActualId = 'user-current';

  /// Inicializar con fincas de ejemplo
  void inicializarFincasEjemplo() {
    if (_todasLasFincas.isEmpty) {
      _todasLasFincas.addAll(_crearFincasEjemplo());
    }
  }

  /// Agregar una nueva finca
  void agregarFinca(Finca finca) {
    _todasLasFincas.add(finca);
    _misFincas.add(finca);
  }

  /// Obtener todas las fincas
  List<Finca> obtenerTodasLasFincas() {
    return List.from(_todasLasFincas);
  }

  /// Obtener solo las fincas del usuario actual
  List<Finca> obtenerMisFincas() {
    return List.from(_misFincas);
  }

  /// Buscar fincas por término de búsqueda
  List<Finca> buscarFincas(String termino) {
    if (termino.isEmpty) return obtenerTodasLasFincas();

    final terminoLower = termino.toLowerCase();
    return _todasLasFincas.where((finca) {
      return finca.titulo.toLowerCase().contains(terminoLower) ||
          finca.descripcion.toLowerCase().contains(terminoLower) ||
          finca.ubicacion.toLowerCase().contains(terminoLower) ||
          finca.ciudad.toLowerCase().contains(terminoLower) ||
          finca.departamento.toLowerCase().contains(terminoLower);
    }).toList();
  }

  /// Filtrar fincas por criterios específicos
  List<Finca> filtrarFincas({
    double? precioMaximo,
    int? capacidadMinima,
    List<String>? servicios,
    TipoFinca? tipo,
  }) {
    return _todasLasFincas.where((finca) {
      // Filtro por precio máximo
      if (precioMaximo != null && finca.precio > precioMaximo) {
        return false;
      }

      // Filtro por capacidad mínima
      if (capacidadMinima != null && finca.capacidadMaxima < capacidadMinima) {
        return false;
      }

      // Filtro por servicios
      if (servicios != null && servicios.isNotEmpty) {
        bool tieneServicios = servicios.every(
          (servicio) => finca.servicios.contains(servicio),
        );
        if (!tieneServicios) return false;
      }

      // Filtro por tipo
      if (tipo != null && finca.tipo != tipo) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Eliminar finca del usuario
  void eliminarMiFinca(String fincaId) {
    _misFincas.removeWhere((finca) => finca.id == fincaId);
    _todasLasFincas.removeWhere(
      (finca) => finca.id == fincaId && finca.propietarioId == _usuarioActualId,
    );
  }

  /// Crear fincas de ejemplo para el sistema
  List<Finca> _crearFincasEjemplo() {
    return [
      Finca(
        id: 'finca-ejemplo-1',
        titulo: 'Villa Campestre Los Robles',
        descripcion:
            'Hermosa villa rodeada de naturaleza, perfecta para descansar en familia. Cuenta con amplios jardines, piscina y zona de BBQ.',
        precio: 350000,
        ubicacion: 'Vereda El Roble, La Calera',
        ciudad: 'La Calera',
        departamento: 'Cundinamarca',
        latitud: 4.7297,
        longitud: -73.9686,
        imagenes: [
          'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop&auto=format',
        ],
        propietarioId: 'propietario-1',
        capacidadMaxima: 8,
        numeroHabitaciones: 4,
        numeroBanos: 3,
        servicios: ['Piscina', 'WiFi', 'Parqueadero', 'Zona BBQ', 'Jardín'],
        actividades: ['Senderismo', 'Observación de aves', 'Ciclismo'],
        disponible: true,
        calificacion: 4.8,
        numeroReviews: 24,
        fechaCreacion: DateTime.now().subtract(const Duration(days: 60)),
        tipo: TipoFinca.casa,
        reglas: [
          ReglaFinca(
            id: 'regla-1',
            titulo: 'No fumar',
            descripcion: 'No se permite fumar en áreas interiores',
            esObligatoria: true,
          ),
        ],
      ),
      Finca(
        id: 'finca-ejemplo-2',
        titulo: 'Cabaña Rústica El Refugio',
        descripcion:
            'Acogedora cabaña de madera con chimenea, ideal para parejas. Ubicada en un bosque de pinos con vista a las montañas.',
        precio: 180000,
        ubicacion: 'Km 15 Vía Chocontá',
        ciudad: 'Chocontá',
        departamento: 'Cundinamarca',
        latitud: 5.1442,
        longitud: -73.6838,
        imagenes: [
          'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&h=600&fit=crop&auto=format',
        ],
        propietarioId: 'propietario-2',
        capacidadMaxima: 4,
        numeroHabitaciones: 2,
        numeroBanos: 1,
        servicios: ['WiFi', 'Chimenea', 'Cocina Equipada', 'Vista Panorámica'],
        actividades: ['Senderismo', 'Fogata', 'Observación de estrellas'],
        disponible: true,
        calificacion: 4.6,
        numeroReviews: 18,
        fechaCreacion: DateTime.now().subtract(const Duration(days: 45)),
        tipo: TipoFinca.cabana,
        reglas: [
          ReglaFinca(
            id: 'regla-2',
            titulo: 'Mascotas no permitidas',
            descripcion: 'No se aceptan mascotas en esta propiedad',
            esObligatoria: true,
          ),
        ],
      ),
      Finca(
        id: 'finca-ejemplo-3',
        titulo: 'Hacienda Santa Elena',
        descripcion:
            'Amplia hacienda tradicional con múltiples actividades. Perfecta para eventos familiares y empresariales.',
        precio: 500000,
        ubicacion: 'Vereda Santa Elena, Guatavita',
        ciudad: 'Guatavita',
        departamento: 'Cundinamarca',
        latitud: 4.9306,
        longitud: -73.8344,
        imagenes: [
          'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=800&h=600&fit=crop&auto=format',
        ],
        propietarioId: 'propietario-3',
        capacidadMaxima: 20,
        numeroHabitaciones: 8,
        numeroBanos: 6,
        servicios: [
          'Piscina',
          'WiFi',
          'Parqueadero',
          'Zona BBQ',
          'Jardín',
          'Zona de Juegos',
          'Aire Acondicionado',
        ],
        actividades: ['Cabalgatas', 'Pesca', 'Volleyball', 'Fútbol'],
        disponible: true,
        calificacion: 4.9,
        numeroReviews: 35,
        fechaCreacion: DateTime.now().subtract(const Duration(days: 90)),
        tipo: TipoFinca.hacienda,
        reglas: [
          ReglaFinca(
            id: 'regla-3',
            titulo: 'Eventos solo con autorización',
            descripcion: 'Los eventos deben ser coordinados previamente',
            esObligatoria: true,
          ),
        ],
      ),
    ];
  }
}
