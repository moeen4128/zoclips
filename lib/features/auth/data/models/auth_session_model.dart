import '../../domain/entities/auth_session_entity.dart';
import 'user_model.dart';

class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({
    required super.accessToken,
    super.refreshToken,
    required UserModel super.user,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      user: UserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
