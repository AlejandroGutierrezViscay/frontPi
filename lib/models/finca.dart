/// Modelo Finca adaptado al backend de FincaSmart
/// Backend: Finca { id, nombre, ubicacion, precioPorNoche, descripcion, propietario, imagenes, amenidades }
class Finca {
  final String id;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final double precioPorNoche;
  final Map<String, dynamic>? propietario; // {id, nombre, email, telefono}
  final List<ImagenFinca>? imagenes;
  final List<Amenidad>? amenidades;

  const Finca({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.precioPorNoche,
    this.propietario,
    this.imagenes,
    this.amenidades,
  });

  // Factory constructor para crear desde JSON del backend
  factory Finca.fromJson(Map<String, dynamic> json) {
    return Finca(
      id: json['id'].toString(),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      ubicacion: json['ubicacion'] as String,
      precioPorNoche: (json['precioPorNoche'] as num).toDouble(),
      propietario: json['propietario'] as Map<String, dynamic>?,
      imagenes: json['imagenes'] != null
          ? (json['imagenes'] as List)
              .map((img) => ImagenFinca.fromJson(img))
              .toList()
          : null,
      amenidades: json['amenidades'] != null
          ? (json['amenidades'] as List)
              .map((am) => Amenidad.fromJson(am))
              .toList()
          : null,
    );
  }

  // Método para convertir a JSON (para enviar al backend al CREAR)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'precioPorNoche': precioPorNoche,
      'propietario': {'id': propietarioId}, // Backend espera {id: x}
    };
  }

  // Método para actualizar (PUT)
  Map<String, dynamic> toJsonUpdate() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'precioPorNoche': precioPorNoche,
      'propietario': {'id': propietarioId},
    };
  }

  // Getters útiles
  String get propietarioId => propietario?['id']?.toString() ?? '';
  String get propietarioNombre => propietario?['nombre'] as String? ?? 'Desconocido';
  
  List<String> get imagenesUrls {
    return imagenes?.map((img) => img.urlImagen).toList() ?? [];
  }
  
  String? get imagenPrincipal {
    if (imagenes == null || imagenes!.isEmpty) return null;
    
    // Buscar imagen marcada como principal
    final principal = imagenes!.firstWhere(
      (img) => img.esPrincipal,
      orElse: () => imagenes!.first,
    );
    return principal.urlImagen;
  }
  
  List<String> get amenidadesNombres {
    return amenidades?.map((am) => am.nombre).toList() ?? [];
  }

  // CopyWith
  Finca copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? ubicacion,
    double? precioPorNoche,
    Map<String, dynamic>? propietario,
    List<ImagenFinca>? imagenes,
    List<Amenidad>? amenidades,
  }) {
    return Finca(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      ubicacion: ubicacion ?? this.ubicacion,
      precioPorNoche: precioPorNoche ?? this.precioPorNoche,
      propietario: propietario ?? this.propietario,
      imagenes: imagenes ?? this.imagenes,
      amenidades: amenidades ?? this.amenidades,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Finca && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Finca(id: $id, nombre: $nombre, ubicacion: $ubicacion, precio: \$$precioPorNoche)';
  }
}

/// Modelo ImagenFinca del backend
/// Backend: ImagenFinca { id, urlImagen, esPrincipal, orden, descripcion }
class ImagenFinca {
  final String id;
  final String urlImagen;
  final bool esPrincipal;
  final int orden;
  final String? descripcion;

  const ImagenFinca({
    required this.id,
    required this.urlImagen,
    this.esPrincipal = false,
    this.orden = 0,
    this.descripcion,
  });

  factory ImagenFinca.fromJson(Map<String, dynamic> json) {
    return ImagenFinca(
      id: json['id'].toString(),
      urlImagen: json['urlImagen'] as String,
      esPrincipal: json['esPrincipal'] as bool? ?? false,
      orden: json['orden'] as int? ?? 0,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urlImagen': urlImagen,
      'esPrincipal': esPrincipal,
      'orden': orden,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }
}

/// Modelo Amenidad del backend
/// Backend: Amenidad { id, nombre, icono, categoria }
class Amenidad {
  final String id;
  final String nombre;
  final String? icono;
  final String? categoria;

  const Amenidad({
    required this.id,
    required this.nombre,
    this.icono,
    this.categoria,
  });

  factory Amenidad.fromJson(Map<String, dynamic> json) {
    return Amenidad(
      id: json['id'].toString(),
      nombre: json['nombre'] as String,
      icono: json['icono'] as String?,
      categoria: json['categoria'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (icono != null) 'icono': icono,
      if (categoria != null) 'categoria': categoria,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Amenidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Clase para filtros de búsqueda de fincas
class FiltrosBusqueda {
  final String? nombre;
  final String? ubicacion;
  final double? precioMin;
  final double? precioMax;

  const FiltrosBusqueda({
    this.nombre,
    this.ubicacion,
    this.precioMin,
    this.precioMax,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, String>{};
    
    if (nombre != null && nombre!.isNotEmpty) {
      params['nombre'] = nombre!;
    }
    if (ubicacion != null && ubicacion!.isNotEmpty) {
      params['ubicacion'] = ubicacion!;
    }
    if (precioMin != null) {
      params['minPrecio'] = precioMin.toString();
    }
    if (precioMax != null) {
      params['maxPrecio'] = precioMax.toString();
    }
    
    return params;
  }

  bool get tieneAlgunFiltro =>
      nombre != null || ubicacion != null || precioMin != null || precioMax != null;
}
