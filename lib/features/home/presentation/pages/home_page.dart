import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Home', style: AppTextStyles.heading),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Your clips dashboard goes here.',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}
