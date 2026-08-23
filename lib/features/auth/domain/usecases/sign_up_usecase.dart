import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<AuthSessionEntity, SignUpParams> {
  final AuthRepository repository;
  const SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, AuthSessionEntity>> call(SignUpParams params) {
    return repository.signUp(email: params.email, password: params.password);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  const SignUpParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
