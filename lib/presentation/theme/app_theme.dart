import 'package:flutter/material.dart';

/// App theme configuration
/// All colors and styling are centralized here
class AppTheme {
  AppTheme._();

  /// Light theme color scheme
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: Color(0xFF1A1A1A),
    secondary: Color(0xFF4A90E2),
    surface: Color(0xFFFAFAFA),
    background: Color(0xFFF5F5F5),
    error: Color(0xFFE74C3C),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF1A1A1A),
    onBackground: Color(0xFF1A1A1A),
    onError: Colors.white,
    brightness: Brightness.light,
  );

  /// Dark theme color scheme
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: Color(0xFFE0E0E0),
    secondary: Color(0xFF64B5F6),
    surface: Color(0xFF1E1E1E),
    background: Color(0xFF121212),
    error: Color(0xFFEF5350),
    onPrimary: Color(0xFF121212),
    onSecondary: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    onBackground: Color(0xFFE0E0E0),
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  /// Get the light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightColorScheme.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: lightColorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: lightColorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getGreyColor(200),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _getGreyColor(300)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _getGreyColor(300)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          color: _getGreyColor(600),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightColorScheme.secondary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: lightColorScheme.onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: lightColorScheme.onSurface,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
          color: lightColorScheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: lightColorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: lightColorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: lightColorScheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.2,
          color: lightColorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightColorScheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: _getGreyColor(600),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: _getGreyColor(600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _getGreyColor(100),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        elevation: 2,
        shape: const CircleBorder(),
      ),
    );
  }

  /// Get the dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkColorScheme.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: darkColorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: darkColorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getDarkGreyColor(700),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _getDarkGreyColor(700)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _getDarkGreyColor(700)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          color: _getDarkGreyColor(400),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColorScheme.secondary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: darkColorScheme.onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: darkColorScheme.onSurface,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
          color: darkColorScheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: darkColorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: darkColorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: darkColorScheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.2,
          color: darkColorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkColorScheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: _getDarkGreyColor(400),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: _getDarkGreyColor(400),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _getDarkGreyColor(800),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
        elevation: 2,
        shape: const CircleBorder(),
      ),
    );
  }

  /// Helper method to get grey color shades for light theme
  static Color _getGreyColor(int shade) {
    return Colors.grey[shade] ?? Colors.grey;
  }

  /// Helper method to get grey color shades for dark theme
  static Color _getDarkGreyColor(int shade) {
    return Colors.grey[shade] ?? Colors.grey;
  }
}

/// Extension methods for easy access to theme colors
extension ThemeColors on BuildContext {
  /// Get the color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get primary color
  Color get primaryColor => colorScheme.primary;

  /// Get secondary color
  Color get secondaryColor => colorScheme.secondary;

  /// Get surface color
  Color get surfaceColor => colorScheme.surface;

  /// Get background color
  Color get backgroundColor => colorScheme.background;

  /// Get error color
  Color get errorColor => colorScheme.error;

  /// Get on surface color (text color)
  Color get onSurfaceColor => colorScheme.onSurface;

  /// Get grey color with shade (adapts to theme brightness)
  Color greyColor(int shade) {
    final brightness = Theme.of(this).brightness;
    if (brightness == Brightness.dark) {
      // For dark mode, invert the shade (darker shades become lighter)
      final invertedShade = 900 - shade;
      return Colors.grey[invertedShade.clamp(50, 900)] ?? Colors.grey;
    }
    return Colors.grey[shade] ?? Colors.grey;
  }
}

/// Status color helper
class StatusColors {
  StatusColors._();

  /// Get status background color
  static Color getBackgroundColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in progress':
        return isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50;
      case 'completed':
        return isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50;
      case 'on hold':
        return isDark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50;
      case 'cancelled':
        return isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50;
      default:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    }
  }

  /// Get status text color
  static Color getTextColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in progress':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'completed':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'on hold':
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      case 'cancelled':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }
}

