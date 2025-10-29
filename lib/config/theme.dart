import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Paleta FincaSmart - Verde degradado profesional
  static const Color primary = Color(0xFF2E7D32); // Verde oscuro principal
  static const Color primaryLight = Color(0xFF4CAF50); // Verde medio
  static const Color secondary = Color(0xFF66BB6A); // Verde claro
  static const Color accent = Color(0xFF81C784); // Verde muy claro

  // Colores base FincaSmart
  static const Color background = Color(0xFFFFFFFF); // Blanco puro
  static const Color surface = Color(0xFFFFFFFF); // Superficie blanca
  static const Color cardSurface = Color(0xFFFFFFFF); // Blanco para tarjetas
  static const Color error = Color(0xFFE53935); // Rojo error
  static const Color warning = Color(0xFFFFC107); // Amarillo advertencia
  static const Color success = Color(0xFF4CAF50); // Verde éxito

  // Colores de texto
  static const Color textPrimary = Color(0xFF212121); // Gris muy oscuro
  static const Color textSecondary = Color(0xFF757575); // Gris medio
  static const Color textDisabled = Color(0xFFBDBDBD); // Gris claro
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // Blanco para texto sobre verde

  // Variaciones para degradados
  static const Color primaryDark = Color(0xFF1B5E20); // Verde muy oscuro
  static const Color gradientStart = Color(0xFF2E7D32); // Inicio degradado
  static const Color gradientEnd = Color(0xFF4CAF50); // Final degradado

  // Colores adicionales
  static const Color earth = Color(0xFFBCAAA4); // Tierra suave
  static const Color sky = Color(0xFFE3F2FD); // Cielo muy claro
  static const Color sunset = Color(0xFFFFF3E0); // Atardecer suave

  // Colores específicos para la interfaz limpia
  static const Color divider = Color(0xFFE0E0E0); // Divisores sutiles
  static const Color border = Color(0xFFE0E0E0); // Bordes neutros
  static const Color chip = Color(0xFFF5F5F5); // Fondo de chips
  static const Color icon = Color(0xFF757575); // Iconos neutros

  // Colores de gradiente para FincaSmart
  static const Gradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient buttonGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient appBarGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
        background: AppColors.background,
      ),

      // Configuración de AppBar - más limpia
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background, // Fondo blanco
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5, // Sombra muy sutil
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Iconos oscuros
      ),

      // Configuración de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Configuración de botones con bordes
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Configuración de botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Configuración de tarjetas - diseño limpio y moderno
      cardTheme: const CardThemeData(
        color: AppColors.cardSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.all(8),
      ),

      // Configuración de chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chip,
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Configuración de campos de texto - más limpios
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background, // Fondo blanco
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      ),

      // Configuración de dividers
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),

      // Configuración de typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: AppColors.textDisabled,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Configuración del scaffold
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  // Método helper para obtener el tema oscuro (para futuro)
  static ThemeData get darkTheme {
    // Por ahora retornamos el light theme, pero esto se puede expandir
    return lightTheme;
  }
}

// Extensiones útiles para trabajar con el tema
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
