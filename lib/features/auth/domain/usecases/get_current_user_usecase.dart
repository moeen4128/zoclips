import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserParams extends Equatable {
  final bool forceRefresh;
  const GetCurrentUserParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class GetCurrentUserUseCase
    implements UseCase<UserEntity, GetCurrentUserParams> {
  final AuthRepository repository;
  const GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GetCurrentUserParams params) {
    return repository.getCurrentUser(forceRefresh: params.forceRefresh);
  }
}
