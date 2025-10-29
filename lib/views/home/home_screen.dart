import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/finca.dart';
import '../../services/finca_service.dart';
import '../../widgets/loading_indicator.dart';
import '../debug/api_test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FincaService _fincaService = FincaService();
  final TextEditingController _searchController = TextEditingController();
  List<Finca> _fincasFiltradas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarFincas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarFincas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fincas = await _fincaService.obtenerFincas();
      setState(() {
        _fincasFiltradas = fincas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _mostrarBusqueda() {
    showSearch(context: context, delegate: FincaSearchDelegate(_fincaService));
  }

  void _mostrarFiltros() {
    // TODO: Implementar pantalla de filtros
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filtros próximamente disponibles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Fondo blanco puro
      appBar: AppBar(
        title: const Text(
          'FincaSmart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary, // Texto blanco
            fontSize: 20,
          ),
        ),
        centerTitle: true, // Centrar el título
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient, // Gradiente verde
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textOnPrimary,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.icon),
            onPressed: _mostrarBusqueda,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.icon),
            onPressed: _mostrarFiltros,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.icon),
            onSelected: (value) {
              switch (value) {
                case 'mis_fincas':
                  context.push(AppRoutes.myFincas);
                  break;
                case 'mis_reservas':
                  context.push(AppRoutes.myReservas);
                  break;
                case 'logout':
                  // TODO: Implementar logout
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mis_fincas',
                child: Row(
                  children: [
                    Icon(Icons.home_work_outlined),
                    SizedBox(width: 12),
                    Text('Mis Fincas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mis_reservas',
                child: Row(
                  children: [
                    Icon(Icons.event_note_outlined),
                    SizedBox(width: 12),
                    Text('Mis Reservas', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined),
                    SizedBox(width: 12),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Stack(
        children: [
          // Botón principal: Agregar Finca
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton.extended(
              onPressed: () {
                context.push(AppRoutes.addFinca);
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_home_outlined),
              label: const Text(
                'Agregar Finca',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // Botón temporal: Test API
          Positioned(
            bottom: 70,
            right: 0,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ApiTestScreen(),
                  ),
                );
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              child: const Icon(Icons.api),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return RefreshIndicator(
      onRefresh: _cargarFincas,
      child: _buildListaFincas(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las fincas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cargarFincas,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaFincas() {
    if (_fincasFiltradas.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fincasFiltradas.length,
      itemBuilder: (context, index) {
        final finca = _fincasFiltradas[index];
        return _buildFincaCard(finca);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.home_work_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay fincas disponibles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sé el primero en agregar una finca',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push(AppRoutes.addFinca);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Agregar mi primera finca',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFincaCard(Finca finca) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push('/finca-detail', extra: finca);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la finca
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: finca.imagenes.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: _buildFincaImage(finca.imagenes.first),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.home_work_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),

            // Información de la finca
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    finca.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          finca.ubicacion,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    finca.descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.people_outline,
                        '${finca.capacidadMaxima} personas',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.bed_outlined,
                        '${finca.numeroHabitaciones} hab.',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.bathroom_outlined,
                        '${finca.numeroBanos} baños',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${finca.precio.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'por noche',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
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

  Widget _buildFincaImage(String imagePath) {
    // Para imágenes en formato base64 (fincas creadas por el usuario)
    if (imagePath.startsWith('data:image/')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: AppColors.primary.withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error al cargar imagen',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Para imágenes de ejemplo (URLs de internet)
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 200,
            color: AppColors.primary.withOpacity(0.1),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: AppColors.primary.withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error al cargar imagen',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Fallback para otros casos
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

// Función auxiliar para construir widgets de imagen de finca
Widget buildFincaImageWidget(String imagePath) {
  // Para imágenes en formato base64 (fincas creadas por el usuario)
  if (imagePath.startsWith('data:image/')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  // Para imágenes de ejemplo (URLs de internet)
  if (imagePath.startsWith('http')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  // Para imágenes de assets/predeterminadas
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.asset(
      imagePath,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: Icon(
            Icons.home_work_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        );
      },
    ),
  );
}

// Delegate para búsqueda de fincas
class FincaSearchDelegate extends SearchDelegate<Finca?> {
  final FincaService _fincaService;

  FincaSearchDelegate(this._fincaService);

  @override
  String get searchFieldLabel => 'Buscar fincas...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Escribe algo para buscar fincas'));
    }

    return FutureBuilder<List<Finca>>(
      future: _fincaService.buscarFincas(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final fincas = snapshot.data ?? [];

        if (fincas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No se encontraron fincas',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Intenta con otros términos de búsqueda',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: fincas.length,
          itemBuilder: (context, index) {
            final finca = fincas[index];
            return ListTile(
              leading: finca.imagenes.isNotEmpty
                  ? buildFincaImageWidget(finca.imagenes.first)
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.home_work_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
              title: Text(finca.titulo),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(finca.ubicacion),
                  Text(
                    '\$${finca.precio.toStringAsFixed(0)}/noche',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // TODO: Navegar a detalles de la finca
                close(context, finca);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
