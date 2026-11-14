import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/clips/data/datasources/clips_remote_datasource.dart';
import 'package:zoclips/features/clips/data/models/clip_metadata_model.dart';
import 'package:zoclips/features/clips/data/models/clip_model.dart';
import 'package:zoclips/features/clips/data/models/pipeline_status_model.dart';
import 'package:zoclips/features/clips/data/models/regenerate_job_model.dart';
import 'package:zoclips/features/clips/presentation/cubit/clip_detail_cubit.dart';
import 'package:zoclips/features/clips/presentation/pages/clip_detail_page.dart';
import 'package:zoclips/injection_container.dart';

/// None of these fixtures set a `latest_render.output_url`, so the page
/// always takes the "still rendering" placeholder path — the real video
/// player (video_player/chewie) needs a platform implementation that
/// `flutter test` doesn't provide, so it's out of scope for widget tests.
class _FakeClipsRemoteDataSource implements ClipsRemoteDataSource {
  final PipelineStatusModel pipelineStatus;
  final ClipMetadataModel metadata;
  final Object? error;

  /// Once `regenerateMetadata` is called, `getClipMetadata` starts
  /// returning this instead — mimics the real job finishing between polls.
  final ClipMetadataModel? regeneratedMetadata;
  final Object? regenerateError;
  bool _regenerateCalled = false;

  _FakeClipsRemoteDataSource({
    required this.pipelineStatus,
    required this.metadata,
    this.error,
    this.regeneratedMetadata,
    this.regenerateError,
  });

  @override
  Future<List<ClipModel>> getClips({required String videoId}) async => const [];

  @override
  Future<PipelineStatusModel> getPipelineStatus({
    required String videoId,
    required String clipId,
  }) async {
    if (error != null) throw error!;
    return pipelineStatus;
  }

  @override
  Future<ClipMetadataModel> getClipMetadata({
    required String videoId,
    required String clipId,
  }) async {
    if (error != null) throw error!;
    if (_regenerateCalled && regeneratedMetadata != null) {
      return regeneratedMetadata!;
    }
    return metadata;
  }

  @override
  Future<RegenerateJobModel> regenerateMetadata({
    required String videoId,
    required String clipId,
  }) async {
    if (regenerateError != null) throw regenerateError!;
    _regenerateCalled = true;
    return const RegenerateJobModel(
      clipMetadataId: 'job-1',
      status: 'pending',
      creditsCharged: 2,
    );
  }
}

ClipModel _clip({int score = 70}) {
  return ClipModel(
    id: 'clip-1',
    startSegment: 0,
    endSegment: 1,
    startSeconds: 0,
    endSeconds: 32,
    durationSeconds: 32,
    title: 'The Truth of Victory',
    category: 'motivational',
    score: score,
    rank: 1,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required PipelineStatusModel pipelineStatus,
  required ClipMetadataModel metadata,
  Object? error,
  ClipMetadataModel? regeneratedMetadata,
  Object? regenerateError,
  int score = 70,
}) async {
  sl.registerFactory<ClipDetailCubit>(
    () => ClipDetailCubit(
      _FakeClipsRemoteDataSource(
        pipelineStatus: pipelineStatus,
        metadata: metadata,
        error: error,
        regeneratedMetadata: regeneratedMetadata,
        regenerateError: regenerateError,
      ),
    ),
  );
  addTearDown(() => sl.unregister<ClipDetailCubit>());

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: ClipDetailPage(
        videoId: 'video-1',
        clipId: 'clip-1',
        clip: _clip(score: score),
      ),
    ),
  );
}

const _queuedStatus = PipelineStatusModel(
  clipId: 'clip-1',
  editingPlanStatus: 'pending',
  cameraAnalysisStatus: 'pending',
  timelineDirectionStatus: 'pending',
  publishStatus: 'draft',
  latestRender: RenderJobModel(id: 'r1', status: 'queued', progress: 0),
);

