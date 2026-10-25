import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class TanizTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: TanizColors.canvasBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TanizColors.primaryBlue,
        primary: TanizColors.primaryBlue,
        secondary: TanizColors.accentGold,
        tertiary: TanizColors.rapidGreen,
        surface: TanizColors.cardSurface,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: TanizColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: TanizColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: TanizColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TanizColors.textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: TanizColors.textPrimary,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: TanizColors.textPrimary,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TanizColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: TanizColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TanizColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: TanizColors.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TanizColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: TanizColors.textPrimary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: TanizColors.textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: TanizColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: TanizColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TanizColors.borderSubtle),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TanizColors.goldenAmber,
          foregroundColor: TanizColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
