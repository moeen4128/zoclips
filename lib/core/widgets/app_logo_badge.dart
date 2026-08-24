import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../constants/asset_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_neutral_colors.dart';

/// Rounded logo badge shown at the top of every auth screen (sign in, sign
/// up, forgot password) — uses the real zoclips mark, picking the
/// white-on-dark or black-on-light variant so it stays legible in both themes.
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      width: AppSizes.logoSize,
      height: AppSizes.logoSize,
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        AssetConstants.logoFor(Theme.of(context).brightness),
        fit: BoxFit.contain,
      ),
    );
  }
}
