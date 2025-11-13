import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/finca.dart';
import '../../services/finca_service.dart';

class AddFincaScreen extends StatefulWidget {
  const AddFincaScreen({super.key});

  @override
  State<AddFincaScreen> createState() => _AddFincaScreenState();
}

class _AddFincaScreenState extends State<AddFincaScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final FincaService _fincaService = FincaService();

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _precioController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _habitacionesController = TextEditingController();
  final _banosController = TextEditingController();
  final _areaController = TextEditingController();
  final _reglasController = TextEditingController();

  // Estado del formulario
  int _currentPage = 0;
  // TipoFinca _tipoSeleccionado = TipoFinca.casa; // TODO: Descomentar cuando backend soporte tipos
  final List<XFile> _fotos = [];
  final List<String> _amenidadesSeleccionadas = [];
  bool _isLoading = false;

  // Lista de amenidades disponibles (nombres deben coincidir EXACTAMENTE con el backend)
  final List<Map<String, dynamic>> _amenidadesDisponibles = [
    {'nombre': 'WiFi Gratuito', 'icono': Icons.wifi_outlined},
    {'nombre': 'Piscina', 'icono': Icons.pool_outlined},
    {'nombre': 'Parqueadero', 'icono': Icons.local_parking_outlined},
    {'nombre': 'Zona BBQ', 'icono': Icons.outdoor_grill_outlined},
    {'nombre': 'Aire Acondicionado', 'icono': Icons.ac_unit_outlined},
    {'nombre': 'Cocina Equipada', 'icono': Icons.kitchen_outlined},
    {'nombre': 'Jacuzzi', 'icono': Icons.hot_tub_outlined},
    {'nombre': 'Cancha de Fútbol', 'icono': Icons.sports_soccer_outlined},
    {
      'nombre': 'Servicio de Limpieza',
      'icono': Icons.cleaning_services_outlined,
    },
    {'nombre': 'Desayuno Incluido', 'icono': Icons.restaurant_outlined},
  ];

  @override
  void initState() {
    super.initState();
    // Agregar listeners para actualizar el estado cuando cambien los campos
    _nombreController.addListener(() => setState(() {}));
    _descripcionController.addListener(() => setState(() {}));
    _ubicacionController.addListener(() => setState(() {}));
    _precioController.addListener(() => setState(() {}));
    _capacidadController.addListener(() => setState(() {}));
    _habitacionesController.addListener(() => setState(() {}));
    _banosController.addListener(() => setState(() {}));
    _areaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _precioController.dispose();
    _capacidadController.dispose();
    _habitacionesController.dispose();
    _banosController.dispose();
    _areaController.dispose();
    _reglasController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (imagen != null) {
      setState(() {
        _fotos.add(imagen);
      });
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
    });
  }

  void _toggleAmenidad(String amenidad) {
    setState(() {
      if (_amenidadesSeleccionadas.contains(amenidad)) {
        _amenidadesSeleccionadas.remove(amenidad);
      } else {
        _amenidadesSeleccionadas.add(amenidad);
      }
    });
  }

  void _siguientePagina() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _guardarFinca();
    }
  }

  void _paginaAnterior() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validarPaginaActual() {
    switch (_currentPage) {
      case 0:
        return _nombreController.text.isNotEmpty &&
            _ubicacionController.text.isNotEmpty &&
            _descripcionController.text.isNotEmpty;
      case 1:
        return _precioController.text.isNotEmpty &&
            _capacidadController.text.isNotEmpty &&
            _habitacionesController.text.isNotEmpty &&
            _banosController.text.isNotEmpty;
      case 2:
        // Las fotos son opcionales ahora (backend no soporta base64 grandes)
        return true;
      default:
        return false;
    }
  }

  String _convertBytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  Future<void> _guardarFinca() async {
    if (!_formKey.currentState!.validate() || !_validarPaginaActual()) {
      _mostrarError('Por favor completa todos los campos obligatorios');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📸 Iniciando guardado de finca con ${_fotos.length} fotos...');

      // Paso 1: Crear la finca (sin amenidades ni imágenes)
      final nuevaFinca = await _fincaService.crearFinca(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precioPorNoche: double.parse(_precioController.text.trim()),
        ubicacion: _ubicacionController.text.trim(),
        propietarioId: 1, // TODO: Obtener del usuario autenticado
        amenidades: null, // NO enviar amenidades aquí para evitar error 500
      );

      if (nuevaFinca == null) {
        _mostrarError('Error al crear la finca');
        return;
      }

      print('✅ Finca creada con ID: ${nuevaFinca.id}');

      // Paso 2: Agregar amenidades (si hay)
      if (_amenidadesSeleccionadas.isNotEmpty) {
        print('🏷️ Agregando ${_amenidadesSeleccionadas.length} amenidades...');
        print('   Amenidades seleccionadas: $_amenidadesSeleccionadas');
        try {
          final success = await _fincaService.agregarAmenidadesAFinca(
            fincaId: int.parse(nuevaFinca.id),
            nombresAmenidades: _amenidadesSeleccionadas,
          );
          if (success) {
            print('✅ Amenidades agregadas correctamente');
          } else {
            print('⚠️ Error al agregar amenidades - revisar logs del servicio');
          }
        } catch (e) {
          print('❌ Error al procesar amenidades: $e');
        }
      } else {
        print('ℹ️ No se seleccionaron amenidades');
      }

      // Paso 3: Subir las imágenes (si hay)
      // NOTA: Las imágenes base64 no se subirán porque el backend limita a 500 caracteres
      // y las imágenes base64 tienen 14,000+ caracteres. La finca se creará sin imágenes.
      if (_fotos.isNotEmpty) {
        print('⚠️ Imágenes seleccionadas pero NO se subirán');
        print('   Razón: Backend limita URLs a 500 caracteres');
        print('   Tamaño típico de imagen base64: 14,000+ caracteres');
        print('   La finca se creará SIN imágenes por ahora.');
        print('');
        print('💡 Para subir imágenes necesitas:');
        print('   1. Modificar backend: cambiar url_imagen a TEXT sin límite');
        print('   2. O usar servicio externo: Cloudinary, ImgBB, AWS S3');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Finca "${nuevaFinca.nombre}" publicada exitosamente!',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Error al guardar finca: $e');
      _mostrarError('Error al guardar la finca: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _extraerCiudad(String ubicacion) {
    final partes = ubicacion.split(',');
    return partes.isNotEmpty ? partes.first.trim() : ubicacion;
  }

  String _extraerDepartamento(String ubicacion) {
    final partes = ubicacion.split(',');
    return partes.length > 1 ? partes.last.trim() : 'N/A';
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Agregar mi Finca',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Indicador de progreso
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Contenido del formulario
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [_buildPagina1(), _buildPagina2(), _buildPagina3()],
              ),
            ),
          ),

          // Botones de navegación
          _buildBotonesNavegacion(),
        ],
      ),
    );
  }

  Widget _buildPagina1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Básica',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuéntanos sobre tu finca',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            label: 'Nombre de la finca',
            hintText: 'Ej: Villa El Paraíso',
            controller: _nombreController,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Ubicación',
            hintText: 'Ciudad, Departamento',
            controller: _ubicacionController,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Selector de tipo de finca
          const Text(
            'Tipo de propiedad',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // TODO: Descomentar cuando backend soporte tipos de finca
          /*
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: TipoFinca.values.map((tipo) {
              final isSelected = _tipoSeleccionado == tipo;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _tipoSeleccionado = tipo;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    _getTipoFincaTexto(tipo),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          */
          Text(
            'Tipo: Finca', // TODO: Permitir selección cuando backend lo soporte
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          CustomTextField(
            label: 'Descripción',
            hintText: 'Describe tu finca, qué la hace especial...',
            controller: _descripcionController,
            maxLines: 4,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPagina2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles y Precios',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Información específica sobre tu propiedad',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Precio por noche',
                  hintText: '\$150,000',
                  controller: _precioController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Obligatorio';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Capacidad máxima',
                  hintText: '8 personas',
                  controller: _capacidadController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Obligatorio';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Habitaciones',
                  hintText: '3',
                  controller: _habitacionesController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Obligatorio';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Baños',
                  hintText: '2',
                  controller: _banosController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Obligatorio';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Área (m²)',
            hintText: '250',
            controller: _areaController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          // Amenidades
          const Text(
            'Amenidades disponibles',
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
            children: _amenidadesDisponibles.map((amenidad) {
              final isSelected = _amenidadesSeleccionadas.contains(
                amenidad['nombre'],
              );
              return GestureDetector(
                onTap: () => _toggleAmenidad(amenidad['nombre']),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        amenidad['icono'],
                        size: 20,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        amenidad['nombre'],
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          CustomTextField(
            label: 'Reglas de la casa (opcional)',
            hintText: 'No fumar, no mascotas, etc.',
            controller: _reglasController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPagina3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fotos de tu Finca',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega al menos una foto para mostrar tu propiedad',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // Botón para agregar fotos
          GestureDetector(
            onTap: _seleccionarFoto,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agregar foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Galería de fotos
          if (_fotos.isNotEmpty) ...[
            const Text(
              'Fotos agregadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _fotos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.surface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FutureBuilder<String>(
                          future: () async {
                            final bytes = await _fotos[index].readAsBytes();
                            return 'data:image/jpeg;base64,${_convertBytesToBase64(bytes)}';
                          }(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.network(
                                snapshot.data!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.primary.withOpacity(0.1),
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _eliminarFoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBotonesNavegacion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: CustomButton(
                  text: 'Anterior',
                  onPressed: _paginaAnterior,
                  type: CustomButtonType.outline,
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: _currentPage == 2 ? 'Publicar Finca' : 'Siguiente',
                onPressed: _validarPaginaActual() ? _siguientePagina : null,
                type: CustomButtonType.primary,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Descomentar cuando backend soporte tipos de finca
  /*
  String _getTipoFincaTexto(TipoFinca tipo) {
    switch (tipo) {
      case TipoFinca.casa:
        return 'Casa de Campo';
      case TipoFinca.cabana:
        return 'Cabaña';
      case TipoFinca.finca:
        return 'Finca';
      case TipoFinca.hacienda:
        return 'Hacienda';
      case TipoFinca.glamping:
        return 'Glamping';
      case TipoFinca.lodge:
        return 'Lodge';
      case TipoFinca.camping:
        return 'Camping';
    }
  }
  */
}
