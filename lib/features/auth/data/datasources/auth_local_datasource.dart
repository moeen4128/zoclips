import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheSession({
    required String accessToken,
    String? refreshToken,
    required UserModel user,
  });
  Future<String?> getToken();
  Future<UserModel?> getCachedUser();
  Future<void> clearSession();
}

/// Uses flutter_secure_storage — backed by Keychain on iOS and
/// EncryptedSharedPreferences/Keystore on Android, so the access token
/// never sits in plain-text prefs.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'cached_user';

  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  @override
  Future<void> cacheSession({
    required String accessToken,
    String? refreshToken,
    required UserModel user,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  @override
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  @override
  Future<UserModel?> getCachedUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
}
