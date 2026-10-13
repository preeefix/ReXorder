import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../domain/recording.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/transcription_models_banner.dart';
import '../processing/transcription_queue.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recordings = ref.watch(recordingsProvider);
    final transcriptionQueue = ref.read(transcriptionQueueProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryTitle),
        actions: [
          IconButton(
            tooltip: 'Search transcripts',
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          const TranscriptionModelsBanner(),
          ValueListenableBuilder<bool>(
            valueListenable: transcriptionQueue.waitingForCharger,
            builder: (context, waiting, _) {
              final queued =
                  recordings.value?.any(
                    (recording) =>
                        recording.transcriptionStatus ==
                        TranscriptionStatus.queued,
                  ) ??
                  false;
              if (!waiting || !queued) return const SizedBox.shrink();
              return Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.battery_charging_full),
                  title: const Text(
                    'Transcription waits until the phone is charging.',
                  ),
                  onTap: () => context.push('/settings'),
                ),
              );
            },
          ),
          Expanded(
            child: recordings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
              data: (items) => items.isEmpty
                  ? _EmptyLibrary(l10n: l10n)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _RecordingTile(recording: items[index]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/record'),
        icon: const Icon(Icons.mic),
        label: Text(l10n.newRecording),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.graphic_eq_rounded,
            size: 72,
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.emptyLibraryTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyLibraryBody,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _RecordingTile extends StatelessWidget {
  const _RecordingTile({required this.recording});

  final Recording recording;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, yyyy · HH:mm').format(recording.createdAt);
    final elapsed = Duration(milliseconds: recording.durationMs);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: const Icon(Icons.mic_none),
        ),
        title: Text(
          recording.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$date  ·  ${_formatDuration(elapsed)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TranscriptionStatus(recording.transcriptionStatus),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.push('/recording/${recording.id}'),
      ),
    );
  }
}

class _TranscriptionStatus extends StatelessWidget {
  const _TranscriptionStatus(this.status);

  final TranscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (status) {
      TranscriptionStatus.none => (null, null),
      TranscriptionStatus.queued => (Icons.schedule, 'Queued'),
      TranscriptionStatus.running => (Icons.sync, 'Transcribing'),
      TranscriptionStatus.done => (Icons.check_circle_outline, 'Transcribed'),
      TranscriptionStatus.failed => (Icons.error_outline, 'Failed'),
    };
    if (icon == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(message: label!, child: Icon(icon, size: 18)),
    );
  }
}

String _formatDuration(Duration duration) =>
    '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
