import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers.dart';
import 'domain/recording_repository.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/benchmark_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/library_screen.dart';
import 'screens/models_screen.dart';
import 'screens/people_screen.dart';
import 'screens/recorder_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'processing/transcription_queue.dart';
import 'theme/theme_mode_provider.dart';

final recordingRepositoryProvider = Provider<RecordingRepository>(
  (ref) => RecordingRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(recordingsDirectoryProvider),
    recordingStorage: ref.watch(recordingStorageProvider),
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
        path: '/recording/:id/compare',
        builder: (context, state) => CompareScreen(
          recordingId: state.pathParameters['id']!,
          runA: state.uri.queryParameters['a'],
          runB: state.uri.queryParameters['b'],
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
      GoRoute(
        path: '/settings/people',
        builder: (context, state) => const PeopleScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class ReXorderApp extends ConsumerStatefulWidget {
  const ReXorderApp({super.key});

  @override
  ConsumerState<ReXorderApp> createState() => _ReXorderAppState();
}

class _ReXorderAppState extends ConsumerState<ReXorderApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_refreshStorageAndQueue());
  }

  Future<void> _refreshStorageAndQueue() async {
    await ref.read(recordingStorageProvider).refresh();
    await ref.read(transcriptionQueueProvider).processQueue();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
