/// Modelo Reseña adaptado al backend de FincaSmart
/// Backend: Resena { id, finca, usuario, reserva, calificacion, comentario, fechaResena, respuestaPropietario, fechaRespuesta }

class Resena {
  final String id;
  final Map<String, dynamic>? finca; // {id, nombre, ubicacion}
  final Map<String, dynamic>? usuario; // {id, nombre, email}
  final Map<String, dynamic>? reserva; // {id, fechaInicio, fechaFin}
  final int calificacion; // 1-5 estrellas
  final String comentario;
  final DateTime fechaResena;
  final String? respuestaPropietario;
  final DateTime? fechaRespuesta;

  const Resena({
    required this.id,
    this.finca,
    this.usuario,
    this.reserva,
    required this.calificacion,
    required this.comentario,
    required this.fechaResena,
    this.respuestaPropietario,
    this.fechaRespuesta,
  });

  // Factory constructor para crear desde JSON del backend
  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: json['id'].toString(),
      finca: json['finca'] as Map<String, dynamic>?,
      usuario: json['usuario'] as Map<String, dynamic>?,
      reserva: json['reserva'] as Map<String, dynamic>?,
      calificacion: json['calificacion'] as int,
      comentario: json['comentario'] as String? ?? '',
      fechaResena: DateTime.parse(json['fechaResena'] as String),
      respuestaPropietario: json['respuestaPropietario'] as String?,
      fechaRespuesta: json['fechaRespuesta'] != null
          ? DateTime.parse(json['fechaRespuesta'] as String)
          : null,
    );
  }

  // Método para convertir a JSON (para enviar al backend al CREAR)
  Map<String, dynamic> toJson() {
    return {
      'finca': {'id': fincaId},
      'usuario': {'id': usuarioId},
      if (reservaId != null) 'reserva': {'id': reservaId},
      'calificacion': calificacion,
      'comentario': comentario,
    };
  }

  // Getters útiles
  String get fincaId => finca?['id']?.toString() ?? '';
  String get fincaNombre => finca?['nombre'] as String? ?? 'Desconocida';

  String get usuarioId => usuario?['id']?.toString() ?? '';
  String get usuarioNombre => usuario?['nombre'] as String? ?? 'Anónimo';
  String get usuarioEmail => usuario?['email'] as String? ?? '';

  String? get reservaId => reserva?['id']?.toString();

  bool get tieneRespuesta =>
      respuestaPropietario != null && respuestaPropietario!.isNotEmpty;

  // Formatear fecha
  String get fechaFormateada {
    return '${fechaResena.day.toString().padLeft(2, '0')}/${fechaResena.month.toString().padLeft(2, '0')}/${fechaResena.year}';
  }

  String? get fechaRespuestaFormateada {
    if (fechaRespuesta == null) return null;
    return '${fechaRespuesta!.day.toString().padLeft(2, '0')}/${fechaRespuesta!.month.toString().padLeft(2, '0')}/${fechaRespuesta!.year}';
  }

  // Generar estrellas visuales
  String get estrellasTexto {
    return '⭐' * calificacion;
  }

  // Copiar con modificaciones
  Resena copyWith({
    String? id,
    Map<String, dynamic>? finca,
    Map<String, dynamic>? usuario,
    Map<String, dynamic>? reserva,
    int? calificacion,
    String? comentario,
    DateTime? fechaResena,
    String? respuestaPropietario,
    DateTime? fechaRespuesta,
  }) {
    return Resena(
      id: id ?? this.id,
      finca: finca ?? this.finca,
      usuario: usuario ?? this.usuario,
      reserva: reserva ?? this.reserva,
      calificacion: calificacion ?? this.calificacion,
      comentario: comentario ?? this.comentario,
      fechaResena: fechaResena ?? this.fechaResena,
      respuestaPropietario: respuestaPropietario ?? this.respuestaPropietario,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
    );
  }
}

/// DTO para estadísticas de reseñas
class EstadisticasResenas {
  final double promedioCalificacion;
  final int totalResenas;
  final int resenas5Estrellas;
  final int resenas4Estrellas;
  final int resenas3Estrellas;
  final int resenas2Estrellas;
  final int resenas1Estrella;

  const EstadisticasResenas({
    required this.promedioCalificacion,
    required this.totalResenas,
    required this.resenas5Estrellas,
    required this.resenas4Estrellas,
    required this.resenas3Estrellas,
    required this.resenas2Estrellas,
    required this.resenas1Estrella,
  });

  factory EstadisticasResenas.fromJson(Map<String, dynamic> json) {
    return EstadisticasResenas(
      promedioCalificacion:
          (json['promedioCalificacion'] as num?)?.toDouble() ?? 0.0,
      totalResenas: json['totalResenas'] as int? ?? 0,
      resenas5Estrellas: json['resenas5Estrellas'] as int? ?? 0,
      resenas4Estrellas: json['resenas4Estrellas'] as int? ?? 0,
      resenas3Estrellas: json['resenas3Estrellas'] as int? ?? 0,
      resenas2Estrellas: json['resenas2Estrellas'] as int? ?? 0,
      resenas1Estrella: json['resenas1Estrella'] as int? ?? 0,
    );
  }

  // Generar texto de promedio (ej: "4.7 ⭐")
  String get promedioTexto {
    return '${promedioCalificacion.toStringAsFixed(1)} ⭐';
  }

  // Calcular porcentaje de cada calificación
  double porcentajeCalificacion(int estrellas) {
    if (totalResenas == 0) return 0;
    final cantidad = switch (estrellas) {
      5 => resenas5Estrellas,
      4 => resenas4Estrellas,
      3 => resenas3Estrellas,
      2 => resenas2Estrellas,
      1 => resenas1Estrella,
      _ => 0,
    };
    return (cantidad / totalResenas) * 100;
  }

  // Verificar si tiene suficientes reseñas para ser confiable
  bool get esConfiable => totalResenas >= 5;
}
