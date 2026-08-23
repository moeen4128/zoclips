import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SnackType { success, error, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final config = _configFor(type);

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.lg,
        ),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: config.borderColor),
          ),
          child: Row(
            children: [
              Icon(config.icon, color: config.iconColor, size: AppSizes.iconMd),
              const SizedBox(width: AppSizes.sm),
              Expanded(child: Text(message, style: AppTextStyles.inputText)),
            ],
          ),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.error);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.info);

  static _SnackConfig _configFor(SnackType type) {
    switch (type) {
      case SnackType.success:
        return _SnackConfig(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          borderColor: AppColors.success.withValues(alpha: 0.4),
        );
      case SnackType.error:
        return _SnackConfig(
          icon: Icons.error_outline,
          iconColor: AppColors.error,
          borderColor: AppColors.error.withValues(alpha: 0.4),
        );
      case SnackType.info:
        return _SnackConfig(
          icon: Icons.info_outline,
          iconColor: AppColors.accentGreen,
          borderColor: AppColors.cardBorder,
        );
    }
  }
}

class _SnackConfig {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;

  const _SnackConfig({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
  });
}
