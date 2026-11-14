import 'package:get_it/get_it.dart';
import 'core/network/dio_client.dart';
import 'core/theme/theme_controller.dart';
import 'features/onboarding/data/onboarding_storage.dart';
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
import 'features/assets/data/datasources/assets_remote_datasource.dart';
import 'features/assets/presentation/cubit/assets_cubit.dart';
import 'features/broll/data/datasources/broll_remote_datasource.dart';
import 'features/broll/presentation/cubit/broll_template_cubit.dart';
import 'features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'features/clips/data/datasources/clips_remote_datasource.dart';
import 'features/clips/presentation/cubit/clip_detail_cubit.dart';
import 'features/clips/presentation/cubit/clips_cubit.dart';
import 'features/create_clips/data/datasources/create_clips_remote_datasource.dart';
import 'features/create_clips/presentation/cubit/create_clips_cubit.dart';
import 'features/home/data/datasources/videos_remote_datasource.dart';
import 'features/home/presentation/cubit/videos_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Local storage (init hive box before app runs — see main.dart)
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  sl.registerLazySingleton(() => ThemeController());
  sl.registerLazySingleton(() => OnboardingStorage());

  // Network
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      getToken: () => sl<AuthLocalDataSource>().getToken(),
      getRefreshToken: () => sl<AuthLocalDataSource>().getRefreshToken(),
      onTokensRefreshed: (accessToken, refreshToken) =>
          sl<AuthLocalDataSource>().updateTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
      onRefreshFailed: () => sl<AuthLocalDataSource>().clearSession(),
    ),
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

  // home
  sl.registerLazySingleton<VideosRemoteDataSource>(
    () => VideosRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerFactory(() => VideosCubit(sl<VideosRemoteDataSource>()));

  // clips
  sl.registerLazySingleton<ClipsRemoteDataSource>(
    () => ClipsRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerFactory(() => ClipsCubit(sl<ClipsRemoteDataSource>()));
  sl.registerFactory(() => ClipDetailCubit(sl<ClipsRemoteDataSource>()));

  // assets
  sl.registerLazySingleton<AssetsRemoteDataSource>(
    () => AssetsRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerFactory(() => AssetsCubit(sl<AssetsRemoteDataSource>()));

  // create clips
  sl.registerLazySingleton<CreateClipsRemoteDataSource>(
    () => CreateClipsRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerFactory(() => CreateClipsCubit(sl<CreateClipsRemoteDataSource>()));

  // broll template
  sl.registerLazySingleton<BrollRemoteDataSource>(
    () => BrollRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerFactory(() => BrollTemplateCubit(sl<BrollRemoteDataSource>()));

  // calendar
  sl.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSourceImpl(sl<DioClient>()),
  );

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
