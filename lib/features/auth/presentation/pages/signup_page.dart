import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_logo_badge.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/google_button.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      SignUpSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

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
        if (state.status == AuthStatus.signUpSuccess) {
          context.pushNamed(
            RouteNames.verifyEmail,
            extra: _emailController.text.trim(),
          );
        }
      },
      child: AuthBackground(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.xl),
          decoration: BoxDecoration(
            color: neutrals.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: neutrals.cardBorder),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogoBadge(),
                const SizedBox(height: AppSizes.lg),
                Text(
                  AppStrings.createAccount,
                  style: AppTextStyles.heading(neutrals),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.signUpSubtitle,
                  style: AppTextStyles.subtitle(neutrals),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xl),
                GoogleButton(
                  onPressed: () =>
                      AppSnackbar.info(context, 'Google sign-in coming soon'),
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    Expanded(child: Divider(color: neutrals.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                      ),
                      child: Text(
                        AppStrings.or,
                        style: AppTextStyles.bodyMuted(neutrals),
                      ),
                    ),
                    Expanded(child: Divider(color: neutrals.divider)),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                AppTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  hint: AppStrings.passwordHint,
                  isPassword: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSizes.xl),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return GradientButton(
                      label: AppStrings.createAccountBtn,
                      isLoading: state.status == AuthStatus.loading,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: AppSizes.md),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyMuted(neutrals),
                    children: [
                      const TextSpan(text: AppStrings.termsPrefix),
                      TextSpan(
                        text: AppStrings.termsOfService,
                        style: AppTextStyles.bodyMuted(
                          neutrals,
                        ).copyWith(color: AppColors.accentGreen),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: AppStrings.and),
                      TextSpan(
                        text: AppStrings.privacyPolicy,
                        style: AppTextStyles.bodyMuted(
                          neutrals,
                        ).copyWith(color: AppColors.accentGreen),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: AppStrings.dot),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      AppStrings.haveAccount,
                      style: AppTextStyles.subtitle(neutrals),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        AppStrings.signIn,
                        style: AppTextStyles.linkGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
