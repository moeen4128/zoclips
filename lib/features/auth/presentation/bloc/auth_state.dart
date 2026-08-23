import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_session_entity.dart';

enum AuthStatus {
  initial,
  loading,
  signUpSuccess,
  signInSuccess,
  forgotPasswordSent,
  resendVerificationSent,
  verifyEmailSuccess,
  verifyEmailFailure,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthSessionEntity? session;
  final String? errorMessage;

  const AuthState._({required this.status, this.session, this.errorMessage});

  const AuthState.initial() : this._(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    AuthSessionEntity? session,
    String? errorMessage,
  }) {
    return AuthState._(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, errorMessage];
}
