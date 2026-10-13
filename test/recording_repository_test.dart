import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/data/database.dart';
import 'package:rexorder/domain/recording_repository.dart';

void main() {
  test(
    'inserts, lists newest first, renames, and deletes recordings',
    () async {
      final directory = await Directory.systemTemp.createTemp('rexorder-repo-');
      addTearDown(() => directory.delete(recursive: true));
      final database = AppDatabase.memory();
      addTearDown(database.close);
      var currentTime = DateTime(2026, 1, 1, 10);
      final repository = RecordingRepository(
        database,
        directory,
        now: () => currentTime,
      );

      await repository.createRecording(id: 'older');
      currentTime = currentTime.add(const Duration(minutes: 1));
      await repository.createRecording(id: 'newer');

      final items = await repository.listRecordings();
      expect(items.map((item) => item.id), ['newer', 'older']);
      expect(items.first.fileName, 'newer.wav');
      expect(items.first.status.name, 'recording');

      await repository.rename('newer', 'Renamed note');
      expect((await repository.getRecording('newer'))!.title, 'Renamed note');
      final wav = File('${directory.path}/newer.wav')..writeAsBytesSync([1]);
      await repository.delete('newer');
      expect(await repository.getRecording('newer'), isNull);
      expect(await wav.exists(), isFalse);
      expect((await repository.listRecordings()).single.id, 'older');
    },
  );
}
