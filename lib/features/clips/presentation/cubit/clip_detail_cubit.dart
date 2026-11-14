import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/clips_remote_datasource.dart';
import '../../data/models/clip_metadata_model.dart';
import 'clip_detail_state.dart';

class ClipDetailCubit extends Cubit<ClipDetailState> {
  final ClipsRemoteDataSource dataSource;

  ClipDetailCubit(this.dataSource) : super(const ClipDetailState.initial());

  Future<void> fetchDetail({
    required String videoId,
    required String clipId,
  }) async {
    emit(state.copyWith(status: ClipDetailStatus.loading));
    try {
      final pipelineStatus = await dataSource.getPipelineStatus(
        videoId: videoId,
        clipId: clipId,
      );
      final metadata = await dataSource.getClipMetadata(
        videoId: videoId,
        clipId: clipId,
      );
      emit(
        state.copyWith(
          status: ClipDetailStatus.loaded,
          pipelineStatus: pipelineStatus,
          metadata: metadata,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(status: ClipDetailStatus.error, errorMessage: e.message),
      );
    } on NetworkException catch (e) {
      emit(
        state.copyWith(status: ClipDetailStatus.error, errorMessage: e.message),
      );
    } on TimeoutException catch (e) {
      emit(
        state.copyWith(status: ClipDetailStatus.error, errorMessage: e.message),
      );
    } on UnauthorizedException catch (e) {
      emit(
        state.copyWith(status: ClipDetailStatus.error, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ClipDetailStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  /// Kicks off a regeneration job, then polls `GET .../metadata` every 2s
  /// (up to 30s) until its status stops being "pending" and swaps the new
  /// title/description/hashtags in. Throws on failure or timeout so the
  /// caller (which has a BuildContext) can surface it — `isRegenerating`
  /// is always cleared via `finally` so the loading state never sticks.
  Future<void> regenerateMetadata({
    required String videoId,
    required String clipId,
  }) async {
    emit(state.copyWith(isRegenerating: true));
    try {
      await dataSource.regenerateMetadata(videoId: videoId, clipId: clipId);
      final updated = await _pollUntilReady(videoId: videoId, clipId: clipId);
      if (updated == null) {
        throw const TimeoutException(
          'Regeneration is taking longer than usual.',
        );
      }
      emit(state.copyWith(metadata: updated));
    } finally {
      emit(state.copyWith(isRegenerating: false));
    }
  }

  Future<ClipMetadataModel?> _pollUntilReady({
    required String videoId,
    required String clipId,
  }) async {
    for (var attempt = 0; attempt < 15; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      final metadata = await dataSource.getClipMetadata(
        videoId: videoId,
        clipId: clipId,
      );
      if (metadata.status != 'pending') return metadata;
    }
    return null;
  }
}
