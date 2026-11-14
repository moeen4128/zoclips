class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String signIn = 'sign-in';
  static const String signUp = 'sign-up';
  static const String forgotPassword = 'forgot-password';
  static const String verifyEmail = 'verify-email';
  static const String emailVerifiedResult = 'email-verified-result';
  static const String settings = 'settings';
  static const String home = 'home';
  static const String clips = 'clips';
  static const String clipDetail = 'clip-detail';
  static const String createClips = 'create-clips';
  static const String brollTemplate = 'broll-template';
}

class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String emailVerifiedResult = '/verify-result';
  static const String settings = '/settings';
  static const String home = '/home';
  static const String clips = '/videos/:videoId/clips';
  static const String clipDetail = '/videos/:videoId/clips/:clipId';
  static const String createClips = '/create-clips';
  static const String brollTemplate = '/broll-template';
}
