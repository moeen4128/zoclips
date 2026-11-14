import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/core/widgets/app_snackbar.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) => Scaffold(
          // Buttons live at the bottom so the top-anchored snackbar overlay
          // never covers their tap targets.
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      AppSnackbar.success(context, 'Saved successfully'),
                  child: const Text('show'),
                ),
                ElevatedButton(
                  onPressed: () => AppSnackbar.error(context, 'Second message'),
                  child: const Text('show2'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('slides in and shows the message when triggered', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('show'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(milliseconds: 200)); // mid slide-in

    expect(find.text('Saved successfully'), findsOneWidget);
  });

  testWidgets('auto-dismisses (slides out) after its duration', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(find.text('Saved successfully'), findsOneWidget);

    // Default duration is 3s; let the auto-dismiss timer fire, then let the
    // 380ms reverse (slide-out) animation finish.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Saved successfully'), findsNothing);
  });

  testWidgets('tapping the close icon dismisses it immediately', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(find.text('Saved successfully'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Saved successfully'), findsNothing);
  });

  testWidgets('a new snackbar replaces one already showing', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(find.text('Saved successfully'), findsOneWidget);

    await tester.tap(find.text('show2'));
    await tester.pumpAndSettle();

    expect(find.text('Saved successfully'), findsNothing);
    expect(find.text('Second message'), findsOneWidget);
  });
}
