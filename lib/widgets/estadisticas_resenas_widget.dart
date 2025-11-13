import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/resena.dart';

/// Widget para mostrar estadísticas de reseñas de una finca
class EstadisticasResenasWidget extends StatelessWidget {
  final EstadisticasResenas estadisticas;
  final bool compact;

  const EstadisticasResenasWidget({
    super.key,
    required this.estadisticas,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildCompleto(context);
  }

  /// Vista compacta: solo promedio y total
  Widget _buildCompact(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          estadisticas.promedioCalificacion.toStringAsFixed(1),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          '(${estadisticas.totalResenas} ${estadisticas.totalResenas == 1 ? 'reseña' : 'reseñas'})',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Vista completa: con distribución de estrellas
  Widget _buildCompleto(BuildContext context) {
    return Container(
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
          // Header con promedio
          Row(
            children: [
              // Promedio grande
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    estadisticas.promedioCalificacion.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < estadisticas.promedioCalificacion.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${estadisticas.totalResenas} ${estadisticas.totalResenas == 1 ? 'reseña' : 'reseñas'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Distribución de estrellas
              Expanded(
                child: Column(
                  children: [
                    _buildBarraEstrellas(5, estadisticas.resenas5Estrellas),
                    const SizedBox(height: 4),
                    _buildBarraEstrellas(4, estadisticas.resenas4Estrellas),
                    const SizedBox(height: 4),
                    _buildBarraEstrellas(3, estadisticas.resenas3Estrellas),
                    const SizedBox(height: 4),
                    _buildBarraEstrellas(2, estadisticas.resenas2Estrellas),
                    const SizedBox(height: 4),
                    _buildBarraEstrellas(1, estadisticas.resenas1Estrella),
                  ],
                ),
              ),
            ],
          ),

          // Badge de confiabilidad
          if (estadisticas.esConfiable) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Calificación confiable',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Barra de progreso para cada nivel de estrellas
  Widget _buildBarraEstrellas(int estrellas, int cantidad) {
    final porcentaje = estadisticas.porcentajeCalificacion(estrellas);

    return Row(
      children: [
        Text('$estrellas', style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Icon(Icons.star, color: Colors.amber, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              // Barra de fondo
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Barra de progreso
              FractionallySizedBox(
                widthFactor: porcentaje / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$cantidad',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
