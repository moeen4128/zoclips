import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_neutral_colors.dart';
import 'app_bottom_nav_bar.dart';

/// Side navigation for tablet/foldable/iPad-width screens — same
/// destinations as [AppBottomNavBar], swapped in by [MainShellPage] once
/// the window is wide enough that a bottom bar stops being idiomatic.
class AppNavigationRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  const AppNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        border: Border(right: BorderSide(color: neutrals.cardBorder)),
      ),
      child: SafeArea(
        child: NavigationRail(
          backgroundColor: Colors.transparent,
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          extended: extended,
          minWidth: AppSizes.navRailWidth,
          minExtendedWidth: AppSizes.navRailExtendedWidth,
          labelType: extended ? null : NavigationRailLabelType.all,
          useIndicator: true,
          indicatorColor: AppColors.accentGreen.withValues(alpha: 0.12),
          selectedIconTheme: const IconThemeData(color: AppColors.accentGreen),
          selectedLabelTextStyle: const TextStyle(
            color: AppColors.accentGreen,
            fontWeight: FontWeight.w600,
          ),
          unselectedIconTheme: IconThemeData(color: neutrals.textSecondary),
          unselectedLabelTextStyle: TextStyle(color: neutrals.textSecondary),
          leading: const SizedBox(height: AppSizes.lg),
          destinations: kBottomNavTabs
              .map(
                (tab) => NavigationRailDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.activeIcon),
                  label: Text(tab.label),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
