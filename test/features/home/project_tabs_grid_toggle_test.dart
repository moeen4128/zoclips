import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/create_clips/data/models/video_source_metadata_model.dart';
import 'package:zoclips/features/home/data/datasources/videos_remote_datasource.dart';
import 'package:zoclips/features/home/data/models/video_model.dart';
import 'package:zoclips/features/home/presentation/cubit/videos_cubit.dart';
import 'package:zoclips/features/home/presentation/widgets/project_tabs.dart';
import 'package:zoclips/features/home/presentation/widgets/projects_grid.dart';

class _FakeVideosRemoteDataSource implements VideosRemoteDataSource {
  @override
  Future<VideoSourceMetadataModel> fetchMetadata({required String url}) async {
    return const VideoSourceMetadataModel(title: 'Video', durationSeconds: 0);
  }

  @override
  Future<VideoListPage> listVideos({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? sourceType,
  }) async {
    return VideoListPage(
      items: List.generate(
        4,
        (i) => VideoModel(
          id: '$i',
          title: 'Project $i',
          thumbnailUrl: null,
          status: 'completed',
          durationSeconds: 90,
          isSaved: i == 0, // at least one item for the Saved projects tab
          createdAt: DateTime.now(),
          sourceType: 'url',
        ),
      ),
      total: 4,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  Future<VideoModel> saveVideo({
    required String videoId,
    required bool isSaved,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteVideo({required String videoId}) async {}
}

Future<void> _pumpApp(WidgetTester tester, VideosCubit cubit) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: BlocProvider.value(
        value: cubit,
        child: const Scaffold(
          body: Column(
            children: [
              ProjectTabs(),
              Expanded(child: ProjectsGrid()),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'tapping the grid icon switches to a fixed 2-column grid, tapping the '
    'card icon switches back',
    (tester) async {
      final cubit = VideosCubit(_FakeVideosRemoteDataSource());
      await cubit.fetchVideos();
      addTearDown(cubit.close);

      await _pumpApp(tester, cubit);
      await tester.pump();

      // Card view is the default — one full-width card per row, regardless
      // of screen width (not a width-driven multi-column grid).
      final gridBefore = tester.widget<GridView>(find.byType(GridView));
      final delegateBefore =
          gridBefore.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegateBefore.crossAxisCount, 1);

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pump();

      final gridAfter = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridAfter.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);

      await tester.tap(find.byIcon(Icons.view_agenda_rounded));
      await tester.pump();
      final gridReverted = tester.widget<GridView>(find.byType(GridView));
      final delegateReverted =
          gridReverted.gridDelegate
              as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegateReverted.crossAxisCount, 1);
    },
  );

  testWidgets('the grid view applies to the Saved projects tab too', (
    tester,
  ) async {
    final cubit = VideosCubit(_FakeVideosRemoteDataSource());
    await cubit.fetchVideos();
    addTearDown(cubit.close);

    await _pumpApp(tester, cubit);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.tap(find.text('Saved projects'));
    await tester.pump();

    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(
      (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      2,
    );
  });

  testWidgets(
    'the two tab pills plus both view-mode icons do not overflow on a '
    'narrow phone width',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640); // narrowest common
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cubit = VideosCubit(_FakeVideosRemoteDataSource());
      await cubit.fetchVideos();
      addTearDown(cubit.close);

      await _pumpApp(tester, cubit);
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
