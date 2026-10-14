import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/recording.dart';

typedef StorageVolumeLoader = Future<List<StorageVolume>> Function();

class StorageVolume {
  const StorageVolume({
    required this.path,
    required this.removable,
    required this.mounted,
    required this.description,
    required this.freeBytes,
    required this.totalBytes,
  });

  final String path;
  final bool removable;
  final bool mounted;
  final String description;
  final int freeBytes;
  final int totalBytes;

  StorageVolume unmounted() => StorageVolume(
    path: path,
    removable: removable,
    mounted: false,
    description: description,
    freeBytes: 0,
    totalBytes: totalBytes,
  );

  factory StorageVolume.fromMap(Map<dynamic, dynamic> map) => StorageVolume(
    path: map['path'] as String,
    removable: map['removable'] as bool? ?? false,
    mounted: map['mounted'] as bool? ?? false,
    description: map['description'] as String? ?? '',
    freeBytes: map['freeBytes'] as int? ?? 0,
    totalBytes: map['totalBytes'] as int? ?? 0,
  );
}

class RecordingStorage extends ChangeNotifier {
  RecordingStorage({
    required this.internalDirectory,
    StorageVolumeLoader? volumeLoader,
  }) : _volumeLoader = volumeLoader ?? _loadPlatformVolumes;

  static const _channel = MethodChannel('rexorder/storage');

  final Directory internalDirectory;
  final StorageVolumeLoader _volumeLoader;
  List<StorageVolume> _volumes = const [];
  StorageVolume? _lastSdVolume;

  List<StorageVolume> get volumes => List.unmodifiable(_volumes);

  StorageVolume? get sdVolume {
    for (final volume in _volumes) {
      if (volume.removable) return volume;
    }
    return _lastSdVolume?.unmounted();
  }

  bool get hasSdCard => sdVolume != null;

  bool get sdAvailable {
    for (final volume in _volumes) {
      if (volume.removable) return volume.mounted;
    }
    return false;
  }

  int? get internalFreeBytes {
    for (final volume in _volumes) {
      if (!volume.removable) return volume.freeBytes;
    }
    return null;
  }

  List<Directory> get mountedRecordingDirectories => [
    internalDirectory,
    if (sdAvailable) dirFor(StorageLocation.sd),
  ];

  Future<void> refresh() async {
    _volumes = await _volumeLoader();
    for (final volume in _volumes) {
      if (volume.removable) {
        _lastSdVolume = volume;
        break;
      }
    }
    notifyListeners();
  }

  Directory dirFor(StorageLocation location) {
    if (location == StorageLocation.internal) return internalDirectory;
    final volume = sdVolume;
    if (volume == null) {
      throw StateError('No removable storage volume has been detected.');
    }
    return Directory(p.join(volume.path, 'recordings'));
  }

  File fileFor(Recording recording) =>
      File(p.join(dirFor(recording.storage).path, recording.fileName));

  bool isAvailable(Recording recording) =>
      recording.storage == StorageLocation.internal || sdAvailable;

  StorageLocation resolveNewRecordingLocation(StorageLocation requested) =>
      requested == StorageLocation.sd && !sdAvailable
      ? StorageLocation.internal
      : requested;

  int? freeBytesFor(StorageLocation location) {
    if (location == StorageLocation.internal) return internalFreeBytes;
    return sdVolume?.freeBytes;
  }

  Future<void> createDirectory(StorageLocation location) =>
      dirFor(location).create(recursive: true);

  static Future<List<StorageVolume>> _loadPlatformVolumes() async {
    try {
      final entries = await _channel.invokeListMethod<dynamic>('listVolumes');
      return [
        for (final entry in entries ?? const [])
          if (entry is Map) StorageVolume.fromMap(entry),
      ];
    } on MissingPluginException {
      return const [];
    }
  }
}

class RecordingStoragePreferences {
  static const _key = 'recordingStorage';

  static Future<StorageLocation> getLocation() async {
    final value = (await SharedPreferences.getInstance()).getString(_key);
    return StorageLocation.values.firstWhere(
      (location) => location.name == value,
      orElse: () => StorageLocation.internal,
    );
  }

  static Future<void> setLocation(StorageLocation location) async {
    await (await SharedPreferences.getInstance()).setString(
      _key,
      location.name,
    );
  }
}
