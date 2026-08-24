import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../injection_container.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'profile_menu_row.dart';

/// Call this instead of pushing a route for the Profile tab.
Future<void> showProfileBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (_) => sl<ProfileCubit>()..fetchProfile(),
      child: const _ProfileSheetContent(),
    ),
  );
}

class _ProfileSheetContent extends StatelessWidget {
  const _ProfileSheetContent();

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.pageHorizontalPadding;
    final neutrals = context.neutrals;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLg),
          topRight: Radius.circular(AppSizes.radiusLg),
        ),
        border: Border(
          top: BorderSide(color: neutrals.cardBorder),
          left: BorderSide(color: neutrals.cardBorder),
          right: BorderSide(color: neutrals.cardBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.maxFormWidth),
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSizes.lg,
                        horizontalPadding,
                        0,
                      ),
                      child: _ProfileHeader(state: state),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border: Border(
                          top: BorderSide(color: neutrals.cardBorder),
                        ),
                      ),
                      child: Column(
                        children: [
                          ProfileMenuRow(
                            leadingIcon: Icons.movie_filter_outlined,
                            label: 'B Roll template',
                            showDivider: false,
                            onTap: () {
                              Navigator.of(context).pop();
                              // TODO: navigate to B Roll template screen
                            },
                          ),
                          ProfileMenuRow(
                            leadingIcon: Icons.bar_chart_rounded,
                            label: 'Analytics',
                            showDivider: false,
                            onTap: () {
                              Navigator.of(context).pop();
                              // TODO: navigate to Analytics screen
                            },
                          ),
                          ProfileMenuRow(
                            leadingIcon: Icons.settings_outlined,
                            label: 'Settings',
                            showDivider: false,
                            onTap: () {
                              final router = GoRouter.of(context);
                              Navigator.of(context).pop();
                              router.pushNamed(RouteNames.settings);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileState state;
  const _ProfileHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    if (state.status == ProfileStatus.loading ||
        state.status == ProfileStatus.initial) {
      return const Row(
        children: [
          _AvatarSkeleton(),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (state.status == ProfileStatus.error) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              state.errorMessage ?? 'Could not load profile',
              style: AppTextStyles.subtitle(neutrals),
            ),
          ),
        ],
      );
    }

    final user = state.user!;
    final displayName = (user.name?.trim().isNotEmpty ?? false)
        ? user.name!
        : user.email.split('@').first;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.accentGreen.withValues(alpha: 0.15),
          backgroundImage:
              (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
              ? Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.fontLg,
                  ),
                )
              : null,
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: AppTextStyles.inputText(neutrals).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.fontMd,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: AppTextStyles.subtitle(neutrals),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarSkeleton extends StatelessWidget {
  const _AvatarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: context.neutrals.inputBackground,
        shape: BoxShape.circle,
      ),
    );
  }
}
