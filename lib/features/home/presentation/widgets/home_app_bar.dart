import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection_container.dart';

/// Top bar for the home tab — logo + wordmark on the left, theme toggle and
/// notifications on the right.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return AppBar(
      backgroundColor: neutrals.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: context.statusBarIconStyle,
      titleSpacing: AppSizes.lg,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetConstants.logoFor(Theme.of(context).brightness),
            height: AppSizes.iconLg,
            width: AppSizes.iconLg,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            AppStrings.appName,
            style: AppTextStyles.heading(
              neutrals,
            ).copyWith(fontSize: AppSizes.fontLg),
          ),
        ],
      ),
      actions: [
        const _ThemeToggleButton(),
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: neutrals.textPrimary,
          ),
          onPressed: () {}, // design only — notifications wired up later
        ),
        const SizedBox(width: AppSizes.sm),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: neutrals.textPrimary,
      ),
      onPressed: () => sl<ThemeController>().setThemeMode(
        isDark ? ThemeMode.light : ThemeMode.dark,
      ),
    );
  }
}
