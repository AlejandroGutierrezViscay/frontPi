import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/finca.dart';
import '../../widgets/custom_button.dart';
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

                  // Actividades disponibles
                  if (widget.finca.actividades.isNotEmpty) ...[
                    _buildActivitiesSection(),
                    const SizedBox(height: 24),
                  ],

                  // Ubicación
                  _buildLocationSection(),
                  const SizedBox(height: 24),

                  // Reglas de la casa
                  if (widget.finca.reglas.isNotEmpty) ...[
                    _buildRulesSection(),
                    const SizedBox(height: 24),
                  ],

                  // Calificaciones y reviews
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
                      '\$${widget.finca.precio.toStringAsFixed(0)}',
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
    if (widget.finca.imagenes.isEmpty) {
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
          itemCount: widget.finca.imagenes.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final imagePath = widget.finca.imagenes[index];
            return _buildImage(imagePath);
          },
        ),

        // Indicadores de página
        if (widget.finca.imagenes.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.finca.imagenes.asMap().entries.map((entry) {
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
    if (imagePath.startsWith('data:image/') || imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.primary.withOpacity(0.1),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    }

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
                _getTipoFincaString(widget.finca.tipo),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  widget.finca.calificacion.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  ' (${widget.finca.numeroReviews} reviews)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.finca.titulo,
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
            Row(
              children: [
                _buildInfoItem(
                  Icons.people_outline,
                  'Huéspedes',
                  '${widget.finca.capacidadMaxima}',
                ),
                _buildInfoItem(
                  Icons.bed_outlined,
                  'Habitaciones',
                  '${widget.finca.numeroHabitaciones}',
                ),
                _buildInfoItem(
                  Icons.bathroom_outlined,
                  'Baños',
                  '${widget.finca.numeroBanos}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
      ],
    );
  }

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
                    '${widget.finca.ciudad}, ${widget.finca.departamento}',
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
}
