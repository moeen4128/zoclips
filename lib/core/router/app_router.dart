import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/animated_splash_page.dart';
import 'route_names.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/pages/email_verification_result_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/clips/presentation/pages/clips_page.dart';
import '../../features/clips/presentation/pages/clip_detail_page.dart';
import '../../features/clips/presentation/pages/clip_detail_args.dart';
import '../../features/create_clips/presentation/pages/create_clips_args.dart';
import '../../features/create_clips/presentation/pages/create_clips_page.dart';
import '../../features/broll/presentation/pages/broll_template_page.dart';
import '../../features/home/data/models/video_model.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const AnimatedSplashPage(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RoutePaths.signIn,
        name: RouteNames.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: RoutePaths.signUp,
        name: RouteNames.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        name: RouteNames.verifyEmail,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailPage(email: email);
        },
      ),
      GoRoute(
        path: '${RoutePaths.emailVerifiedResult}/:status',
        name: RouteNames.emailVerifiedResult,
        builder: (context, state) {
          final status = state.pathParameters['status'] ?? 'failed';
          return EmailVerificationResultPage(success: status == 'success');
        },
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      // Bottom-nav shell — a single route; which of the 4 tabs is showing is
      // local state inside MainShellPage, not go_router's StatefulShellRoute
      // (see the comment on MainShellPage for why: that API has a still-open
      // upstream bug where leaving this route and coming back collides the
      // new shell with the old one over an internal GlobalKey).
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const MainShellPage(),
      ),
      GoRoute(
        path: RoutePaths.clips,
        name: RouteNames.clips,
        builder: (context, state) => ClipsPage(
          videoId: state.pathParameters['videoId']!,
          video: state.extra as VideoModel?,
        ),
      ),
      GoRoute(
        path: RoutePaths.clipDetail,
        name: RouteNames.clipDetail,
        builder: (context, state) {
          final args = state.extra as ClipDetailArgs?;
          return ClipDetailPage(
            videoId: state.pathParameters['videoId']!,
            clipId: state.pathParameters['clipId']!,
            video: args?.video,
            clip: args?.clip,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.createClips,
        name: RouteNames.createClips,
        builder: (context, state) {
          final args = state.extra as CreateClipsArgs;
          return CreateClipsPage(
            videoSource: args.videoSource,
            sourceUrl: args.sourceUrl,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.brollTemplate,
        name: RouteNames.brollTemplate,
        builder: (context, state) => const BrollTemplatePage(),
      ),
    ],
  );
}
