// Modelo para una finca/propiedad rural
class Finca {
  final String id;
  final String titulo;
  final String descripcion;
  final double precio; // Precio por noche
  final String ubicacion;
  final String ciudad;
  final String departamento;
  final double latitud;
  final double longitud;
  final List<String> imagenes;
  final String propietarioId;
  final int capacidadMaxima;
  final int numeroHabitaciones;
  final int numeroBanos;
  final List<String> servicios; // WiFi, piscina, etc.
  final List<String> actividades; // Pesca, senderismo, etc.
  final bool disponible;
  final double calificacion;
  final int numeroReviews;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final TipoFinca tipo;
  final List<ReglaFinca> reglas;

  const Finca({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.ubicacion,
    required this.ciudad,
    required this.departamento,
    required this.latitud,
    required this.longitud,
    required this.imagenes,
    required this.propietarioId,
    required this.capacidadMaxima,
    required this.numeroHabitaciones,
    required this.numeroBanos,
    required this.servicios,
    required this.actividades,
    this.disponible = true,
    this.calificacion = 0.0,
    this.numeroReviews = 0,
    required this.fechaCreacion,
    this.fechaActualizacion,
    required this.tipo,
    this.reglas = const [],
  });

  // Factory constructor para crear desde JSON
  factory Finca.fromJson(Map<String, dynamic> json) {
    return Finca(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      precio: (json['precio'] as num).toDouble(),
      ubicacion: json['ubicacion'] as String,
      ciudad: json['ciudad'] as String,
      departamento: json['departamento'] as String,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      imagenes: List<String>.from(json['imagenes'] as List),
      propietarioId: json['propietarioId'] as String,
      capacidadMaxima: json['capacidadMaxima'] as int,
      numeroHabitaciones: json['numeroHabitaciones'] as int,
      numeroBanos: json['numeroBanos'] as int,
      servicios: List<String>.from(json['servicios'] as List),
      actividades: List<String>.from(json['actividades'] as List),
      disponible: json['disponible'] as bool? ?? true,
      calificacion: (json['calificacion'] as num?)?.toDouble() ?? 0.0,
      numeroReviews: json['numeroReviews'] as int? ?? 0,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.parse(json['fechaActualizacion'] as String)
          : null,
      tipo: TipoFinca.values.firstWhere(
        (tipo) => tipo.name == json['tipo'],
        orElse: () => TipoFinca.casa,
      ),
      reglas:
          (json['reglas'] as List?)
              ?.map((regla) => ReglaFinca.fromJson(regla))
              .toList() ??
          [],
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'ubicacion': ubicacion,
      'ciudad': ciudad,
      'departamento': departamento,
      'latitud': latitud,
      'longitud': longitud,
      'imagenes': imagenes,
      'propietarioId': propietarioId,
      'capacidadMaxima': capacidadMaxima,
      'numeroHabitaciones': numeroHabitaciones,
      'numeroBanos': numeroBanos,
      'servicios': servicios,
      'actividades': actividades,
      'disponible': disponible,
      'calificacion': calificacion,
      'numeroReviews': numeroReviews,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'tipo': tipo.name,
      'reglas': reglas.map((regla) => regla.toJson()).toList(),
    };
  }

