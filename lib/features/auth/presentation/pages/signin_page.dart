import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
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

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
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
      SignInSubmitted(
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
        if (state.status == AuthStatus.signInSuccess) {
          context.goNamed(RouteNames.home);
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppLogoBadge(),
                const SizedBox(height: AppSizes.lg),
                Text(
                  AppStrings.welcomeBack,
                  style: AppTextStyles.heading(neutrals),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.signInSubtitle,
                  style: AppTextStyles.subtitle(neutrals),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xl),
                GoogleButton(
                  onPressed: () =>
                      AppSnackbar.info(context, 'Google sign-in coming soon'),
                ),
                const SizedBox(height: AppSizes.lg),
                _OrDivider(),
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
                  hint: '••••••••',
                  isPassword: true,
                  validator: Validators.password,
                  trailingLink: TextButton(
                    onPressed: () =>
                        context.pushNamed(RouteNames.forgotPassword),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.linkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return GradientButton(
                      label: AppStrings.signIn,
                      isLoading: state.status == AuthStatus.loading,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccount,
                      style: AppTextStyles.subtitle(neutrals),
                    ),
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.signUp),
                      child: Text(
                        AppStrings.createOne,
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Row(
      children: [
        Expanded(child: Divider(color: neutrals.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(AppStrings.or, style: AppTextStyles.bodyMuted(neutrals)),
        ),
        Expanded(child: Divider(color: neutrals.divider)),
      ],
    );
  }
}
