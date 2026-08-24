class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://backend.zoclips.com';
  static const String apiPrefix = '/api/v1';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
  static const int sendTimeoutMs = 15000;

  // Auth endpoints
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String verifyEmail = '$apiPrefix/auth/verify_email';
  static const String resendVerification =
      '$apiPrefix/auth/resend_verification';
  static const String forgotPassword = '$apiPrefix/auth/forgot_password';
  static const String resetPassword = '$apiPrefix/auth/reset_password';
  static const String googleLogin = '$apiPrefix/auth/google_login';
  static const String googleCallback = '$apiPrefix/auth/google_callback';
  static const String me = '$apiPrefix/auth/me';

  // Video endpoints
  static const String videoMetadata = '$apiPrefix/videos/metadata';

  // Headers
  static const String contentType = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';
}
