import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background — near-black with green radial glow (per screenshots)
  static const Color background = Color(0xFF000000);
  static const Color glowGreen = Color(0xFF17C964);

  // Card / surfaces
  static const Color cardBackground = Color(0xFF0A0A0A);
  static const Color cardBorder = Color(0xFF262626);

  // Brand green (buttons, links, accents)
  static const Color primaryGreenStart = Color(0xFF22C55E);
  static const Color primaryGreenEnd = Color(0xFF16A34A);
  static const Color accentGreen = Color(0xFF4ADE80);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textHint = Color(0xFF6B6B6B);

  // Input
  static const Color inputBackground = Color(0xFF0D0D0D);
  static const Color inputBorder = Color(0xFF2A2A2A);
  static const Color inputBorderFocused = Color(0xFF22C55E);

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color errorBackground = Color(0xFF1A0E0E);
  static const Color success = Color(0xFF22C55E);
  static const Color divider = Color(0xFF262626);

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryGreenStart, accentGreen],
  );
}
