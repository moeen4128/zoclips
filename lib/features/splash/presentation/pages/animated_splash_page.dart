import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../../features/onboarding/data/onboarding_storage.dart';
import '../../../../injection_container.dart';

/// Flutter-side splash shown right after the native splash hands off: the
/// logo mark appears centered, slides left to make room, then the "zoclips"
/// wordmark reveals in brand green at the same height as the mark. Once the
/// animation settles, it routes to onboarding (first run) or sign-in.
class AnimatedSplashPage extends StatefulWidget {
  const AnimatedSplashPage({super.key});

  @override
  State<AnimatedSplashPage> createState() => _AnimatedSplashPageState();
}

class _AnimatedSplashPageState extends State<AnimatedSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoIn;
  late final Animation<double> _textReveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );
    _textReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    );
    _run();
  }

  Future<void> _run() async {
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    // Trust the cached token directly — no network round-trip here. A splash
    // that gates navigation on a live "get current user" call bounces a
    // genuinely logged-in user back to sign-in the moment the network is
    // slow, offline, or the backend hiccups, even though nothing about their
    // session actually changed. If a token is expired/invalid, the screens
    // that hit the API (Home, Settings, etc.) already surface that via their
    // own error states instead.
    final token = await sl<AuthLocalDataSource>().getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      context.goNamed(RouteNames.home);
      return;
    }

    final hasSeenOnboarding = sl<OnboardingStorage>().hasSeenOnboarding;
    context.goNamed(
      hasSeenOnboarding ? RouteNames.signIn : RouteNames.onboarding,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: neutrals.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final logoT = _logoIn.value.clamp(0.0, 1.0);
            final textT = _textReveal.value.clamp(0.0, 1.0);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: logoT,
                  child: Transform.scale(
                    scale: 0.7 + 0.3 * logoT,
                    child: Image.asset(
                      AssetConstants.logoFor(brightness),
                      width: AppSizes.splashLogoSize,
                      height: AppSizes.splashLogoSize,
                    ),
                  ),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: textT,
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSizes.md),
                      child: Opacity(
                        opacity: textT,
                        child: Text(
                          'zoclips',
                          style: TextStyle(
                            fontSize: AppSizes.splashWordmarkSize,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentGreen,
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
