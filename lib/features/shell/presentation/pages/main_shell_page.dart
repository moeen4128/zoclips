import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_navigation_rail.dart';
import '../../../profile/presentation/widgets/profile_bottom_sheet.dart';

class MainShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  static const int _profileTabIndex = 3;

  void _handleTap(BuildContext context, int index) {
    if (index == _profileTabIndex) {
      showProfileBottomSheet(context);
      return; // don't switch branches — stay on the current tab underneath
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Phones and folded/cover-screen foldables: bottom tab bar.
    if (context.isCompact) {
      return Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _handleTap(context, index),
        ),
      );
    }

    // Tablets, unfolded foldables, iPad and desktop-class widths: side rail.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AppNavigationRail(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => _handleTap(context, index),
            extended: context.isExpanded,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
