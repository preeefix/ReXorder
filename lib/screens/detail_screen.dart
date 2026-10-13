import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../data/providers.dart';
import '../domain/recording.dart';
import '../domain/transcript_segment.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/model_catalog.dart';
import '../models/model_import_client.dart';
import '../models/transcription_models_banner.dart';
import '../processing/transcription_queue.dart';

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
    final repository = ref.read(recordingRepositoryProvider);
    return StreamBuilder<Recording?>(
      stream: repository.watchRecording(recording.id),
      initialData: recording,
      builder: (context, recordingSnapshot) {
        final current = recordingSnapshot.data ?? recording;
        return StreamBuilder<List<TranscriptSegment>>(
          stream: repository.watchTranscriptSegments(recording.id),
          initialData: const [],
          builder: (context, segmentsSnapshot) {
            final segments = segmentsSnapshot.data ?? const [];
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.recordingDetails),
                actions: [
                  IconButton(
                    tooltip: l10n.rename,
                    onPressed: () => _rename(current),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.share,
                    onPressed: () => _share(current),
                    icon: const Icon(Icons.share_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.delete,
                    onPressed: () => _delete(current),
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
                      current.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(current.createdAt.toLocal()),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
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
                                    final maxMilliseconds = duration
                                        .inMilliseconds
                                        .toDouble()
                                        .clamp(1.0, double.infinity);
                                    return Column(
                                      children: [
                                        Slider(
                                          value: position.inMilliseconds
                                              .toDouble()
                                              .clamp(0.0, maxMilliseconds),
                                          max: maxMilliseconds,
                                          onChanged: (value) => _player.seek(
                                            Duration(
                                              milliseconds: value.round(),
                                            ),
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
                                  onPressed: () => playing
                                      ? _player.pause()
                                      : _player.play(),
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
                    const TranscriptionModelsBanner(),
                    _TranscriptionStatusRow(
                      recording: current,
                      segments: segments,
                      onTranscribe: () => _transcribe(current),
                      onRetry: () => _retry(current),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transcript',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: StreamBuilder<Duration>(
                        stream: _player.positionStream,
                        builder: (context, snapshot) {
                          if (segments.isEmpty) {
                            return const Center(
                              child: Text('No transcript segments yet.'),
                            );
                          }
                          return _TranscriptList(
                            segments: segments,
                            position: snapshot.data ?? Duration.zero,
                            onSeek: (position) => _player.seek(position),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _share(current),
                        icon: const Icon(Icons.ios_share),
                        label: Text(l10n.shareWav),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _transcribe(Recording recording) async {
    final installed = await const MethodChannelModelImportClient()
        .listInstalled();
    final models = modelCatalog
        .where(
          (model) =>
              model.isAsr &&
              model.files.every(
                (file) => installed[model.id]?.contains(file) ?? false,
              ),
        )
        .toList();
    final vad = installed['silero-vad']?.contains('silero_vad.onnx') ?? false;
    if (!mounted) return;
    if (models.isEmpty || !vad) {
      context.push('/settings/models');
      return;
    }
    var selectedModelId =
        models.any((model) => model.id == recording.asrModelId)
        ? recording.asrModelId!
        : models.first.id;
    var selectedLanguage = recording.languageHint;
    final selection = await showModalBottomSheet<(String, LanguageHint)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recording.transcriptionStatus == TranscriptionStatus.done
                      ? 'Re-transcribe'
                      : 'Transcribe',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<LanguageHint>(
                  initialValue: selectedLanguage,
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: const [
                    DropdownMenuItem(
                      value: LanguageHint.auto,
                      child: Text('Auto'),
                    ),
                    DropdownMenuItem(
                      value: LanguageHint.en,
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: LanguageHint.ja,
                      child: Text('日本語'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => selectedLanguage = value);
                    }
                  },
                ),
                if (models.length > 1) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedModelId,
                    decoration: const InputDecoration(labelText: 'Model'),
                    items: [
                      for (final model in models)
                        DropdownMenuItem(
                          value: model.id,
                          child: Text(model.displayName),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() => selectedModelId = value);
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, (
                      selectedModelId,
                      selectedLanguage,
                    )),
                    child: const Text('Start transcription'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selection == null) return;
    final reset =
        recording.transcriptionStatus == TranscriptionStatus.done ||
        recording.asrModelId != selection.$1 ||
        recording.languageHint != selection.$2;
    await ref
        .read(transcriptionQueueProvider)
        .enqueue(
          recording.id,
          modelId: selection.$1,
          language: selection.$2,
          retranscribe: reset,
        );
  }

  Future<void> _retry(Recording recording) => ref
      .read(transcriptionQueueProvider)
      .enqueue(
        recording.id,
        modelId: recording.asrModelId,
        language: recording.languageHint,
      );

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

class _TranscriptionStatusRow extends StatelessWidget {
  const _TranscriptionStatusRow({
    required this.recording,
    required this.segments,
    required this.onTranscribe,
    required this.onRetry,
  });

  final Recording recording;
  final List<TranscriptSegment> segments;
  final Future<void> Function() onTranscribe;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final completed = segments.where((segment) => segment.text != null).length;
    final total = segments.length;
    final status = recording.transcriptionStatus;
    final statusText = switch (status) {
      TranscriptionStatus.none => 'Not transcribed',
      TranscriptionStatus.queued => 'Queued',
      TranscriptionStatus.running => 'Transcribing $completed/$total',
      TranscriptionStatus.done => 'Transcription complete',
      TranscriptionStatus.failed => 'Transcription failed',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(statusText)),
            if (status == TranscriptionStatus.none ||
                status == TranscriptionStatus.done)
              TextButton(
                onPressed: onTranscribe,
                child: Text(
                  status == TranscriptionStatus.done
                      ? 'Re-transcribe'
                      : 'Transcribe',
                ),
              ),
            if (status == TranscriptionStatus.failed)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
        if (status == TranscriptionStatus.running)
          LinearProgressIndicator(value: total > 0 ? completed / total : null),
        if (status == TranscriptionStatus.failed &&
            recording.transcriptionError != null)
          Text(
            recording.transcriptionError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}

class _TranscriptList extends StatefulWidget {
  const _TranscriptList({
    required this.segments,
    required this.position,
    required this.onSeek,
  });

  final List<TranscriptSegment> segments;
  final Duration position;
  final ValueChanged<Duration> onSeek;

  @override
  State<_TranscriptList> createState() => _TranscriptListState();
}

class _TranscriptListState extends State<_TranscriptList> {
  late List<GlobalKey> _itemKeys;
  int _lastActiveIndex = -1;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.segments.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant _TranscriptList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.segments.length != oldWidget.segments.length) {
      _itemKeys = List.generate(widget.segments.length, (_) => GlobalKey());
      _lastActiveIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final positionMs = widget.position.inMilliseconds;
    final activeIndex = widget.segments.indexWhere(
      (segment) => positionMs >= segment.startMs && positionMs < segment.endMs,
    );
    if (activeIndex != _lastActiveIndex) {
      _lastActiveIndex = activeIndex;
      if (activeIndex >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final itemContext = _itemKeys[activeIndex].currentContext;
          if (itemContext != null && mounted) {
            Scrollable.ensureVisible(
              itemContext,
              duration: const Duration(milliseconds: 180),
              alignment: 0.45,
            );
          }
        });
      }
    }
    final languageCounts = <String, int>{};
    for (final segment in widget.segments) {
      final language = segment.lang;
      if (language != null) {
        languageCounts.update(
          language,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }
    String? majorityLanguage;
    for (final entry in languageCounts.entries) {
      if (majorityLanguage == null ||
          entry.value > languageCounts[majorityLanguage]!) {
        majorityLanguage = entry.key;
      }
    }
    return ListView.builder(
      itemCount: widget.segments.length,
      itemBuilder: (context, index) {
        final segment = widget.segments[index];
        final highlighted = index == activeIndex;
        final language = segment.lang;
        return Card(
          key: _itemKeys[index],
          color: highlighted
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            onTap: () => widget.onSeek(Duration(milliseconds: segment.startMs)),
            leading: Text(_formatSegmentTime(segment.startMs)),
            title: Text(segment.text ?? '…'),
            trailing: language != null && language != majorityLanguage
                ? Chip(
                    label: Text(language),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
        );
      },
    );
  }
}

String _formatSegmentTime(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  return '${duration.inMinutes.toString().padLeft(2, '0')}:'
      '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}

String _format(Duration duration) =>
    '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
