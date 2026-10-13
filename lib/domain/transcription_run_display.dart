import 'package:intl/intl.dart';

import 'recording.dart';
import 'transcription_run.dart';

String runLanguageLabel(LanguageHint language) => switch (language) {
  LanguageHint.auto => 'Auto',
  LanguageHint.en => 'English',
  LanguageHint.ja => '日本語',
};

String runSpeakerCountLabel({
  required int detected,
  required int? hint,
  bool diarized = false,
}) {
  if (detected > 0) return _speakerCount(detected);
  if (hint != null) return _speakerCount(hint);
  return diarized ? 'No speakers' : 'Auto speakers';
}

String runProcessingTimeLabel(int processingMs) {
  final duration = Duration(milliseconds: processingMs);
  return '${duration.inMinutes}:'
      '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}

String runDetailsLabel(TranscriptionRun run) {
  final date = DateFormat('MM/dd HH:mm').format(run.createdAt.toLocal());
  return '${runLanguageLabel(run.languageHint)} · '
      '${runSpeakerCountLabel(detected: run.speakerCount, hint: run.speakerCountHint, diarized: run.diarized)} · '
      '$date · ${runProcessingTimeLabel(run.processingMs)} processing';
}

String _speakerCount(int count) =>
    '$count ${count == 1 ? 'speaker' : 'speakers'}';
