import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_neutral_colors.dart';
import '../constants/app_sizes.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily =
      'Georgia'; // headings look serif in screenshots

  static TextStyle heading(AppNeutralColors colors) => TextStyle(
    fontFamily: fontFamily,
    fontSize: AppSizes.fontXl,
    fontWeight: FontWeight.bold,
    color: colors.textPrimary,
  );

  static TextStyle subtitle(AppNeutralColors colors) => TextStyle(
    fontSize: AppSizes.fontSm,
    color: colors.textSecondary,
    height: 1.4,
  );

  static TextStyle label(AppNeutralColors colors) => TextStyle(
    fontSize: AppSizes.fontSm,
    fontWeight: FontWeight.w500,
    color: colors.textSecondary,
  );

  static TextStyle inputText(AppNeutralColors colors) =>
      TextStyle(fontSize: AppSizes.fontSm, color: colors.textPrimary);

  static TextStyle hintText(AppNeutralColors colors) =>
      TextStyle(fontSize: AppSizes.fontSm, color: colors.textHint);

  static TextStyle bodyMuted(AppNeutralColors colors) => TextStyle(
    fontSize: AppSizes.fontXs,
    color: colors.textSecondary,
    height: 1.4,
  );

  // Brand-colored — identical in both themes, no AppNeutralColors needed.
  static const TextStyle button = TextStyle(
    fontSize: AppSizes.fontMd,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const TextStyle linkGreen = TextStyle(
    fontSize: AppSizes.fontSm,
    fontWeight: FontWeight.w600,
    color: AppColors.accentGreen,
  );
}
