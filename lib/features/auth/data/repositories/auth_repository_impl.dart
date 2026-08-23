import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/constants/api_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthSessionEntity>> signUp({
    required String email,
    required String password,
  }) => _runSession(
    () => remoteDataSource.signUp(email: email, password: password),
  );

  @override
  Future<Either<Failure, AuthSessionEntity>> signIn({
    required String email,
    required String password,
  }) => _runSession(
    () => remoteDataSource.signIn(email: email, password: password),
  );

  @override
  Future<Either<Failure, Unit>> verifyEmail({required String token}) =>
      _run(() => remoteDataSource.verifyEmail(token: token));

  @override
  Future<Either<Failure, Unit>> resendVerification({required String email}) =>
      _run(() => remoteDataSource.resendVerification(email: email));

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) =>
      _run(() => remoteDataSource.forgotPassword(email: email));

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String password,
  }) => _run(
    () => remoteDataSource.resetPassword(token: token, password: password),
  );

  @override
  String buildGoogleLoginUrl() =>
      '${ApiConstants.baseUrl}${ApiConstants.googleLogin}';
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  Future<Either<Failure, AuthSessionEntity>> _runSession(
    Future<dynamic> Function() call,
  ) async {
    try {
      final session = await call();
      await localDataSource.cacheSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        user: session.user as UserModel,
      );
      return Right(session);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  Future<Either<Failure, Unit>> _run(Future<void> Function() call) async {
    try {
      await call();
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  Failure _mapException(Object e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is TimeoutException) return TimeoutFailure(e.message);
    if (e is CacheException) return CacheFailure(e.message);
    return UnknownFailure(e.toString());
  }
}
