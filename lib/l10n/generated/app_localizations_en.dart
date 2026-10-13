// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ReXorder';

  @override
  String get libraryTitle => 'Recordings';

  @override
  String get newRecording => 'New recording';

  @override
  String get emptyLibraryTitle => 'Your recordings will appear here';

  @override
  String get emptyLibraryBody => 'Tap New recording to capture audio offline.';

  @override
  String get recorderTitle => 'New recording';

  @override
  String get recordingStatus => 'Recording';

  @override
  String get pausedStatus => 'Paused';

  @override
  String get savingStatus => 'Saving recording…';

  @override
  String get readyStatus => 'Ready to record';

  @override
  String get stop => 'Stop';

  @override
  String get stopRecordingQuestion => 'Stop recording?';

  @override
  String get stopRecordingBody =>
      'Stop and save this recording, or keep recording.';

  @override
  String get keepRecording => 'Keep recording';

  @override
  String get stopAndSave => 'Stop and save';

  @override
  String get recordingDetails => 'Recording';

  @override
  String get rename => 'Rename';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get shareWav => 'Share WAV';

  @override
  String get renameRecording => 'Rename recording';

  @override
  String get title => 'Title';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteRecording => 'Delete recording?';

  @override
  String get deleteRecordingBody =>
      'This recording and its audio file will be deleted.';
}
