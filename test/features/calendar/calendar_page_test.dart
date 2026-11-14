import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:zoclips/features/calendar/data/models/video_scheduling_summary_model.dart';
import 'package:zoclips/features/calendar/presentation/pages/calendar_page.dart';
import 'package:zoclips/injection_container.dart';

class _FakeCalendarRemoteDataSource implements CalendarRemoteDataSource {
  @override
  Future<List<VideoSchedulingSummaryModel>> getSchedulingSummary() async =>
      const [];
}

const _weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

Future<void> _pump(WidgetTester tester) async {
  sl.registerLazySingleton<CalendarRemoteDataSource>(
    () => _FakeCalendarRemoteDataSource(),
  );
  addTearDown(() => sl.unregister<CalendarRemoteDataSource>());

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: const Scaffold(body: CalendarPage()),
    ),
  );
  await tester.pumpAndSettle();
}

String _currentMonthHeader() {
  final now = DateTime.now();
  return '${_monthNames[now.month - 1]} ${now.year}';
}

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String _selectedDayLabel(DateTime date) =>
    '${_weekdayNames[date.weekday - 1]}, '
    '${_monthNames[date.month - 1]} ${date.day}';

void main() {
  testWidgets('shows the current month, weekday headers, and today', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text(_currentMonthHeader()), findsOneWidget);
    for (final label in _weekdayLabels) {
      expect(find.text(label.toUpperCase()), findsOneWidget);
    }
    expect(find.text('${DateTime.now().day}'), findsWidgets);
  });

  testWidgets(
    'next/prev month navigation changes the header, Today resets it',
    (tester) async {
      await _pump(tester);
      final startHeader = _currentMonthHeader();

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text(startHeader), findsNothing);

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(find.text(startHeader), findsOneWidget);
    },
  );

  testWidgets('prev/next year navigation changes the header year', (
    tester,
  ) async {
    await _pump(tester);
    final startHeader = _currentMonthHeader();

    await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text(startHeader), findsNothing);
    expect(
      find.text(
        '${_monthNames[DateTime.now().month - 1]} ${DateTime.now().year + 1}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping Schedule a clip opens the schedule sheet', (
    tester,
  ) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Schedule a clip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule a clip'));
    await tester.pumpAndSettle();

    // Two matches now: the empty-state button's label and the sheet's own
    // title header.
    expect(find.text('Schedule a clip'), findsNWidgets(2));
  });

  testWidgets('shows the empty schedule state by default', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('No posts scheduled'));
    expect(find.text('No posts scheduled'), findsOneWidget);
    expect(
      find.text('Schedule a clip to see it show up here.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Add on the header opens the schedule sheet', (
    tester,
  ) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // The empty-state button's label is still in the tree underneath, plus
    // the sheet's own title header.
    expect(find.text('Schedule a clip'), findsNWidgets(2));
  });

  testWidgets('tapping a day before today does not change the selection', (
    tester,
  ) async {
    final now = DateTime.now();
    // On the 1st there's no guaranteed past day visible in-month; skip this
    // rare edge case rather than special-casing the previous month's grid.
    if (now.day == 1) return;
    final yesterday = now.subtract(const Duration(days: 1));

    await _pump(tester);
    final todayLabel = find.text(_selectedDayLabel(now));
    expect(todayLabel, findsOneWidget);

    // Grid order is chronological, so the first match for yesterday's day
    // number is always a past cell even if a future month reuses the digit.
    await tester.tap(find.text('${yesterday.day}').first);
    await tester.pumpAndSettle();

    expect(todayLabel, findsOneWidget);
    expect(find.text(_selectedDayLabel(yesterday)), findsNothing);
  });
}
