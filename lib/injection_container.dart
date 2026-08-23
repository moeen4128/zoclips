import 'package:get_it/get_it.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/resend_verification_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/verify_email_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Local storage (init hive box before app runs — see main.dart)
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // Network
  sl.registerLazySingleton<DioClient>(
    () => DioClient(getToken: () => sl<AuthLocalDataSource>().getToken()),
  );

  // Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // auth
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => ProfileCubit(getCurrentUserUseCase: sl()));

  // Usecases
  sl.registerLazySingleton(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => ResendVerificationUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));

  // Bloc — factory, new instance per screen
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      verifyEmailUseCase: sl(),
      resendVerificationUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );
}