  // Método copyWith
  Finca copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    double? precio,
    String? ubicacion,
    String? ciudad,
    String? departamento,
    double? latitud,
    double? longitud,
    List<String>? imagenes,
    String? propietarioId,
    int? capacidadMaxima,
    int? numeroHabitaciones,
    int? numeroBanos,
    List<String>? servicios,
    List<String>? actividades,
    bool? disponible,
    double? calificacion,
    int? numeroReviews,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    TipoFinca? tipo,
    List<ReglaFinca>? reglas,
  }) {
    return Finca(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      ubicacion: ubicacion ?? this.ubicacion,
      ciudad: ciudad ?? this.ciudad,
      departamento: departamento ?? this.departamento,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      imagenes: imagenes ?? this.imagenes,
      propietarioId: propietarioId ?? this.propietarioId,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      numeroHabitaciones: numeroHabitaciones ?? this.numeroHabitaciones,
      numeroBanos: numeroBanos ?? this.numeroBanos,
      servicios: servicios ?? this.servicios,
      actividades: actividades ?? this.actividades,
      disponible: disponible ?? this.disponible,
      calificacion: calificacion ?? this.calificacion,
      numeroReviews: numeroReviews ?? this.numeroReviews,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      tipo: tipo ?? this.tipo,
      reglas: reglas ?? this.reglas,
    );
  }

  // Getters útiles
  String get precioFormateado => '\$${precio.toStringAsFixed(0)}';
  String get ubicacionCompleta => '$ciudad, $departamento';
  bool get tieneImagenes => imagenes.isNotEmpty;
  String get imagenPrincipal => imagenes.isNotEmpty ? imagenes.first : '';
  bool get estaCalificada => calificacion > 0;
  String get calificacionTexto => calificacion.toStringAsFixed(1);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Finca && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Finca(id: $id, titulo: $titulo, precio: $precio, ubicacion: $ubicacionCompleta)';
  }
}

// Enum para tipos de finca
enum TipoFinca {
  casa('Casa de Campo'),
  finca('Finca'),
  cabana('Cabaña'),
  hacienda('Hacienda'),
  lodge('Lodge'),
  camping('Camping'),
  glamping('Glamping');

  const TipoFinca(this.displayName);
  final String displayName;
}

// Clase para reglas de la finca
class ReglaFinca {
  final String id;
  final String titulo;
  final String descripcion;
  final bool esObligatoria;

  const ReglaFinca({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.esObligatoria = false,
  });

  factory ReglaFinca.fromJson(Map<String, dynamic> json) {
    return ReglaFinca(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      esObligatoria: json['esObligatoria'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'esObligatoria': esObligatoria,
    };
  }
}

// Clase para filtros de búsqueda
class FiltrosBusqueda {
  final String? ciudad;
  final String? departamento;
  final double? precioMin;
  final double? precioMax;
  final int? capacidadMinima;
  final List<String>? servicios;
  final List<String>? actividades;
  final TipoFinca? tipo;
  final double? calificacionMinima;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const FiltrosBusqueda({
    this.ciudad,
    this.departamento,
    this.precioMin,
    this.precioMax,
    this.capacidadMinima,
    this.servicios,
    this.actividades,
    this.tipo,
    this.calificacionMinima,
    this.fechaInicio,
    this.fechaFin,
  });

  FiltrosBusqueda copyWith({
    String? ciudad,
    String? departamento,
    double? precioMin,
    double? precioMax,
    int? capacidadMinima,
    List<String>? servicios,
    List<String>? actividades,
    TipoFinca? tipo,
    double? calificacionMinima,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return FiltrosBusqueda(
      ciudad: ciudad ?? this.ciudad,
      departamento: departamento ?? this.departamento,
      precioMin: precioMin ?? this.precioMin,
      precioMax: precioMax ?? this.precioMax,
      capacidadMinima: capacidadMinima ?? this.capacidadMinima,
      servicios: servicios ?? this.servicios,
      actividades: actividades ?? this.actividades,
      tipo: tipo ?? this.tipo,
      calificacionMinima: calificacionMinima ?? this.calificacionMinima,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ciudad != null) 'ciudad': ciudad,
      if (departamento != null) 'departamento': departamento,
      if (precioMin != null) 'precioMin': precioMin,
      if (precioMax != null) 'precioMax': precioMax,
      if (capacidadMinima != null) 'capacidadMinima': capacidadMinima,
      if (servicios != null) 'servicios': servicios,
      if (actividades != null) 'actividades': actividades,
      if (tipo != null) 'tipo': tipo!.name,
      if (calificacionMinima != null) 'calificacionMinima': calificacionMinima,
      if (fechaInicio != null) 'fechaInicio': fechaInicio!.toIso8601String(),
      if (fechaFin != null) 'fechaFin': fechaFin!.toIso8601String(),
    };
  }
}
