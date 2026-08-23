import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class AuthSessionEntity extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final UserEntity user;

  const AuthSessionEntity({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
