import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final hiveDb = ref.watch(hiveDatabaseProvider);
    final savedMode = hiveDb.getThemeMode();
    return _parseThemeMode(savedMode);
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final hiveDb = ref.read(hiveDatabaseProvider);
    hiveDb.saveThemeMode(_themeModeToString(mode));
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.system);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  ThemeMode _parseThemeMode(String modeStr) {
    switch (modeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
