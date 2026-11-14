import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_neutral_colors.dart';
import 'app_text_styles.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme =>
      _build(AppNeutralColors.dark, Brightness.dark);

  static ThemeData get lightTheme =>
      _build(AppNeutralColors.light, Brightness.light);

  static ThemeData _build(AppNeutralColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: AppColors.primaryGreenStart,
              secondary: AppColors.accentGreen,
              surface: Color(0xFF0A0A0A),
              error: AppColors.error,
            )
          : ColorScheme.light(
              primary: AppColors.primaryGreenStart,
              secondary: AppColors.accentGreen,
              surface: colors.cardBackground,
              error: AppColors.error,
            ),
      extensions: [colors],
      // M3 tints an AppBar with colorScheme.primary (our green) once content
      // scrolls under it — kill that globally so every AppBar stays the page
      // background color.
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputBackground,
        hintStyle: AppTextStyles.hintText(colors),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.inputBorderFocused,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreenStart,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: AppTextStyles.heading(colors),
        bodyMedium: AppTextStyles.subtitle(colors),
        labelLarge: AppTextStyles.label(colors),
      ),
    );
  }
}
