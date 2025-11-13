import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/reserva.dart';
import '../../services/reserva_service.dart';
import '../../services/resena_service.dart';
import '../../widgets/custom_button.dart';
import '../resena/crear_resena_screen.dart';

class MyReservasScreen extends StatefulWidget {
  const MyReservasScreen({super.key});

  @override
  State<MyReservasScreen> createState() => _MyReservasScreenState();
}

class _MyReservasScreenState extends State<MyReservasScreen> {
  final ReservaService _reservaService = ReservaService();
  final ResenaService _resenaService = ResenaService();
  List<Reserva> _reservas = [];
  bool _isLoading = false;

  // Mapa para guardar si cada reserva ya tiene reseña
  Map<String, bool> _reservasTienenResena = {};

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Obtener el ID del usuario autenticado
      final usuarioId = 1; // Temporal: usar ID fijo
      final reservas = await _reservaService.obtenerMisReservas(usuarioId);

      // Verificar qué reservas ya tienen reseña (completadas o pasadas)
      for (var reserva in reservas) {
        if (reserva.estaCompletada || reserva.esPasada) {
          final tieneResena = await _resenaService.reservaTieneResena(
            int.parse(reserva.id),
          );
          _reservasTienenResena[reserva.id] = tieneResena;
        }
      }

      setState(() {
        _reservas = reservas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelarReserva(String reservaId) async {
    // Mostrar diálogo de confirmación
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Reserva'),
          content: const Text(
            '¿Estás seguro de que deseas cancelar esta reserva?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Sí, cancelar',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      setState(() {
        _isLoading = true;
      });

      final success = await _reservaService.cancelarReserva(reservaId);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _cargarReservas(); // Recargar las reservas
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Reserva cancelada exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al cancelar la reserva'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Mis Reservas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservas.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                _cargarReservas();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reservas.length,
                itemBuilder: (context, index) {
                  final reserva = _reservas[index];
                  return _buildReservaCard(reserva);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes reservas aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora nuestras fincas y haz tu primera reserva',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Explorar Fincas',
            onPressed: () {
              Navigator.of(context).pop(); // Volver al home
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReservaCard(Reserva reserva) {
    final Color statusColor = _getStatusColor(reserva.estado);
    final String statusText = _getStatusText(reserva.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reserva #${reserva.id.substring(0, reserva.id.length < 8 ? reserva.id.length : 8)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Información de fechas
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatDate(reserva.fechaInicio)} - ${_formatDate(reserva.fechaFin)}',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Información de huéspedes
          Row(
            children: [
              Icon(Icons.people, size: 16, color: AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                'Reserva confirmada', // TODO: '${reserva.numeroHuespedes} huéspedes • ${reserva.numeroNoches} noches' cuando backend lo soporte
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Precio total
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '\$${reserva.precioTotal.toStringAsFixed(0)} COP total',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          // TODO: Contacto - pendiente de implementar en backend
          /*
          if (reserva.datosContacto.nombreCompleto.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos de contacto:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reserva.datosContacto.nombreCompleto,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (reserva.datosContacto.telefono.isNotEmpty)
                    Text(
                      reserva.datosContacto.telefono,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
          */

          // Botones de acción según el estado
          if (reserva.estado == EstadoReserva.CONFIRMADA ||
              reserva.estado == EstadoReserva.PENDIENTE) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelarReserva(reserva.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implementar modificar reserva
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función disponible próximamente'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Modificar'),
                  ),
                ),
              ],
            ),
          ],

          // Botón de reseña para reservas completadas O pasadas
          // Mostrar botón si: 1) Estado es COMPLETADA, o 2) La fecha de fin ya pasó
          if (reserva.estaCompletada || reserva.esPasada) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _reservasTienenResena[reserva.id] == true
                  ? OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ya has reseñado esta reserva'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Reseña publicada'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        // Navegar a pantalla de crear reseña
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CrearResenaScreen(reserva: reserva),
                          ),
                        );

                        // Si se creó la reseña, recargar
                        if (result == true) {
                          _cargarReservas();
                        }
                      },
                      icon: const Icon(Icons.rate_review, size: 18),
                      label: const Text('Dejar Reseña'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.PENDIENTE:
        return Colors.orange;
      case EstadoReserva.CONFIRMADA:
        return AppColors.success;
      case EstadoReserva.CANCELADA:
        return AppColors.error;
      case EstadoReserva.COMPLETADA:
        return Colors.blue;
    }
  }

  String _getStatusText(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.PENDIENTE:
        return 'Pendiente';
      case EstadoReserva.CONFIRMADA:
        return 'Confirmada';
      case EstadoReserva.CANCELADA:
        return 'Cancelada';
      case EstadoReserva.COMPLETADA:
        return 'Completada';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
