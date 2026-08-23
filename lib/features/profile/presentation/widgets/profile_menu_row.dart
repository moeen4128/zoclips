import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileMenuRow extends StatelessWidget {
  final IconData leadingIcon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const ProfileMenuRow({
    super.key,
    required this.leadingIcon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.md,
                horizontal: AppSizes.lg,
              ),
              child: Row(
                children: [
                  Icon(
                    leadingIcon,
                    size: AppSizes.iconMd,
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: Text(label, style: AppTextStyles.inputText)),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            color: AppColors.divider,
            indent: AppSizes.lg,
            endIndent: AppSizes.lg,
          ),
      ],
    );
  }
}
