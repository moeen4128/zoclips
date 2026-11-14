import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/create_clips/data/datasources/create_clips_remote_datasource.dart';
import 'package:zoclips/features/create_clips/data/models/broll_template_model.dart';
import 'package:zoclips/features/create_clips/data/models/language_model.dart';
import 'package:zoclips/features/create_clips/data/models/music_track_model.dart';
import 'package:zoclips/features/create_clips/data/models/social_account_model.dart';
import 'package:zoclips/features/create_clips/data/models/video_source_metadata_model.dart';
import 'package:zoclips/features/create_clips/presentation/cubit/create_clips_cubit.dart';
import 'package:zoclips/features/create_clips/presentation/cubit/create_clips_state.dart';

const _source = VideoSourceMetadataModel(
  title: 'Some clip',
  authorName: 'Narm Edits',
  providerName: 'Youtube',
  durationSeconds: 8,
);

class _FakeCreateClipsRemoteDataSource implements CreateClipsRemoteDataSource {
  final Object? error;
  final bool youtubeConnected;
  final Object? musicError;
  BrollTemplateModel brollTemplate;
  _FakeCreateClipsRemoteDataSource({
    this.error,
    this.youtubeConnected = true,
    this.musicError,
    this.brollTemplate = const BrollTemplateModel(enabled: false),
  });

  @override
  Future<List<LanguageModel>> getLanguages() async {
    if (error != null) throw error!;
    return const [
      LanguageModel(code: 'en', englishName: 'English', nativeName: 'English'),
      LanguageModel(code: 'ur', englishName: 'Urdu', nativeName: 'اردو'),
    ];
  }

  @override
  Future<BrollTemplateModel> getBrollTemplate() async {
    if (error != null) throw error!;
    return brollTemplate;
  }

  @override
  Future<List<SocialAccountModel>> getSocialAccounts() async {
    if (error != null) throw error!;
    if (!youtubeConnected) return const [];
    return const [
      SocialAccountModel(
        id: 'a1',
        platform: 'youtube',
        channelName: 'My channel',
      ),
    ];
  }

  @override
  Future<List<MusicTrackModel>> getMusicLibrary() async {
    if (musicError != null) throw musicError!;
    return const [
      MusicTrackModel(
        id: 'track-1',
        title: 'Golden Rays',
        artist: 'coruscate',
        durationSeconds: 190,
        previewUrl: 'https://example.com/70070.mp3',
        licenseName: 'Attribution (3.0)',
        licenseUrl: 'http://creativecommons.org/licenses/by/3.0/',
      ),
    ];
  }
}

