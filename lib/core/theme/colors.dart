import 'package:flutter/material.dart';

/// Tanizkart Premium Motion Design System Colors
/// Strict palette: Primary Blue #0055AA, Primary Deep #003F7F, Accent Gold #FFAA00, Accent Deep #FF7F00
class TanizColors {
  // Brand Core Colors
  static const Color primaryBlue = Color(0xFF0055AA);
  static const Color primaryDeep = Color(0xFF003F7F);
  static const Color primaryBlueDark = Color(0xFF003F7F);
  static const Color primaryBlueLight = Color(0xFF2E7BDB);
  static const Color blueContainer = Color(0xFFEBF3FF);

  static const Color accentGold = Color(0xFFFFAA00);
  static const Color accentDeep = Color(0xFFFF7F00);
  static const Color goldenAmber = Color(0xFFFFAA00);
  static const Color goldenAmberDark = Color(0xFFFF7F00);
  static const Color goldenAmberLight = Color(0xFFFFBE3B);
  static const Color amberContainer = Color(0xFFFFF7ED);
  static const Color amberBadgeBg = Color(0xFFFFF4D6);
  static const Color primaryGold = Color(0xFFFFAA00);

  // Speed & SLA
  static const Color rapidGreen = Color(0xFF0C831F);
  static const Color rapidGreenDark = Color(0xFF0A6818);
  static const Color greenContainer = Color(0xFFE8F5E9);
  static const Color greenBorder = Color(0xFFA5D6A7);

  // Midnight Quick-Commerce Docks & Cards
  static const Color midnightNavy = Color(0xFF003F7F);
  static const Color deepNavy = Color(0xFF00224A);
  static const Color navyDark = Color(0xFF0F2552);
  static const Color navyCard = Color(0xFF003F7F);
  static const Color redContainer = Color(0xFFFEE2E2);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral Canvas & Surfaces
  static const Color canvasBackground = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;
  static const Color surfaceLow = Color(0xFFF1F5F9);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderCard = Color(0xFFE5E9F0);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF131B2E);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  // Feedback Colors
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color successGreen = Color(0xFF0C831F);

  // Blue-tinted soft shadows at 8-16% opacity (No harsh black drop shadows)
  static BoxShadow get softShadow => BoxShadow(
        color: const Color(0xFF0055AA).withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  static BoxShadow get cardShadow => BoxShadow(
        color: const Color(0xFF003F7F).withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 2),
      );

  static BoxShadow get floatingShadow => BoxShadow(
        color: const Color(0xFF0055AA).withValues(alpha: 0.16),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );

  // 135° Blue -> Gold Gradient ONLY for hero banners and primary CTAs
  static const LinearGradient blueGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0055AA),
      Color(0xFF003F7F),
      Color(0xFFFF7F00),
      Color(0xFFFFAA00),
    ],
    stops: [0.0, 0.4, 0.8, 1.0],
  );

  static const LinearGradient heroNavyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0055AA), Color(0xFF003F7F)],
  );

  static const LinearGradient goldVIPGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFAA00), Color(0xFFFF7F00)],
  );
}
