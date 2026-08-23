import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationUseCase
    implements UseCase<Unit, ResendVerificationParams> {
  final AuthRepository repository;
  const ResendVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ResendVerificationParams params) {
    return repository.resendVerification(email: params.email);
  }
}

class ResendVerificationParams extends Equatable {
  final String email;
  const ResendVerificationParams({required this.email});

  @override
  List<Object?> get props => [email];
}
