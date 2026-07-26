import 'package:flutter/material.dart';

class AppColors {
  // Light Palette - Apple + Material You Hybrid
  static const Color lightPrimary = Color(0xFF0061A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFD1E4FF);
  static const Color lightOnPrimaryContainer = Color(0xFF001D36);

  static const Color lightSecondary = Color(0xFF535F70);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFD7E3F7);
  static const Color lightOnSecondaryContainer = Color(0xFF101C2B);

  static const Color lightTertiary = Color(0xFF6B5778);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFF3DAFF);
  static const Color lightOnTertiaryContainer = Color(0xFF251431);

  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFDFE2EB);
  static const Color lightOnSurface = Color(0xFF1A1C1E);
  static const Color lightOnSurfaceVariant = Color(0xFF43474E);

  // Dark Palette
  static const Color darkPrimary = Color(0xFF9ECAFF);
  static const Color darkOnPrimary = Color(0xFF003258);
  static const Color darkPrimaryContainer = Color(0xFF00497D);
  static const Color darkOnPrimaryContainer = Color(0xFFD1E4FF);

  static const Color darkSecondary = Color(0xFFBBC7DB);
  static const Color darkOnSecondary = Color(0xFF253140);
  static const Color darkSecondaryContainer = Color(0xFF3B4758);
  static const Color darkOnSecondaryContainer = Color(0xFFD7E3F7);

  static const Color darkTertiary = Color(0xFFD7BEE4);
  static const Color darkOnTertiary = Color(0xFF3B2947);
  static const Color darkTertiaryContainer = Color(0xFF533F5F);
  static const Color darkOnTertiaryContainer = Color(0xFFF3DAFF);

  static const Color darkBackground = Color(0xFF111318);
  static const Color darkSurface = Color(0xFF191C20);
  static const Color darkSurfaceVariant = Color(0xFF43474E);
  static const Color darkOnSurface = Color(0xFFE2E2E6);
  static const Color darkOnSurfaceVariant = Color(0xFFC3C7D0);

  // Accent & Functional Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFBA1A1A);
  static const Color info = Color(0xFF0288D1);

  // Gradients
  static const LinearGradient appleGradientLight = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient appleGradientDark = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
