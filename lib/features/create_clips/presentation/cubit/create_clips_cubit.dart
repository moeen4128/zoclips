import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/create_clips_remote_datasource.dart';
import '../../data/models/video_source_metadata_model.dart';
import 'create_clips_state.dart';

class CreateClipsCubit extends Cubit<CreateClipsState> {
  final CreateClipsRemoteDataSource dataSource;

  CreateClipsCubit(this.dataSource)
    : super(
        CreateClipsState.initial(
          videoSource: const VideoSourceMetadataModel(
            title: '',
            durationSeconds: 0,
          ),
          sourceUrl: '',
        ),
      );

  Future<void> load({
    required VideoSourceMetadataModel videoSource,
    required String sourceUrl,
  }) async {
    emit(
      CreateClipsState.initial(videoSource: videoSource, sourceUrl: sourceUrl),
    );
    try {
      // Sequential, not concurrent — concurrent futures that are abandoned
      // after an earlier one throws become unhandled-error zone warnings.
      final languages = await dataSource.getLanguages();
      final broll = await dataSource.getBrollTemplate();
      final accounts = await dataSource.getSocialAccounts();
      emit(
        state.copyWith(
          status: CreateClipsStatus.loaded,
          languages: languages,
          brollTemplate: broll,
          socialAccounts: accounts,
          selectedPlatform: accounts.any((a) => a.platform == 'youtube')
              ? 'youtube'
              : null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CreateClipsStatus.error,
          errorMessage: 'Could not load clip settings. Please try again.',
        ),
      );
    }
  }

  void setClipCount(ClipCountOption option) =>
      emit(state.copyWith(clipCount: option));

  void setCustomClipCount(String value) =>
      emit(state.copyWith(customClipCount: value));

  void setClipLength(ClipLengthOption option) =>
      emit(state.copyWith(clipLength: option));

  void setCustomClipLength(String value) =>
      emit(state.copyWith(customClipLength: value));

  void setAiModel(AiModelOption option) =>
      emit(state.copyWith(aiModel: option));

  void setCaptionWordStyle(CaptionWordStyle style) =>
      emit(state.copyWith(captionWordStyle: style));

  void setLanguageCode(String code) => emit(state.copyWith(languageCode: code));

  void setCaptionPreset(String id) => emit(state.copyWith(captionPresetId: id));

  void setCaptionPosition(CaptionPosition position) =>
      emit(state.copyWith(captionPosition: position));

  void setHighlightColorIndex(int index) =>
      emit(state.copyWith(highlightColorIndex: index));

  void setAspectRatio(String ratio) => emit(state.copyWith(aspectRatio: ratio));

  void setBrollOverlayEnabled(bool enabled) {
    if (!state.canEnableBroll) return;
    emit(state.copyWith(brollOverlayEnabled: enabled));
  }

  /// Re-checks whether B-Roll is usable now — called after coming back from
  /// the B-Roll page, since saving a template there happens outside this
  /// cubit entirely.
  Future<void> refreshBrollTemplate() async {
    try {
      final broll = await dataSource.getBrollTemplate();
      emit(state.copyWith(brollTemplate: broll));
    } catch (_) {
      // Non-fatal — the toggle just stays locked with the stale state.
    }
  }

  void setRemoveCopyrightMusic(bool enabled) {
    emit(state.copyWith(removeCopyrightMusic: enabled));
    if (enabled && state.musicTracks.isEmpty && !state.musicLibraryLoading) {
      loadMusicLibrary();
    }
  }

  Future<void> loadMusicLibrary() async {
    emit(
      state.copyWith(musicLibraryLoading: true, clearMusicLibraryError: true),
    );
    try {
      final tracks = await dataSource.getMusicLibrary();
      emit(state.copyWith(musicTracks: tracks, musicLibraryLoading: false));
    } catch (_) {
      emit(
        state.copyWith(
          musicLibraryLoading: false,
          musicLibraryError: 'Could not load background music. Try again.',
        ),
      );
    }
  }

  void setSelectedMusicTrack(String id) =>
      emit(state.copyWith(selectedMusicTrackId: id));

  void setAutoPublishSchedule(bool enabled) => emit(
    state.copyWith(
      autoPublishSchedule: enabled,
      selectedPlatform: enabled && state.selectedPlatform == null
          ? (state.isYoutubeConnected ? 'youtube' : null)
          : state.selectedPlatform,
    ),
  );

  void setSelectedPlatform(String platform) {
    if (platform != 'youtube' || !state.isYoutubeConnected) return;
    emit(state.copyWith(selectedPlatform: platform));
  }

  void setWhenToPublish(WhenToPublish value) =>
      emit(state.copyWith(whenToPublish: value));

  void setDailyTime({
    required int hour,
    required int minute,
    required String period,
  }) => emit(
    state.copyWith(dailyHour: hour, dailyMinute: minute, dailyPeriod: period),
  );
}
