import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_sizes.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily =
      'Georgia'; // headings look serif in screenshots

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: AppSizes.fontXl,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: AppSizes.fontSm,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: AppSizes.fontSm,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: AppSizes.fontSm,
    color: AppColors.textPrimary,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: AppSizes.fontSm,
    color: AppColors.textHint,
  );

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

  static const TextStyle bodyMuted = TextStyle(
    fontSize: AppSizes.fontXs,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}
