import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rexorder/data/recording_storage.dart';
import 'package:rexorder/domain/recording.dart';

void main() {
  test(
    'resolves internal and SD paths and checks mounted availability',
    () async {
      final root = await Directory.systemTemp.createTemp('rexorder-storage-');
      addTearDown(() => root.delete(recursive: true));
      var volumes = <StorageVolume>[
        StorageVolume(
          path: '${root.path}/primary',
          removable: false,
          mounted: true,
          description: 'Internal',
          freeBytes: 1000,
          totalBytes: 2000,
        ),
        StorageVolume(
          path: '${root.path}/sd/Android/data/app/files',
          removable: true,
          mounted: true,
          description: 'SD card',
          freeBytes: 3000,
          totalBytes: 4000,
        ),
      ];
      final storage = RecordingStorage(
        internalDirectory: Directory('${root.path}/internal/recordings'),
        volumeLoader: () async => volumes,
      );
      addTearDown(storage.dispose);
      await storage.refresh();

      final internal = _recording(StorageLocation.internal);
      final sd = _recording(StorageLocation.sd);
      expect(
        storage.fileFor(internal).path,
        '${root.path}/internal/recordings/clip.wav',
      );
      expect(
        storage.fileFor(sd).path,
        '${root.path}/sd/Android/data/app/files/recordings/clip.wav',
      );
      expect(storage.isAvailable(internal), isTrue);
      expect(storage.isAvailable(sd), isTrue);
      expect(storage.freeBytesFor(StorageLocation.internal), 1000);
      expect(storage.freeBytesFor(StorageLocation.sd), 3000);

      volumes = [volumes.first, volumes.last.unmounted()];
      await storage.refresh();
      expect(storage.isAvailable(sd), isFalse);
      expect(
        storage.resolveNewRecordingLocation(StorageLocation.sd),
        StorageLocation.internal,
      );
    },
  );
}

Recording _recording(StorageLocation storage) => Recording(
  id: 'clip',
  title: 'Clip',
  createdAt: DateTime(2026),
  durationMs: 1000,
  fileName: 'clip.wav',
  sampleRate: 16000,
  status: RecordingStatus.ready,
  storage: storage,
);
