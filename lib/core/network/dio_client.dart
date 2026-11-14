import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

/// Wraps a configured Dio instance. Token attach + centralized error mapping
/// lives here so every datasource stays thin.
class DioClient {
  final Dio dio;
  final Future<String?> Function() getToken;
  final Future<String?> Function() getRefreshToken;
  final Future<void> Function(String accessToken, String? refreshToken)
  onTokensRefreshed;
  final Future<void> Function() onRefreshFailed;

  /// Dedupes concurrent 401s during the same refresh — without this, N
  /// requests failing at once would each fire their own refresh call.
  Future<String?>? _refreshing;

  DioClient({
    required this.getToken,
    required this.getRefreshToken,
    required this.onTokensRefreshed,
    required this.onRefreshFailed,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: ApiConstants.baseUrl,
           connectTimeout: const Duration(
             milliseconds: ApiConstants.connectTimeoutMs,
           ),
           receiveTimeout: const Duration(
             milliseconds: ApiConstants.receiveTimeoutMs,
           ),
           sendTimeout: const Duration(
             milliseconds: ApiConstants.sendTimeoutMs,
           ),
           headers: {'Content-Type': ApiConstants.contentType},
         ),
       ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConstants.authorizationHeader] =
                '${ApiConstants.bearerPrefix} $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          final isRefreshCall =
              e.requestOptions.path == ApiConstants.refreshToken;
          if (e.response?.statusCode == 401 && !isRefreshCall) {
            final newToken = await _refreshAccessToken();
            if (newToken != null) {
              try {
                final options = e.requestOptions;
                options.headers[ApiConstants.authorizationHeader] =
                    '${ApiConstants.bearerPrefix} $newToken';
                final retryResponse = await dio.fetch(options);
                return handler.resolve(retryResponse);
              } on DioException {
                // Retry failed for its own reason — fall through and
                // surface the original 401 below.
              }
            }
          }
          handler.next(e);
        },
      ),
    );

    // Keep logging out of release builds — flip with kDebugMode at call site if desired.
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<String?> _refreshAccessToken() {
    return _refreshing ??= _performRefresh().whenComplete(() {
      _refreshing = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await onRefreshFailed();
      return null;
    }
    try {
      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String?;
      if (newAccessToken == null || newAccessToken.isEmpty) {
        await onRefreshFailed();
        return null;
      }
      await onTokensRefreshed(newAccessToken, data['refresh_token'] as String?);
      return newAccessToken;
    } on DioException {
      await onRefreshFailed();
      return null;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _guard(
      () => dio.post(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _guard(() => dio.get(path, queryParameters: queryParameters));
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _guard(
      () => dio.patch(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _guard(
      () => dio.delete(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<Response> _guard(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Request timed out');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractMessage(e.response?.data) ?? 'Server error';
        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedException(message);
        }
        return ServerException(message, statusCode: statusCode);
      default:
        return ServerException(e.message ?? 'Unknown error');
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // FastAPI validation errors come back as {"detail": [...]} or {"detail": "msg"}
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null)
          return first['msg'].toString();
      }
    }
    return null;
  }
}
