import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFBFDFA), // Very light mint-tinted gray
      colorScheme: const ColorScheme.light().copyWith(
        surface: Colors.white,
        onSurface: const Color(0xFF1B1C17), // Deep charcoal
        primary: const Color(0xFF22C55E), // Vibrant Green (Lucid Green)
        onPrimary: Colors.white,
        secondary: const Color(0xFFECFDF5), // Soft Mint
        onSecondary: const Color(0xFF065F46), // Emerald Forest
        error: const Color(0xFFEF4444),
        onError: Colors.white,
        outline: const Color(0xFFE2E8F0),
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme), // Outfit is more modern/tech
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      colorScheme: const ColorScheme.dark().copyWith(
        surface: const Color(0xFF1E293B), // Slate 800
        onSurface: const Color(0xFFF1F5F9), // Slate 100
        primary: const Color(0xFF22C55E),
        onPrimary: Colors.white,
        secondary: const Color(0xFF334155), // Slate 700
        onSecondary: const Color(0xFFF8FAFC),
        error: const Color(0xFFF87171),
        onError: Colors.white,
        outline: const Color(0xFF334155),
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
    );
  }
}

