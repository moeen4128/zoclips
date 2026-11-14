import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../injection_container.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_menu_row.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..fetchProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: AppTextStyles.heading(
              neutrals,
            ).copyWith(fontSize: AppSizes.fontXl),
          ),
          const SizedBox(height: 4),
          Text(
            'Your account, workspace tools, and settings.',
            style: AppTextStyles.subtitle(neutrals),
          ),
          const SizedBox(height: AppSizes.xl),
          const _ProfileHeaderCard(),
          const SizedBox(height: AppSizes.xl),
          const _SectionLabel(label: 'Workspace'),
          const SizedBox(height: AppSizes.sm),
          _MenuCard(
            children: [
              ProfileMenuRow(
                leadingIcon: Icons.movie_filter_outlined,
                label: 'B-Roll template',
                showDivider: true,
                onTap: () => context.pushNamed(RouteNames.brollTemplate),
              ),
              ProfileMenuRow(
                leadingIcon: Icons.bar_chart_rounded,
                label: 'Analytics',
                showDivider: false,
                onTap: () => AppSnackbar.info(context, 'Analytics coming soon'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          const _SectionLabel(label: 'Account'),
          const SizedBox(height: AppSizes.sm),
          _MenuCard(
            children: [
              ProfileMenuRow(
                leadingIcon: Icons.settings_outlined,
                label: 'Settings',
                showDivider: false,
                onTap: () => context.pushNamed(RouteNames.settings),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          _LogoutButton(
            onTap: _isLoggingOut ? null : () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
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

    context.goNamed(RouteNames.signIn);
  }
}

/// Gradient header — avatar, name + verified badge, email. Reacts to
/// [ProfileCubit] on its own: shimmer while loading, an inline retry
/// affordance on failure.
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryButtonGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowGreen.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          switch (state.status) {
            case ProfileStatus.loading:
            case ProfileStatus.initial:
              return const _HeaderSkeleton();
            case ProfileStatus.error:
              return _HeaderError(message: state.errorMessage);
            case ProfileStatus.loaded:
              return _HeaderContent(user: state.user!);
          }
        },
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

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

class _HeaderError extends StatelessWidget {
  final String? message;
  const _HeaderError({this.message});

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

class _HeaderContent extends StatelessWidget {
  final UserEntity user;
  const _HeaderContent({required this.user});

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
                onTap: () =>
                    AppSnackbar.info(context, 'Editing profile coming soon'),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      displayName,
                      style: AppTextStyles.inputText(neutrals).copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.fontLg,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Colors.black87,
                    ),
                  ],
                ],
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
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.bodyMuted(
        context.neutrals,
      ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
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
