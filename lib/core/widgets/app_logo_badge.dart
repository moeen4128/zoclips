import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';

class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.logoSize,
      height: AppSizes.logoSize,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: AppSizes.fontLg,
          ),
          children: [
            TextSpan(
              text: 'A',
              style: TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: 'I',
              style: TextStyle(color: AppColors.accentGreen),
            ),
          ],
        ),
      ),
    );
  }
}
