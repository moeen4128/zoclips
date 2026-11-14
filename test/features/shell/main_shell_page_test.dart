import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/core/widgets/app_bottom_nav_bar.dart';
import 'package:zoclips/core/widgets/app_navigation_rail.dart';
import 'package:zoclips/features/shell/presentation/pages/main_shell_page.dart';

/// Tall enough to overflow a phone-height screen, so it's actually
/// scrollable — real page bodies (ResponsivePage) are also scroll views.
/// Stands in for the real HomePage tab, which needs a DI container
/// (VideosCubit via get_it) that these tests don't set up.
class _ScrollableHome extends StatelessWidget {
  const _ScrollableHome();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50,
      itemBuilder: (context, index) =>
          SizedBox(height: 60, child: Center(child: Text('Item $index'))),
    );
  }
}

const _fakeTabs = [
  _ScrollableHome(),
  Center(child: Text('Assets tab content')),
  Center(child: Text('Calendar tab content')),
  Center(child: Text('Profile tab content')),
];

/// Minimal router mirroring AppRouter's shape — a single /home route for the
/// shell, plus sibling top-level routes standing in for /sign-in and
/// /settings, enough to exercise leaving the shell entirely and re-entering
/// it later (the same shape of navigation as logout → sign back in).
GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (_, _) => const _FakeSignIn(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, _) => const _FakeSettings(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, _) => const MainShellPage(tabs: _fakeTabs),
      ),
    ],
  );
}

class _FakeSignIn extends StatelessWidget {
  const _FakeSignIn();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Sign In')));
}

/// Stand-in for SettingsPage — pushed on top of the shell, same shape as
/// the real logout entry point.
class _FakeSettings extends StatelessWidget {
  const _FakeSettings();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}

double _bottomNavOpacity(WidgetTester tester) {
  return tester
      .widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byType(AppBottomNavBar),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;
}

Future<void> _pumpAtSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.darkTheme,
      routerConfig: _buildTestRouter(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the bottom nav bar on phone-width (compact) screens', (
    tester,
  ) async {
    await _pumpAtSize(tester, const Size(390, 844)); // iPhone-class width

    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.byType(AppNavigationRail), findsNothing);
  });

  testWidgets('shows the side nav rail on tablet/foldable/iPad-width screens', (
    tester,
  ) async {
    await _pumpAtSize(tester, const Size(1024, 768)); // iPad-class width

    expect(find.byType(AppNavigationRail), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsNothing);
  });

  testWidgets(
    'switches from rail back to bottom bar when the window narrows (fold)',
    (tester) async {
      await _pumpAtSize(tester, const Size(1024, 768));
      expect(find.byType(AppNavigationRail), findsOneWidget);

      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(find.byType(AppNavigationRail), findsNothing);
    },
  );

  testWidgets(
    'hides the bottom nav bar when scrolling down, shows it again scrolling up',
    (tester) async {
      await _pumpAtSize(tester, const Size(390, 844));
      expect(_bottomNavOpacity(tester), 1);

      // Drag content upward (finger moves up) — scrolling down through the
      // list — should hide the bar.
      await tester.fling(
        find.byType(_ScrollableHome),
        const Offset(0, -300),
        800,
      );
      await tester.pumpAndSettle();
      expect(_bottomNavOpacity(tester), 0);

      // Drag back down — scrolling up — should bring it back.
      await tester.fling(
        find.byType(_ScrollableHome),
        const Offset(0, 300),
        800,
      );
      await tester.pumpAndSettle();
      expect(_bottomNavOpacity(tester), 1);
    },
  );

  testWidgets('switches tabs by tapping the bottom nav bar', (tester) async {
    await _pumpAtSize(tester, const Size(390, 844));
    expect(find.byType(_ScrollableHome), findsOneWidget);

    await tester.tap(find.text('Assets')); // the nav bar's own label
    await tester.pumpAndSettle();

    expect(find.text('Assets tab content'), findsOneWidget);
  });

  testWidgets('tapping Profile switches to the Profile tab like any other tab '
      '(no bottom sheet)', (tester) async {
    await _pumpAtSize(tester, const Size(390, 844));

    await tester.tap(find.text('Profile')); // the nav bar's own label
    await tester.pumpAndSettle();

    expect(find.text('Profile tab content'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets(
    'survives leaving the shell route and re-entering it (logout then log back in)',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _buildTestRouter();
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavBar), findsOneWidget);

      // "Logout": leave the shell entirely for a sibling top-level route.
      router.go('/sign-in');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsNothing);

      // "Log back in": navigate back into the shell.
      router.go('/home');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    },
  );

  testWidgets(
    'survives the real logout flow: settings pushed on the shell, then '
    'straight to sign-in and back to home without waiting for transitions '
    'to settle in between',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _buildTestRouter();
      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
      );
      await tester.pumpAndSettle();

      // Settings is pushed on top of the shell (as it is from the profile
      // sheet in the real app), not navigated to in its place.
      router.pushNamed('settings');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Settings'), findsOneWidget);

      // _confirmLogout's actual sequence: a single goNamed(signIn) that
      // replaces both the pushed settings page and the shell page at once.
      router.goNamed('sign-in');
      await tester.pump(); // deliberately not settled — no delay assumed
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsNothing);

      // Logging back in straight away, same frame-tight timing.
      router.goNamed('home');
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    },
  );
}
