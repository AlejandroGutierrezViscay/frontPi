import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/auth/welcome_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/home/home_screen.dart';
import '../views/finca/add_finca_screen.dart';
import '../views/finca/my_fincas_screen.dart';
import '../views/finca/my_reservas_screen.dart';
import '../views/finca/finca_detail_screen.dart';
import '../views/finca/booking_screen.dart';
import '../models/finca.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addFinca = '/add-finca';
  static const String myFincas = '/my-fincas';
  static const String myReservas = '/my-reservas';
  static const String fincaDetail = '/finca-detail';
  static const String booking = '/booking';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true,
    routes: [
      // Pantalla de bienvenida/splash
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Pantalla de login
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),

      // Pantalla de registro
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),

      // Pantalla principal (home)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
                child: child,
              ),
        ),
      ),

      // Pantalla para agregar finca
      GoRoute(
        path: AppRoutes.addFinca,
        name: 'addFinca',
        builder: (context, state) => const AddFincaScreen(),
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AddFincaScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),

      // Pantalla de mis fincas
      GoRoute(
        path: AppRoutes.myFincas,
        name: 'myFincas',
        builder: (context, state) => const MyFincasScreen(),
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MyFincasScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),

      // Pantalla de mis reservas
      GoRoute(
        path: AppRoutes.myReservas,
        name: 'myReservas',
        builder: (context, state) => const MyReservasScreen(),
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MyReservasScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),

      // Pantalla de detalle de finca
      GoRoute(
        path: AppRoutes.fincaDetail,
        name: 'fincaDetail',
        builder: (context, state) {
          final finca = state.extra as Finca;
          return FincaDetailScreen(finca: finca);
        },
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: FincaDetailScreen(finca: state.extra as Finca),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),

      // Pantalla de reserva
      GoRoute(
        path: AppRoutes.booking,
        name: 'booking',
        builder: (context, state) {
          final finca = state.extra as Finca;
          return BookingScreen(finca: finca);
        },
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: BookingScreen(finca: state.extra as Finca),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
        ),
      ),
    ],

    // Manejo de errores de navegación
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'La página "${state.matchedLocation}" no existe.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.welcome),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Extensiones para facilitar la navegación
extension GoRouterExtension on BuildContext {
  void goToWelcome() => go(AppRoutes.welcome);
  void goToLogin() => go(AppRoutes.login);
  void goToRegister() => go(AppRoutes.register);
  void goToHome() => go(AppRoutes.home);

  void pushLogin() => push(AppRoutes.login);
  void pushRegister() => push(AppRoutes.register);

  bool canPop() => GoRouter.of(this).canPop();
  void popOrGoHome() {
    if (canPop()) {
      pop();
    } else {
      goToHome();
    }
  }
}
