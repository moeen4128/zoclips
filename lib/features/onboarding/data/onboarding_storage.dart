import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks whether the first-run onboarding flow has been shown. [load] must
/// complete before the router is built so [hasSeenOnboarding] can be read
/// synchronously when deciding the initial route.
class OnboardingStorage {
  static const _key = 'has_seen_onboarding';

  final FlutterSecureStorage _storage;
  bool _hasSeenOnboarding = false;

  OnboardingStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> load() async {
    final raw = await _storage.read(key: _key);
    _hasSeenOnboarding = raw == 'true';
  }

  Future<void> markSeen() async {
    _hasSeenOnboarding = true;
    await _storage.write(key: _key, value: 'true');
  }
}
