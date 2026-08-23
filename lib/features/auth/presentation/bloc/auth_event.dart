import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SignUpSubmitted extends AuthEvent {
  final String email;
  final String password;
  const SignUpSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SignInSubmitted extends AuthEvent {
  final String email;
  final String password;
  const SignInSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;
  const ForgotPasswordSubmitted({required this.email});
  @override
  List<Object?> get props => [email];
}

class ResendVerificationSubmitted extends AuthEvent {
  final String email;
  const ResendVerificationSubmitted({required this.email});
  @override
  List<Object?> get props => [email];
}

class VerifyEmailSubmitted extends AuthEvent {
  final String token;
  const VerifyEmailSubmitted({required this.token});
  @override
  List<Object?> get props => [token];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String token;
  final String password;
  const ResetPasswordSubmitted({required this.token, required this.password});
  @override
  List<Object?> get props => [token, password];
}

/// Clears status/error back to initial — call when leaving a screen or
/// dismissing an error, so a stale failure doesn't leak into the next form.
class AuthStatusReset extends AuthEvent {
  const AuthStatusReset();
}
