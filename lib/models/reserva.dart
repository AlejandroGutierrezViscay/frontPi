/// Modelo Reserva adaptado al backend de FincaSmart
/// Backend: Reserva { id, usuario, finca, fechaInicio, fechaFin, precioTotal, estado }
class Reserva {
  final String id;
  final Map<String, dynamic>? usuario; // {id, nombre, email, telefono}
  final Map<String, dynamic>? finca; // {id, nombre, ubicacion, precioPorNoche}
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double precioTotal;
  final EstadoReserva estado;

  const Reserva({
    required this.id,
    this.usuario,
    this.finca,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioTotal,
    required this.estado,
  });

  // Factory constructor para crear desde JSON del backend
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'].toString(),
      usuario: json['usuario'] as Map<String, dynamic>?,
      finca: json['finca'] as Map<String, dynamic>?,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      precioTotal: (json['precioTotal'] as num).toDouble(),
      estado: EstadoReserva.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['estado'] as String).toUpperCase(),
        orElse: () => EstadoReserva.PENDIENTE,
      ),
    );
  }

  // Método para convertir a JSON (para enviar al backend al CREAR)
  // Backend espera: { usuario: {id: x}, finca: {id: y}, fechaInicio, fechaFin, estado }
  Map<String, dynamic> toJson() {
    return {
      'usuario': {'id': usuarioId},
      'finca': {'id': fincaId},
      'fechaInicio': _formatDate(fechaInicio),
      'fechaFin': _formatDate(fechaFin),
      'estado': estado.name,
    };
  }

  // Método para actualizar
  Map<String, dynamic> toJsonUpdate() {
    return {
      'usuario': {'id': usuarioId},
      'finca': {'id': fincaId},
      'fechaInicio': _formatDate(fechaInicio),
      'fechaFin': _formatDate(fechaFin),
      'estado': estado.name,
    };
  }

  // Formatear fecha como YYYY-MM-DD (LocalDate en Java)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Getters útiles
  String get usuarioId => usuario?['id']?.toString() ?? '';
  String get usuarioNombre => usuario?['nombre'] as String? ?? 'Desconocido';
  String get usuarioEmail => usuario?['email'] as String? ?? '';

  String get fincaId => finca?['id']?.toString() ?? '';
  String get fincaNombre => finca?['nombre'] as String? ?? 'Desconocida';
  String get fincaUbicacion => finca?['ubicacion'] as String? ?? '';

  int get numeroNoches => fechaFin.difference(fechaInicio).inDays;

  double get precioPorNoche {
    if (numeroNoches <= 0) return 0;
    return precioTotal / numeroNoches;
  }

  bool get estaPendiente => estado == EstadoReserva.PENDIENTE;
  bool get estaConfirmada => estado == EstadoReserva.CONFIRMADA;
  bool get estaCancelada => estado == EstadoReserva.CANCELADA;
  bool get estaCompletada => estado == EstadoReserva.COMPLETADA;

  bool get esActiva => estaConfirmada || estaPendiente;
  bool get esFutura => fechaInicio.isAfter(DateTime.now());
  bool get esPasada => fechaFin.isBefore(DateTime.now());
  bool get estaEnCurso {
    final ahora = DateTime.now();
    return ahora.isAfter(fechaInicio) && ahora.isBefore(fechaFin);
  }

  String get fechasFormateadas {
    return '${_formatearFecha(fechaInicio)} - ${_formatearFecha(fechaFin)}';
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String get precioFormateado => '\$${precioTotal.toStringAsFixed(0)}';

  // CopyWith
  Reserva copyWith({
    String? id,
    Map<String, dynamic>? usuario,
    Map<String, dynamic>? finca,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    double? precioTotal,
    EstadoReserva? estado,
  }) {
    return Reserva(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      finca: finca ?? this.finca,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      precioTotal: precioTotal ?? this.precioTotal,
      estado: estado ?? this.estado,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reserva && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reserva(id: $id, finca: $fincaNombre, fechas: $fechasFormateadas, estado: ${estado.name})';
  }
}

/// Enum para estados de reserva (debe coincidir con el backend)
/// Backend: enum EstadoReserva { PENDIENTE, CONFIRMADA, CANCELADA, COMPLETADA }
enum EstadoReserva {
  PENDIENTE('Pendiente'),
  CONFIRMADA('Confirmada'),
  CANCELADA('Cancelada'),
  COMPLETADA('Completada');

  const EstadoReserva(this.displayName);
  final String displayName;
}

/// Clase para crear una nueva reserva
class NuevaReservaRequest {
  final String usuarioId;
  final String fincaId;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const NuevaReservaRequest({
    required this.usuarioId,
    required this.fincaId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuario': {'id': int.parse(usuarioId)},
      'finca': {'id': int.parse(fincaId)},
      'fechaInicio': _formatDate(fechaInicio),
      'fechaFin': _formatDate(fechaFin),
      'estado': 'PENDIENTE',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Validaciones
  bool get fechasValidas => fechaFin.isAfter(fechaInicio);
  bool get noEsPasado => fechaInicio.isAfter(DateTime.now());
  int get numeroNoches => fechaFin.difference(fechaInicio).inDays;
  bool get duracionMinima => numeroNoches >= 1;

  bool get esValida => fechasValidas && noEsPasado && duracionMinima;

  List<String> get errores {
    final errores = <String>[];

    if (!fechasValidas) {
      errores.add('La fecha de fin debe ser posterior a la fecha de inicio');
    }
    if (!noEsPasado) {
      errores.add('La fecha de inicio debe ser futura');
    }
    if (!duracionMinima) {
      errores.add('La reserva debe ser de al menos 1 noche');
    }

    return errores;
  }
}

/// Clase para verificar disponibilidad
class DisponibilidadRequest {
  final String fincaId;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const DisponibilidadRequest({
    required this.fincaId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  Map<String, String> toQueryParams() {
    return {
      'fincaId': fincaId,
      'fechaInicio': _formatDate(fechaInicio),
      'fechaFin': _formatDate(fechaFin),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
