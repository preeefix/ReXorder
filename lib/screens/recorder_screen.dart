import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../recorder/recorder_controller.dart';

class RecorderScreen extends ConsumerWidget {
  const RecorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recorderControllerProvider, (previous, next) {
      if (!next.storageFallback || previous?.storageFallback == true) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SD card unavailable — saving to internal storage'),
        ),
      );
    });
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(recorderControllerProvider);
    final controller = ref.read(recorderControllerProvider.notifier);
    final isActive =
        state.phase == RecorderPhase.recording ||
        state.phase == RecorderPhase.paused;
    return PopScope(
      canPop: !isActive && state.phase != RecorderPhase.saving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !isActive) return;
        final shouldStop = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.stopRecordingQuestion),
            content: Text(l10n.stopRecordingBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.keepRecording),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.stopAndSave),
              ),
            ],
          ),
        );
        if (shouldStop == true && context.mounted) {
          final id = await controller.stop();
          if (id != null && context.mounted) context.go('/recording/$id');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.recorderTitle)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDuration(state.elapsed),
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(fontFeatures: const []),
                ),
                const SizedBox(height: 14),
                Text(switch (state.phase) {
                  RecorderPhase.recording => l10n.recordingStatus,
                  RecorderPhase.paused => l10n.pausedStatus,
                  RecorderPhase.saving => l10n.savingStatus,
                  RecorderPhase.idle => l10n.readyStatus,
                }, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 36),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.level,
                    minHeight: 10,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 44),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MainRecordButton(
                      phase: state.phase,
                      onPressed: () {
                        if (state.phase == RecorderPhase.idle) {
                          controller.start();
                        } else if (state.phase == RecorderPhase.recording) {
                          controller.pause();
                        } else if (state.phase == RecorderPhase.paused) {
                          controller.resume();
                        }
                      },
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 16),
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          final positionMs = await controller.addBookmark();
                          if (!context.mounted || positionMs == null) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Bookmark at ${_formatDuration(Duration(milliseconds: positionMs))}',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: const Text('Bookmark'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonalIcon(
                        onPressed: state.phase == RecorderPhase.saving
                            ? null
                            : () async {
                                final id = await controller.stop();
                                if (id != null && context.mounted) {
                                  context.go('/recording/$id');
                                }
                              },
                        icon: const Icon(Icons.stop_rounded),
                        label: Text(l10n.stop),
                      ),
                    ],
                  ],
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainRecordButton extends StatelessWidget {
  const _MainRecordButton({required this.phase, required this.onPressed});

  final RecorderPhase phase;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final saving = phase == RecorderPhase.saving;
    final recording = phase == RecorderPhase.recording;
    return SizedBox(
      width: 92,
      height: 92,
      child: FloatingActionButton(
        heroTag: 'record-control',
        onPressed: saving ? null : onPressed,
        shape: const CircleBorder(),
        backgroundColor: recording
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        child: saving
            ? const CircularProgressIndicator(color: Colors.white)
            : Icon(
                recording
                    ? Icons.pause_rounded
                    : phase == RecorderPhase.paused
                    ? Icons.play_arrow_rounded
                    : Icons.mic_rounded,
                size: 40,
                color: Colors.white,
              ),
      ),
    );
  }
}

String _formatDuration(Duration duration) =>
    '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
