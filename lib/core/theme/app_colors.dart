import 'package:flutter/material.dart';

/// Brand colors — identical in light and dark theme. Surface/text colors
/// that flip per theme live in [AppNeutralColors] instead.
class AppColors {
  AppColors._();

  static const Color glowGreen = Color(0xFF17C964);

  // Brand green (buttons, links, accents)
  static const Color primaryGreenStart = Color(0xFF22C55E);
  static const Color primaryGreenEnd = Color(0xFF16A34A);
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color inputBorderFocused = Color(0xFF22C55E);

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryGreenStart, accentGreen],
  );
}
