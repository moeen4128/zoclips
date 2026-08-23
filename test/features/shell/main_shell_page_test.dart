import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:zoclips/core/widgets/app_bottom_nav_bar.dart';
import 'package:zoclips/core/widgets/app_navigation_rail.dart';
import 'package:zoclips/features/assets/presentation/pages/assets_page.dart';
import 'package:zoclips/features/calendar/presentation/pages/calendar_page.dart';
import 'package:zoclips/features/home/presentation/pages/home_page.dart';
import 'package:zoclips/features/profile/presentation/pages/profile_page.dart';
import 'package:zoclips/features/shell/presentation/pages/main_shell_page.dart';

/// Minimal router that mirrors the shell branches in AppRouter, without the
/// auth/settings routes (which need DI) — just enough to exercise
/// MainShellPage's compact-vs-large-screen layout switch.
GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomePage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/assets', builder: (_, _) => const AssetsPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/calendar', builder: (_, _) => const CalendarPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfilePage())],
          ),
        ],
      ),
    ],
  );
}

Future<void> _pumpAtSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp.router(routerConfig: _buildTestRouter()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the bottom nav bar on phone-width (compact) screens', (tester) async {
    await _pumpAtSize(tester, const Size(390, 844)); // iPhone-class width

    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.byType(AppNavigationRail), findsNothing);
  });

  testWidgets('shows the side nav rail on tablet/foldable/iPad-width screens', (tester) async {
    await _pumpAtSize(tester, const Size(1024, 768)); // iPad-class width

    expect(find.byType(AppNavigationRail), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsNothing);
  });

  testWidgets('switches from rail back to bottom bar when the window narrows (fold)', (
    tester,
  ) async {
    await _pumpAtSize(tester, const Size(1024, 768));
    expect(find.byType(AppNavigationRail), findsOneWidget);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.byType(AppNavigationRail), findsNothing);
  });
}
