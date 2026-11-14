import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/clips/data/datasources/clips_remote_datasource.dart';
import 'package:zoclips/features/clips/data/models/clip_metadata_model.dart';
import 'package:zoclips/features/clips/data/models/clip_model.dart';
import 'package:zoclips/features/clips/data/models/pipeline_status_model.dart';
import 'package:zoclips/features/clips/data/models/regenerate_job_model.dart';
import 'package:zoclips/features/clips/presentation/cubit/clip_detail_cubit.dart';
import 'package:zoclips/features/clips/presentation/cubit/clips_cubit.dart';
import 'package:zoclips/features/clips/presentation/pages/clip_detail_args.dart';
import 'package:zoclips/features/clips/presentation/pages/clip_detail_page.dart';
import 'package:zoclips/features/clips/presentation/pages/clips_page.dart';
import 'package:zoclips/injection_container.dart';

class _FakeClipsRemoteDataSource implements ClipsRemoteDataSource {
  final List<ClipModel> clips;
  _FakeClipsRemoteDataSource(this.clips);

  @override
  Future<List<ClipModel>> getClips({required String videoId}) async => clips;

  @override
  Future<PipelineStatusModel> getPipelineStatus({
    required String videoId,
    required String clipId,
  }) async => const PipelineStatusModel(
    clipId: 'clip-1',
    editingPlanStatus: 'pending',
    cameraAnalysisStatus: 'pending',
    timelineDirectionStatus: 'pending',
    publishStatus: 'draft',
    latestRender: RenderJobModel(id: 'r1', status: 'queued', progress: 0),
  );

  @override
  Future<ClipMetadataModel> getClipMetadata({
    required String videoId,
    required String clipId,
  }) async => const ClipMetadataModel(status: 'pending');

  @override
  Future<RegenerateJobModel> regenerateMetadata({
    required String videoId,
    required String clipId,
  }) async => const RegenerateJobModel(
    clipMetadataId: 'job-1',
    status: 'pending',
    creditsCharged: 2,
  );
}

void main() {
  testWidgets(
    'tapping a clip card carries its real score through to the detail page '
    '(regression for the record-extra routing bug)',
    (tester) async {
      final dataSource = _FakeClipsRemoteDataSource([
        const ClipModel(
          id: 'clip-1',
          startSegment: 0,
          endSegment: 1,
          startSeconds: 0,
          endSeconds: 32,
          durationSeconds: 32,
          title: 'The Truth of Victory',
          category: 'motivational',
          score: 70,
          rank: 1,
        ),
      ]);
      sl.registerFactory<ClipsCubit>(() => ClipsCubit(dataSource));
      sl.registerFactory<ClipDetailCubit>(() => ClipDetailCubit(dataSource));
      // ClipCard's thumbnail fetches pipeline-status directly via sl, not
      // through the cubit.
      sl.registerLazySingleton<ClipsRemoteDataSource>(() => dataSource);
      addTearDown(() {
        sl.unregister<ClipsCubit>();
        sl.unregister<ClipDetailCubit>();
        sl.unregister<ClipsRemoteDataSource>();
      });

      // Mirrors app_router.dart's clips/clip-detail routes exactly,
      // including the ClipDetailArgs extra-passing.
      final router = GoRouter(
        initialLocation: '/videos/video-1/clips',
        routes: [
          GoRoute(
            path: '/videos/:videoId/clips',
            name: 'clips',
            builder: (context, state) =>
                ClipsPage(videoId: state.pathParameters['videoId']!),
          ),
          GoRoute(
            path: '/videos/:videoId/clips/:clipId',
            name: 'clip-detail',
            builder: (context, state) {
              final args = state.extra as ClipDetailArgs?;
              return ClipDetailPage(
                videoId: state.pathParameters['videoId']!,
                clipId: state.pathParameters['clipId']!,
                video: args?.video,
                clip: args?.clip,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('The Truth of Victory'));
      await tester.pump();
      await tester.pump();

      // The clips grid page stays mounted underneath the pushed detail
      // page, so a plain find.text('70') also matches its thumbnail/chip
      // badges — the detail page's large score number is the one that
      // actually proves the fix, so match on its distinct font size.
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == '70' && w.style?.fontSize == 40,
        ),
        findsOneWidget,
      );
      expect(find.text('Strong'), findsOneWidget);
      expect(find.text('Needs work'), findsNothing);
    },
  );
}
