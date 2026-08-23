import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive_page.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assets', style: AppTextStyles.heading),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Uploaded videos/clips will list here.',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}
