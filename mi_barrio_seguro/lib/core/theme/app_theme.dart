import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color alertRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF2ECC71);
  static const Color warningOrange = Color(0xFFF39C12);
  
  // Colores para Modo Oscuro
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: successGreen,
        surface: surfaceDark,
        error: alertRed,
        onPrimary: Colors.white,
        onSurface: Colors.white70,
      ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: const TextStyle(fontSize: 18, color: Colors.white70),
        bodyMedium: const TextStyle(fontSize: 16, color: Colors.white60),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
