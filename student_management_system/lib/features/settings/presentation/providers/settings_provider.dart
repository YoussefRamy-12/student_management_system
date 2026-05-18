import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main');
});

class SettingsState {
  final ThemeMode themeMode;
  final String language; // 'ar' or 'en'
  final String serverUrl;

  SettingsState({
    required this.themeMode,
    required this.language,
    required this.serverUrl,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    String? serverUrl,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _themeKey = 'settings_theme_mode';
  static const _langKey = 'settings_language';
  static const _serverUrlKey = 'settings_server_url';
  static const _defaultServerUrl =
      'https://script.google.com/macros/s/AKfycbyfLQ5RAz9sy2ztz3qOeS21vIrBqpMDfdUt5lhfDygWW8MTjFf7xrwXXf4sdAmNPoK_pg/exec';

  late SharedPreferences _prefs;

  @override
  SettingsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);

    final themeStr = _prefs.getString(_themeKey) ?? 'light';
    final themeMode = themeStr == 'dark'
        ? ThemeMode.dark
        : (themeStr == 'system' ? ThemeMode.system : ThemeMode.light);

    final language = _prefs.getString(_langKey) ?? 'ar';
    final serverUrl = _prefs.getString(_serverUrlKey) ?? _defaultServerUrl;

    return SettingsState(
      themeMode: themeMode,
      language: language,
      serverUrl: serverUrl,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final themeStr = mode == ThemeMode.dark
        ? 'dark'
        : (mode == ThemeMode.system ? 'system' : 'light');
    await _prefs.setString(_themeKey, themeStr);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLanguage(String lang) async {
    await _prefs.setString(_langKey, lang);
    state = state.copyWith(language: lang);
  }

  Future<void> setServerUrl(String url) async {
    final trimmedUrl = url.trim();
    await _prefs.setString(_serverUrlKey, trimmedUrl);
    state = state.copyWith(serverUrl: trimmedUrl);
  }

  Future<void> resetServerUrl() async {
    await _prefs.setString(_serverUrlKey, _defaultServerUrl);
    state = state.copyWith(serverUrl: _defaultServerUrl);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
