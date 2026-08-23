import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Reached via deep link after the user taps the verification link in their
/// inbox. `success` is resolved upstream (VerifyEmailSubmitted already ran).
class EmailVerificationResultPage extends StatefulWidget {
  final bool success;
  const EmailVerificationResultPage({super.key, required this.success});

  @override
  State<EmailVerificationResultPage> createState() =>
      _EmailVerificationResultPageState();
}

class _EmailVerificationResultPageState
    extends State<EmailVerificationResultPage> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    if (widget.success) {
      // Matches the "Taking you to your dashboard..." copy in the design —
      // short pause so the checkmark actually registers before we navigate away.
      _redirectTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) context.goNamed(RouteNames.home);
      });
    }
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final success = widget.success;
    return AuthBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (success ? AppColors.success : AppColors.error).withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? AppColors.success : AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            success
                ? AppStrings.emailVerifiedTitle
                : AppStrings.verificationFailedTitle,
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            success
                ? AppStrings.emailVerifiedSubtitle
                : AppStrings.invalidOrExpiredToken,
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          if (success) ...[
            const SizedBox(height: AppSizes.xl),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.accentGreen,
              ),
            ),
          ],
          if (!success) ...[
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: 200,
              child: GradientButton(
                label: AppStrings.backToSignIn,
                onPressed: () => context.goNamed(RouteNames.signIn),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
