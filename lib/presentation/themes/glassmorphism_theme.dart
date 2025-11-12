import 'package:flutter/material.dart';

/// Builds the glassmorphism theme for the WriteOffline app
ThemeData buildGlassmorphismTheme() {
  // Glassmorphism color palette
  const Color primaryColor = Color(0xFF6366F1); // Indigo
  const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  const Color accentColor = Color(0xFF06B6D4); // Cyan
  const Color surfaceColor = Color(0xFF1E293B); // Slate-800
  const Color surfaceVariant = Color(0xFF334155); // Slate-700

  return ThemeData(
    useMaterial3: true,

    // Color scheme with glassmorphism palette
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      surfaceContainerHighest: surfaceVariant,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFCBD5E1), // Slate-300
    ),

    // AppBar with glassmorphism
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor.withOpacity(0.8),
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
    ),

    // Cards with glassmorphism effect
    cardTheme: CardThemeData(
      color: surfaceColor.withOpacity(0.6),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),

    // Input decoration with glassmorphism
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.8),
      ),
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.6),
      ),
    ),

    // Elevated buttons with glassmorphism
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor.withOpacity(0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    // Floating action button with glassmorphism
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor.withOpacity(0.8),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant.withOpacity(0.6),
      labelStyle: const TextStyle(color: Colors.white),
      side: BorderSide(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor.withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),

    // Text theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: Color(0xFFCBD5E1), // Slate-300
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: Color(0xFFCBD5E1), // Slate-300
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
