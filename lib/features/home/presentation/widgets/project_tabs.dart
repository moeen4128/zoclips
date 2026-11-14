import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/videos_cubit.dart';
import '../cubit/videos_state.dart';

class ProjectTabs extends StatelessWidget {
  const ProjectTabs({super.key});

  static const _tabs = ['All projects', 'Saved projects'];

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final state = context.watch<VideosCubit>().state;
    final showSavedOnly = state.showSavedOnly;

    // Scrollable rather than Expanded/wrapped: on narrow screens the 2 tab
    // pills + 2 view-mode icons don't all fit at their natural size, and a
    // plain Row doesn't shrink its children — it overflows instead. This
    // stays correct regardless of screen width or label/locale length.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(_tabs.length, (i) {
            final isSelected = (i == 1) == showSavedOnly;
            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: GestureDetector(
                onTap: () =>
                    context.read<VideosCubit>().setShowSavedOnly(i == 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? neutrals.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    border: Border.all(
                      color: isSelected
                          ? neutrals.textPrimary
                          : neutrals.cardBorder,
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: AppTextStyles.label(neutrals).copyWith(
                      color: isSelected
                          ? neutrals.cardBackground
                          : neutrals.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
          _ViewModeToggle(
            icon: Icons.view_agenda_rounded,
            mode: ProjectsViewMode.card,
            selected: state.viewMode,
          ),
          const SizedBox(width: AppSizes.xs),
          _ViewModeToggle(
            icon: Icons.grid_view_rounded,
            mode: ProjectsViewMode.grid,
            selected: state.viewMode,
          ),
        ],
      ),
    );
  }
}

/// One button of the card/grid view-mode pair — selected styling matches
/// the tab pills' highlight treatment.
class _ViewModeToggle extends StatelessWidget {
  final IconData icon;
  final ProjectsViewMode mode;
  final ProjectsViewMode selected;

  const _ViewModeToggle({
    required this.icon,
    required this.mode,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final isSelected = mode == selected;
    return GestureDetector(
      onTap: () => context.read<VideosCubit>().setViewMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGreen.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : neutrals.cardBorder,
          ),
        ),
        child: Icon(
          icon,
          size: AppSizes.iconSm,
          color: isSelected ? AppColors.accentGreen : neutrals.textSecondary,
        ),
      ),
    );
  }
}
