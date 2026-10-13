import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../compare/run_alignment.dart';
import '../compare/text_diff.dart';
import '../domain/recording.dart';
import '../domain/transcript_segment.dart';
import '../domain/transcription_run.dart';
import '../models/model_catalog.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({
    required this.recordingId,
    this.runA,
    this.runB,
    super.key,
  });

  final String recordingId;
  final String? runA;
  final String? runB;

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  String? _runA;
  String? _runB;

  @override
  void initState() {
    super.initState();
    _runA = widget.runA;
    _runB = widget.runB;
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.read(recordingRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Compare runs')),
      body: StreamBuilder<Recording?>(
        stream: repository.watchRecording(widget.recordingId),
        builder: (context, recordingSnapshot) =>
            StreamBuilder<List<TranscriptionRun>>(
              stream: repository.watchRuns(widget.recordingId),
              builder: (context, runsSnapshot) {
                final recording = recordingSnapshot.data;
                final runs = runsSnapshot.data ?? const <TranscriptionRun>[];
                if (recording == null || runs.isEmpty) {
                  return const Center(child: Text('No transcription runs.'));
                }
                final defaultA = runs.firstWhere(
                  (run) => run.id == recording.activeRunId,
                  orElse: () => runs.first,
                );
                final runA = runs.firstWhere(
                  (run) => run.id == _runA,
                  orElse: () => defaultA,
                );
                final defaultB = runs.firstWhere(
                  (run) =>
                      run.id != runA.id &&
                      run.status == TranscriptionStatus.done,
                  orElse: () => runs.firstWhere(
                    (run) => run.id != runA.id,
                    orElse: () => runA,
                  ),
                );
                final runB = runs.firstWhere(
                  (run) => run.id == _runB && run.id != runA.id,
                  orElse: () => defaultB,
                );
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _runPicker(
                              label: 'A',
                              selected: runA,
                              runs: runs,
                              onChanged: (run) => setState(() => _runA = run),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _runPicker(
                              label: 'B',
                              selected: runB,
                              runs: runs,
                              onChanged: (run) => setState(() => _runB = run),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: runA.id == runB.id
                          ? const Center(
                              child: Text('Choose two different runs.'),
                            )
                          : _ComparisonBody(
                              recording: recording,
                              runA: runA,
                              runB: runB,
                            ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _runPicker({
    required String label,
    required TranscriptionRun selected,
    required List<TranscriptionRun> runs,
    required ValueChanged<String> onChanged,
  }) => DropdownButtonFormField<String>(
    initialValue: selected.id,
    decoration: InputDecoration(labelText: 'Run $label'),
    items: [
      for (final run in runs)
        DropdownMenuItem(value: run.id, child: Text(_modelName(run))),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

class _ComparisonBody extends ConsumerWidget {
  const _ComparisonBody({
    required this.recording,
    required this.runA,
    required this.runB,
  });

  final Recording recording;
  final TranscriptionRun runA;
  final TranscriptionRun runB;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(recordingRepositoryProvider);
    return StreamBuilder<List<TranscriptSegment>>(
      stream: repository.watchRunSegments(runA.id),
      builder: (context, aSnapshot) => StreamBuilder<List<TranscriptSegment>>(
        stream: repository.watchRunSegments(runB.id),
        builder: (context, bSnapshot) {
          final a = aSnapshot.data ?? const <TranscriptSegment>[];
          final b = bSnapshot.data ?? const <TranscriptSegment>[];
          final rows = alignRuns(a, b);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                children: [
                  Expanded(child: _header(context, runA, a)),
                  const SizedBox(width: 8),
                  Expanded(child: _header(context, runB, b)),
                ],
              ),
              for (final row in rows)
                Card(
                  child: InkWell(
                    onTap: () => context.push(
                      '/recording/${recording.id}?t=${row.a?.startMs ?? row.b.first.startMs}',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_time(row.a?.startMs ?? row.b.first.startMs)),
                          const SizedBox(height: 6),
                          _DiffLine(
                            label: 'A · ${_shortName(runA)}',
                            spans: diffText(
                              row.a?.text ?? '',
                              row.b
                                  .map((segment) => segment.text ?? '')
                                  .join(' '),
                            ).a,
                          ),
                          for (final segment in row.b)
                            _DiffLine(
                              label: 'B · ${_shortName(runB)}',
                              spans: diffText(
                                row.a?.text ?? '',
                                segment.text ?? '',
                              ).b,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(
    BuildContext context,
    TranscriptionRun run,
    List<TranscriptSegment> segments,
  ) {
    final speakers = segments
        .map((segment) => segment.speaker)
        .whereType<int>()
        .toSet()
        .length;
    final durationMs = recording.durationMs;
    final rtf = durationMs == 0
        ? '—'
        : (run.processingMs / durationMs).toStringAsFixed(2);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _modelName(run),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(run.languageHint.name),
            Text(speakers == 0 ? 'No speakers' : '$speakers speakers'),
            Text('${_time(run.processingMs)} · RTF $rtf'),
            Text('${segments.length} segments'),
          ],
        ),
      ),
    );
  }
}

class _DiffLine extends StatelessWidget {
  const _DiffLine({required this.label, required this.spans});

  final String label;
  final List<DiffSpan> spans;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(text: '$label: '),
            for (final span in spans)
              TextSpan(
                text: span.text,
                style: span.changed
                    ? TextStyle(
                        backgroundColor: scheme.tertiaryContainer,
                        color: scheme.onTertiaryContainer,
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

String _modelName(TranscriptionRun run) =>
    modelById(run.asrModelId ?? '')?.displayName ?? 'Unknown model';

String _shortName(TranscriptionRun run) =>
    modelById(run.asrModelId ?? '')?.displayName.split(' ').first ?? 'Run';

String _time(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  return '${duration.inMinutes.toString().padLeft(2, '0')}:'
      '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}
