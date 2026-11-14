import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zoclips/core/error/failures.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:zoclips/features/auth/data/models/user_model.dart';
import 'package:zoclips/features/auth/domain/entities/auth_session_entity.dart';
import 'package:zoclips/features/auth/domain/entities/user_entity.dart';
import 'package:zoclips/features/auth/domain/repositories/auth_repository.dart';
import 'package:zoclips/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:zoclips/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:zoclips/features/profile/presentation/pages/profile_page.dart';
import 'package:zoclips/injection_container.dart';

const _user = UserEntity(
  id: 'u1',
  email: 'shahzad@zoclips.com',
  isVerified: true,
  name: 'Shahzad',
);

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser({
    bool forceRefresh = false,
  }) async => const Right(_user);

  @override
  Future<Either<Failure, AuthSessionEntity>> signUp({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthSessionEntity>> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> verifyEmail({required String token}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> resendVerification({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String password,
  }) => throw UnimplementedError();

  @override
  String buildGoogleLoginUrl() => throw UnimplementedError();
}

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  bool cleared = false;

  @override
  Future<void> clearSession() async => cleared = true;

  @override
  Future<String?> getToken() async => 'token';

  @override
  Future<String?> getRefreshToken() async => 'refresh';

  @override
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {}

  @override
  Future<void> cacheSession({
    required String accessToken,
    String? refreshToken,
    required UserModel user,
  }) async {}

  @override
  Future<UserModel?> getCachedUser() async => null;

  @override
  Future<void> cacheUser(UserModel user) async {}
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const Scaffold(body: ProfilePage()),
      ),
      GoRoute(
        path: '/broll-template',
        name: 'broll-template',
        builder: (context, state) =>
            const Scaffold(body: Text('B-Roll Template Page')),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) =>
            const Scaffold(body: Text('Settings Page')),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const Scaffold(body: Text('Sign In Page')),
      ),
    ],
  );
}

void main() {
  late _FakeAuthLocalDataSource authLocal;

  setUp(() {
    authLocal = _FakeAuthLocalDataSource();
    sl.registerFactory<ProfileCubit>(
      () => ProfileCubit(
        getCurrentUserUseCase: GetCurrentUserUseCase(_FakeAuthRepository()),
      ),
    );
    sl.registerLazySingleton<AuthLocalDataSource>(() => authLocal);
  });

  tearDown(() {
    sl.unregister<ProfileCubit>();
    sl.unregister<AuthLocalDataSource>();
  });

  testWidgets('shows the loaded profile and section menus', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.darkTheme,
        routerConfig: _buildRouter(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shahzad'), findsOneWidget);
    expect(find.text('shahzad@zoclips.com'), findsOneWidget);
    expect(find.text('B-Roll template'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });

  testWidgets('tapping B-Roll template navigates to the broll-template route', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.darkTheme,
        routerConfig: _buildRouter(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('B-Roll template'));
    await tester.pumpAndSettle();

    expect(find.text('B-Roll Template Page'), findsOneWidget);
  });

  testWidgets('tapping Settings navigates to the settings route', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.darkTheme,
        routerConfig: _buildRouter(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings Page'), findsOneWidget);
  });

  testWidgets('log out requires confirmation then clears the session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.darkTheme,
        routerConfig: _buildRouter(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);

    // Cancel first — should not clear the session or navigate away.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(authLocal.cleared, isFalse);
    expect(find.text('Shahzad'), findsOneWidget);

    // Confirm this time.
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();

    expect(authLocal.cleared, isTrue);
    expect(find.text('Sign In Page'), findsOneWidget);
  });
}
