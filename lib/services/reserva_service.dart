import '../models/reserva.dart';

class ReservaService {
  static final ReservaService _instance = ReservaService._internal();
  factory ReservaService() => _instance;
  ReservaService._internal();

  // Lista de reservas del usuario actual
  final List<Reserva> _reservas = [];

  // Obtener todas las reservas
  List<Reserva> get reservas => List.unmodifiable(_reservas);

  // Agregar nueva reserva
  void agregarReserva(Reserva reserva) {
    _reservas.add(reserva);
    print('✅ Reserva agregada: ${reserva.id}');
  }

  // Obtener reserva por ID
  Reserva? obtenerReservaPorId(String id) {
    try {
      return _reservas.firstWhere((reserva) => reserva.id == id);
    } catch (e) {
      return null;
    }
  }

  // Cancelar reserva
  bool cancelarReserva(String id) {
    final index = _reservas.indexWhere((reserva) => reserva.id == id);
    if (index != -1) {
      final reserva = _reservas[index];
      final reservaCancelada = Reserva(
        id: reserva.id,
        fincaId: reserva.fincaId,
        usuarioId: reserva.usuarioId,
        fechaInicio: reserva.fechaInicio,
        fechaFin: reserva.fechaFin,
        numeroHuespedes: reserva.numeroHuespedes,
        precioTotal: reserva.precioTotal,
        precioNoche: reserva.precioNoche,
        numeroNoches: reserva.numeroNoches,
        estado: EstadoReserva.cancelada,
        fechaCreacion: reserva.fechaCreacion,
        fechaCancelacion: DateTime.now(),
        motivoCancelacion: 'Cancelada por el usuario',
        datosContacto: reserva.datosContacto,
        notasEspeciales: reserva.notasEspeciales,
        serviciosAdicionales: reserva.serviciosAdicionales,
      );

      _reservas[index] = reservaCancelada;
      print('✅ Reserva cancelada: $id');
      return true;
    }
    print('❌ Reserva no encontrada: $id');
    return false;
  }

  // Obtener reservas por estado
  List<Reserva> obtenerReservasPorEstado(EstadoReserva estado) {
    return _reservas.where((reserva) => reserva.estado == estado).toList();
  }

  // Obtener reservas activas (confirmadas y pendientes)
  List<Reserva> get reservasActivas {
    return _reservas
        .where(
          (reserva) =>
              reserva.estado == EstadoReserva.confirmada ||
              reserva.estado == EstadoReserva.pendiente,
        )
        .toList();
  }

  // Limpiar todas las reservas (útil para desarrollo)
  void limpiarReservas() {
    _reservas.clear();
    print('🗑️ Todas las reservas han sido eliminadas');
  }
}
