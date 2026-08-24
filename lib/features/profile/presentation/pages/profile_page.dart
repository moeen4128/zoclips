import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: AppTextStyles.heading(neutrals)),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Account settings, logout, etc.',
            style: AppTextStyles.subtitle(neutrals),
          ),
        ],
      ),
    );
  }
}
