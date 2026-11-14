import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/home/data/models/video_model.dart';
import 'package:zoclips/features/home/presentation/widgets/project_card.dart';

VideoModel _video({required String title, bool isSaved = false}) {
  return VideoModel(
    id: '1',
    title: title,
    thumbnailUrl: null,
    status: 'completed',
    durationSeconds: 125,
    isSaved: isSaved,
    createdAt: DateTime.now(),
    sourceType: 'url',
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: Center(child: SizedBox(width: 340, height: 320, child: child)),
    ),
  );
}

void main() {
  testWidgets(
    'does not overflow at the widest grid cell with a long, wrapping title',
    (tester) async {
      // Matches the grid's maxCrossAxisExtent/mainAxisExtent — the exact box
      // size that produced the reported RenderFlex overflow.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 340,
                height: 320,
                child: ProjectCard(
                  video: _video(
                    title:
                        'A very long project title that wraps onto two full lines of text',
                  ),
                  onToggleSaved: (_) {},
                  onDelete: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('does not overflow at a narrow single-column width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 320,
              child: ProjectCard(
                video: _video(title: 'Short title'),
                onToggleSaved: (_) {},
                onDelete: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'tapping the bookmark icon calls onToggleSaved with the video id',
    (tester) async {
      String? toggledId;
      await tester.pumpWidget(
        _wrap(
          ProjectCard(
            video: _video(title: 'Short title'),
            onToggleSaved: (id) => toggledId = id,
            onDelete: (_) {},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      await tester.pump();

      expect(toggledId, '1');
    },
  );

  testWidgets('shows a spinner instead of the bookmark icon while saving', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ProjectCard(
          video: _video(title: 'Short title'),
          isSaving: true,
          onToggleSaved: (_) {},
          onDelete: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a spinner instead of the delete icon while deleting', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ProjectCard(
          video: _video(title: 'Short title'),
          isDeleting: true,
          onToggleSaved: (_) {},
          onDelete: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('delete requires confirmation — Cancel does not call onDelete', (
    tester,
  ) async {
    var deleteCalled = false;
    await tester.pumpWidget(
      _wrap(
        ProjectCard(
          video: _video(title: 'Short title'),
          onToggleSaved: (_) {},
          onDelete: (_) => deleteCalled = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Delete project?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isFalse);
    expect(find.text('Delete project?'), findsNothing);
  });

  testWidgets('delete confirmation — Delete calls onDelete with the video id', (
    tester,
  ) async {
    String? deletedId;
    await tester.pumpWidget(
      _wrap(
        ProjectCard(
          video: _video(title: 'Short title'),
          onToggleSaved: (_) {},
          onDelete: (id) => deletedId = id,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deletedId, '1');
  });
}
