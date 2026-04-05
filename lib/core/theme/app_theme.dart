import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    final colorScheme = const ColorScheme.light().copyWith(
      surface: Colors.white,
      onSurface: const Color(0xFF1B1C17), 
      primary: const Color(0xFF22C55E), 
      onPrimary: Colors.white,
      secondary: const Color(0xFFECFDF5), 
      onSecondary: const Color(0xFF065F46), 
      tertiary: const Color(0xFFF59E0B), 
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      outline: const Color(0xFFE2E8F0),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFBFDFA), 
      colorScheme: colorScheme,
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shadowColor: colorScheme.onSurface.withValues(alpha: 0.1),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.primary);
          }
          return TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 26);
          }
          return IconThemeData(color: colorScheme.onSurface.withValues(alpha: 0.6), size: 24);
        }),
      ),
      extensions: [
        const CustomColors(
          success: Color(0xFF22C55E),
          warning: Color(0xFFF59E0B),
          info: Color(0xFF3B82F6),
          neutral: Color(0xFF64748B),
          purple: Color(0xFF8B5CF6),
          indigo: Color(0xFF6366F1),
          teal: Color(0xFF14B8A6),
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    final colorScheme = const ColorScheme.dark().copyWith(
      surface: const Color(0xFF1E293B), 
      onSurface: const Color(0xFFF1F5F9), 
      primary: const Color(0xFF22C55E),
      onPrimary: Colors.white,
      secondary: const Color(0xFF334155), 
      onSecondary: const Color(0xFFF8FAFC),
      tertiary: const Color(0xFFFBBF24), 
      error: const Color(0xFFF87171),
      onError: Colors.white,
      outline: const Color(0xFF334155),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A), 
      colorScheme: colorScheme,
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shadowColor: colorScheme.onSurface.withValues(alpha: 0.1),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
           if (states.contains(WidgetState.selected)) {
             return TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.primary);
           }
           return TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 26);
          }
          return IconThemeData(color: colorScheme.onSurface.withValues(alpha: 0.6), size: 24);
        }),
      ),
      extensions: [
        const CustomColors(
          success: Color(0xFF22C55E),
          warning: Color(0xFFFBBF24),
          info: Color(0xFF60A5FA),
          neutral: Color(0xFF94A3B8),
          purple: Color(0xFFA78BFA),
          indigo: Color(0xFF818CF8),
          teal: Color(0xFF2DD4BF),
        ),
      ],
    );
  }
}

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? success;
  final Color? warning;
  final Color? info;
  final Color? neutral;
  final Color? purple;
  final Color? indigo;
  final Color? teal;

  const CustomColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.neutral,
    required this.purple,
    required this.indigo,
    required this.teal,
  });

  @override
  CustomColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? neutral,
    Color? purple,
    Color? indigo,
    Color? teal,
  }) {
    return CustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      neutral: neutral ?? this.neutral,
      purple: purple ?? this.purple,
      indigo: indigo ?? this.indigo,
      teal: teal ?? this.teal,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
      info: Color.lerp(info, other.info, t),
      neutral: Color.lerp(neutral, other.neutral, t),
      purple: Color.lerp(purple, other.purple, t),
      indigo: Color.lerp(indigo, other.indigo, t),
      teal: Color.lerp(teal, other.teal, t),
    );
  }
}

