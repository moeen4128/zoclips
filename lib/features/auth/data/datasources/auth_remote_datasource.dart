import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> signUp({
    required String email,
    required String password,
  });
  Future<AuthSessionModel> signIn({
    required String email,
    required String password,
  });
  Future<void> verifyEmail({required String token});
  Future<void> resendVerification({required String email});
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String token, required String password});
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  const AuthRemoteDataSourceImpl(this.client);

  @override
  Future<AuthSessionModel> signUp({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      ApiConstants.register,
      data: {'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthSessionModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    await client.post(ApiConstants.verifyEmail, data: {'token': token});
  }

  @override
  Future<void> resendVerification({required String email}) async {
    await client.post(ApiConstants.resendVerification, data: {'email': email});
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await client.post(ApiConstants.forgotPassword, data: {'email': email});
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await client.post(
      ApiConstants.resetPassword,
      data: {'token': token, 'password': password},
    );
  }

  // add to AuthRemoteDataSourceImpl:
  @override
  Future<UserModel> getCurrentUser() async {
    final response = await client.get(ApiConstants.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
