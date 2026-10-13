import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'model_manager.dart';

class TranscriptionModelsBanner extends ConsumerWidget {
  const TranscriptionModelsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modelManagerProvider);
    if (state.isLoading || (state.hasVad && state.hasAsr)) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        leading: const Icon(Icons.download_for_offline_outlined),
        title: const Text('Transcription needs models'),
        subtitle: const Text('Import Silero VAD and at least one ASR model.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/settings/models'),
      ),
    );
  }
}
