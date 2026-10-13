import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers.dart';
import 'domain/recording_repository.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/benchmark_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/library_screen.dart';
import 'screens/models_screen.dart';
import 'screens/recorder_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/theme_mode_provider.dart';

final recordingRepositoryProvider = Provider<RecordingRepository>(
  (ref) => RecordingRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(recordingsDirectoryProvider),
  ),
);

final recordingsProvider = StreamProvider(
  (ref) => ref.watch(recordingRepositoryProvider).watchRecordings(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LibraryScreen()),
      GoRoute(
        path: '/record',
        builder: (context, state) => const RecorderScreen(),
      ),
      GoRoute(
        path: '/recording/:id',
        builder: (context, state) => DetailScreen(
          recordingId: state.pathParameters['id']!,
          initialPositionMs: int.tryParse(state.uri.queryParameters['t'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/models',
        builder: (context, state) => const ModelsScreen(),
      ),
      GoRoute(
        path: '/settings/benchmark',
        builder: (context, state) => const BenchmarkScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class ReXorderApp extends ConsumerWidget {
  const ReXorderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF345C50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F2),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF345C50),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ref.watch(themeModeProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
