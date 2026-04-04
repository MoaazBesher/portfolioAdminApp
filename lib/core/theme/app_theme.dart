import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryStatus = Color(0xFF3B82F6);
  static const Color successStatus = Color(0xFF10B981);
  static const Color warningStatus = Color(0xFFF59E0B);
  static const Color dangerStatus = Color(0xFFEF4444);
  static const Color educationStatus = Color(0xFF8B5CF6);
  static const Color bgDark = Color(0xFF1E293B); // Slate-800 instead of 0D1117
  static const Color panelBg = Color(0xFF334155); // Slate-700 instead of 0x08FFFFFF
  static const Color panelBorder = Color(0xFF475569); // Slate-600
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFFCBD5E1);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryStatus,
      colorScheme: const ColorScheme.dark(
        primary: primaryStatus,
        secondary: educationStatus,
        background: bgDark,
        surface: panelBg,
        error: dangerStatus,
        onBackground: textMain,
        onSurface: textMain,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textMain),
        titleTextStyle: GoogleFonts.outfit(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryStatus,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: panelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: panelBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryStatus, width: 2),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
    );
  }
}
