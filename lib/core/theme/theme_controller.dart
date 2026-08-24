import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the active [ThemeMode] and persists the user's choice. Defaults to
/// [ThemeMode.system] until a saved preference is loaded.
class ThemeController extends ValueNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  final FlutterSecureStorage _storage;

  ThemeController({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(ThemeMode.system);

  Future<void> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return;
    try {
      value = ThemeMode.values.byName(raw);
    } catch (_) {
      // Unknown/corrupt value — keep the system default.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;
    await _storage.write(key: _key, value: mode.name);
  }
}
