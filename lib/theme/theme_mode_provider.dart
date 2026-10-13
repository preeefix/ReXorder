import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const themeModePreferenceKey = 'theme_mode';

ThemeMode parseThemeMode(String? value) => ThemeMode.values.firstWhere(
  (mode) => mode.name == value,
  orElse: () => ThemeMode.system,
);

Future<ThemeMode> loadThemeMode() async {
  final preferences = await SharedPreferences.getInstance();
  return parseThemeMode(preferences.getString(themeModePreferenceKey));
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  ThemeModeController([this.initialMode = ThemeMode.system]);

  final ThemeMode initialMode;

  @override
  ThemeMode build() => initialMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(themeModePreferenceKey, themeMode.name);
  }
}
