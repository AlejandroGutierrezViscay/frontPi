import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/api_config.dart';
import 'services/user_api_service.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar API y verificar conectividad
  await _configurarAPI();

  runApp(const FincaSmartApp());
}

Future<void> _configurarAPI() async {
  print('🚀 INICIANDO CONFIGURACIÓN API');

  // Mostrar configuración
  ApiConfig.printConfig();

  // Verificar que estamos usando localhost
  if (!ApiConfig.isLocalhost) {
    print('⚠️ ADVERTENCIA: No estás usando localhost!');
    print('   URL actual: ${ApiConfig.baseUrl}');
  }

  // Probar conectividad con backend
  print('🔍 Verificando conectividad con backend...');
  final userApiService = UserApiService();
  final conectado = await userApiService.probarConexion();

  if (conectado) {
    print('✅ Backend disponible en ${ApiConfig.baseUrl}');
    print('🎯 Modo API ACTIVADO - Los datos se guardarán en PostgreSQL');
  } else {
    print('❌ Backend no disponible - Verifica que Spring Boot esté corriendo');
    print('💡 Ejecuta tu proyecto Spring Boot en localhost:8080');
  }

  print('🚀 CONFIGURACIÓN API COMPLETADA\n');
}

class FincaSmartApp extends StatelessWidget {
  const FincaSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FincaSmart - Alquiler de Fincas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
