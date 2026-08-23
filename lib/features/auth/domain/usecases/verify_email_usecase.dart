import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase implements UseCase<Unit, VerifyEmailParams> {
  final AuthRepository repository;
  const VerifyEmailUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(VerifyEmailParams params) {
    return repository.verifyEmail(token: params.token);
  }
}

class VerifyEmailParams extends Equatable {
  final String token;
  const VerifyEmailParams({required this.token});

  @override
  List<Object?> get props => [token];
}
