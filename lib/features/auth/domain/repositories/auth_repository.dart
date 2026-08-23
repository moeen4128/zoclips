import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_session_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSessionEntity>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthSessionEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> verifyEmail({required String token});

  Future<Either<Failure, Unit>> resendVerification({required String email});

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String password,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  String buildGoogleLoginUrl();
}
