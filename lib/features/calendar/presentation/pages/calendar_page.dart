import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive_page.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calendar', style: AppTextStyles.heading),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Scheduled posts will show here.',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}
