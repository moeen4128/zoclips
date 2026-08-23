import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';

class NavTabData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavTabData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<NavTabData> kBottomNavTabs = [
  NavTabData(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
  NavTabData(
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
    label: 'Assets',
  ),
  NavTabData(
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
    label: 'Calendar',
  ),
  NavTabData(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
  ),
];

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          0,
          AppSizes.lg,
          AppSizes.md,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: AppColors.accentGreen.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.glowGreen.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(kBottomNavTabs.length, (index) {
            final tab = kBottomNavTabs[index];
            final selected = index == currentIndex;
            return _NavTabItem(
              tab: tab,
              selected: selected,
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final NavTabData tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accentGreen.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? tab.activeIcon : tab.icon,
                  size: AppSizes.iconMd,
                  color: selected
                      ? AppColors.accentGreen
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.accentGreen
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
