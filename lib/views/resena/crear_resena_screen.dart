import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/reserva.dart';
import '../../services/resena_service.dart';
import '../../widgets/custom_button.dart';

class CrearResenaScreen extends StatefulWidget {
  final Reserva reserva;

  const CrearResenaScreen({super.key, required this.reserva});

  @override
  State<CrearResenaScreen> createState() => _CrearResenaScreenState();
}

class _CrearResenaScreenState extends State<CrearResenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();
  final ResenaService _resenaService = ResenaService();

  int _calificacion = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviarResena() async {
    if (!_formKey.currentState!.validate()) return;
    if (_calificacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona una calificación'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resena = await _resenaService.crearResena(
        usuarioId: 1, // TODO: Obtener del usuario autenticado
        fincaId: int.parse(widget.reserva.fincaId),
        reservaId: int.parse(widget.reserva.id),
        calificacion: _calificacion,
        comentario: _comentarioController.text.trim(),
      );

      if (mounted && resena != null) {
        // Mostrar confirmación
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                const Text('¡Reseña publicada!'),
              ],
            ),
            content: Text(
              'Gracias por compartir tu experiencia. Tu reseña ayuda a otros usuarios a tomar mejores decisiones.',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar dialog
                  Navigator.of(
                    context,
                  ).pop(true); // Cerrar screen con resultado
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al publicar la reseña'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          'Deja tu reseña',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info de la finca
              Container(
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
                child: Row(
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.reserva.fincaNombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.reserva.fincaUbicacion,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.reserva.fechasFormateadas,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Selector de calificación
              const Text(
                '¿Cómo calificarías tu experiencia?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNumber = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _calificacion = starNumber;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              starNumber <= _calificacion
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 48,
                              color: Colors.amber,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _calificacion == 0
                          ? 'Selecciona una calificación'
                          : _getCalificacionTexto(_calificacion),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _calificacion == 0
                            ? AppColors.textSecondary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Campo de comentario
              const Text(
                'Cuéntanos sobre tu experiencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _comentarioController,
                maxLines: 8,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText:
                      '¿Qué te gustó más? ¿Cómo fue la atención? ¿Recomendarías este lugar?',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor escribe un comentario';
                  }
                  if (value.trim().length < 10) {
                    return 'El comentario debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón enviar
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isLoading ? 'Publicando...' : 'Publicar Reseña',
                  onPressed: _isLoading ? null : _enviarResena,
                ),
              ),

              const SizedBox(height: 16),

              // Nota informativa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tu reseña será pública y ayudará a otros usuarios a elegir su próxima estadía.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCalificacionTexto(int calificacion) {
    switch (calificacion) {
      case 1:
        return 'Muy mala experiencia';
      case 2:
        return 'Experiencia regular';
      case 3:
        return 'Buena experiencia';
      case 4:
        return 'Muy buena experiencia';
      case 5:
        return '¡Excelente experiencia!';
      default:
        return '';
    }
  }
}
