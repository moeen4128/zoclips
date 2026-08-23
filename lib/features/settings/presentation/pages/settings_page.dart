import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../injection_container.dart';
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
  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.pageHorizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Settings',
          style: AppTextStyles.heading.copyWith(fontSize: AppSizes.fontLg),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading ||
                state.status == ProfileStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accentGreen),
              );
            }

            if (state.status == ProfileStatus.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Text(
                    state.errorMessage ?? 'Could not load settings',
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final user = state.user!;
            final displayName = (user.name?.trim().isNotEmpty ?? false)
                ? user.name!
                : user.email.split('@').first;
            final initial = displayName.isNotEmpty
                ? displayName[0].toUpperCase()
                : '?';

            return SingleChildScrollView(
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
                      // Profile header banner — avatar with pen badge, name, email, Edit action
                      // (matches reference design; existing color scheme reused, not changed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.lg),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryButtonGradient,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar with pen-icon badge
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.black.withValues(
                                    alpha: 0.15,
                                  ),
                                  backgroundImage:
                                      (user.avatarUrl != null &&
                                          user.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child:
                                      (user.avatarUrl == null ||
                                          user.avatarUrl!.isEmpty)
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
                                    style: AppTextStyles.inputText.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppSizes.fontLg,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: AppTextStyles.subtitle.copyWith(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
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
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: AppTextStyles.subtitle.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
      style: AppTextStyles.subtitle.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
