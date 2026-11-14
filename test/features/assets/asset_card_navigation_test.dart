import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/assets/data/models/asset_item_model.dart';
import 'package:zoclips/features/assets/presentation/widgets/asset_card.dart';

final _item = AssetItemModel(
  renderJobId: 'r1',
  videoId: 'video-1',
  clipId: 'clip-1',
  title: 'The Truth of Victory',
  category: 'motivational',
  durationSeconds: 32,
  outputUrl: 'https://example.com/clip.mp4',
  videoTitle: 'Source video',
  createdAt: DateTime(2026, 1, 1),
);

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/assets',
    routes: [
      GoRoute(
        path: '/assets',
        name: 'assets',
        // Bounded, like a real grid cell — AssetCard isn't meant to fill an
        // unconstrained Scaffold body.
        builder: (context, state) => Scaffold(
          body: Center(
            // Matches _gridDelegateFor's real math in assets_page.dart:
            // 200 * 4/3 (thumbnail) + 150 (info panel).
            child: SizedBox(
              width: 200,
              height: 416,
              child: AssetCard(item: _item),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/videos/:videoId/clips/:clipId',
        name: 'clip-detail',
        builder: (context, state) => Scaffold(
          body: Text(
            'Clip Detail: ${state.pathParameters['videoId']}/'
            '${state.pathParameters['clipId']}',
          ),
        ),
      ),
      GoRoute(
        path: '/videos/:videoId/clips',
        name: 'clips',
        builder: (context, state) =>
            Scaffold(body: Text('Clips: ${state.pathParameters['videoId']}')),
      ),
    ],
  );
}

void main() {
  testWidgets(
    'tapping the asset card (thumbnail/play badge) opens the clip detail '
    'page — the bug where nothing happened on tap',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.darkTheme,
          routerConfig: _buildRouter(),
        ),
      );

      // Tap the thumbnail area itself (not the Download/Open buttons).
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Clip Detail: video-1/clip-1'), findsOneWidget);
    },
  );

  testWidgets(
    'the Open button still goes to the parent video, not clip detail',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.darkTheme,
          routerConfig: _buildRouter(),
        ),
      );

      await tester.tap(find.byIcon(Icons.open_in_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Clips: video-1'), findsOneWidget);
      expect(find.textContaining('Clip Detail'), findsNothing);
    },
  );
}
