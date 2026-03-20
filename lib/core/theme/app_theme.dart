import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      scaffoldBackgroundColor: HSLColor.fromAHSL(1.0, 40, 0.33, 0.98).toColor(),
      colorScheme: const ColorScheme.light().copyWith(
        surface: HSLColor.fromAHSL(1.0, 0, 0, 1.0).toColor(),
        onSurface: HSLColor.fromAHSL(1.0, 20, 0.14, 0.04).toColor(),
        primary: HSLColor.fromAHSL(1.0, 142, 0.71, 0.29).toColor(),
        onPrimary: HSLColor.fromAHSL(1.0, 0, 0, 1.0).toColor(),
        secondary: HSLColor.fromAHSL(1.0, 36, 0.33, 0.97).toColor(),
        onSecondary: HSLColor.fromAHSL(1.0, 142, 0.71, 0.29).toColor(),
        error: HSLColor.fromAHSL(1.0, 0, 0.84, 0.60).toColor(),
        onError: HSLColor.fromAHSL(1.0, 0, 0, 1.0).toColor(),
        outline: HSLColor.fromAHSL(1.0, 36, 0.15, 0.88).toColor(),
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return baseTheme.copyWith(
      scaffoldBackgroundColor: HSLColor.fromAHSL(1.0, 20, 0.14, 0.04).toColor(),
      colorScheme: const ColorScheme.dark().copyWith(
        surface: HSLColor.fromAHSL(1.0, 24, 0.10, 0.08).toColor(),
        onSurface: HSLColor.fromAHSL(1.0, 40, 0.33, 0.98).toColor(),
        primary: HSLColor.fromAHSL(1.0, 142, 0.60, 0.45).toColor(),
        onPrimary: HSLColor.fromAHSL(1.0, 0, 0, 1.0).toColor(),
        secondary: HSLColor.fromAHSL(1.0, 24, 0.10, 0.12).toColor(),
        onSecondary: HSLColor.fromAHSL(1.0, 40, 0.33, 0.98).toColor(),
        error: HSLColor.fromAHSL(1.0, 0, 0.628, 0.306).toColor(),
        onError: HSLColor.fromAHSL(1.0, 40, 0.33, 0.98).toColor(),
        outline: HSLColor.fromAHSL(1.0, 24, 0.10, 0.12).toColor(),
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
    );
  }
}
