import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Design-only filter — no project list to filter yet.
class ProjectTabs extends StatefulWidget {
  const ProjectTabs({super.key});

  @override
  State<ProjectTabs> createState() => _ProjectTabsState();
}

class _ProjectTabsState extends State<ProjectTabs> {
  static const _tabs = ['All projects', 'Saved projects'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Row(
      children: List.generate(_tabs.length, (i) {
        final isSelected = i == _selected;
        return Padding(
          padding: EdgeInsets.only(right: i == _tabs.length - 1 ? 0 : AppSizes.sm),
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? neutrals.textPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                border: Border.all(
                  color: isSelected ? neutrals.textPrimary : neutrals.cardBorder,
                ),
              ),
              child: Text(
                _tabs[i],
                style: AppTextStyles.label(neutrals).copyWith(
                  color: isSelected ? neutrals.cardBackground : neutrals.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
