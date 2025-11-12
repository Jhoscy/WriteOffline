import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism utility class for creating glass-like effects
class GlassmorphismUtils {
  /// Creates a glassmorphism container with blur effect
  static Widget glassContainer({
    required Widget child,
    double blurStrength = 10.0,
    double opacity = 0.15,
    Color? tintColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double borderOpacity = 0.2,
    double borderWidth = 1.0,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (tintColor ?? Colors.white).withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(borderOpacity),
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Creates a glassmorphism card with enhanced styling
  static Widget glassCard({
    required Widget child,
    double blurStrength = 12.0,
    double opacity = 0.1,
    Color? tintColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double elevation = 0,
    BoxShadow? customShadow,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: customShadow != null
            ? [customShadow]
            : [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: elevation,
                  spreadRadius: 0,
                  offset: Offset(0, elevation / 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (tintColor ?? Colors.white).withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Creates a glassmorphism app bar background
  static Widget glassAppBar({
    required Widget child,
    double blurStrength = 20.0,
    double opacity = 0.1,
    bool extendBodyBehindAppBar = true,
  }) {
    return extendBodyBehindAppBar
        ? Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Container(
                color: Colors.white.withOpacity(opacity),
                child: child,
              ),
            ],
          )
        : Container(
            color: Colors.white.withOpacity(opacity),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
              child: child,
            ),
          );
  }

  /// Creates a gradient background for glassmorphism effects
  static Widget gradientBackground({
    required Widget child,
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ??
              [
                const Color(0xFF0F172A), // Slate-900
                const Color(0xFF1E293B), // Slate-800
                const Color(0xFF334155), // Slate-700
              ],
        ),
      ),
      child: child,
    );
  }

  /// Creates a glassmorphism button
  static Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    double blurStrength = 8.0,
    double opacity = 0.2,
    Color? tintColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    double borderOpacity = 0.3,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(borderOpacity),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
            child: Container(
              color: (tintColor ?? Colors.white).withOpacity(opacity),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a glassmorphism floating action button
  static Widget glassFab({
    required Widget child,
    required VoidCallback onPressed,
    double blurStrength = 15.0,
    double opacity = 0.15,
    Color? tintColor,
    double size = 56.0,
    double borderOpacity = 0.25,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(borderOpacity),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
            child: Container(
              color: (tintColor ?? Colors.white).withOpacity(opacity),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension methods for easier glassmorphism usage
extension GlassmorphismExtensions on Widget {
  /// Wraps widget in a glassmorphism container
  Widget withGlassmorphism({
    double blurStrength = 10.0,
    double opacity = 0.15,
    Color? tintColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double borderOpacity = 0.2,
    double borderWidth = 1.0,
  }) {
    return GlassmorphismUtils.glassContainer(
      child: this,
      blurStrength: blurStrength,
      opacity: opacity,
      tintColor: tintColor,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      borderOpacity: borderOpacity,
      borderWidth: borderWidth,
    );
  }

  /// Wraps widget in a glassmorphism card
  Widget withGlassCard({
    double blurStrength = 12.0,
    double opacity = 0.1,
    Color? tintColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double elevation = 0,
  }) {
    return GlassmorphismUtils.glassCard(
      child: this,
      blurStrength: blurStrength,
      opacity: opacity,
      tintColor: tintColor,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      elevation: elevation,
    );
  }
}
