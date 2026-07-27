import 'package:flutter/material.dart';

class AppColors {
  // ─── Dark-first premium palette ───────────────────────────────────────────
  // Background layers
  static const Color darkBg          = Color(0xFF080C14);  // near-black blue
  static const Color darkSurface0    = Color(0xFF0D1117);  // deep surface
  static const Color darkSurface1    = Color(0xFF131924);  // card bg
  static const Color darkSurface2    = Color(0xFF1A2232);  // elevated card
  static const Color darkSurfaceVariant = Color(0xFF242D3E);

  // Primary accent – cool electric blue
  static const Color darkPrimary          = Color(0xFF4FC3F7);  // sky blue
  static const Color darkOnPrimary        = Color(0xFF003A52);
  static const Color darkPrimaryContainer = Color(0xFF003A52);
  static const Color darkOnPrimaryContainer = Color(0xFFB3E5FC);

  // Secondary – teal-cyan
  static const Color darkSecondary          = Color(0xFF26C6DA);
  static const Color darkOnSecondary        = Color(0xFF003238);
  static const Color darkSecondaryContainer = Color(0xFF004D59);
  static const Color darkOnSecondaryContainer = Color(0xFFB2EBF2);

  // Tertiary – indigo-purple
  static const Color darkTertiary          = Color(0xFF9575CD);
  static const Color darkOnTertiary        = Color(0xFF1A0033);
  static const Color darkTertiaryContainer = Color(0xFF311B52);
  static const Color darkOnTertiaryContainer = Color(0xFFEDE7F6);

  // Text / on-surface
  static const Color darkOnSurface        = Color(0xFFE8F0FE);
  static const Color darkOnSurfaceVariant = Color(0xFF8A9BBE);

  // Legacy aliases so existing code doesn't break
  static const Color darkBackground = darkBg;
  static const Color darkBackground2 = darkSurface1;

  // ─── Light palette ────────────────────────────────────────────────────────
  static const Color lightPrimary          = Color(0xFF0077CC);
  static const Color lightOnPrimary        = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFCCE8FF);
  static const Color lightOnPrimaryContainer = Color(0xFF001D36);

  static const Color lightSecondary          = Color(0xFF0097A7);
  static const Color lightOnSecondary        = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFB2EBF2);
  static const Color lightOnSecondaryContainer = Color(0xFF00232B);

  static const Color lightTertiary          = Color(0xFF7E57C2);
  static const Color lightOnTertiary        = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFEDE7F6);
  static const Color lightOnTertiaryContainer = Color(0xFF21005E);

  static const Color lightBackground    = Color(0xFFF0F4FF);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFDDE3F0);
  static const Color lightOnSurface     = Color(0xFF101820);
  static const Color lightOnSurfaceVariant = Color(0xFF42505F);

  // ─── Shared functional colors ─────────────────────────────────────────────
  static const Color success = Color(0xFF00C897);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error   = Color(0xFFEF5350);
  static const Color info    = Color(0xFF4FC3F7);

  // ─── Gradient presets ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0066CC), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF006064)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00838F), Color(0xFF4FC3F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF4527A0), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00695C), Color(0xFF00C897)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism surface
  static const Color glassDark  = Color(0x261A2232);  // 15% opacity
  static const Color glassLight = Color(0x40FFFFFF);  // 25% opacity

  // Legacy aliases
  static const LinearGradient appleGradientLight = primaryGradient;
  static const LinearGradient appleGradientDark  = heroGradientDark;
}
