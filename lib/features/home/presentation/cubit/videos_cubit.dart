import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/videos_remote_datasource.dart';
import 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  final VideosRemoteDataSource dataSource;

  VideosCubit(this.dataSource) : super(const VideosState.initial());

  Future<void> fetchVideos() async {
    emit(state.copyWith(status: VideosStatus.loading));
    try {
      final page = await dataSource.listVideos();
      emit(state.copyWith(status: VideosStatus.loaded, items: page.items));
    } on ServerException catch (e) {
      emit(state.copyWith(status: VideosStatus.error, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(status: VideosStatus.error, errorMessage: e.message));
    } on TimeoutException catch (e) {
      emit(state.copyWith(status: VideosStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: VideosStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void setShowSavedOnly(bool value) =>
      emit(state.copyWith(showSavedOnly: value));

  /// Switches between the single-column card layout and the fixed 2-column
  /// grid — applies to both the All projects and Saved projects tabs.
  void setViewMode(ProjectsViewMode mode) =>
      emit(state.copyWith(viewMode: mode));

  /// `PATCH .../save` — flips the current video's saved flag. Throws on
  /// failure so the caller (which has a BuildContext) can surface it; the
  /// pending id is always cleared via finally so the spinner never sticks.
  Future<void> toggleSaved(String videoId) async {
    final index = state.items.indexWhere((v) => v.id == videoId);
    if (index == -1) return;
    final targetSaved = !state.items[index].isSaved;

    emit(state.copyWith(savingIds: {...state.savingIds, videoId}));
    try {
      final updated = await dataSource.saveVideo(
        videoId: videoId,
        isSaved: targetSaved,
      );
      final items = [...state.items];
      final freshIndex = items.indexWhere((v) => v.id == videoId);
      if (freshIndex != -1) items[freshIndex] = updated;
      emit(state.copyWith(items: items));
    } finally {
      emit(state.copyWith(savingIds: {...state.savingIds}..remove(videoId)));
    }
  }

  /// `DELETE .../{video_id}` — removes the video from the list only once
  /// the backend confirms the delete. Throws on failure so the caller can
  /// surface it.
  Future<void> deleteVideo(String videoId) async {
    emit(state.copyWith(deletingIds: {...state.deletingIds, videoId}));
    try {
      await dataSource.deleteVideo(videoId: videoId);
      final items = state.items.where((v) => v.id != videoId).toList();
      emit(state.copyWith(items: items));
    } finally {
      emit(
        state.copyWith(deletingIds: {...state.deletingIds}..remove(videoId)),
      );
    }
  }
}
