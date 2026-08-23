import 'package:go_router/go_router.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'route_names.dart';
import '../../features/auth/presentation/pages/signin_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/pages/email_verification_result_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/assets/presentation/pages/assets_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RoutePaths.signIn,
    routes: [
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
      // Bottom-nav shell — 4 branches, each its own independent navigator.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.assets,
                name: RouteNames.assets,
                builder: (context, state) => const AssetsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.calendar,
                name: RouteNames.calendar,
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
