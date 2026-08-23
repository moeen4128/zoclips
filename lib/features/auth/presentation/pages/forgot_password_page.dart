import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_logo_badge.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      ForgotPasswordSubmitted(email: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          AppSnackbar.error(
            context,
            state.errorMessage ?? AppStrings.somethingWentWrong,
          );
        }
        if (state.status == AuthStatus.forgotPasswordSent) {
          AppSnackbar.success(context, 'Reset link sent — check your inbox.');
        }
      },
      child: AuthBackground(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.xl),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogoBadge(),
                const SizedBox(height: AppSizes.lg),
                Text(
                  AppStrings.forgotPasswordTitle,
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.forgotPasswordSubtitle,
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSizes.xl),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return GradientButton(
                      label: AppStrings.sendResetLink,
                      isLoading: state.status == AuthStatus.loading,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        size: AppSizes.iconSm,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        AppStrings.backToSignIn,
                        style: AppTextStyles.subtitle,
                      ),
                    ],
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
