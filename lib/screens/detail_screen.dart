import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../data/providers.dart';
import '../domain/bookmark.dart';
import '../domain/recording.dart';
import '../domain/recording_repository.dart';
import '../domain/transcript_segment.dart';
import '../domain/transcription_run.dart';
import '../domain/transcription_run_display.dart';
import '../export/transcript_export.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/model_catalog.dart';
import '../models/model_import_client.dart';
import '../models/transcription_models_banner.dart';
import '../processing/transcription_queue.dart';
import '../voiceprint/voiceprint_types.dart';
import '../voiceprint/matcher.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({
    required this.recordingId,
    this.initialPositionMs,
    super.key,
  });

  final String recordingId;
  final int? initialPositionMs;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  Recording? _recording;
  String? _error;
  Stream<Map<int, SpeakerNameDetails>>? _speakerDetailsStream;
  bool _audioReady = false;
  String? _loadedFilePath;

  @override
  void initState() {
    super.initState();
    ref.read(recordingStorageProvider).addListener(_onStorageChanged);
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
      if (mounted) setState(() => _recording = recording);
      await _loadAudio(recording);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _loadAudio(Recording recording) async {
    final storage = ref.read(recordingStorageProvider);
    if (!storage.isAvailable(recording)) {
      if (mounted) setState(() => _audioReady = false);
      return;
    }
    final file = storage.fileFor(recording);
    if (!await file.exists()) {
      if (mounted) setState(() => _audioReady = false);
      return;
    }
    if (_loadedFilePath == file.path && _audioReady) return;
    try {
      await _player.setFilePath(file.path);
      final initialPositionMs = widget.initialPositionMs;
      if (initialPositionMs != null) {
        await _player.seek(Duration(milliseconds: initialPositionMs));
      }
      _loadedFilePath = file.path;
      if (mounted) setState(() => _audioReady = true);
    } catch (_) {
      if (mounted) setState(() => _audioReady = false);
    }
  }

  void _onStorageChanged() {
    final recording = _recording;
    if (recording == null) return;
    if (!ref.read(recordingStorageProvider).isAvailable(recording)) {
      _loadedFilePath = null;
      unawaited(_player.stop());
      if (mounted) setState(() => _audioReady = false);
    } else {
      unawaited(_loadAudio(recording));
    }
  }

  @override
  void dispose() {
    ref.read(recordingStorageProvider).removeListener(_onStorageChanged);
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
        final storage = ref.read(recordingStorageProvider);
        final audioAvailable = _audioReady && storage.isAvailable(current);
        return StreamBuilder<List<TranscriptSegment>>(
          stream: repository.watchTranscriptSegments(recording.id),
          initialData: const [],
          builder: (context, segmentsSnapshot) {
            final segments = segmentsSnapshot.data ?? const [];
            return StreamBuilder<Map<int, String>>(
              stream: repository.watchSpeakerNames(recording.id),
              initialData: const {},
              builder: (context, namesSnapshot) {
                final speakerNames = namesSnapshot.data ?? const {};
                return StreamBuilder<List<Bookmark>>(
                  stream: repository.watchBookmarks(recording.id),
                  initialData: const [],
                  builder: (context, bookmarksSnapshot) {
                    final bookmarks = bookmarksSnapshot.data ?? const [];
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(l10n.recordingDetails),
                        actions: [
                          IconButton(
                            tooltip: l10n.rename,
                            onPressed: () => _rename(current),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Export',
                            enabled: segments.isNotEmpty,
                            onSelected: (format) => _export(
                              current,
                              segments,
                              speakerNames,
                              bookmarks,
                              format,
                            ),
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'txt', child: Text('TXT')),
                              PopupMenuItem(value: 'srt', child: Text('SRT')),
                              PopupMenuItem(value: 'vtt', child: Text('VTT')),
                              PopupMenuItem(value: 'json', child: Text('JSON')),
                              PopupMenuItem(
                                value: 'copy',
                                child: Text('Copy text'),
                              ),
                            ],
                          ),
                          IconButton(
                            tooltip: l10n.share,
                            onPressed: audioAvailable
                                ? () => _share(current)
                                : null,
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
                            if (!storage.isAvailable(current))
                              Card(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                child: const ListTile(
                                  leading: Icon(Icons.sd_card_alert),
                                  title: Text('SD card not available'),
                                  subtitle: Text(
                                    'Insert and mount the card to play, share, or transcribe this recording. Transcript text and exports remain available.',
                                  ),
                                ),
                              ),
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
                                        final duration =
                                            snapshot.data ?? Duration.zero;
                                        return StreamBuilder<Duration>(
                                          stream: _player.positionStream,
                                          builder: (context, positionSnapshot) {
                                            final position =
                                                positionSnapshot.data ??
                                                Duration.zero;
                                            final maxMilliseconds = duration
                                                .inMilliseconds
                                                .toDouble()
                                                .clamp(1.0, double.infinity);
                                            return Column(
                                              children: [
                                                Slider(
                                                  value: position.inMilliseconds
                                                      .toDouble()
                                                      .clamp(
                                                        0.0,
                                                        maxMilliseconds,
                                                      ),
                                                  max: maxMilliseconds,
                                                  onChanged: audioAvailable
                                                      ? (value) => _player.seek(
                                                          Duration(
                                                            milliseconds: value
                                                                .round(),
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                        final playing =
                                            snapshot.data?.playing ?? false;
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton.filled(
                                              iconSize: 36,
                                              onPressed: audioAvailable
                                                  ? () => playing
                                                        ? _player.pause()
                                                        : _player.play()
                                                  : null,
                                              icon: Icon(
                                                playing
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Add bookmark',
                                              onPressed: audioAvailable
                                                  ? () => _addBookmark(
                                                      recording.id,
                                                      _player
                                                          .position
                                                          .inMilliseconds,
                                                    )
                                                  : null,
                                              icon: const Icon(
                                                Icons.bookmark_add_outlined,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const TranscriptionModelsBanner(),
                            ValueListenableBuilder<bool>(
                              valueListenable: ref
                                  .read(transcriptionQueueProvider)
                                  .waitingForCharger,
                              builder: (context, waitingForCharger, _) =>
                                  ValueListenableBuilder<String?>(
                                    valueListenable: ref
                                        .read(transcriptionQueueProvider)
                                        .stage,
                                    builder: (context, stage, _) =>
                                        _TranscriptionStatusRow(
                                          recording: current,
                                          segments: segments,
                                          stage: stage,
                                          waitingForCharger: waitingForCharger,
                                          audioAvailable: audioAvailable,
                                          onTranscribe: () =>
                                              _transcribe(current),
                                          onRetry: () => _retry(current),
                                        ),
                                  ),
                            ),
                            if (bookmarks.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Bookmarks',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 160,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: bookmarks.length,
                                  itemBuilder: (context, index) {
                                    final bookmark = bookmarks[index];
                                    return Card(
                                      child: ListTile(
                                        dense: true,
                                        leading: Text(
                                          _format(
                                            Duration(
                                              milliseconds: bookmark.positionMs,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          bookmark.label?.isNotEmpty == true
                                              ? bookmark.label!
                                              : 'Bookmark',
                                        ),
                                        onTap: audioAvailable
                                            ? () => _player.seek(
                                                Duration(
                                                  milliseconds:
                                                      bookmark.positionMs,
                                                ),
                                              )
                                            : null,
                                        onLongPress: () =>
                                            _manageBookmark(bookmark),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            StreamBuilder<List<TranscriptionRun>>(
                              stream: repository.watchRuns(recording.id),
                              builder: (context, runsSnapshot) {
                                final runs =
                                    runsSnapshot.data ??
                                    const <TranscriptionRun>[];
                                if (runs.length < 2) {
                                  return const SizedBox.shrink();
                                }
                                final selected = runs.firstWhere(
                                  (run) => run.id == current.activeRunId,
                                  orElse: () => runs.first,
                                );
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            initialValue: selected.id,
                                            decoration: const InputDecoration(
                                              labelText: 'Transcription run',
                                              border: InputBorder.none,
                                            ),
                                            items: [
                                              for (final run in runs)
                                                DropdownMenuItem(
                                                  value: run.id,
                                                  child: GestureDetector(
                                                    onLongPress: () async {
                                                      if (run.id ==
                                                              current
                                                                  .activeRunId ||
                                                          run.status ==
                                                              TranscriptionStatus
                                                                  .queued ||
                                                          run.status ==
                                                              TranscriptionStatus
                                                                  .running) {
                                                        return;
                                                      }
                                                      final confirmed = await showDialog<bool>(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text(
                                                            'Delete run?',
                                                          ),
                                                          content: const Text(
                                                            'This run and its transcript will be deleted.',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                              child: const Text(
                                                                'Cancel',
                                                              ),
                                                            ),
                                                            FilledButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                              child: const Text(
                                                                'Delete',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirmed == true) {
                                                        await repository
                                                            .deleteRun(run.id);
                                                      }
                                                    },
                                                    child: _RunSelectorItem(
                                                      run: run,
                                                      active:
                                                          run.id ==
                                                          current.activeRunId,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                            onChanged: (runId) async {
                                              if (runId == null) return;
                                              final run = runs.firstWhere(
                                                (item) => item.id == runId,
                                              );
                                              if (run.status ==
                                                  TranscriptionStatus.done) {
                                                await repository.setActiveRun(
                                                  recording.id,
                                                  runId,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Compare runs',
                                          onPressed: () => context.push(
                                            '/recording/${recording.id}/compare',
                                          ),
                                          icon: const Icon(
                                            Icons.compare_arrows,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (selected.status ==
                                        TranscriptionStatus.failed)
                                      Text(
                                        selected.error ?? 'Run failed',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      ),
                                  ],
                                );
                              },
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
                                      child: Text(
                                        'No transcript segments yet.',
                                      ),
                                    );
                                  }
                                  return StreamBuilder<
                                    Map<int, SpeakerNameDetails>
                                  >(
                                    stream: _speakerDetailsStream ??= repository
                                        .watchSpeakerNameDetails(recording.id),
                                    initialData: const {},
                                    builder: (context, detailsSnapshot) =>
                                        _TranscriptList(
                                          segments: segments,
                                          speakerNames: speakerNames,
                                          speakerDetails:
                                              detailsSnapshot.data ?? const {},
                                          position:
                                              snapshot.data ?? Duration.zero,
                                          onSeek: audioAvailable
                                              ? (position) =>
                                                    _player.seek(position)
                                              : (_) {},
                                          onRenameSpeaker: (speaker, name) =>
                                              _manageSpeaker(
                                                recording.id,
                                                current.activeRunId,
                                                speaker,
                                                name,
                                              ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: audioAvailable
                                    ? () => _share(current)
                                    : null,
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
          },
        );
      },
    );
  }

  Future<void> _transcribe(Recording recording) async {
    if (!ref.read(recordingStorageProvider).isAvailable(recording)) return;
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
        : preferredInstalledAsr(models.map((model) => model.id))?.id ??
              models.first.id;
    var selectedLanguage = recording.languageHint;
    final diarizationModelIds = ['pyannote-segmentation', 'campplus-zh-en'];
    final hasDiarization = diarizationModelIds.every((id) {
      final model = modelById(id)!;
      return model.files.every(
        (file) => installed[id]?.contains(file) ?? false,
      );
    });
    var selectedSpeakerCount = recording.speakerCountHint ?? 0;
    final selection = await showModalBottomSheet<(String, LanguageHint, int?)>(
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
                const SizedBox(height: 12),
                if (hasDiarization)
                  DropdownButtonFormField<int>(
                    initialValue: selectedSpeakerCount,
                    decoration: const InputDecoration(labelText: 'Speakers'),
                    items: [
                      const DropdownMenuItem(value: 0, child: Text('Auto')),
                      for (var count = 1; count <= 6; count++)
                        DropdownMenuItem(value: count, child: Text('$count')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() => selectedSpeakerCount = value);
                      }
                    },
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      this.context.push('/settings/models');
                    },
                    child: const Text('Enable speaker detection in Models'),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, (
                      selectedModelId,
                      selectedLanguage,
                      selectedSpeakerCount == 0 ? null : selectedSpeakerCount,
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
        recording.languageHint != selection.$2 ||
        recording.speakerCountHint != selection.$3;
    await ref
        .read(transcriptionQueueProvider)
        .enqueue(
          recording.id,
          modelId: selection.$1,
          language: selection.$2,
          speakerCount: selection.$3,
          retranscribe: reset,
        );
  }

  Future<void> _retry(Recording recording) async {
    if (!ref.read(recordingStorageProvider).isAvailable(recording)) return;
    await ref
        .read(transcriptionQueueProvider)
        .enqueue(
          recording.id,
          modelId: recording.asrModelId,
          language: recording.languageHint,
          speakerCount: recording.speakerCountHint,
        );
  }

  Future<void> _manageSpeaker(
    String recordingId,
    String? runId,
    int speaker,
    String? currentName,
  ) async {
    if (runId == null) return;
    final repository = ref.read(recordingRepositoryProvider);
    final details =
        await repository.speakerNameDetails(recordingId, speaker) ??
        SpeakerNameDetails(name: currentName ?? '', source: 'manual');
    final embedding = await repository.getRunSpeakerEmbedding(runId, speaker);
    if (!mounted) return;
    final canEnroll =
        embedding != null && embedding.speechMs >= voiceprintMinimumSpeechMs;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('This is…'),
              subtitle: canEnroll
                  ? null
                  : const Text('Not enough speech for a voiceprint'),
              enabled: canEnroll,
              onTap: canEnroll
                  ? () => Navigator.pop(context, 'identify')
                  : null,
            ),
            if (details.source == 'auto' && details.personId != null) ...[
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text('Confirm ${details.name}'),
                onTap: () => Navigator.pop(context, 'confirm'),
              ),
              ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: Text('Not ${details.name}'),
                onTap: () => Navigator.pop(context, 'reject'),
              ),
            ],
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'rename') {
      await _renameSpeakerName(recordingId, speaker, currentName);
    } else if (action == 'reject') {
      await repository.setSpeakerName(
        recordingId: recordingId,
        speaker: speaker,
        name: '',
      );
    } else {
      var personId = details.personId;
      if (action == 'identify') {
        personId = await _choosePerson(repository);
      }
      if (personId == null) return;
      await repository.confirmSpeaker(
        recordingId: recordingId,
        runId: runId,
        speaker: speaker,
        personId: personId,
      );
    }
  }

  Future<String?> _choosePerson(RecordingRepository repository) async {
    const newPerson = '__new_person__';
    final people = await repository.listPeople();
    if (!mounted) return null;
    final selection = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final person in people)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(person.name),
                onTap: () => Navigator.pop(context, person.id),
              ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('New person…'),
              onTap: () => Navigator.pop(context, newPerson),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selection == null) return null;
    if (selection != newPerson) return selection;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New person'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return null;
    return repository.createPerson(name);
  }

  Future<void> _renameSpeakerName(
    String recordingId,
    int speaker,
    String? currentName,
  ) async {
    var enteredName = currentName ?? 'Speaker ${speaker + 1}';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Speaker ${speaker + 1}'),
        content: TextFormField(
          initialValue: enteredName,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Speaker name'),
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => enteredName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, enteredName),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null) return;
    await ref
        .read(recordingRepositoryProvider)
        .setSpeakerName(recordingId: recordingId, speaker: speaker, name: name);
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
    final storage = ref.read(recordingStorageProvider);
    if (!storage.isAvailable(recording)) return;
    final file = storage.fileFor(recording);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'audio/wav')],
        title: recording.title,
      ),
    );
  }

  Future<void> _export(
    Recording recording,
    List<TranscriptSegment> segments,
    Map<int, String> speakerNames,
    List<Bookmark> bookmarks,
    String format,
  ) async {
    if (format == 'copy') {
      await Clipboard.setData(
        ClipboardData(
          text: exportTxt(
            recording,
            segments,
            speakerNames,
            bookmarks: bookmarks,
          ),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transcript copied to clipboard.')),
        );
      }
      return;
    }

    final contents = switch (format) {
      'srt' => exportSrt(
        recording,
        segments,
        speakerNames,
        bookmarks: bookmarks,
      ),
      'vtt' => exportVtt(
        recording,
        segments,
        speakerNames,
        bookmarks: bookmarks,
      ),
      'json' => exportJson(
        recording,
        segments,
        speakerNames,
        bookmarks: bookmarks,
      ),
      _ => exportTxt(recording, segments, speakerNames, bookmarks: bookmarks),
    };
    final mimeType = switch (format) {
      'srt' => 'application/x-subrip',
      'vtt' => 'text/vtt',
      'json' => 'application/json',
      _ => 'text/plain',
    };
    final exportsDirectory = Directory(
      p.join((await getTemporaryDirectory()).path, 'exports'),
    );
    await exportsDirectory.create(recursive: true);
    final filename = '${sanitizeExportFilename(recording.title)}.$format';
    final file = File(p.join(exportsDirectory.path, filename));
    await file.writeAsString(contents);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        title: filename,
      ),
    );
  }

  Future<void> _addBookmark(String recordingId, int positionMs) async {
    await ref
        .read(recordingRepositoryProvider)
        .addBookmark(recordingId, positionMs);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bookmark at ${_format(Duration(milliseconds: positionMs))}',
        ),
      ),
    );
  }

  Future<void> _manageBookmark(Bookmark bookmark) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    final repository = ref.read(recordingRepositoryProvider);
    if (action == 'delete') {
      await repository.deleteBookmark(bookmark.id);
      return;
    }

    final controller = TextEditingController(text: bookmark.label ?? '');
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename bookmark'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (label != null) await repository.renameBookmark(bookmark.id, label);
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
    required this.stage,
    required this.waitingForCharger,
    required this.audioAvailable,
    required this.onTranscribe,
    required this.onRetry,
  });

  final Recording recording;
  final List<TranscriptSegment> segments;
  final String? stage;
  final bool waitingForCharger;
  final bool audioAvailable;
  final Future<void> Function() onTranscribe;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final completed = segments.where((segment) => segment.text != null).length;
    final total = segments.length;
    final status = recording.transcriptionStatus;
    final statusText = switch (status) {
      TranscriptionStatus.none => 'Not transcribed',
      TranscriptionStatus.queued =>
        waitingForCharger ? 'Waiting for charger' : 'Queued',
      TranscriptionStatus.running =>
        stage == 'speakers'
            ? 'Detecting speakers…'
            : 'Transcribing $completed/$total',
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
                onPressed: audioAvailable ? onTranscribe : null,
                child: Text(
                  status == TranscriptionStatus.done
                      ? 'Re-transcribe'
                      : 'Transcribe',
                ),
              ),
            if (status == TranscriptionStatus.failed)
              TextButton.icon(
                onPressed: audioAvailable ? onRetry : null,
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
    required this.speakerNames,
    required this.speakerDetails,
    required this.position,
    required this.onSeek,
    required this.onRenameSpeaker,
  });

  final List<TranscriptSegment> segments;
  final Map<int, String> speakerNames;
  final Map<int, SpeakerNameDetails> speakerDetails;
  final Duration position;
  final ValueChanged<Duration> onSeek;
  final void Function(int speaker, String? currentName) onRenameSpeaker;

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
        final speaker = segment.speaker;
        final showSpeaker =
            speaker != null &&
            (index == 0 || widget.segments[index - 1].speaker != speaker);
        final speakerName = speaker == null
            ? null
            : widget.speakerNames[speaker];
        final speakerDetails = speaker == null
            ? null
            : widget.speakerDetails[speaker];
        return Column(
          key: _itemKeys[index],
          children: [
            if (showSpeaker)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: _SpeakerChip(
                    speaker: speaker,
                    name: speakerName?.isNotEmpty == true
                        ? speakerName!
                        : 'Speaker ${speaker + 1}',
                    source: speakerDetails?.source,
                    matchScore: speakerDetails?.matchScore,
                    onTap: () => widget.onRenameSpeaker(speaker, speakerName),
                  ),
                ),
              ),
            Card(
              color: highlighted
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: ListTile(
                onTap: () =>
                    widget.onSeek(Duration(milliseconds: segment.startMs)),
                leading: Text(_formatSegmentTime(segment.startMs)),
                title: Text(segment.text ?? '…'),
                trailing: language != null && language != majorityLanguage
                    ? Chip(
                        label: Text(language),
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

const _speakerPalette = [
  Color(0xFF1565C0),
  Color(0xFFC62828),
  Color(0xFF2E7D32),
  Color(0xFF6A1B9A),
  Color(0xFFEF6C00),
  Color(0xFF00838F),
  Color(0xFFAD1457),
  Color(0xFF827717),
];

class _SpeakerChip extends StatelessWidget {
  const _SpeakerChip({
    required this.speaker,
    required this.name,
    required this.source,
    required this.matchScore,
    required this.onTap,
  });

  final int speaker;
  final String name;
  final String? source;
  final double? matchScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = _speakerPalette[speaker % _speakerPalette.length];
    final background = Color.lerp(
      base,
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      Theme.of(context).brightness == Brightness.dark ? 0.55 : 0.82,
    )!;
    final foreground = background.computeLuminance() > 0.4
        ? Colors.black
        : Colors.white;
    final chip = ActionChip(
      avatar: source == 'auto'
          ? Icon(Icons.auto_awesome, size: 16, color: foreground)
          : null,
      label: Text(name),
      backgroundColor: background,
      side: BorderSide(color: base),
      labelStyle: TextStyle(color: foreground),
      onPressed: onTap,
    );
    if (source != 'auto' || matchScore == null) return chip;
    return Tooltip(
      message: 'Auto match · ${(matchScore! * 100).round()}%',
      child: chip,
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

class _RunSelectorItem extends StatelessWidget {
  const _RunSelectorItem({required this.run, required this.active});

  final TranscriptionRun run;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final model =
        modelById(run.asrModelId ?? '')?.displayName ?? 'Unknown model';
    final status = switch (run.status) {
      TranscriptionStatus.queued => 'Queued',
      TranscriptionStatus.running => 'Running',
      TranscriptionStatus.failed => 'Failed',
      _ => null,
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  model,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (status != null)
                Tooltip(
                  message: status == 'Failed' ? run.error ?? 'Failed' : status,
                  child: _RunBadge(status),
                ),
              if (active) const _RunBadge('Active'),
            ],
          ),
          Text(
            runDetailsLabel(run),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RunBadge extends StatelessWidget {
  const _RunBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: colors.onSecondaryContainer),
      ),
    );
  }
}