void main() {
  test(
    'load fetches languages/broll/social accounts and defaults platform',
    () async {
      final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
      addTearDown(cubit.close);

      await cubit.load(
        videoSource: _source,
        sourceUrl: 'https://youtube.com/x',
      );

      expect(cubit.state.status, CreateClipsStatus.loaded);
      expect(cubit.state.languages, hasLength(2));
      expect(cubit.state.canEnableBroll, isFalse);
      expect(cubit.state.isYoutubeConnected, isTrue);
      expect(cubit.state.selectedPlatform, 'youtube');
    },
  );

  test('load emits an error state on failure', () async {
    final cubit = CreateClipsCubit(
      _FakeCreateClipsRemoteDataSource(error: Exception('boom')),
    );
    addTearDown(cubit.close);

    await cubit.load(videoSource: _source, sourceUrl: 'https://youtube.com/x');

    expect(cubit.state.status, CreateClipsStatus.error);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test(
    'setBrollOverlayEnabled is a no-op when the template is not enabled',
    () async {
      final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: _source,
        sourceUrl: 'https://youtube.com/x',
      );

      cubit.setBrollOverlayEnabled(true);

      expect(cubit.state.brollOverlayEnabled, isFalse);
    },
  );

  test(
    'clip count/length custom selection stores the free-text value',
    () async {
      final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: _source,
        sourceUrl: 'https://youtube.com/x',
      );

      cubit.setClipCount(ClipCountOption.custom);
      cubit.setCustomClipCount('7');
      cubit.setClipLength(ClipLengthOption.custom);
      cubit.setCustomClipLength('45s');

      expect(cubit.state.clipCount, ClipCountOption.custom);
      expect(cubit.state.customClipCount, '7');
      expect(cubit.state.clipLength, ClipLengthOption.custom);
      expect(cubit.state.customClipLength, '45s');
    },
  );

  test(
    'setSelectedPlatform ignores platforms other than a connected youtube',
    () async {
      final cubit = CreateClipsCubit(
        _FakeCreateClipsRemoteDataSource(youtubeConnected: false),
      );
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: _source,
        sourceUrl: 'https://youtube.com/x',
      );

      expect(cubit.state.selectedPlatform, isNull);

      cubit.setSelectedPlatform('youtube');
      expect(cubit.state.selectedPlatform, isNull); // not connected — ignored

      cubit.setSelectedPlatform('tiktok');
      expect(cubit.state.selectedPlatform, isNull); // unsupported — ignored
    },
  );

  test('setDailyTime updates the daily publish time fields', () async {
    final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
    addTearDown(cubit.close);
    await cubit.load(videoSource: _source, sourceUrl: 'https://youtube.com/x');

    cubit.setDailyTime(hour: 5, minute: 30, period: 'PM');

    expect(cubit.state.dailyHour, 5);
    expect(cubit.state.dailyMinute, 30);
    expect(cubit.state.dailyPeriod, 'PM');
  });

  group('clipLengthWarning', () {
    const oneMinuteVideo = VideoSourceMetadataModel(
      title: 'A 1 minute video',
      durationSeconds: 60,
    );

    test(
      'warns when 10 clips at up to 90s each exceed a 1-minute video',
      () async {
        final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
        addTearDown(cubit.close);
        await cubit.load(
          videoSource: oneMinuteVideo,
          sourceUrl: 'https://youtube.com/x',
        );

        cubit.setClipCount(ClipCountOption.ten);
        cubit.setClipLength(ClipLengthOption.from60to90);

        expect(
          cubit.state.clipLengthWarning,
          '10 clips at up to 90s each needs 15m 00s, which exceeds the '
          "source video's length of 1m 00s. Reduce the number of clips or "
          'shorten the clip length.',
        );
      },
    );

    test('is null when the selection fits inside the video', () async {
      final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: oneMinuteVideo,
        sourceUrl: 'https://youtube.com/x',
      );

      cubit.setClipCount(ClipCountOption.one);
      cubit.setClipLength(ClipLengthOption.under30);

      expect(cubit.state.clipLengthWarning, isNull);
    });

    test('is null while either side is still Auto', () async {
      final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: oneMinuteVideo,
        sourceUrl: 'https://youtube.com/x',
      );

      cubit.setClipCount(ClipCountOption.ten);
      // clipLength left at the default Auto.

      expect(cubit.state.clipLengthWarning, isNull);
    });

    test('parses a custom "1-2min" length as 120 seconds', () async {
      final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: oneMinuteVideo,
        sourceUrl: 'https://youtube.com/x',
      );

      cubit.setClipCount(ClipCountOption.custom);
      cubit.setCustomClipCount('1');
      cubit.setClipLength(ClipLengthOption.custom);
      cubit.setCustomClipLength('1-2min');

      expect(cubit.state.resolvedMaxClipLengthSeconds, 120);
      expect(cubit.state.clipLengthWarning, isNotNull);
    });
  });

  group('music library', () {
    test(
      'switching Remove copyright music on fetches the library once',
      () async {
        final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
        addTearDown(cubit.close);
        await cubit.load(
          videoSource: _source,
          sourceUrl: 'https://youtube.com/x',
        );

        expect(cubit.state.musicTracks, isEmpty);

        cubit.setRemoveCopyrightMusic(true);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.musicLibraryLoading, isFalse);
        expect(cubit.state.musicTracks, hasLength(1));
        expect(cubit.state.musicTracks.first.title, 'Golden Rays');
      },
    );

    test('emits an error when the music library fails to load', () async {
      final cubit = CreateClipsCubit(
        _FakeCreateClipsRemoteDataSource(musicError: Exception('boom')),
      );
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: _source,
        sourceUrl: 'https://youtube.com/x',
      );

      cubit.setRemoveCopyrightMusic(true);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.musicLibraryLoading, isFalse);
      expect(cubit.state.musicLibraryError, isNotNull);
      expect(cubit.state.musicTracks, isEmpty);
    });

    test('does not re-fetch once tracks are already loaded', () async {
      final cubit = CreateClipsCubit(_FakeCreateClipsRemoteDataSource());
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: _source,
        sourceUrl: 'https://youtube.com/x',
      );

      cubit.setRemoveCopyrightMusic(true);
      await Future<void>.delayed(Duration.zero);
      cubit.setRemoveCopyrightMusic(false);
      cubit.setRemoveCopyrightMusic(true);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.musicTracks, hasLength(1));
    });
  });

  group('B-Roll availability', () {
    test(
      'canEnableBroll is false when enabled but no asset was ever picked',
      () async {
        final cubit = CreateClipsCubit(
          _FakeCreateClipsRemoteDataSource(
            brollTemplate: const BrollTemplateModel(enabled: true),
          ),
        );
        addTearDown(cubit.close);

        await cubit.load(
          videoSource: _source,
          sourceUrl: 'https://youtube.com/x',
        );

        expect(cubit.state.canEnableBroll, isFalse);
      },
    );

    test(
      'canEnableBroll is true once enabled and an asset is active',
      () async {
        final cubit = CreateClipsCubit(
          _FakeCreateClipsRemoteDataSource(
            brollTemplate: const BrollTemplateModel(
              enabled: true,
              activeAsset: 'broll/user-1/overlay.webp',
            ),
          ),
        );
        addTearDown(cubit.close);

        await cubit.load(
          videoSource: _source,
          sourceUrl: 'https://youtube.com/x',
        );

        expect(cubit.state.canEnableBroll, isTrue);
      },
    );

    test('refreshBrollTemplate picks up a template enabled on the B-Roll page '
        'after this cubit already loaded', () async {
      final dataSource = _FakeCreateClipsRemoteDataSource();
      final cubit = CreateClipsCubit(dataSource);
      addTearDown(cubit.close);
      await cubit.load(
        videoSource: _source,
        sourceUrl: 'https://youtube.com/x',
      );
      expect(cubit.state.canEnableBroll, isFalse);

      // Simulate the user enabling + saving a template on the B-Roll page
      // while this cubit's state is still the stale pre-save snapshot.
      dataSource.brollTemplate = const BrollTemplateModel(
        enabled: true,
        activeAsset: 'broll/user-1/overlay.webp',
      );

      await cubit.refreshBrollTemplate();

      expect(cubit.state.canEnableBroll, isTrue);
    });
  });
}
