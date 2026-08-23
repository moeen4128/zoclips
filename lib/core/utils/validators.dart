import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.emailRequired;
    if (!_emailRegex.hasMatch(value.trim())) return AppStrings.emailInvalid;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < 8) return AppStrings.passwordTooShort;
    return null;
  }
}
