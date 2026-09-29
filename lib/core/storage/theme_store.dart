import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's theme choice. `system` is the default so a fresh
/// install follows the OS appearance until the user overrides it.
class ThemeStore {
  ThemeStore({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  static const String _key = 'theme_mode';

  /// Reads the stored choice. Safe to call synchronously at startup because
  /// [SharedPreferences] is already in memory by then.
  ThemeMode read() {
    final stored = _prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> write(ThemeMode mode) => _prefs.setString(_key, mode.name);
}
