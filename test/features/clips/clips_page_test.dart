import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/clips/data/datasources/clips_remote_datasource.dart';
import 'package:zoclips/features/clips/data/models/clip_metadata_model.dart';
import 'package:zoclips/features/clips/data/models/clip_model.dart';
import 'package:zoclips/features/clips/data/models/pipeline_status_model.dart';
import 'package:zoclips/features/clips/data/models/regenerate_job_model.dart';
import 'package:zoclips/features/clips/presentation/cubit/clips_cubit.dart';
import 'package:zoclips/features/clips/presentation/pages/clips_page.dart';
import 'package:zoclips/injection_container.dart';

class _FakeClipsRemoteDataSource implements ClipsRemoteDataSource {
  final List<ClipModel>? clips;
  final Object? error;
  _FakeClipsRemoteDataSource({this.clips, this.error});

  @override
  Future<List<ClipModel>> getClips({required String videoId}) async {
    if (error != null) throw error!;
    return clips ?? const [];
  }

  @override
  Future<PipelineStatusModel> getPipelineStatus({
    required String videoId,
    required String clipId,
  }) async {
    return const PipelineStatusModel(
      clipId: 'clip-1',
      editingPlanStatus: 'pending',
      cameraAnalysisStatus: 'pending',
      timelineDirectionStatus: 'pending',
      publishStatus: 'draft',
    );
  }

  @override
  Future<ClipMetadataModel> getClipMetadata({
    required String videoId,
    required String clipId,
  }) async {
    return const ClipMetadataModel(status: 'pending');
  }

  @override
  Future<RegenerateJobModel> regenerateMetadata({
    required String videoId,
    required String clipId,
  }) async {
    return const RegenerateJobModel(
      clipMetadataId: 'job-1',
      status: 'pending',
      creditsCharged: 2,
    );
  }
}

ClipModel _clip({
  required String title,
  required String category,
  int score = 70,
}) {
  return ClipModel(
    id: title,
    startSegment: 0,
    endSegment: 1,
    startSeconds: 0,
    endSeconds: 32,
    durationSeconds: 32,
    title: title,
    category: category,
    score: score,
    rank: 1,
  );
}

Future<void> _pump(
  WidgetTester tester,
  ClipsRemoteDataSource dataSource,
) async {
  sl.registerFactory<ClipsCubit>(() => ClipsCubit(dataSource));
  // ClipCard's thumbnail fetches pipeline-status directly via sl, not
  // through the cubit.
  sl.registerLazySingleton<ClipsRemoteDataSource>(() => dataSource);
  addTearDown(() {
    sl.unregister<ClipsCubit>();
    sl.unregister<ClipsRemoteDataSource>();
  });

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: const ClipsPage(videoId: 'video-1'),
    ),
  );
}

void main() {
  testWidgets('shows clip cards once loaded', (tester) async {
    await _pump(
      tester,
      _FakeClipsRemoteDataSource(
        clips: [
          _clip(title: 'The Truth of Victory', category: 'motivational'),
          _clip(
            title: 'Legacy of the Golden Warrior',
            category: 'inspirational',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('The Truth of Victory'), findsOneWidget);
    expect(find.text('Legacy of the Golden Warrior'), findsOneWidget);
    expect(find.text('Motivational'), findsOneWidget);
    expect(find.text('2'), findsWidgets); // clips found / ready stat tiles
  });

  testWidgets(
    'hides the score badge instead of showing "0" for an unscored clip',
    (tester) async {
      await _pump(
        tester,
        _FakeClipsRemoteDataSource(
          clips: [_clip(title: 'A clip', category: 'motivational', score: 0)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A clip'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    },
  );

  testWidgets('shows an empty state when there are no clips', (tester) async {
    await _pump(tester, _FakeClipsRemoteDataSource(clips: const []));
    await tester.pumpAndSettle();

    expect(find.text('No clips found yet'), findsOneWidget);
  });

  testWidgets('shows an error with retry on failure', (tester) async {
    await _pump(
      tester,
      _FakeClipsRemoteDataSource(error: Exception('network down')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'does not overflow at a phone width where the single-column card is '
    'wider than the grid delegate\'s maxCrossAxisExtent',
    (tester) async {
      // At this width, ResponsivePage's padding leaves ~358 of content —
      // narrower than 2x maxCrossAxisExtent (340), so the grid falls back
      // to a single column that's itself wider than 340. A fixed
      // mainAxisExtent tuned only for the 340-wide case overflows here.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pump(
        tester,
        _FakeClipsRemoteDataSource(
          clips: [_clip(title: 'A clip', category: 'motivational')],
        ),
      );
      await tester.pump(); // skeleton frame — this is where it overflowed
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
