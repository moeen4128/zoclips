import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/create_clips/data/datasources/create_clips_remote_datasource.dart';
import 'package:zoclips/features/create_clips/data/models/broll_template_model.dart';
import 'package:zoclips/features/create_clips/data/models/language_model.dart';
import 'package:zoclips/features/create_clips/data/models/music_track_model.dart';
import 'package:zoclips/features/create_clips/data/models/social_account_model.dart';
import 'package:zoclips/features/create_clips/data/models/video_source_metadata_model.dart';
import 'package:zoclips/features/create_clips/presentation/cubit/create_clips_cubit.dart';
import 'package:zoclips/features/create_clips/presentation/pages/create_clips_page.dart';
import 'package:zoclips/injection_container.dart';

const _source = VideoSourceMetadataModel(
  title: 'Nashtar | Full OST | Shani Arshad',
  authorName: 'Narm Edits',
  providerName: 'Youtube',
  durationSeconds: 8,
);

class _FakeCreateClipsRemoteDataSource implements CreateClipsRemoteDataSource {
  @override
  Future<List<LanguageModel>> getLanguages() async => const [
    LanguageModel(code: 'en', englishName: 'English', nativeName: 'English'),
  ];

  @override
  Future<BrollTemplateModel> getBrollTemplate() async =>
      const BrollTemplateModel(enabled: false);

  @override
  Future<List<SocialAccountModel>> getSocialAccounts() async => const [
    SocialAccountModel(
      id: 'a1',
      platform: 'youtube',
      channelName: 'My channel',
    ),
  ];

  @override
  Future<List<MusicTrackModel>> getMusicLibrary() async => const [];
}

Future<void> _pump(WidgetTester tester) async {
  sl.registerFactory<CreateClipsCubit>(
    () => CreateClipsCubit(_FakeCreateClipsRemoteDataSource()),
  );
  addTearDown(() => sl.unregister<CreateClipsCubit>());

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: const CreateClipsPage(
        videoSource: _source,
        sourceUrl: 'https://youtube.com/x',
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('shows the fetched video source and clip settings once loaded', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Create clips'), findsOneWidget);
    expect(find.text('Nashtar | Full OST | Shani Arshad'), findsOneWidget);
    expect(find.text('Narm Edits · Youtube'), findsOneWidget);
    expect(find.text('Change Video'), findsOneWidget);
    expect(find.text('Get clips in 1 click'), findsOneWidget);
  });

  testWidgets('Change Video pops the page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  sl.registerFactory<CreateClipsCubit>(
                    () => CreateClipsCubit(_FakeCreateClipsRemoteDataSource()),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateClipsPage(
                        videoSource: _source,
                        sourceUrl: 'https://youtube.com/x',
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    addTearDown(() => sl.unregister<CreateClipsCubit>());

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Create clips'), findsOneWidget);

    await tester.tap(find.text('Change Video'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create clips'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
