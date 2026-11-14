import 'package:equatable/equatable.dart';
import '../../data/models/broll_template_model.dart';
import '../../data/models/language_model.dart';
import '../../data/models/music_track_model.dart';
import '../../data/models/social_account_model.dart';
import '../../data/models/video_source_metadata_model.dart';

enum CreateClipsStatus { loading, loaded, error }

enum ClipCountOption { auto, one, five, ten, custom }

enum ClipLengthOption { auto, under30, from30to60, from60to90, custom }

enum AiModelOption { proAutoSelect, standard }

enum CaptionWordStyle { multipleWords, oneWordAtATime }

enum CaptionPosition { top, center, bottom }

enum WhenToPublish { now, dailySchedule }

class CreateClipsState extends Equatable {
  final CreateClipsStatus status;
  final String? errorMessage;

  final VideoSourceMetadataModel videoSource;
  final String sourceUrl;

  final List<LanguageModel> languages;
  final BrollTemplateModel? brollTemplate;
  final List<SocialAccountModel> socialAccounts;

  // Clip settings
  final ClipCountOption clipCount;
  final String customClipCount;
  final ClipLengthOption clipLength;
  final String customClipLength;
  final AiModelOption aiModel;
  final CaptionWordStyle captionWordStyle;
  final String languageCode;

  // Quick presets
  final String captionPresetId;
  final CaptionPosition captionPosition;
  final int highlightColorIndex;
  final String aspectRatio;

  // B-Roll
  final bool brollOverlayEnabled;

  // Music
  final bool removeCopyrightMusic;
  final String selectedMusicTrackId;
  final List<MusicTrackModel> musicTracks;
  final bool musicLibraryLoading;
  final String? musicLibraryError;

  // Publish
  final bool autoPublishSchedule;
  final String? selectedPlatform;
  final WhenToPublish whenToPublish;
  final int dailyHour;
  final int dailyMinute;
  final String dailyPeriod;

  const CreateClipsState._({
    required this.status,
    this.errorMessage,
    required this.videoSource,
    required this.sourceUrl,
    this.languages = const [],
    this.brollTemplate,
    this.socialAccounts = const [],
    this.clipCount = ClipCountOption.auto,
    this.customClipCount = '',
    this.clipLength = ClipLengthOption.auto,
    this.customClipLength = '',
    this.aiModel = AiModelOption.proAutoSelect,
    this.captionWordStyle = CaptionWordStyle.multipleWords,
    this.languageCode = 'auto',
    this.captionPresetId = 'none',
    this.captionPosition = CaptionPosition.bottom,
    this.highlightColorIndex = 0,
    this.aspectRatio = '9:16',
    this.brollOverlayEnabled = false,
    this.removeCopyrightMusic = false,
    this.selectedMusicTrackId = 'auto',
    this.musicTracks = const [],
    this.musicLibraryLoading = false,
    this.musicLibraryError,
    this.autoPublishSchedule = false,
    this.selectedPlatform,
    this.whenToPublish = WhenToPublish.now,
    this.dailyHour = 9,
    this.dailyMinute = 0,
    this.dailyPeriod = 'AM',
  });

  const CreateClipsState.initial({
    required VideoSourceMetadataModel videoSource,
    required String sourceUrl,
  }) : this._(
         status: CreateClipsStatus.loading,
         videoSource: videoSource,
         sourceUrl: sourceUrl,
       );

  // Enabled but with no asset picked yet means there's nothing to actually
  // overlay — still point the user at the B-Roll page in that case.
  bool get canEnableBroll =>
      (brollTemplate?.enabled ?? false) &&
      (brollTemplate?.activeAsset?.isNotEmpty ?? false);

  bool get isYoutubeConnected =>
      socialAccounts.any((a) => a.platform == 'youtube');

  /// Null when the count is "Auto" (the AI decides, so there's nothing
  /// fixed to check) or a custom value that isn't a valid number yet.
  int? get resolvedClipCount {
    switch (clipCount) {
      case ClipCountOption.auto:
        return null;
      case ClipCountOption.one:
        return 1;
      case ClipCountOption.five:
        return 5;
      case ClipCountOption.ten:
        return 10;
      case ClipCountOption.custom:
        return int.tryParse(customClipCount.trim());
    }
  }

  /// The longest a single clip can be under the current selection, in
  /// seconds. Null for "Auto" or an unparsable custom value.
  int? get resolvedMaxClipLengthSeconds {
    switch (clipLength) {
      case ClipLengthOption.auto:
        return null;
      case ClipLengthOption.under30:
        return 30;
      case ClipLengthOption.from30to60:
        return 60;
      case ClipLengthOption.from60to90:
        return 90;
      case ClipLengthOption.custom:
        return _parseCustomLengthSeconds(customClipLength);
    }
  }

