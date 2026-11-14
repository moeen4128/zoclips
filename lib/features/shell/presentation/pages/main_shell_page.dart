import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_navigation_rail.dart';
import '../../../assets/presentation/pages/assets_page.dart';
import '../../../calendar/presentation/pages/calendar_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainShellPage extends StatefulWidget {
  /// Overridable for tests — the real tabs need a DI container set up
  /// (HomePage pulls VideosCubit from get_it, etc.) which unit/widget tests
  /// don't have; production call sites just use the default.
  final List<Widget>? tabs;

  const MainShellPage({super.key, this.tabs});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  // Tab switching is plain local state rather than go_router's
  // StatefulShellRoute — that combination has a still-open upstream bug
  // (https://github.com/flutter/flutter/issues/148768) where leaving this
  // shell for a sibling route and returning to it collides the new shell
  // instance with the old one over StatefulShellRoute's internal
  // GlobalKey<StatefulNavigationShellState> ("Duplicate GlobalKey ...").
  // None of these four tabs push their own nested routes, so an IndexedStack
  // driven by local state gives the same "preserve each tab's scroll
  // position when switching" behavior without go_router managing a
  // persistent per-branch Navigator/GlobalKey at all.
  int _currentIndex = 0;

  static const List<Widget> _defaultTabs = [
    HomePage(),
    AssetsPage(),
    CalendarPage(),
    ProfilePage(),
  ];

  /// Scrolling down (further into the content) hides the bottom nav bar to
  /// give the page more room; scrolling back up brings it back.
  bool _showBottomNav = true;

  void _handleTap(int index) {
    setState(() => _currentIndex = index);
  }

  bool _handleScrollNotification(UserScrollNotification notification) {
    final direction = notification.direction;
    if (direction == ScrollDirection.reverse && _showBottomNav) {
      setState(() => _showBottomNav = false); // scrolling down
    } else if (direction == ScrollDirection.forward && !_showBottomNav) {
      setState(() => _showBottomNav = true); // scrolling up
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final content = IndexedStack(
      index: _currentIndex,
      children: widget.tabs ?? _defaultTabs,
    );

    // Phones and folded/cover-screen foldables: bottom tab bar.
    if (context.isCompact) {
      // To reclaim the full screen when the bar hides (not just fade it
      // out, which leaves Scaffold still reserving its height), animate
      // the bottomNavigationBar's actual layout height to zero via
      // AnimatedAlign(heightFactor: ...) instead of a paint-only transform.
      return Scaffold(
        backgroundColor: context.neutrals.background,
        extendBody: true,
        body: NotificationListener<UserScrollNotification>(
          onNotification: _handleScrollNotification,
          child: content,
        ),
        bottomNavigationBar: ClipRect(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            heightFactor: _showBottomNav ? 1.0 : 0.0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showBottomNav ? 1 : 0,
              child: AppBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _handleTap,
              ),
            ),
          ),
        ),
      );
    }

    // Tablets, unfolded foldables, iPad and desktop-class widths: side rail.
    return Scaffold(
      backgroundColor: context.neutrals.background,
      body: Row(
        children: [
          AppNavigationRail(
            currentIndex: _currentIndex,
            onTap: _handleTap,
            extended: context.isExpanded,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
