import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Tanizkart Premium Typography System
/// Headings: Plus Jakarta Sans (weight 600-700)
/// Body: Inter (weight 400-500)
/// Scale: Display 28-32 / H1 22-24 / H2 18-20 / Body 14-16 / Caption 12
class TanizTypography {
  // Headings (Plus Jakarta Sans, weight 600-700)
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: TanizColors.textPrimary,
      );

  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: TanizColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: TanizColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: TanizColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: TanizColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: TanizColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: TanizColors.textPrimary,
      );

  // Body text (Inter, weight 400-500)
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: TanizColors.textSecondary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: TanizColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: TanizColors.textMuted,
      );

  // Labels & Captions (Inter, weight 500)
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: TanizColors.textMuted,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: TanizColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: TanizColors.textPrimary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: TanizColors.textPrimary,
      );

  // Tabular rupee price style with clear spacing
  static TextStyle get priceLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: TanizColors.textPrimary,
      );

  static TextStyle get priceMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: TanizColors.textPrimary,
      );

  static TextStyle get priceSmall => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: TanizColors.textPrimary,
      );
}
