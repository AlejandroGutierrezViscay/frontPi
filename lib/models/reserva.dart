// Modelo para una reserva de finca
class Reserva {
  final String id;
  final String fincaId;
  final String usuarioId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int numeroHuespedes;
  final double precioTotal;
  final double precioNoche;
  final int numeroNoches;
  final EstadoReserva estado;
  final DateTime fechaCreacion;
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;
  final String? notasEspeciales;
  final DatosContacto datosContacto;
  final List<String>? serviciosAdicionales;

  const Reserva({
    required this.id,
    required this.fincaId,
    required this.usuarioId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.numeroHuespedes,
    required this.precioTotal,
    required this.precioNoche,
    required this.numeroNoches,
    required this.estado,
    required this.fechaCreacion,
    this.fechaCancelacion,
    this.motivoCancelacion,
    this.notasEspeciales,
    required this.datosContacto,
    this.serviciosAdicionales,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] as String,
      fincaId: json['fincaId'] as String,
      usuarioId: json['usuarioId'] as String,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      numeroHuespedes: json['numeroHuespedes'] as int,
      precioTotal: (json['precioTotal'] as num).toDouble(),
      precioNoche: (json['precioNoche'] as num).toDouble(),
      numeroNoches: json['numeroNoches'] as int,
      estado: EstadoReserva.values.firstWhere(
        (estado) => estado.name == json['estado'],
        orElse: () => EstadoReserva.pendiente,
      ),
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaCancelacion: json['fechaCancelacion'] != null
          ? DateTime.parse(json['fechaCancelacion'] as String)
          : null,
      motivoCancelacion: json['motivoCancelacion'] as String?,
      notasEspeciales: json['notasEspeciales'] as String?,
      datosContacto: DatosContacto.fromJson(json['datosContacto']),
      serviciosAdicionales: json['serviciosAdicionales'] != null
          ? List<String>.from(json['serviciosAdicionales'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fincaId': fincaId,
      'usuarioId': usuarioId,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'numeroHuespedes': numeroHuespedes,
      'precioTotal': precioTotal,
      'precioNoche': precioNoche,
      'numeroNoches': numeroNoches,
      'estado': estado.name,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaCancelacion': fechaCancelacion?.toIso8601String(),
      'motivoCancelacion': motivoCancelacion,
      'notasEspeciales': notasEspeciales,
      'datosContacto': datosContacto.toJson(),
      'serviciosAdicionales': serviciosAdicionales,
    };
  }

  Reserva copyWith({
    String? id,
    String? fincaId,
    String? usuarioId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? numeroHuespedes,
    double? precioTotal,
    double? precioNoche,
    int? numeroNoches,
    EstadoReserva? estado,
    DateTime? fechaCreacion,
    DateTime? fechaCancelacion,
    String? motivoCancelacion,
    String? notasEspeciales,
    DatosContacto? datosContacto,
    List<String>? serviciosAdicionales,
  }) {
    return Reserva(
      id: id ?? this.id,
      fincaId: fincaId ?? this.fincaId,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      numeroHuespedes: numeroHuespedes ?? this.numeroHuespedes,
      precioTotal: precioTotal ?? this.precioTotal,
      precioNoche: precioNoche ?? this.precioNoche,
      numeroNoches: numeroNoches ?? this.numeroNoches,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCancelacion: fechaCancelacion ?? this.fechaCancelacion,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      notasEspeciales: notasEspeciales ?? this.notasEspeciales,
      datosContacto: datosContacto ?? this.datosContacto,
      serviciosAdicionales: serviciosAdicionales ?? this.serviciosAdicionales,
    );
  }

  // Getters útiles
  Duration get duracion => fechaFin.difference(fechaInicio);
  bool get estaCancelada => estado == EstadoReserva.cancelada;
  bool get estaConfirmada => estado == EstadoReserva.confirmada;
  bool get estaPendiente => estado == EstadoReserva.pendiente;
  bool get estaCompletada => estado == EstadoReserva.completada;

  String get fechasFormateadas {
    final formato = 'dd/MM/yyyy';
    return '${_formatearFecha(fechaInicio, formato)} - ${_formatearFecha(fechaFin, formato)}';
  }

  String _formatearFecha(DateTime fecha, String formato) {
    // Implementación simple, en producción usarías intl package
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String get precioFormateado => '\$${precioTotal.toStringAsFixed(0)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reserva && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reserva(id: $id, fincaId: $fincaId, fechas: $fechasFormateadas, estado: ${estado.displayName})';
  }
}

// Enum para el estado de una reserva
enum EstadoReserva {
  pendiente('Pendiente'),
  confirmada('Confirmada'),
  enCurso('En Curso'),
  completada('Completada'),
  cancelada('Cancelada');

