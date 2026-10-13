import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/app.dart';
import 'package:rexorder/domain/recording.dart';

void main() {
  testWidgets('Library shows the empty state and then recordings', (
    tester,
  ) async {
    final recordings = StreamController<List<Recording>>.broadcast();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordingsProvider.overrideWith((ref) => recordings.stream),
        ],
        child: const ReXorderApp(),
      ),
    );
    recordings.add([]);
    await tester.pumpAndSettle();
    expect(find.text('Your recordings will appear here'), findsOneWidget);

    recordings.add([
      Recording(
        id: 'first',
        title: 'Morning notes',
        createdAt: DateTime(2026, 1, 2, 9),
        durationMs: 12500,
        fileName: 'first.wav',
        sampleRate: 16000,
        status: RecordingStatus.ready,
      ),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Morning notes'), findsOneWidget);
    await recordings.close();
  });
}
