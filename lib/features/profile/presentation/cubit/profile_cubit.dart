import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  ProfileCubit({required this.getCurrentUserUseCase})
    : super(const ProfileState.initial());

  Future<void> fetchProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await getCurrentUserUseCase(const NoParams());
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
