import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _mint = Color(0xFF9ADBCB);
  static const Color _ink = Color(0xFF102A43);
  static const Color _gold = Color(0xFFF7C873);
  static const Color _coral = Color(0xFFFF8E72);
  static const Color _surface = Color(0xFFF6F8F7);
  static const Color _darkSurface = Color(0xFF0F1720);

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.dmSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _surface,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _mint,
        brightness: Brightness.light,
        primary: _ink,
        secondary: _mint,
        tertiary: _gold,
        error: _coral,
        surface: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: _ink,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _ink, width: 1.4),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.dmSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkSurface,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _mint,
        brightness: Brightness.dark,
        primary: _mint,
        secondary: _gold,
        tertiary: _coral,
        surface: const Color(0xFF18212B),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF18212B),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF18212B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _mint, width: 1.4),
        ),
      ),
    );
  }
}
