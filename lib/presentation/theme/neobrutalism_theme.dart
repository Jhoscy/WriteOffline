import 'package:flutter/material.dart';

/// Neobrutalism + Japanese Style Theme
/// Features:
/// - Bold, thick borders (4-6px)
/// - Bright, saturated colors with Japanese palette
/// - High contrast
/// - Sharp edges (minimal rounded corners)
/// - Offset drop shadows
/// - Bold typography
class NeobrutalismTheme {
  // Japanese-inspired color palette
  static const Color primaryRed = Color(0xFFDC143C); // Crimson red (Japanese red)
  static const Color primaryBlack = Color(0xFF1A1A1A); // Deep black
  static const Color primaryWhite = Color(0xFFFFFEF7); // Warm white
  static const Color accentIndigo = Color(0xFF4B0082); // Indigo (Japanese indigo)
  static const Color accentGold = Color(0xFFFFD700); // Gold
  static const Color accentCoral = Color(0xFFFF6B6B); // Coral
  static const Color accentTeal = Color(0xFF20B2AA); // Teal
  
  // Status colors
  static const Color statusActive = Color(0xFF00C853); // Green
  static const Color statusCompleted = Color(0xFF2196F3); // Blue
  static const Color statusOnHold = Color(0xFFFF9800); // Orange
  static const Color statusCancelled = Color(0xFFE53935); // Red
  static const Color statusPlanning = Color(0xFF6A1B9A); // Purple
  
  // Background colors
  static const Color bgLight = Color(0xFFFFFEF7);
  static const Color bgDark = Color(0xFF2C2C2C);
  static const Color bgCard = Color(0xFFFFFFFF);
  
  // Border settings
  static const double borderWidth = 4.0;
  static const double borderWidthThick = 6.0;
  static const double borderRadius = 0.0; // Sharp edges (neobrutalism)
  static const double borderRadiusSmall = 2.0; // Minimal rounding
  
  // Shadow settings (offset, not blurred)
  static const BoxShadow defaultShadow = BoxShadow(
    color: primaryBlack,
    offset: Offset(8, 8),
    blurRadius: 0,
    spreadRadius: 0,
  );
  
  static const BoxShadow pressedShadow = BoxShadow(
    color: primaryBlack,
    offset: Offset(3, 3),
    blurRadius: 0,
    spreadRadius: 0,
  );
  
  static const BoxShadow cardShadow = BoxShadow(
    color: primaryBlack,
    offset: Offset(6, 6),
    blurRadius: 0,
    spreadRadius: 0,
  );
  
  static const BoxShadow buttonShadow = BoxShadow(
    color: primaryBlack,
    offset: Offset(6, 6),
    blurRadius: 0,
    spreadRadius: 0,
  );
  
  static const BoxShadow labelShadow = BoxShadow(
    color: primaryBlack,
    offset: Offset(4, 4),
    blurRadius: 0,
    spreadRadius: 0,
  );
  
  static const BoxShadow smallShadow = BoxShadow(
    color: primaryBlack,
    offset: Offset(3, 3),
    blurRadius: 0,
    spreadRadius: 0,
  );
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: false, // We'll customize everything
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: accentIndigo,
        surface: bgCard,
        background: bgLight,
        error: statusCancelled,
        onPrimary: primaryWhite,
        onSecondary: primaryWhite,
        onSurface: primaryBlack,
        onBackground: primaryBlack,
        onError: primaryWhite,
      ),
      
      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: primaryBlack,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: primaryBlack,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: primaryBlack,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: primaryBlack,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primaryBlack,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: primaryBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: primaryBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: primaryBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: primaryBlack,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: primaryBlack,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: primaryBlack,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
        ),
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: primaryRed,
        foregroundColor: primaryWhite,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: primaryWhite,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: primaryWhite,
          size: 24,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: bgCard,
        shape: Border.all(
          color: primaryBlack,
          width: borderWidth,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryWhite,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: primaryBlack,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: primaryBlack,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: primaryRed,
            width: borderWidthThick,
          ),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: statusCancelled,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: statusCancelled,
            width: borderWidthThick,
          ),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        labelStyle: const TextStyle(
          color: primaryBlack,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryRed,
          foregroundColor: primaryWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
            side: const BorderSide(
              color: primaryBlack,
              width: borderWidth,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlack,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
            side: const BorderSide(
              color: primaryBlack,
              width: borderWidth,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: accentGold,
        foregroundColor: primaryBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadiusSmall)),
          side: BorderSide(
            color: primaryBlack,
            width: borderWidth,
          ),
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: primaryWhite,
        deleteIconColor: primaryBlack,
        disabledColor: Colors.grey.shade300,
        selectedColor: accentIndigo,
        secondarySelectedColor: accentIndigo,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: primaryBlack,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: primaryWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          side: const BorderSide(
            color: primaryBlack,
            width: 2,
          ),
        ),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: primaryWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          side: const BorderSide(
            color: primaryBlack,
            width: borderWidth,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: primaryBlack,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: primaryBlack,
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryBlack,
        contentTextStyle: const TextStyle(
          color: primaryWhite,
          fontWeight: FontWeight.w600,
        ),
        shape: Border.all(
          color: primaryBlack,
          width: borderWidth,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: bgLight,
    );
  }
  
  /// Helper method to get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in progress':
        return statusActive;
      case 'completed':
        return statusCompleted;
      case 'on hold':
        return statusOnHold;
      case 'cancelled':
        return statusCancelled;
      case 'planning':
        return statusPlanning;
      default:
        return primaryBlack;
    }
  }
  
  /// Helper method to create a neobrutalism box decoration
  static BoxDecoration neobrutalismBox({
    Color? color,
    Color borderColor = primaryBlack,
    double borderWidth = borderWidth,
    BoxShadow? shadow,
    bool pressed = false,
  }) {
    return BoxDecoration(
      color: color ?? primaryWhite,
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: [
        shadow ?? (pressed ? pressedShadow : defaultShadow),
      ],
    );
  }
  
  /// Helper method to create a neobrutalism button style
  static ButtonStyle neobrutalismButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    bool pressed = false,
  }) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: backgroundColor ?? primaryRed,
      foregroundColor: foregroundColor ?? primaryWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusSmall),
        side: const BorderSide(
          color: primaryBlack,
          width: borderWidth,
        ),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ).copyWith(
      shadowColor: MaterialStateProperty.all(Colors.transparent),
    );
  }
}

