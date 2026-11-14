import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/create_clips/data/datasources/create_clips_remote_datasource.dart';
import 'package:zoclips/features/create_clips/data/models/broll_template_model.dart';
import 'package:zoclips/features/create_clips/data/models/language_model.dart';
import 'package:zoclips/features/create_clips/data/models/music_track_model.dart';
import 'package:zoclips/features/create_clips/data/models/social_account_model.dart';
import 'package:zoclips/features/create_clips/data/models/video_source_metadata_model.dart';
import 'package:zoclips/features/create_clips/presentation/cubit/create_clips_cubit.dart';
import 'package:zoclips/features/create_clips/presentation/pages/create_clips_args.dart';
import 'package:zoclips/features/create_clips/presentation/pages/create_clips_page.dart';
import 'package:zoclips/features/home/data/datasources/videos_remote_datasource.dart';
import 'package:zoclips/features/home/data/models/video_model.dart';
import 'package:zoclips/features/home/presentation/widgets/one_click_ai_magic_card.dart';
import 'package:zoclips/injection_container.dart';

class _FakeVideosRemoteDataSource implements VideosRemoteDataSource {
  @override
  Future<VideoSourceMetadataModel> fetchMetadata({required String url}) async {
    return const VideoSourceMetadataModel(title: 'A video', durationSeconds: 8);
  }

  @override
  Future<VideoListPage> listVideos({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? sourceType,
  }) async => const VideoListPage(items: [], total: 0, page: 1, pageSize: 20);

  @override
  Future<VideoModel> saveVideo({
    required String videoId,
    required bool isSaved,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteVideo({required String videoId}) async {}
}

class _FakeCreateClipsRemoteDataSource implements CreateClipsRemoteDataSource {
  @override
  Future<List<LanguageModel>> getLanguages() async => const [];

  @override
  Future<BrollTemplateModel> getBrollTemplate() async =>
      const BrollTemplateModel(enabled: false);

  @override
  Future<List<SocialAccountModel>> getSocialAccounts() async => const [];

  @override
  Future<List<MusicTrackModel>> getMusicLibrary() async => const [];
}

void main() {
  testWidgets('the pasted link clears once you come back via Change Video', (
    tester,
  ) async {
    sl.registerLazySingleton<VideosRemoteDataSource>(
      () => _FakeVideosRemoteDataSource(),
    );
    sl.registerFactory<CreateClipsCubit>(
      () => CreateClipsCubit(_FakeCreateClipsRemoteDataSource()),
    );
    addTearDown(() {
      sl.unregister<VideosRemoteDataSource>();
      sl.unregister<CreateClipsCubit>();
    });

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) =>
              const Scaffold(body: OneClickAiMagicCard()),
        ),
        GoRoute(
          path: '/create-clips',
          name: 'create-clips',
          builder: (context, state) {
            final args = state.extra as CreateClipsArgs;
            return CreateClipsPage(
              videoSource: args.videoSource,
              sourceUrl: args.sourceUrl,
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
    );
    await tester.pump();

    await tester.enterText(
      find.byType(TextField),
      'https://youtube.com/shorts/abc',
    );
    await tester.pump();

    await tester.tap(find.text('Get clips in 1 click'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create clips'), findsOneWidget);

    await tester.tap(find.text('Change Video'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create clips'), findsNothing);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);
  });
}
