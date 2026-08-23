import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/resend_verification_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResendVerificationUseCase resendVerificationUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.verifyEmailUseCase,
    required this.resendVerificationUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
  }) : super(const AuthState.initial()) {
    on<SignUpSubmitted>(_onSignUp);
    on<SignInSubmitted>(_onSignIn);
    on<ForgotPasswordSubmitted>(_onForgotPassword);
    on<ResendVerificationSubmitted>(_onResendVerification);
    on<VerifyEmailSubmitted>(_onVerifyEmail);
    on<ResetPasswordSubmitted>(_onResetPassword);
    on<AuthStatusReset>((event, emit) => emit(const AuthState.initial()));
  }

  Future<void> _onSignUp(SignUpSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await signUpUseCase(
      SignUpParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (session) => emit(
        state.copyWith(status: AuthStatus.signUpSuccess, session: session),
      ),
    );
  }

  Future<void> _onSignIn(SignInSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (session) => emit(
        state.copyWith(status: AuthStatus.signInSuccess, session: session),
      ),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: AuthStatus.forgotPasswordSent)),
    );
  }

  Future<void> _onResendVerification(
    ResendVerificationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await resendVerificationUseCase(
      ResendVerificationParams(email: event.email),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: AuthStatus.resendVerificationSent)),
    );
  }

  Future<void> _onVerifyEmail(
    VerifyEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await verifyEmailUseCase(
      VerifyEmailParams(token: event.token),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.verifyEmailFailure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: AuthStatus.verifyEmailSuccess)),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await resetPasswordUseCase(
      ResetPasswordParams(token: event.token, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: AuthStatus.initial)),
    );
  }
}
