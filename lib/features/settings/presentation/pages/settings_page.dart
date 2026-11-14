import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../injection_container.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/widgets/profile_menu_row.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..fetchProfile(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.pageHorizontalPadding;
    final neutrals = context.neutrals;

    return Scaffold(
      backgroundColor: neutrals.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: context.statusBarIconStyle,
        iconTheme: IconThemeData(color: neutrals.textPrimary),
        title: Text(
          'Settings',
          style: AppTextStyles.heading(
            neutrals,
          ).copyWith(fontSize: AppSizes.fontLg),
        ),
      ),
      // The rest of the page (appearance, account menus, logout) doesn't
      // depend on the profile fetch, so it always renders — only the banner
      // below reacts to that request's loading/error/loaded state. A failed
      // or slow profile fetch (e.g. an expired token) shouldn't block the
      // user from using the rest of Settings, including logging out.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSizes.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxPageWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ProfileBanner(),
                  const SizedBox(height: AppSizes.xl),

                  // Appearance — light/dark/system theme switch
                  const _SectionTitle(title: 'Appearance'),
                  const SizedBox(height: AppSizes.sm),
                  const _ThemeModeSwitcher(),
                  const SizedBox(height: AppSizes.xl),

                  // Account Setting
                  const _SectionTitle(title: 'Account Setting'),
                  const SizedBox(height: AppSizes.sm),
                  Column(
                    children: [
                      ProfileMenuRow(
                        leadingIcon: Icons.shield_outlined,
                        label: 'Security',
                        showDivider: true,
                        onTap: () {
                          // TODO: navigate to Security screen
                        },
                      ),
                      ProfileMenuRow(
                        leadingIcon: Icons.notifications_none_rounded,
                        label: 'Notification',
                        showDivider: true,
                        onTap: () {
                          // TODO: navigate to Notification screen
                        },
                      ),
                      ProfileMenuRow(
                        leadingIcon: Icons.account_circle_outlined,
                        label: 'Account',
                        showDivider: false,
                        onTap: () {
                          // TODO: navigate to Account screen
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Connected Accounts
                  const _SectionTitle(title: 'Connected Accounts'),
                  const SizedBox(height: AppSizes.sm),
                  Column(
                    children: [
                      ProfileMenuRow(
                        leadingIcon: Icons.share_outlined,
                        label: 'Social account',
                        showDivider: false,
                        onTap: () {
                          // TODO: navigate to Social account screen
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Subscription plan and billing
                  const _SectionTitle(title: 'Subscription plan & billing'),
                  const SizedBox(height: AppSizes.sm),
                  Column(
                    children: [
                      ProfileMenuRow(
                        leadingIcon: Icons.workspace_premium_outlined,
                        label: 'Subscriptions',
                        showDivider: true,
                        onTap: () {
                          // TODO: navigate to Subscriptions screen
                        },
                      ),
                      ProfileMenuRow(
                        leadingIcon: Icons.receipt_long_outlined,
                        label: 'Billing',
                        showDivider: false,
                        onTap: () {
                          // TODO: navigate to Billing screen
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Help and Support
                  const _SectionTitle(title: 'Help and Support'),
                  const SizedBox(height: AppSizes.sm),
                  Column(
                    children: [
                      ProfileMenuRow(
                        leadingIcon: Icons.school_outlined,
                        label: 'Learning center',
                        showDivider: true,
                        onTap: () {
                          // TODO: navigate to Learning center screen
                        },
                      ),
                      ProfileMenuRow(
                        leadingIcon: Icons.help_outline_rounded,
                        label: 'Help center',
                        showDivider: false,
                        onTap: () {
                          // TODO: navigate to Help center screen
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Logout
                  _LogoutButton(
                    onTap: _isLoggingOut ? null : () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    // Ask first — the spinner on the logout button should only appear once
    // the user has actually confirmed, not while the dialog itself is open.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isLoggingOut = true);

    await sl<AuthLocalDataSource>().clearSession();
    if (!context.mounted) return;

    // Settings is pushed on top of the bottom-nav shell; goNamed replaces
    // the whole match list (both pages) in one atomic transition.
    context.goNamed(RouteNames.signIn);
  }
}

/// Profile header banner — avatar, name, email, Edit action. Reacts to
/// [ProfileCubit] on its own: shimmer while loading, an inline
/// retry affordance if the fetch fails (e.g. an expired token), without
/// touching anything else on the page.
class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryButtonGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          switch (state.status) {
            case ProfileStatus.loading:
            case ProfileStatus.initial:
              return const _ProfileBannerSkeleton();
            case ProfileStatus.error:
              return _ProfileBannerError(message: state.errorMessage);
            case ProfileStatus.loaded:
              return _ProfileBannerContent(user: state.user!);
          }
        },
      ),
    );
  }
}

class _ProfileBannerSkeleton extends StatelessWidget {
  const _ProfileBannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Row(
        children: [
          const ShimmerBox.circle(size: 64),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                ShimmerBox(width: 140, height: 16),
                SizedBox(height: AppSizes.sm),
                ShimmerBox(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBannerError extends StatelessWidget {
  final String? message;
  const _ProfileBannerError({this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline, color: Colors.black54),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Could not load profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.fontMd,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message ?? 'Check your connection and try again.',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.7),
                  fontSize: AppSizes.fontSm,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          tooltip: 'Retry',
          onPressed: () => context.read<ProfileCubit>().fetchProfile(),
        ),
      ],
    );
  }
}

class _ProfileBannerContent extends StatelessWidget {
  final UserEntity user;
  const _ProfileBannerContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final displayName = (user.name?.trim().isNotEmpty ?? false)
        ? user.name!
        : user.email.split('@').first;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with pen-icon badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.black.withValues(alpha: 0.15),
              backgroundImage:
                  (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontLg,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // TODO: hook up avatar/profile edit action
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSizes.md),
        // Name + email (static)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: AppTextStyles.inputText(neutrals).copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.fontLg,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: AppTextStyles.subtitle(
                  neutrals,
                ).copyWith(color: Colors.black.withValues(alpha: 0.7)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        // Edit action, top-right, like the reference screenshot
        InkWell(
          onTap: () {
            // TODO: navigate to edit profile screen
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Text(
                'Edit',
                style: AppTextStyles.subtitle(
                  neutrals,
                ).copyWith(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small caps-style section header used above each grouped menu list,
/// matching the "Account Setting" / "Earning Money" style in the reference design.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.subtitle(
        context.neutrals,
      ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );
  }
}

class _ThemeModeSwitcher extends StatelessWidget {
  const _ThemeModeSwitcher();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: sl<ThemeController>(),
      builder: (context, mode, _) {
        return SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {mode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              sl<ThemeController>().setThemeMode(selection.first),
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLoading = onTap == null;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
          ),
          child: isLoading
              ? const SizedBox(
                  height: AppSizes.iconMd,
                  width: AppSizes.iconMd,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.error,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      size: AppSizes.iconMd,
                      color: AppColors.error,
                    ),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      'Log out',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
