import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/reserva.dart';
import '../../services/reserva_service.dart';
import '../../widgets/custom_button.dart';

class MyReservasScreen extends StatefulWidget {
  const MyReservasScreen({super.key});

  @override
  State<MyReservasScreen> createState() => _MyReservasScreenState();
}

class _MyReservasScreenState extends State<MyReservasScreen> {
  final ReservaService _reservaService = ReservaService();
  List<Reserva> _reservas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  void _cargarReservas() {
    setState(() {
      _reservas = _reservaService.reservas;
    });
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

      // Simular delay de API
      await Future.delayed(const Duration(seconds: 1));

      final success = _reservaService.cancelarReserva(reservaId);

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
                'Reserva #${reserva.id.substring(0, 8)}',
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
              const SizedBox(width: 8),
              Text(
                '${reserva.numeroHuespedes} huéspedes • ${reserva.numeroNoches} noches',
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

          // Contacto
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

          // Botones de acción
          if (reserva.estado == EstadoReserva.confirmada ||
              reserva.estado == EstadoReserva.pendiente) ...[
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
        ],
      ),
    );
  }

  Color _getStatusColor(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.pendiente:
        return Colors.orange;
      case EstadoReserva.confirmada:
        return AppColors.success;
      case EstadoReserva.cancelada:
        return AppColors.error;
      case EstadoReserva.completada:
        return Colors.blue;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.pendiente:
        return 'Pendiente';
      case EstadoReserva.confirmada:
        return 'Confirmada';
      case EstadoReserva.cancelada:
        return 'Cancelada';
      case EstadoReserva.completada:
        return 'Completada';
      default:
        return 'Desconocido';
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
