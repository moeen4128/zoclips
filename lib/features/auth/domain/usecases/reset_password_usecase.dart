import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<Unit, ResetPasswordParams> {
  final AuthRepository repository;
  const ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      token: params.token,
      password: params.password,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String token;
  final String password;
  const ResetPasswordParams({required this.token, required this.password});

  @override
  List<Object?> get props => [token, password];
}
