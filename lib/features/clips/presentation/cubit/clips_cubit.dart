import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/clips_remote_datasource.dart';
import 'clips_state.dart';

class ClipsCubit extends Cubit<ClipsState> {
  final ClipsRemoteDataSource dataSource;

  ClipsCubit(this.dataSource) : super(const ClipsState.initial());

  Future<void> fetchClips(String videoId) async {
    emit(state.copyWith(status: ClipsStatus.loading));
    try {
      final clips = await dataSource.getClips(videoId: videoId);
      emit(state.copyWith(status: ClipsStatus.loaded, clips: clips));
    } on ServerException catch (e) {
      emit(state.copyWith(status: ClipsStatus.error, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(status: ClipsStatus.error, errorMessage: e.message));
    } on TimeoutException catch (e) {
      emit(state.copyWith(status: ClipsStatus.error, errorMessage: e.message));
    } on UnauthorizedException catch (e) {
      emit(state.copyWith(status: ClipsStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: ClipsStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
