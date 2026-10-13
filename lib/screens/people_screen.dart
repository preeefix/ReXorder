import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../domain/recording_repository.dart';
import '../processing/transcription_queue.dart';
import '../voiceprint/voiceprint_types.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  bool _backfilling = false;
  int _completed = 0;
  int _total = 0;
  String? _backfillMessage;

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(recordingRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _backfilling ? null : _computeOlderVoiceprints,
              icon: const Icon(Icons.manage_search),
              label: const Text('Compute voiceprints for older recordings'),
            ),
          ),
          if (_backfilling) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _total == 0 ? null : _completed / _total,
            ),
            const SizedBox(height: 4),
            Text('Computing voiceprints: $_completed / $_total'),
          ] else if (_backfillMessage != null) ...[
            const SizedBox(height: 8),
            Text(_backfillMessage!),
          ],
          const SizedBox(height: 16),
          StreamBuilder<List<VoiceprintPersonSummary>>(
            stream: repository.watchPeople(),
            initialData: const [],
            builder: (context, snapshot) {
              final people = snapshot.data ?? const [];
              if (people.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No people yet.')),
                );
              }
              return Column(
                children: [
                  for (final person in people)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(person.name),
                        subtitle: Text(
                          '${person.voiceprintCount} voiceprints · '
                          '${person.activeRecordingCount} recordings',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _managePerson(repository, person),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _computeOlderVoiceprints() async {
    final repository = ref.read(recordingRepositoryProvider);
    final queue = ref.read(transcriptionQueueProvider);
    final runIds = await repository.activeDiarizedRunIdsWithoutEmbeddings();
    if (!mounted) return;
    setState(() {
      _backfilling = true;
      _completed = 0;
      _total = runIds.length;
      _backfillMessage = null;
    });
    String? error;
    for (final runId in runIds) {
      try {
        await queue.computeRunEmbeddings(runId);
      } catch (value) {
        error ??= value.toString();
      }
      if (mounted) setState(() => _completed++);
    }
    if (!mounted) return;
    setState(() {
      _backfilling = false;
      _backfillMessage = error == null
          ? 'Older recordings are up to date.'
          : 'Some voiceprints could not be computed: $error';
    });
  }

  Future<void> _managePerson(
    RecordingRepository repository,
    VoiceprintPersonSummary person,
  ) async {
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
    if (action == 'rename') {
      final controller = TextEditingController(text: person.name);
      final name = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rename person'),
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
              child: const Text('Save'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (name == null || name.trim().isEmpty) return;
      await repository.renamePerson(person.id, name);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete person?'),
        content: Text(
          'Delete ${person.name} and all of their voiceprints? '
          'Confirmed speaker names will remain on recordings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await repository.deletePerson(person.id);
  }
}
