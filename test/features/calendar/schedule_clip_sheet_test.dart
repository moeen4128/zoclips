import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:zoclips/features/calendar/data/models/video_scheduling_summary_model.dart';
import 'package:zoclips/features/calendar/presentation/widgets/schedule_clip_sheet.dart';
import 'package:zoclips/features/clips/data/datasources/clips_remote_datasource.dart';
import 'package:zoclips/features/clips/data/models/clip_metadata_model.dart';
import 'package:zoclips/features/clips/data/models/clip_model.dart';
import 'package:zoclips/features/clips/data/models/pipeline_status_model.dart';
import 'package:zoclips/features/clips/data/models/regenerate_job_model.dart';
import 'package:zoclips/injection_container.dart';

const _videos = [
  VideoSchedulingSummaryModel(
    videoId: 'v1',
    title: 'Wonder Woman 1984 | Young Diana Takes on The Amazon Games',
    thumbnailUrl: 'https://example.com/thumb1.webp',
    totalClips: 2,
    publishedClips: 1,
  ),
  VideoSchedulingSummaryModel(
    videoId: 'v2',
    title: 'Learn English By Movies - The Pursuit Of Happyness',
    totalClips: 2,
    publishedClips: 0,
  ),
];

class _FakeCalendarRemoteDataSource implements CalendarRemoteDataSource {
  final Object? error;
  final List<VideoSchedulingSummaryModel> videos;
  _FakeCalendarRemoteDataSource({this.error, this.videos = const []});

  @override
  Future<List<VideoSchedulingSummaryModel>> getSchedulingSummary() async {
    if (error != null) throw error!;
    return videos;
  }
}

const _clips = [
  ClipModel(
    id: 'c1',
    startSegment: 0,
    endSegment: 1,
    title: 'The Football Rebounder That Replaces Your Coach',
    startSeconds: 0,
    endSeconds: 25,
    durationSeconds: 25,
    category: 'Highlights',
    score: 90,
    rank: 1,
  ),
  ClipModel(
    id: 'c2',
    startSegment: 1,
    endSegment: 2,
    title: 'A Tool That Makes Waste Collection Hygienic and Hands-Free',
    startSeconds: 0,
    endSeconds: 24,
    durationSeconds: 24,
    category: 'Highlights',
    score: 80,
    rank: 2,
  ),
];

class _FakeClipsRemoteDataSource implements ClipsRemoteDataSource {
  final List<ClipModel> clips;
  _FakeClipsRemoteDataSource({this.clips = const []});

  @override
  Future<List<ClipModel>> getClips({required String videoId}) async => clips;

  @override
  Future<PipelineStatusModel> getPipelineStatus({
    required String videoId,
    required String clipId,
  }) => throw UnimplementedError();

  @override
  Future<ClipMetadataModel> getClipMetadata({
    required String videoId,
    required String clipId,
  }) => throw UnimplementedError();

  @override
  Future<RegenerateJobModel> regenerateMetadata({
    required String videoId,
    required String clipId,
  }) => throw UnimplementedError();
}

Future<void> _pumpWithButton(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showScheduleClipSheet(
              context,
              dateLabel: 'Wednesday, November 4',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(() {
    if (sl.isRegistered<CalendarRemoteDataSource>()) {
      sl.unregister<CalendarRemoteDataSource>();
    }
    if (sl.isRegistered<ClipsRemoteDataSource>()) {
      sl.unregister<ClipsRemoteDataSource>();
    }
  });

  testWidgets('shows the video list once loaded', (tester) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(videos: _videos),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Schedule a clip'), findsOneWidget);
    expect(find.text('Wednesday, November 4'), findsOneWidget);
    expect(
      find.text('Wonder Woman 1984 | Young Diana Takes on The Amazon Games'),
      findsOneWidget,
    );
    expect(find.text('1/2 published'), findsOneWidget);
    expect(find.text('0/2 published'), findsOneWidget);
  });

  testWidgets('tapping a video row shows that video\'s clips', (tester) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(videos: _videos),
    );
    sl.registerLazySingleton<ClipsRemoteDataSource>(
      () => _FakeClipsRemoteDataSource(clips: _clips),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1/2 published'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a clip'), findsOneWidget);
    expect(
      find.text('Wonder Woman 1984 | Young Diana Takes on The Amazon Games'),
      findsOneWidget,
    );
    expect(
      find.text('The Football Rebounder That Replaces Your Coach'),
      findsOneWidget,
    );
    expect(find.text('0:25'), findsOneWidget);
    expect(find.text('0:24'), findsOneWidget);
  });

  testWidgets('back arrow on the clip step returns to the video list', (
    tester,
  ) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(videos: _videos),
    );
    sl.registerLazySingleton<ClipsRemoteDataSource>(
      () => _FakeClipsRemoteDataSource(clips: _clips),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1/2 published'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Schedule a clip'), findsOneWidget);
    expect(find.text('1/2 published'), findsOneWidget);
  });

  testWidgets('tapping a clip row shows the pick-a-time step', (tester) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(videos: _videos),
    );
    sl.registerLazySingleton<ClipsRemoteDataSource>(
      () => _FakeClipsRemoteDataSource(clips: _clips),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1/2 published'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('The Football Rebounder That Replaces Your Coach'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pick a time'), findsOneWidget);
    expect(
      find.text('The Football Rebounder That Replaces Your Coach'),
      findsOneWidget,
    );
    expect(find.text('Schedule'), findsWidgets);
    expect(find.text('Publish now'), findsOneWidget);
  });

  testWidgets('back arrow on the time step returns to the clip list', (
    tester,
  ) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(videos: _videos),
    );
    sl.registerLazySingleton<ClipsRemoteDataSource>(
      () => _FakeClipsRemoteDataSource(clips: _clips),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1/2 published'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('The Football Rebounder That Replaces Your Coach'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Choose a clip'), findsOneWidget);
    expect(find.text('0:25'), findsOneWidget);
  });

  testWidgets('switching to Publish now hides the time field', (tester) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(videos: _videos),
    );
    sl.registerLazySingleton<ClipsRemoteDataSource>(
      () => _FakeClipsRemoteDataSource(clips: _clips),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1/2 published'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('The Football Rebounder That Replaces Your Coach'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Time'), findsOneWidget);

    await tester.tap(find.text('Publish now').first);
    await tester.pumpAndSettle();

    expect(find.text('Time'), findsNothing);
  });

  testWidgets('tapping the Schedule button shows a coming-soon snackbar', (
    tester,
  ) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(videos: _videos),
    );
    sl.registerLazySingleton<ClipsRemoteDataSource>(
      () => _FakeClipsRemoteDataSource(clips: _clips),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1/2 published'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('The Football Rebounder That Replaces Your Coach'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Schedule'));
    await tester.pump();

    expect(find.text('Scheduling coming soon'), findsOneWidget);
  });

  testWidgets('shows an error with retry on failure', (tester) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(error: Exception('boom')),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load your videos. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('the close button dismisses the sheet', (tester) async {
    sl.registerLazySingleton<CalendarRemoteDataSource>(
      () => _FakeCalendarRemoteDataSource(videos: _videos),
    );
    await _pumpWithButton(tester);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule a clip'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Schedule a clip'), findsNothing);
  });
}
