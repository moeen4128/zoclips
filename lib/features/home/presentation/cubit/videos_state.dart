import 'package:equatable/equatable.dart';
import '../../data/models/video_model.dart';

enum VideosStatus { initial, loading, loaded, error }

/// `card` is one large full-width card per row (the app's original layout);
/// `grid` is a denser fixed 2-column layout.
enum ProjectsViewMode { card, grid }

class VideosState extends Equatable {
  final VideosStatus status;
  final List<VideoModel> items;
  final bool showSavedOnly;
  final ProjectsViewMode viewMode;
  final String? errorMessage;

  /// Video ids with an in-flight save/unsave or delete request — drives the
  /// per-card progress spinner on the save/delete icon buttons.
  final Set<String> savingIds;
  final Set<String> deletingIds;

  const VideosState._({
    required this.status,
    this.items = const [],
    this.showSavedOnly = false,
    this.viewMode = ProjectsViewMode.card,
    this.errorMessage,
    this.savingIds = const {},
    this.deletingIds = const {},
  });

  const VideosState.initial() : this._(status: VideosStatus.initial);

  /// The API has no "saved" filter param (see the Swagger `List Videos`
  /// params: page/page_size/search/source_type only) — so the Saved tab
  /// filters the already-fetched list client-side.
  List<VideoModel> get visibleItems =>
      showSavedOnly ? items.where((v) => v.isSaved).toList() : items;

  VideosState copyWith({
    VideosStatus? status,
    List<VideoModel>? items,
    bool? showSavedOnly,
    ProjectsViewMode? viewMode,
    String? errorMessage,
    Set<String>? savingIds,
    Set<String>? deletingIds,
  }) {
    return VideosState._(
      status: status ?? this.status,
      items: items ?? this.items,
      showSavedOnly: showSavedOnly ?? this.showSavedOnly,
      viewMode: viewMode ?? this.viewMode,
      errorMessage: errorMessage,
      savingIds: savingIds ?? this.savingIds,
      deletingIds: deletingIds ?? this.deletingIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    showSavedOnly,
    viewMode,
    errorMessage,
    savingIds,
    deletingIds,
  ];
}
