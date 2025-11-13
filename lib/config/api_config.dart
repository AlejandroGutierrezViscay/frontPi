/// Configuración centralizada para API
/// Maneja todas las URLs y configuraciones del backend
class ApiConfig {
  // ✅ URL CORRECTA - localhost:8080 (puerto obligatorio para el proyecto)
  static const String baseUrl =
      'https://backfincasmart-production.up.railway.app';

  // Headers estándar para todas las peticiones
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Charset': 'utf-8',
  };

  // Headers con autenticación
  static Map<String, String> headersWithAuth(String token) {
    return {...headers, 'Authorization': 'Bearer $token'};
  }

  // Endpoints de usuarios (según backend real)
  static const String usersEndpoint = '/api/users';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';

  // Endpoints de fincas
  static const String fincasEndpoint = '/api/fincas';
  static const String misFincasEndpoint = '/api/fincas/mis-fincas';

  // Endpoints de reservas
  static const String reservasEndpoint = '/api/reservas';
  static const String misReservasEndpoint = '/api/reservas/mis-reservas';

  // URLs completas
  static String get usersUrl => '$baseUrl$usersEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get fincasUrl => '$baseUrl$fincasEndpoint';
  static String get misFincasUrl => '$baseUrl$misFincasEndpoint';
  static String get reservasUrl => '$baseUrl$reservasEndpoint';
  static String get misReservasUrl => '$baseUrl$misReservasEndpoint';

  // Configuración de timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Debug: imprimir configuración
  static void printConfig() {
    print('🔧 API CONFIGURATION:');
    print('  Base URL: $baseUrl');
    print('  Users: $usersUrl');
    print('  Login: $loginUrl');
    print('  Register: $registerUrl');
    print('  Fincas: $fincasUrl');
    print('  Reservas: $reservasUrl');
  }

  // Verificar si la URL es correcta
  static bool get isLocalhost => baseUrl.contains('localhost:8080');

  // Método para probar conectividad (endpoint de usuarios como health check)
  static String get healthCheckUrl => '$baseUrl/api/users';
}