void main() {
  testWidgets('shows the viral score and the clip title', (tester) async {
    await _pump(
      tester,
      pipelineStatus: _queuedStatus,
      metadata: const ClipMetadataModel(status: 'pending'),
      score: 70,
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('The Truth of Victory'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);
    expect(find.text('Strong'), findsOneWidget); // score >= 70 bucket
  });

  testWidgets('shows "Nothing generated yet" when metadata is empty', (
    tester,
  ) async {
    await _pump(
      tester,
      pipelineStatus: _queuedStatus,
      metadata: const ClipMetadataModel(status: 'pending'),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Nothing generated yet'), findsOneWidget);
  });

  testWidgets('shows the generated title/description/hashtags when present', (
    tester,
  ) async {
    await _pump(
      tester,
      pipelineStatus: _queuedStatus,
      metadata: const ClipMetadataModel(
        status: 'completed',
        title: 'The Truth About Winning',
        description: 'A raw monologue about readiness.',
        hashtags: ['motivation', 'truth'],
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('The Truth About Winning'), findsOneWidget);
    expect(find.text('A raw monologue about readiness.'), findsOneWidget);
    expect(find.text('#motivation'), findsOneWidget);
    expect(find.text('#truth'), findsOneWidget);
  });

  testWidgets('shows the rendering placeholder instead of a dead player', (
    tester,
  ) async {
    await _pump(
      tester,
      pipelineStatus: _queuedStatus,
      metadata: const ClipMetadataModel(status: 'pending'),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Queued for rendering…'), findsOneWidget);
  });

  testWidgets('shows a Draft status chip and no View link by default', (
    tester,
  ) async {
    await _pump(
      tester,
      pipelineStatus: _queuedStatus,
      metadata: const ClipMetadataModel(status: 'pending'),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Publish status'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('View'), findsNothing);
  });

  testWidgets('shows a Published status chip and a View link once the clip is '
      'published', (tester) async {
    await _pump(
      tester,
      pipelineStatus: const PipelineStatusModel(
        clipId: 'clip-1',
        editingPlanStatus: 'ready',
        cameraAnalysisStatus: 'ready',
        timelineDirectionStatus: 'ready',
        publishStatus: 'published',
        publishedUrl: 'https://www.youtube.com/watch?v=_Zr38BCRRvg',
        latestRender: RenderJobModel(
          id: 'r1',
          status: 'completed',
          progress: 100,
        ),
      ),
      metadata: const ClipMetadataModel(status: 'pending'),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Published'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
  });

  testWidgets('shows an error with retry on failure', (tester) async {
    await _pump(
      tester,
      pipelineStatus: _queuedStatus,
      metadata: const ClipMetadataModel(status: 'pending'),
      error: Exception('network down'),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Publish opens a confirmation dialog, Cancel dismisses it with no '
    'snackbar',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pump(
        tester,
        pipelineStatus: _queuedStatus,
        metadata: const ClipMetadataModel(status: 'pending'),
      );
      await tester.pump();
      await tester.pump();

      // Not pumpAndSettle: the page behind the dialog has a perpetual
      // CircularProgressIndicator (the "still rendering" placeholder),
      // which never settles.
      final publishButton = find.widgetWithText(ElevatedButton, 'Publish');
      await tester.ensureVisible(publishButton);
      await tester.tap(publishButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Publish this clip now'), findsOneWidget);
      expect(find.text('Publish now'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Publish this clip now'), findsNothing);
      expect(find.text('Publishing coming soon'), findsNothing);
    },
  );

  testWidgets('confirming Publish now shows the coming-soon snackbar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(
      tester,
      pipelineStatus: _queuedStatus,
      metadata: const ClipMetadataModel(status: 'pending'),
    );
    await tester.pump();
    await tester.pump();

    final publishButton = find.widgetWithText(ElevatedButton, 'Publish');
    await tester.ensureVisible(publishButton);
    await tester.tap(publishButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Publish now'));
    await tester.pump(); // dialog pop
    await tester.pump(); // AppSnackbar's slide-in animates continuously,
    // and the page behind it never settles either — pumpAndSettle would
    // time out here.

    expect(find.text('Publishing coming soon'), findsOneWidget);
  });

  testWidgets(
    'Schedule opens a date/time dialog with Schedule disabled until a '
    'date is picked',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pump(
        tester,
        pipelineStatus: _queuedStatus,
        metadata: const ClipMetadataModel(status: 'pending'),
      );
      await tester.pump();
      await tester.pump();

      final scheduleButton = find.widgetWithText(OutlinedButton, 'Schedule');
      await tester.ensureVisible(scheduleButton);
      await tester.tap(scheduleButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Schedule this clip'), findsOneWidget);
      expect(find.text('dd/mm/yyyy --:-- --'), findsOneWidget);
      final dialogScheduleButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Schedule'),
      );
      expect(dialogScheduleButton.onPressed, isNull);
    },
  );

  testWidgets(
    'tapping Regenerate shows the loading state then swaps in the new copy',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pump(
        tester,
        pipelineStatus: _queuedStatus,
        metadata: const ClipMetadataModel(
          status: 'completed',
          title: 'Old Title',
          description: 'Old description.',
          hashtags: ['old'],
        ),
        regeneratedMetadata: const ClipMetadataModel(
          status: 'completed',
          title: 'New Title',
          description: 'New description.',
          hashtags: ['new'],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Old Title'), findsOneWidget);

      final regenerateButton = find.widgetWithText(
        TextButton,
        'Regenerate · 2',
      );
      await tester.ensureVisible(regenerateButton);
      await tester.tap(regenerateButton);
      await tester.pump(); // isRegenerating: true

      expect(find.text('Writing your copy…'), findsOneWidget);
      expect(find.text('Old Title'), findsNothing);

      // testWidgets runs inside a fake-async zone, so this elapses the
      // cubit's 2s poll delay instantly rather than actually waiting.
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(); // process the getClipMetadata response

      expect(find.text('New Title'), findsOneWidget);
      expect(find.text('Writing your copy…'), findsNothing);
    },
  );

  testWidgets('shows an error snackbar if regenerating fails', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(
      tester,
      pipelineStatus: _queuedStatus,
      metadata: const ClipMetadataModel(status: 'pending'),
      regenerateError: Exception('network down'),
    );
    await tester.pump();
    await tester.pump();

    final regenerateButton = find.widgetWithText(TextButton, 'Regenerate · 2');
    await tester.ensureVisible(regenerateButton);
    await tester.tap(regenerateButton);
    await tester.pump();
    await tester.pump();

    expect(find.text('Could not regenerate. Try again.'), findsOneWidget);
  });
}
