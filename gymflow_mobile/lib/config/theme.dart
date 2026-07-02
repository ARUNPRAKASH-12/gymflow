import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GymFlowColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFF8A5C);
  static const Color secondary = Color(0xFF2563EB);
  static const Color secondaryDark = Color(0xFF1D4ED8);
  static const Color secondaryLight = Color(0xFF60A5FA);

  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF16213E);
  static const Color surfaceLighter = Color(0xFF1E2A4A);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0x1A22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0x1AF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0x1AEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color border = Color(0xFF2D3A5C);
  static const Color borderLight = Color(0xFF3D4A6C);
  static const Color divider = Color(0xFF1E2A3A);

  static const Color cardOverlay = Color(0x1AFFFFFF);
  static const Color shimmerBase = Color(0xFF1E2A4A);
  static const Color shimmerHighlight = Color(0xFF2D3A5C);

  static const Color qrOverlay = Color(0xCC000000);
  static const Color scaffoldBg = Color(0xFF0A0A14);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderLight = Color(0xFFCBD5E1);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightScaffoldBg = Color(0xFFF0F2F5);
}

class GymFlowTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: GymFlowColors.primary,
        secondary: GymFlowColors.secondary,
        surface: GymFlowColors.lightSurface,
        error: GymFlowColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: GymFlowColors.lightTextPrimary,
      ),
      scaffoldBackgroundColor: GymFlowColors.lightScaffoldBg,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 28, fontWeight: FontWeight.bold,
          color: GymFlowColors.lightTextPrimary,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 24, fontWeight: FontWeight.bold,
          color: GymFlowColors.lightTextPrimary,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: GymFlowColors.lightTextPrimary,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: GymFlowColors.lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: GymFlowColors.lightTextPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: GymFlowColors.lightTextSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, color: GymFlowColors.lightTextMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: GymFlowColors.lightTextPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GymFlowColors.lightSurface,
        foregroundColor: GymFlowColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: GymFlowColors.lightTextPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: GymFlowColors.lightSurface,
        selectedItemColor: GymFlowColors.primary,
        unselectedItemColor: GymFlowColors.lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: GymFlowColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: GymFlowColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GymFlowColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GymFlowColors.primary,
          side: const BorderSide(color: GymFlowColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GymFlowColors.lightSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymFlowColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymFlowColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymFlowColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymFlowColors.error),
        ),
        labelStyle: const TextStyle(color: GymFlowColors.lightTextMuted),
        hintStyle: const TextStyle(color: GymFlowColors.lightTextMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: GymFlowColors.lightDivider, thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GymFlowColors.lightSurfaceLight,
        selectedColor: GymFlowColors.primary,
        labelStyle: const TextStyle(color: GymFlowColors.lightTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: GymFlowColors.lightBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GymFlowColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GymFlowColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: GymFlowColors.primary,
        secondary: GymFlowColors.secondary,
        surface: GymFlowColors.surface,
        error: GymFlowColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: GymFlowColors.textPrimary,
      ),
      scaffoldBackgroundColor: GymFlowColors.scaffoldBg,
      backgroundColor: GymFlowColors.background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: GymFlowColors.textPrimary,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: GymFlowColors.textPrimary,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GymFlowColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: GymFlowColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: GymFlowColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: GymFlowColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: GymFlowColors.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: GymFlowColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GymFlowColors.background,
        foregroundColor: GymFlowColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: GymFlowColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: GymFlowColors.surface,
        selectedItemColor: GymFlowColors.primary,
        unselectedItemColor: GymFlowColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: GymFlowColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: GymFlowColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GymFlowColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GymFlowColors.primary,
          side: const BorderSide(color: GymFlowColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GymFlowColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymFlowColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymFlowColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymFlowColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymFlowColors.error),
        ),
        labelStyle: const TextStyle(color: GymFlowColors.textMuted),
        hintStyle: const TextStyle(color: GymFlowColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: GymFlowColors.divider,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GymFlowColors.surfaceLight,
        selectedColor: GymFlowColors.primary,
        labelStyle: const TextStyle(color: GymFlowColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: GymFlowColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GymFlowColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GymFlowColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
