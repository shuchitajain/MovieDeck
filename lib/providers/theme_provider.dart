import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.system});

  bool get isDark => themeMode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  static const _storageKey = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  @override
  ThemeState build() {
    _loadTheme();
    return const ThemeState();
  }

  Future<void> _loadTheme() async {
    final stored = await _storage.read(key: _storageKey);
    if (stored != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => ThemeMode.system,
      );
      state = state.copyWith(themeMode: mode);
    }
  }

  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(themeMode: newMode);
    await _storage.write(key: _storageKey, value: newMode.name);
  }
}
