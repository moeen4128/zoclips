class AppStrings {
  AppStrings._();

  static const String appName = 'Zoclips';

  // Sign in
  static const String welcomeBack = 'Welcome back';
  static const String signInSubtitle = 'Sign in to continue editing your clips';
  static const String continueWithGoogle = 'Google';
  static const String or = 'Or';
  static const String email = 'Email';
  static const String emailHint = 'you@example.com';
  static const String password = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String forgotPassword = 'Forgot password?';
  static const String signIn = 'Sign in';
  static const String noAccount = "Don't have an account? ";
  static const String createOne = 'Create one';

  // Sign up
  static const String createAccount = 'Create your account';
  static const String signUpSubtitle =
      'Start turning long videos into viral clips.';
  static const String createAccountBtn = 'Create account';
  static const String termsPrefix = 'By continuing, you agree to our ';
  static const String termsOfService = 'Terms of Service';
  static const String and = ' and ';
  static const String privacyPolicy = 'Privacy Policy';
  static const String dot = '.';
  static const String haveAccount = 'Already have an account? ';

  // Forgot password
  static const String forgotPasswordTitle = 'Forgot password?';
  static const String forgotPasswordSubtitle =
      "Enter your email and we'll send you a reset link.";
  static const String sendResetLink = 'Send reset link';
  static const String backToSignIn = 'Back to sign in';

  // Verify email
  static const String verifyEmailTitle = 'Verify your email';
  static const String verifyEmailSubtitlePrefix =
      'We sent a verification link to ';
  static const String verifyEmailSubtitleSuffix =
      '. Click it to activate your account.';
  static const String resendEmail = 'Resend email';

  // Email verified / failed
  static const String emailVerifiedTitle = 'Email verified';
  static const String emailVerifiedSubtitle =
      'Your account is active. Taking you to your dashboard...';
  static const String verificationFailedTitle = 'Verification failed';
  static const String invalidOrExpiredToken = 'Invalid or expired token';

  // Validation
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 8 characters';

  // Generic errors
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String noInternet = 'No internet connection';
  static const String serverError = 'Server error, please try again later';
  static const String requestTimeout = 'Request timed out';
}
