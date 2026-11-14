import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  ProfileCubit({required this.getCurrentUserUseCase})
    : super(const ProfileState.initial());

  /// Serves the cached profile when available — Settings and the Profile
  /// tab each create their own ProfileCubit, so without this every visit
  /// would hit `/auth/me` again. Pass [forceRefresh] for an explicit reload.
  Future<void> fetchProfile({bool forceRefresh = false}) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await getCurrentUserUseCase(
      GetCurrentUserParams(forceRefresh: forceRefresh),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(state.copyWith(status: ProfileStatus.loaded, user: user)),
    );
  }
}
