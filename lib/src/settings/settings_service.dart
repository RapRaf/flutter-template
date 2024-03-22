import 'package:flutter/material.dart';
import 'package:flutter_template/store_controller.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    String? themeModeString = await StoreController().getTheme();
    if (themeModeString != null) {
      return themeModeFromString(themeModeString);
    } else {
      return ThemeMode.system;
    }
  }

  Future<String> language() async {
    return await StoreController().getLanguage() ?? 'en,US';
  }

  ThemeMode themeModeFromString(String themeModeString) {
    switch (themeModeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    StoreController().setTheme(theme.toString());
  }

  Future<void> updateLanguage(String language) async {
    StoreController().setLanguage(language);
  }
}