  static int? _parseCustomLengthSeconds(String text) {
    final numbers = RegExp(
      r'\d+(\.\d+)?',
    ).allMatches(text).map((m) => double.parse(m.group(0)!)).toList();
    if (numbers.isEmpty) return null;
    final maxNumber = numbers.reduce((a, b) => a > b ? a : b);
    final isMinutes = text.toLowerCase().contains('min');
    return (isMinutes ? maxNumber * 60 : maxNumber).round();
  }

  /// Warns when the selected number of clips × max clip length can't
  /// physically fit inside the source video — null when either side is
  /// still "Auto"/unparsed, or when the selection fits.
  String? get clipLengthWarning {
    final count = resolvedClipCount;
    final maxLength = resolvedMaxClipLengthSeconds;
    if (count == null || maxLength == null || count <= 0 || maxLength <= 0) {
      return null;
    }
    final neededSeconds = count * maxLength;
    final videoSeconds = videoSource.durationSeconds.round();
    if (neededSeconds <= videoSeconds) return null;
    return '$count clips at up to ${maxLength}s each needs '
        '${_formatMinSec(neededSeconds)}, which exceeds the source '
        "video's length of ${_formatMinSec(videoSeconds)}. Reduce the "
        'number of clips or shorten the clip length.';
  }

  static String _formatMinSec(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  CreateClipsState copyWith({
    CreateClipsStatus? status,
    String? errorMessage,
    VideoSourceMetadataModel? videoSource,
    List<LanguageModel>? languages,
    BrollTemplateModel? brollTemplate,
    List<SocialAccountModel>? socialAccounts,
    ClipCountOption? clipCount,
    String? customClipCount,
    ClipLengthOption? clipLength,
    String? customClipLength,
    AiModelOption? aiModel,
    CaptionWordStyle? captionWordStyle,
    String? languageCode,
    String? captionPresetId,
    CaptionPosition? captionPosition,
    int? highlightColorIndex,
    String? aspectRatio,
    bool? brollOverlayEnabled,
    bool? removeCopyrightMusic,
    String? selectedMusicTrackId,
    List<MusicTrackModel>? musicTracks,
    bool? musicLibraryLoading,
    String? musicLibraryError,
    bool clearMusicLibraryError = false,
    bool? autoPublishSchedule,
    String? selectedPlatform,
    bool clearSelectedPlatform = false,
    WhenToPublish? whenToPublish,
    int? dailyHour,
    int? dailyMinute,
    String? dailyPeriod,
  }) {
    return CreateClipsState._(
      status: status ?? this.status,
      errorMessage: errorMessage,
      videoSource: videoSource ?? this.videoSource,
      sourceUrl: sourceUrl,
      languages: languages ?? this.languages,
      brollTemplate: brollTemplate ?? this.brollTemplate,
      socialAccounts: socialAccounts ?? this.socialAccounts,
      clipCount: clipCount ?? this.clipCount,
      customClipCount: customClipCount ?? this.customClipCount,
      clipLength: clipLength ?? this.clipLength,
      customClipLength: customClipLength ?? this.customClipLength,
      aiModel: aiModel ?? this.aiModel,
      captionWordStyle: captionWordStyle ?? this.captionWordStyle,
      languageCode: languageCode ?? this.languageCode,
      captionPresetId: captionPresetId ?? this.captionPresetId,
      captionPosition: captionPosition ?? this.captionPosition,
      highlightColorIndex: highlightColorIndex ?? this.highlightColorIndex,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      brollOverlayEnabled: brollOverlayEnabled ?? this.brollOverlayEnabled,
      removeCopyrightMusic: removeCopyrightMusic ?? this.removeCopyrightMusic,
      selectedMusicTrackId: selectedMusicTrackId ?? this.selectedMusicTrackId,
      musicTracks: musicTracks ?? this.musicTracks,
      musicLibraryLoading: musicLibraryLoading ?? this.musicLibraryLoading,
      musicLibraryError: clearMusicLibraryError
          ? null
          : (musicLibraryError ?? this.musicLibraryError),
      autoPublishSchedule: autoPublishSchedule ?? this.autoPublishSchedule,
      selectedPlatform: clearSelectedPlatform
          ? null
          : (selectedPlatform ?? this.selectedPlatform),
      whenToPublish: whenToPublish ?? this.whenToPublish,
      dailyHour: dailyHour ?? this.dailyHour,
      dailyMinute: dailyMinute ?? this.dailyMinute,
      dailyPeriod: dailyPeriod ?? this.dailyPeriod,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    videoSource,
    sourceUrl,
    languages,
    brollTemplate,
    socialAccounts,
    clipCount,
    customClipCount,
    clipLength,
    customClipLength,
    aiModel,
    captionWordStyle,
    languageCode,
    captionPresetId,
    captionPosition,
    highlightColorIndex,
    aspectRatio,
    brollOverlayEnabled,
    removeCopyrightMusic,
    selectedMusicTrackId,
    musicTracks,
    musicLibraryLoading,
    musicLibraryError,
    autoPublishSchedule,
    selectedPlatform,
    whenToPublish,
    dailyHour,
    dailyMinute,
    dailyPeriod,
  ];
}
