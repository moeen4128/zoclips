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
  static const String refreshToken = '$apiPrefix/auth/refresh';
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
  static const String videos = '$apiPrefix/videos';
  static String videoById(String videoId) => '$apiPrefix/videos/$videoId';
  static String videoSave(String videoId) => '$apiPrefix/videos/$videoId/save';
  static String videoClips(String videoId) =>
      '$apiPrefix/videos/$videoId/clips';
  static String clipPipelineStatus(String videoId, String clipId) =>
      '$apiPrefix/videos/$videoId/clips/$clipId/pipeline-status';
  static String clipMetadata(String videoId, String clipId) =>
      '$apiPrefix/videos/$videoId/clips/$clipId/metadata';
  static const String assets = '$apiPrefix/videos/assets';
  static const String storageUsage = '$apiPrefix/videos/storage-usage';
  static const String subscriptionMe = '$apiPrefix/subscription/me';
  static const String videoLanguages = '$apiPrefix/videos/languages';
  static const String brollTemplate = '$apiPrefix/broll/template';
  static const String socialAccounts = '$apiPrefix/social-accounts';
  static const String musicLibrary = '$apiPrefix/music-library';
  static const String brollUploadPresign =
      '$apiPrefix/broll/assets/uploads/presign';
  static const String videoSchedulingSummary =
      '$apiPrefix/videos/scheduling-summary';

  // Headers
  static const String contentType = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer';
}