  const EstadoReserva(this.displayName);
  final String displayName;
}

// Clase para datos de contacto del huésped
class DatosContacto {
  final String nombreCompleto;
  final String telefono;
  final String email;
  final String? telefonoEmergencia;
  final String? nombreEmergencia;

  const DatosContacto({
    required this.nombreCompleto,
    required this.telefono,
    required this.email,
    this.telefonoEmergencia,
    this.nombreEmergencia,
  });

  factory DatosContacto.fromJson(Map<String, dynamic> json) {
    return DatosContacto(
      nombreCompleto: json['nombreCompleto'] as String,
      telefono: json['telefono'] as String,
      email: json['email'] as String,
      telefonoEmergencia: json['telefonoEmergencia'] as String?,
      nombreEmergencia: json['nombreEmergencia'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
      'email': email,
      'telefonoEmergencia': telefonoEmergencia,
      'nombreEmergencia': nombreEmergencia,
    };
  }

  DatosContacto copyWith({
    String? nombreCompleto,
    String? telefono,
    String? email,
    String? telefonoEmergencia,
    String? nombreEmergencia,
  }) {
    return DatosContacto(
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      telefonoEmergencia: telefonoEmergencia ?? this.telefonoEmergencia,
      nombreEmergencia: nombreEmergencia ?? this.nombreEmergencia,
    );
  }
}

// Clase para crear una nueva reserva
class NuevaReserva {
  final String fincaId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int numeroHuespedes;
  final String? notasEspeciales;
  final DatosContacto datosContacto;
  final List<String>? serviciosAdicionales;

  const NuevaReserva({
    required this.fincaId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.numeroHuespedes,
    this.notasEspeciales,
    required this.datosContacto,
    this.serviciosAdicionales,
  });

  Map<String, dynamic> toJson() {
    return {
      'fincaId': fincaId,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'numeroHuespedes': numeroHuespedes,
      'notasEspeciales': notasEspeciales,
      'datosContacto': datosContacto.toJson(),
      'serviciosAdicionales': serviciosAdicionales,
    };
  }

  // Calcular el número de noches
  int get numeroNoches => fechaFin.difference(fechaInicio).inDays;

  // Validaciones
  bool get fechasValidas => fechaFin.isAfter(fechaInicio);
  bool get esReservaFutura => fechaInicio.isAfter(DateTime.now());
}

// Clase para el resumen de una reserva
class ResumenReserva {
  final String fincaId;
  final String tituloFinca;
  final String imagenFinca;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int numeroNoches;
  final int numeroHuespedes;
  final double precioNoche;
  final double precioTotal;
  final List<String>? serviciosAdicionales;

  const ResumenReserva({
    required this.fincaId,
    required this.tituloFinca,
    required this.imagenFinca,
    required this.fechaInicio,
    required this.fechaFin,
    required this.numeroNoches,
    required this.numeroHuespedes,
    required this.precioNoche,
    required this.precioTotal,
    this.serviciosAdicionales,
  });

  String get fechasFormateadas {
    final formato = 'dd/MM/yyyy';
    return '${_formatearFecha(fechaInicio, formato)} - ${_formatearFecha(fechaFin, formato)}';
  }

  String _formatearFecha(DateTime fecha, String formato) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String get precioTotalFormateado => '\$${precioTotal.toStringAsFixed(0)}';
  String get precioNocheFormateado => '\$${precioNoche.toStringAsFixed(0)}';
}
