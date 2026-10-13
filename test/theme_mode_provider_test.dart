import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/theme/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme preference loads and writes back the selected mode', () async {
    SharedPreferences.setMockInitialValues({themeModePreferenceKey: 'dark'});

    final initialMode = await loadThemeMode();
    final container = ProviderContainer(
      overrides: [
        themeModeProvider.overrideWith(() => ThemeModeController(initialMode)),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);

    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.light);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(themeModePreferenceKey), 'light');
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('unknown theme preference falls back to system', () async {
    SharedPreferences.setMockInitialValues({themeModePreferenceKey: 'sepia'});

    expect(await loadThemeMode(), ThemeMode.system);
  });
}
