import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/finca.dart';
import '../../models/resena.dart';
import '../../services/resena_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/estadisticas_resenas_widget.dart';
import '../../widgets/resena_card.dart';
import 'booking_screen.dart';

class FincaDetailScreen extends StatefulWidget {
  final Finca finca;

  const FincaDetailScreen({super.key, required this.finca});

  @override
  State<FincaDetailScreen> createState() => _FincaDetailScreenState();
}

class _FincaDetailScreenState extends State<FincaDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  // Estado de reseñas
  final ResenaService _resenaService = ResenaService();
  List<Resena> _resenas = [];
  EstadisticasResenas? _estadisticas;
  bool _isLoadingResenas = false;

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    setState(() => _isLoadingResenas = true);

    try {
      final fincaId = int.parse(widget.finca.id);

      // Cargar reseñas y estadísticas en paralelo
      final results = await Future.wait([
        _resenaService.obtenerResenasPorFinca(fincaId),
        _resenaService.obtenerEstadisticas(fincaId),
      ]);

      setState(() {
        _resenas = results[0] as List<Resena>;
        _estadisticas = results[1] as EstadisticasResenas?;
        _isLoadingResenas = false;
      });
    } catch (e) {
      print('Error cargando reseñas: $e');
      setState(() => _isLoadingResenas = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(background: _buildImageCarousel()),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isFavorite
                            ? 'Agregado a favoritos'
                            : 'Removido de favoritos',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // TODO: Implementar compartir
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compartir próximamente disponible'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y precio
                  _buildHeaderSection(),
                  const SizedBox(height: 24),

                  // Información básica
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),

                  // Descripción
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),

                  // Servicios y amenidades
                  _buildServicesSection(),
                  const SizedBox(height: 24),

                  // TODO: Actividades disponibles - pendiente de implementar en backend
                  // if (widget.finca.actividades.isNotEmpty) ...[
                  //   _buildActivitiesSection(),
                  //   const SizedBox(height: 24),
                  // ],

                  // Ubicación
                  _buildLocationSection(),
                  const SizedBox(height: 24),

                  // TODO: Reglas de la casa - pendiente de implementar en backend
                  // if (widget.finca.reglas.isNotEmpty) ...[
                  //   _buildRulesSection(),
                  //   const SizedBox(height: 24),
                  // ],

                  // Reseñas y calificaciones
                  _buildReviewsSection(),
                  const SizedBox(height: 100), // Espacio para el botón flotante
                ],
              ),
            ),
          ),
        ],
      ),

      // Botón de reservar flotante
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${widget.finca.precioPorNoche.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'por noche',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Reservar Ahora',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingScreen(finca: widget.finca),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final imagenes = widget.finca.imagenes ?? [];
    if (imagenes.isEmpty) {
      return Container(
        color: AppColors.primary.withOpacity(0.1),
        child: const Center(
          child: Icon(
            Icons.home_work_outlined,
            size: 80,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: imagenes.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final imagen = imagenes[index];
            return _buildImage(imagen.urlImagen);
          },
        ),

        // Indicadores de página
        if (imagenes.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imagenes.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(String imagePath) {
    print(
      '🖼️ Intentando cargar imagen: ${imagePath.substring(0, imagePath.length > 100 ? 100 : imagePath.length)}...',
    );

    if (imagePath.isEmpty) {
      print('⚠️ URL de imagen vacía');
      return Container(
        color: AppColors.primary.withOpacity(0.1),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 80,
                color: AppColors.primary,
              ),
              SizedBox(height: 8),
              Text(
                'Sin imagen',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (imagePath.startsWith('data:image/') || imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('✅ Imagen cargada exitosamente');
            return child;
          }
          final progress = loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null;
          print(
            '📥 Cargando imagen: ${progress != null ? (progress * 100).toStringAsFixed(0) : "?"}%',
          );
          return Center(child: CircularProgressIndicator(value: progress));
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error al cargar imagen: $error');
          return Container(
            color: AppColors.primary.withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error al cargar imagen',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    print('⚠️ Formato de imagen no reconocido');
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 80,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Finca', // TODO: Agregar tipo de finca cuando el backend lo soporte
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            // TODO: Calificaciones - pendiente de implementar en backend
            // Row(
            //   children: [
            //     Icon(Icons.star, color: Colors.amber[600], size: 20),
            //     const SizedBox(width: 4),
            //     Text(
            //       '0.0',
            //       style: const TextStyle(
            //         fontWeight: FontWeight.w600,
            //         fontSize: 16,
            //       ),
            //     ),
            //     Text(
            //       ' (0 reviews)',
            //       style: TextStyle(
            //         color: AppColors.textSecondary,
            //         fontSize: 14,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.finca.nombre,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.finca.ubicacion,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información básica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: Información adicional - pendiente de implementar en backend
            // Row(
            //   children: [
            //     _buildInfoItem(
            //       Icons.people_outline,
            //       'Huéspedes',
            //       '0', // capacidadMaxima
            //     ),
            //     _buildInfoItem(
            //       Icons.bed_outlined,
            //       'Habitaciones',
            //       '0', // numeroHabitaciones
            //     ),
            //     _buildInfoItem(
            //       Icons.bathroom_outlined,
            //       'Baños',
            //       '0', // numeroBanos
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // TODO: Info items (huéspedes, habitaciones, baños) - pendiente de implementar en backend
  /*
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  */

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.finca.descripcion,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios y amenidades',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: (widget.finca.amenidades ?? []).map((amenidad) {
            final nombre = amenidad.nombre;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                nombre,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        ),
        /* OLD CODE - comentado para usar amenidades del backend
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.finca.servicios.map((servicio) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getServiceIcon(servicio),
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    servicio,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        */
      ],
    );
  }

  // TODO: Actividades - pendiente de implementar en backend
  /* 
  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividades disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.finca.actividades.map((actividad) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getActivityIcon(actividad),
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    actividad,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  */

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_city_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.finca.ubicacion, // Usar ubicacion directamente
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.finca.ubicacion,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TODO: Reglas - pendiente de implementar en backend
  /*
  Widget _buildRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reglas de la casa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.finca.reglas.map((regla) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: regla.esObligatoria
                        ? AppColors.error
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        regla.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: regla.esObligatoria
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (regla.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          regla.descripcion,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  */

  // TODO: Reseñas/Reviews - pendiente de implementar en backend
  /*
  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Calificaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Implementar pantalla de todas las reviews
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ver todas las reseñas próximamente'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    widget.finca.calificacion.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.finca.calificacion.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber[600],
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.finca.numeroReviews} reseñas',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Excelente puntuación basada en ${widget.finca.numeroReviews} reseñas de huéspedes.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los huéspedes destacan: limpieza, ubicación y atención del anfitrión.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  */

  // TODO: TipoFinca - pendiente de implementar en backend
  /*
  String _getTipoFincaString(TipoFinca tipo) {
    switch (tipo) {
      case TipoFinca.casa:
        return 'Casa';
      case TipoFinca.cabana:
        return 'Cabaña';
      case TipoFinca.hacienda:
        return 'Hacienda';
      case TipoFinca.finca:
        return 'Finca';
      case TipoFinca.lodge:
        return 'Lodge';
      case TipoFinca.camping:
        return 'Camping';
      case TipoFinca.glamping:
        return 'Glamping';
    }
  }
  */

  // TODO: Service Icons - pendiente de implementar en backend
  /*
  IconData _getServiceIcon(String servicio) {
    switch (servicio.toLowerCase()) {
      case 'piscina':
        return Icons.pool_outlined;
      case 'wifi':
        return Icons.wifi_outlined;
      case 'aire acondicionado':
        return Icons.ac_unit_outlined;
      case 'cocina equipada':
        return Icons.kitchen_outlined;
      case 'parqueadero':
        return Icons.local_parking_outlined;
      case 'zona bbq':
        return Icons.outdoor_grill_outlined;
      case 'jardín':
        return Icons.grass_outlined;
      case 'mascotas permitidas':
        return Icons.pets_outlined;
      case 'tv cable':
        return Icons.tv_outlined;
      case 'lavandería':
        return Icons.local_laundry_service_outlined;
      case 'zona de juegos':
        return Icons.sports_soccer_outlined;
      case 'vista panorámica':
        return Icons.landscape_outlined;
      case 'chimenea':
        return Icons.fireplace_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }
  */

  // TODO: Activity Icons - pendiente de implementar en backend
  /*
  IconData _getActivityIcon(String actividad) {
    switch (actividad.toLowerCase()) {
      case 'senderismo':
        return Icons.hiking_outlined;
      case 'observación de aves':
        return Icons.visibility_outlined;
      case 'ciclismo':
        return Icons.pedal_bike_outlined;
      case 'fogata':
        return Icons.local_fire_department_outlined;
      case 'observación de estrellas':
        return Icons.nights_stay_outlined;
      case 'cabalgatas':
        return Icons.directions_run_outlined;
      case 'pesca':
        return Icons.phishing_outlined;
      case 'volleyball':
        return Icons.sports_volleyball_outlined;
      case 'fútbol':
        return Icons.sports_soccer_outlined;
      default:
        return Icons.local_activity_outlined;
    }
  }
  */

  // ==================== SECCIÓN DE RESEÑAS ====================

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Reseñas y calificaciones',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Estadísticas o loading
        if (_isLoadingResenas)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_estadisticas != null) ...[
          // Mostrar estadísticas
          EstadisticasResenasWidget(estadisticas: _estadisticas!),
          const SizedBox(height: 24),

          // Filtros (opcional)
          if (_estadisticas!.totalResenas > 0) ...[
            Row(
              children: [
                Text(
                  'Mostrando ${_resenas.length} ${_resenas.length == 1 ? 'reseña' : 'reseñas'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                // TODO: Agregar botón de filtros si se necesita
                // TextButton.icon(
                //   onPressed: () {
                //     // Mostrar filtros
                //   },
                //   icon: const Icon(Icons.filter_list, size: 18),
                //   label: const Text('Filtrar'),
                // ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de reseñas
            ..._resenas.map((resena) {
              return ResenaCard(
                resena: resena,
                mostrarUsuario: true,
                mostrarFinca: false,
              );
            }),

            // Botón para ver todas las reseñas (si hay muchas)
            if (_resenas.length > 5)
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Navegar a pantalla con todas las reseñas
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ver todas las reseñas - Próximamente'),
                      ),
                    );
                  },
                  child: const Text('Ver todas las reseñas'),
                ),
              ),
          ],
        ] else ...[
          // No hay reseñas aún
          Container(
            padding: const EdgeInsets.all(32),
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
                Icon(
                  Icons.rate_review_outlined,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aún no hay reseñas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¡Sé el primero en dejar una reseña!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
