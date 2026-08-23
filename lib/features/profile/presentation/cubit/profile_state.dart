import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const ProfileState._({required this.status, this.user, this.errorMessage});

  const ProfileState.initial() : this._(status: ProfileStatus.initial);

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return ProfileState._(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
