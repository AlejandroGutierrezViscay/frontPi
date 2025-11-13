import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/finca.dart';
import '../../models/reserva.dart';
import '../../services/reserva_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class BookingScreen extends StatefulWidget {
  final Finca finca;

  const BookingScreen({super.key, required this.finca});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _solicitudesController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int _numeroHuespedes = 1;
  bool _isLoading = false;

  double get _subtotal {
    if (_fechaInicio == null || _fechaFin == null) return 0;
    final dias = _fechaFin!.difference(_fechaInicio!).inDays;
    return dias * widget.finca.precioPorNoche;
  }

  double get _tasasServicios => _subtotal * 0.1; // 10% de tasas
  double get _total => _subtotal + _tasasServicios;

  @override
  void initState() {
    super.initState();
    // Agregar listeners para actualizar el estado cuando cambien los campos
    _nombreController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _telefonoController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _solicitudesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Reservar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de la finca
              _buildFincaInfoCard(),
              const SizedBox(height: 24),

              // Selección de fechas
              _buildDateSelection(),
              const SizedBox(height: 24),

              // Número de huéspedes
              _buildGuestSelection(),
              const SizedBox(height: 24),

              // Información del huésped
              _buildGuestInfoSection(),
              const SizedBox(height: 24),

              // Solicitudes especiales
              _buildSpecialRequests(),
              const SizedBox(height: 24),

              // Resumen de costos
              _buildCostSummary(),
              const SizedBox(height: 32),

              // Botón de confirmar reserva
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFincaInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen pequeña
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: (widget.finca.imagenes?.isNotEmpty ?? false)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.finca.imagenes!.first.urlImagen,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.home_work_outlined,
                            color: AppColors.primary,
                            size: 32,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.home_work_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 16),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.finca.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.finca.ubicacion,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '0.0', // TODO: Agregar calificación cuando el backend lo soporte
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' (0)', // TODO: Agregar número de reviews cuando el backend lo soporte
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fechas de estadía',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'Fecha de llegada',
                _fechaInicio,
                (date) => setState(() => _fechaInicio = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                'Fecha de salida',
                _fechaFin,
                (date) {
                  setState(() {
                    _fechaFin = date;
                    // Si no hay fecha de inicio y se selecciona fecha de fin,
                    // establecer fecha de inicio como un día antes
                    if (_fechaInicio == null || date.isBefore(_fechaInicio!)) {
                      _fechaInicio = date.subtract(const Duration(days: 1));
                    }
                  });
                },
                minDate:
                    _fechaInicio?.add(const Duration(days: 1)) ??
                    DateTime.now().add(const Duration(days: 1)),
              ),
            ),
          ],
        ),
        if (_fechaInicio != null && _fechaFin != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_fechaFin!.difference(_fechaInicio!).inDays} noches',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected, {
    DateTime? minDate,
  }) {
    return GestureDetector(
      onTap: () async {
        print('Tapped on $label'); // Debug
        final initialDate = selectedDate ?? (minDate ?? DateTime.now());
        final firstDate = minDate ?? DateTime.now();

        // Asegurar que initialDate no sea menor que firstDate
        final validInitialDate = initialDate.isBefore(firstDate)
            ? firstDate
            : initialDate;

        final date = await showDatePicker(
          context: context,
          initialDate: validInitialDate,
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        width: double.infinity, // Asegurar que ocupe todo el ancho
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
          // color: Colors.red.withOpacity(0.1), // Debug color - remover después
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : 'Seleccionar fecha',
              style: TextStyle(
                fontSize: 16,
                color: selectedDate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Número de huéspedes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.people_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Huéspedes',
                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                ),
              ),
              IconButton(
                onPressed: _numeroHuespedes > 1
                    ? () => setState(() => _numeroHuespedes--)
                    : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: _numeroHuespedes > 1
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                '$_numeroHuespedes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed:
                    _numeroHuespedes <
                        10 // TODO: Usar capacidadMaxima del backend
                    ? () => setState(() => _numeroHuespedes++)
                    : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _numeroHuespedes < 10
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (_numeroHuespedes == 10) ...[
          const SizedBox(height: 8),
          Text(
            'Capacidad máxima: 10 huéspedes', // TODO: Usar capacidadMaxima del backend
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildGuestInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información del huésped principal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nombreController,
          label: 'Nombre completo',
          hintText: 'Ingresa tu nombre completo',
          prefixIcon: Icon(Icons.person_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Correo electrónico',
          hintText: 'ejemplo@correo.com',
          prefixIcon: Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El correo es obligatorio';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Ingresa un correo válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _telefonoController,
          label: 'Teléfono',
          hintText: '+57 300 123 4567',
          prefixIcon: Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El teléfono es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSpecialRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Solicitudes especiales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Opcional - Comparte cualquier solicitud especial con el anfitrión',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _solicitudesController,
          label: 'Solicitudes especiales',
          hintText:
              'Ej: Llegada tarde, celebración especial, necesidades dietéticas...',
          maxLines: 4,
          prefixIcon: Icon(Icons.message_outlined),
        ),
      ],
    );
  }

  Widget _buildCostSummary() {
    if (_fechaInicio == null || _fechaFin == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Selecciona las fechas para ver el costo total',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    final dias = _fechaFin!.difference(_fechaInicio!).inDays;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de costos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildCostRow(
              '\$${widget.finca.precioPorNoche.toStringAsFixed(0)} x $dias noches',
              '\$${_subtotal.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            _buildCostRow(
              'Tasas y servicios',
              '\$${_tasasServicios.toStringAsFixed(0)}',
            ),
            const Divider(height: 24),
            _buildCostRow(
              'Total',
              '\$${_total.toStringAsFixed(0)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final isFormValid =
        _fechaInicio != null &&
        _fechaFin != null &&
        _nombreController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _telefonoController.text.isNotEmpty;

    // Debug: imprimir estado de validación
    print('🔍 VALIDACIÓN FORMULARIO:');
    print('  - Fecha inicio: ${_fechaInicio != null ? 'OK' : 'FALTA'}');
    print('  - Fecha fin: ${_fechaFin != null ? 'OK' : 'FALTA'}');
    print(
      '  - Nombre: ${_nombreController.text.isNotEmpty ? 'OK' : 'FALTA'} (${_nombreController.text})',
    );
    print(
      '  - Email: ${_emailController.text.isNotEmpty ? 'OK' : 'FALTA'} (${_emailController.text})',
    );
    print(
      '  - Teléfono: ${_telefonoController.text.isNotEmpty ? 'OK' : 'FALTA'} (${_telefonoController.text})',
    );
    print('  - Formulario válido: $isFormValid');
    print('  - Loading: $_isLoading');

    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isLoading
            ? 'Verificando disponibilidad...'
            : 'Confirmar Reserva',
        onPressed: isFormValid && !_isLoading ? _confirmarReserva : null,
      ),
    );
  }

  Future<void> _confirmarReserva() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Preparar fechas en formato YYYY-MM-DD
      final fechaInicioStr = _fechaInicio!.toIso8601String().split(
        'T',
      )[0]; // YYYY-MM-DD
      final fechaFinStr = _fechaFin!.toIso8601String().split('T')[0];

      // PASO 1: Verificar disponibilidad antes de crear la reserva
      print('🔍 Verificando disponibilidad antes de crear reserva...');
      final disponible = await ReservaService().verificarDisponibilidad(
        fincaId: int.parse(widget.finca.id),
        fechaInicio: fechaInicioStr,
        fechaFin: fechaFinStr,
      );

      if (!disponible) {
        // Las fechas NO están disponibles
        setState(() => _isLoading = false);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 28),
                  const SizedBox(width: 12),
                  const Text('Fechas no disponibles'),
                ],
              ),
              content: Text(
                'Las fechas seleccionadas ya han sido reservadas por otro usuario. Por favor, selecciona otras fechas.',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // PASO 2: Si está disponible, crear la reserva
      print('✅ Fechas disponibles, creando reserva...');
      final reserva = await ReservaService().crearReserva(
        usuarioId: 1, // TODO: Obtener del usuario autenticado
        fincaId: int.parse(widget.finca.id),
        fechaInicio: fechaInicioStr,
        fechaFin: fechaFinStr,
      );

      if (mounted && reserva != null) {
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
                const Text('¡Reserva confirmada!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu reserva ha sido confirmada exitosamente.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles de la reserva:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('ID: ${reserva.id}'),
                      Text(
                        'Fechas: ${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year} - ${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}',
                      ),
                      Text('Huéspedes: $_numeroHuespedes'),
                      Text('Total: \$${_total.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recibirás un correo de confirmación en ${_emailController.text}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar dialog
                  Navigator.of(context).pop(); // Cerrar booking screen
                  Navigator.of(context).pop(); // Cerrar detail screen
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la reserva: $e'),
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
}
