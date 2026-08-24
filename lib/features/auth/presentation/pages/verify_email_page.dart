import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailPage extends StatelessWidget {
  final String email;
  const VerifyEmailPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: _VerifyEmailView(email: email),
    );
  }
}

class _VerifyEmailView extends StatelessWidget {
  final String email;
  const _VerifyEmailView({required this.email});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          AppSnackbar.error(
            context,
            state.errorMessage ?? AppStrings.somethingWentWrong,
          );
        }
        if (state.status == AuthStatus.resendVerificationSent) {
          AppSnackbar.success(context, 'Verification email resent.');
        }
      },
      child: AuthBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.accentGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              AppStrings.verifyEmailTitle,
              style: AppTextStyles.heading(neutrals),
            ),
            const SizedBox(height: AppSizes.sm),
            Text.rich(
              TextSpan(
                style: AppTextStyles.subtitle(neutrals),
                children: [
                  const TextSpan(text: AppStrings.verifyEmailSubtitlePrefix),
                  TextSpan(
                    text: email,
                    style: TextStyle(
                      color: neutrals.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: AppStrings.verifyEmailSubtitleSuffix),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state.status == AuthStatus.loading;
                return OutlinedButton(
                  onPressed: loading
                      ? null
                      : () => context.read<AuthBloc>().add(
                          ResendVerificationSubmitted(email: email),
                        ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: neutrals.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xl,
                      vertical: AppSizes.md,
                    ),
                  ),
                  child: loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: neutrals.textSecondary,
                          ),
                        )
                      : Text(
                          AppStrings.resendEmail,
                          style: TextStyle(color: neutrals.textPrimary),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
