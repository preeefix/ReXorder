import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../data/providers.dart';
import '../domain/recording.dart';
import '../l10n/generated/app_localizations.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({required this.recordingId, super.key});

  final String recordingId;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  Recording? _recording;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecording();
  }

  Future<void> _loadRecording() async {
    try {
      final repo = ref.read(recordingRepositoryProvider);
      final recording = await repo.getRecording(widget.recordingId);
      if (recording == null) {
        setState(() => _error = 'Recording not found.');
        return;
      }
      final file = File(
        p.join(ref.read(recordingsDirectoryProvider).path, recording.fileName),
      );
      await _player.setFilePath(file.path);
      if (mounted) setState(() => _recording = recording);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recording = _recording;
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error!)),
      );
    }
    if (recording == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordingDetails),
        actions: [
          IconButton(
            tooltip: l10n.rename,
            onPressed: () => _rename(recording),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.share,
            onPressed: () => _share(recording),
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: l10n.delete,
            onPressed: () => _delete(recording),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recording.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${recording.createdAt.toLocal()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    StreamBuilder<Duration?>(
                      stream: _player.durationStream,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration>(
                          stream: _player.positionStream,
                          builder: (context, positionSnapshot) {
                            final position =
                                positionSnapshot.data ?? Duration.zero;
                            final maxSeconds = duration.inMilliseconds
                                .toDouble()
                                .clamp(1.0, double.infinity);
                            return Column(
                              children: [
                                Slider(
                                  value: position.inMilliseconds
                                      .toDouble()
                                      .clamp(0.0, maxSeconds),
                                  max: maxSeconds,
                                  onChanged: (value) => _player.seek(
                                    Duration(milliseconds: value.round()),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_format(position)),
                                    Text(_format(duration)),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return IconButton.filled(
                          iconSize: 36,
                          onPressed: () =>
                              playing ? _player.pause() : _player.play(),
                          icon: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _share(recording),
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.shareWav),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(Recording recording) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: recording.title);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameRecording),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.title),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty) return;
    await ref.read(recordingRepositoryProvider).rename(recording.id, title);
    if (mounted) setState(() => _recording = recording.copyWith(title: title));
  }

  Future<void> _share(Recording recording) async {
    final file = File(
      p.join(ref.read(recordingsDirectoryProvider).path, recording.fileName),
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'audio/wav')],
        title: recording.title,
      ),
    );
  }

  Future<void> _delete(Recording recording) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecording),
        content: Text(l10n.deleteRecordingBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(recordingRepositoryProvider).delete(recording.id);
    if (mounted) context.go('/');
  }
}

String _format(Duration duration) =>
    '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
