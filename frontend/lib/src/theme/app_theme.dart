import 'package:flutter/material.dart';

/// Centralized theme configuration for the restaurant app.
/// All colors, text styles, and theme data are defined here.
class AppTheme {
  // ─── Brand Colors ───
  static const Color primary = Color(0xFF9B1B1B);       // Dark red (logo & titles)
  static const Color primaryLight = Color(0xFFD4605A);   // Lighter red (accents)
  static const Color primaryFaded = Color(0xFFE8A9A5);   // Faded pink (dots)

  static const Color background = Color(0xFFFFF5F0);     // Warm cream background
  static const Color surface = Color(0xFFFFFFFF);         // White cards/circles
  static const Color textDark = Color(0xFF2D2D2D);        // Primary text
  static const Color textMuted = Color(0xFF9E8E87);       // Subtitle / muted text

  // ─── Status Colors ───
  static const Color success = Color(0xFF2E7D32);         // Green
  static const Color error = Color(0xFFD32F2F);           // Red

  // ─── Text Styles ───
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: primary,
    letterSpacing: 0.5,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textMuted,
    letterSpacing: 0.3,
  );

  // ─── Theme Data ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        surface: surface,
      ),
      fontFamily: 'Poppins',
    );
  }
}
