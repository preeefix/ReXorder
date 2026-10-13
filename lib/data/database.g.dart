// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RecordingsTable extends Recordings
    with TableInfo<$RecordingsTable, Recording> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sampleRateMeta = const VerificationMeta(
    'sampleRate',
  );
  @override
  late final GeneratedColumn<int> sampleRate = GeneratedColumn<int>(
    'sample_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecordingStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordingStatus>($RecordingsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<TranscriptionStatus, String>
  transcriptionStatus =
      GeneratedColumn<String>(
        'transcription_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('none'),
      ).withConverter<TranscriptionStatus>(
        $RecordingsTable.$convertertranscriptionStatus,
      );
  @override
  late final GeneratedColumnWithTypeConverter<LanguageHint, String>
  languageHint = GeneratedColumn<String>(
    'language_hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  ).withConverter<LanguageHint>($RecordingsTable.$converterlanguageHint);
  static const VerificationMeta _asrModelIdMeta = const VerificationMeta(
    'asrModelId',
  );
  @override
  late final GeneratedColumn<String> asrModelId = GeneratedColumn<String>(
    'asr_model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptionErrorMeta =
      const VerificationMeta('transcriptionError');
  @override
  late final GeneratedColumn<String> transcriptionError =
      GeneratedColumn<String>(
        'transcription_error',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _speakerCountHintMeta = const VerificationMeta(
    'speakerCountHint',
  );
  @override
  late final GeneratedColumn<int> speakerCountHint = GeneratedColumn<int>(
    'speaker_count_hint',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeRunIdMeta = const VerificationMeta(
    'activeRunId',
  );
  @override
  late final GeneratedColumn<String> activeRunId = GeneratedColumn<String>(
    'active_run_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    createdAt,
    durationMs,
    fileName,
    sampleRate,
    status,
    transcriptionStatus,
    languageHint,
    asrModelId,
    transcriptionError,
    speakerCountHint,
    activeRunId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recordings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recording> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('sample_rate')) {
      context.handle(
        _sampleRateMeta,
        sampleRate.isAcceptableOrUnknown(data['sample_rate']!, _sampleRateMeta),
      );
    } else if (isInserting) {
      context.missing(_sampleRateMeta);
    }
    if (data.containsKey('asr_model_id')) {
      context.handle(
        _asrModelIdMeta,
        asrModelId.isAcceptableOrUnknown(
          data['asr_model_id']!,
          _asrModelIdMeta,
        ),
      );
    }
    if (data.containsKey('transcription_error')) {
      context.handle(
        _transcriptionErrorMeta,
        transcriptionError.isAcceptableOrUnknown(
          data['transcription_error']!,
          _transcriptionErrorMeta,
        ),
      );
    }
    if (data.containsKey('speaker_count_hint')) {
      context.handle(
        _speakerCountHintMeta,
        speakerCountHint.isAcceptableOrUnknown(
          data['speaker_count_hint']!,
          _speakerCountHintMeta,
        ),
      );
    }
    if (data.containsKey('active_run_id')) {
      context.handle(
        _activeRunIdMeta,
        activeRunId.isAcceptableOrUnknown(
          data['active_run_id']!,
          _activeRunIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recording map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recording(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      sampleRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_rate'],
      )!,
      status: $RecordingsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      transcriptionStatus: $RecordingsTable.$convertertranscriptionStatus
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}transcription_status'],
            )!,
          ),
      languageHint: $RecordingsTable.$converterlanguageHint.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}language_hint'],
        )!,
      ),
      asrModelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asr_model_id'],
      ),
      transcriptionError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcription_error'],
      ),
      speakerCountHint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaker_count_hint'],
      ),
      activeRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_run_id'],
      ),
    );
  }

  @override
  $RecordingsTable createAlias(String alias) {
    return $RecordingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecordingStatus, String, String> $converterstatus =
      const EnumNameConverter<RecordingStatus>(RecordingStatus.values);
  static JsonTypeConverter2<TranscriptionStatus, String, String>
  $convertertranscriptionStatus = const EnumNameConverter<TranscriptionStatus>(
    TranscriptionStatus.values,
  );
  static JsonTypeConverter2<LanguageHint, String, String>
  $converterlanguageHint = const EnumNameConverter<LanguageHint>(
    LanguageHint.values,
  );
}

class Recording extends DataClass implements Insertable<Recording> {
  final String id;
  final String title;
  final DateTime createdAt;
  final int durationMs;
  final String fileName;
  final int sampleRate;
  final RecordingStatus status;
  final TranscriptionStatus transcriptionStatus;
  final LanguageHint languageHint;
  final String? asrModelId;
  final String? transcriptionError;
  final int? speakerCountHint;
  final String? activeRunId;
  const Recording({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.durationMs,
    required this.fileName,
    required this.sampleRate,
    required this.status,
    required this.transcriptionStatus,
    required this.languageHint,
    this.asrModelId,
    this.transcriptionError,
    this.speakerCountHint,
    this.activeRunId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_name'] = Variable<String>(fileName);
    map['sample_rate'] = Variable<int>(sampleRate);
    {
      map['status'] = Variable<String>(
        $RecordingsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['transcription_status'] = Variable<String>(
        $RecordingsTable.$convertertranscriptionStatus.toSql(
          transcriptionStatus,
        ),
      );
    }
    {
      map['language_hint'] = Variable<String>(
        $RecordingsTable.$converterlanguageHint.toSql(languageHint),
      );
    }
    if (!nullToAbsent || asrModelId != null) {
      map['asr_model_id'] = Variable<String>(asrModelId);
    }
    if (!nullToAbsent || transcriptionError != null) {
      map['transcription_error'] = Variable<String>(transcriptionError);
    }
    if (!nullToAbsent || speakerCountHint != null) {
      map['speaker_count_hint'] = Variable<int>(speakerCountHint);
    }
    if (!nullToAbsent || activeRunId != null) {
      map['active_run_id'] = Variable<String>(activeRunId);
    }
    return map;
  }

  RecordingsCompanion toCompanion(bool nullToAbsent) {
    return RecordingsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      durationMs: Value(durationMs),
      fileName: Value(fileName),
      sampleRate: Value(sampleRate),
      status: Value(status),
      transcriptionStatus: Value(transcriptionStatus),
      languageHint: Value(languageHint),
      asrModelId: asrModelId == null && nullToAbsent
          ? const Value.absent()
          : Value(asrModelId),
      transcriptionError: transcriptionError == null && nullToAbsent
          ? const Value.absent()
          : Value(transcriptionError),
      speakerCountHint: speakerCountHint == null && nullToAbsent
          ? const Value.absent()
          : Value(speakerCountHint),
      activeRunId: activeRunId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeRunId),
    );
  }

  factory Recording.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recording(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      fileName: serializer.fromJson<String>(json['fileName']),
      sampleRate: serializer.fromJson<int>(json['sampleRate']),
      status: $RecordingsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      transcriptionStatus: $RecordingsTable.$convertertranscriptionStatus
          .fromJson(serializer.fromJson<String>(json['transcriptionStatus'])),
      languageHint: $RecordingsTable.$converterlanguageHint.fromJson(
        serializer.fromJson<String>(json['languageHint']),
      ),
      asrModelId: serializer.fromJson<String?>(json['asrModelId']),
      transcriptionError: serializer.fromJson<String?>(
        json['transcriptionError'],
      ),
      speakerCountHint: serializer.fromJson<int?>(json['speakerCountHint']),
      activeRunId: serializer.fromJson<String?>(json['activeRunId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'fileName': serializer.toJson<String>(fileName),
      'sampleRate': serializer.toJson<int>(sampleRate),
      'status': serializer.toJson<String>(
        $RecordingsTable.$converterstatus.toJson(status),
      ),
      'transcriptionStatus': serializer.toJson<String>(
        $RecordingsTable.$convertertranscriptionStatus.toJson(
          transcriptionStatus,
        ),
      ),
      'languageHint': serializer.toJson<String>(
        $RecordingsTable.$converterlanguageHint.toJson(languageHint),
      ),
      'asrModelId': serializer.toJson<String?>(asrModelId),
      'transcriptionError': serializer.toJson<String?>(transcriptionError),
      'speakerCountHint': serializer.toJson<int?>(speakerCountHint),
      'activeRunId': serializer.toJson<String?>(activeRunId),
    };
  }

  Recording copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    int? durationMs,
    String? fileName,
    int? sampleRate,
    RecordingStatus? status,
    TranscriptionStatus? transcriptionStatus,
    LanguageHint? languageHint,
    Value<String?> asrModelId = const Value.absent(),
    Value<String?> transcriptionError = const Value.absent(),
    Value<int?> speakerCountHint = const Value.absent(),
    Value<String?> activeRunId = const Value.absent(),
  }) => Recording(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    durationMs: durationMs ?? this.durationMs,
    fileName: fileName ?? this.fileName,
    sampleRate: sampleRate ?? this.sampleRate,
    status: status ?? this.status,
    transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
    languageHint: languageHint ?? this.languageHint,
    asrModelId: asrModelId.present ? asrModelId.value : this.asrModelId,
    transcriptionError: transcriptionError.present
        ? transcriptionError.value
        : this.transcriptionError,
    speakerCountHint: speakerCountHint.present
        ? speakerCountHint.value
        : this.speakerCountHint,
    activeRunId: activeRunId.present ? activeRunId.value : this.activeRunId,
  );
  Recording copyWithCompanion(RecordingsCompanion data) {
    return Recording(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      sampleRate: data.sampleRate.present
          ? data.sampleRate.value
          : this.sampleRate,
      status: data.status.present ? data.status.value : this.status,
      transcriptionStatus: data.transcriptionStatus.present
          ? data.transcriptionStatus.value
          : this.transcriptionStatus,
      languageHint: data.languageHint.present
          ? data.languageHint.value
          : this.languageHint,
      asrModelId: data.asrModelId.present
          ? data.asrModelId.value
          : this.asrModelId,
      transcriptionError: data.transcriptionError.present
          ? data.transcriptionError.value
          : this.transcriptionError,
      speakerCountHint: data.speakerCountHint.present
          ? data.speakerCountHint.value
          : this.speakerCountHint,
      activeRunId: data.activeRunId.present
          ? data.activeRunId.value
          : this.activeRunId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recording(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileName: $fileName, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('status: $status, ')
          ..write('transcriptionStatus: $transcriptionStatus, ')
          ..write('languageHint: $languageHint, ')
          ..write('asrModelId: $asrModelId, ')
          ..write('transcriptionError: $transcriptionError, ')
          ..write('speakerCountHint: $speakerCountHint, ')
          ..write('activeRunId: $activeRunId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    createdAt,
    durationMs,
    fileName,
    sampleRate,
    status,
    transcriptionStatus,
    languageHint,
    asrModelId,
    transcriptionError,
    speakerCountHint,
    activeRunId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recording &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.durationMs == this.durationMs &&
          other.fileName == this.fileName &&
          other.sampleRate == this.sampleRate &&
          other.status == this.status &&
          other.transcriptionStatus == this.transcriptionStatus &&
          other.languageHint == this.languageHint &&
          other.asrModelId == this.asrModelId &&
          other.transcriptionError == this.transcriptionError &&
          other.speakerCountHint == this.speakerCountHint &&
          other.activeRunId == this.activeRunId);
}

class RecordingsCompanion extends UpdateCompanion<Recording> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<int> durationMs;
  final Value<String> fileName;
  final Value<int> sampleRate;
  final Value<RecordingStatus> status;
  final Value<TranscriptionStatus> transcriptionStatus;
  final Value<LanguageHint> languageHint;
  final Value<String?> asrModelId;
  final Value<String?> transcriptionError;
  final Value<int?> speakerCountHint;
  final Value<String?> activeRunId;
  final Value<int> rowid;
  const RecordingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileName = const Value.absent(),
    this.sampleRate = const Value.absent(),
    this.status = const Value.absent(),
    this.transcriptionStatus = const Value.absent(),
    this.languageHint = const Value.absent(),
    this.asrModelId = const Value.absent(),
    this.transcriptionError = const Value.absent(),
    this.speakerCountHint = const Value.absent(),
    this.activeRunId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecordingsCompanion.insert({
    required String id,
    required String title,
    required DateTime createdAt,
    required int durationMs,
    required String fileName,
    required int sampleRate,
    required RecordingStatus status,
    this.transcriptionStatus = const Value.absent(),
    this.languageHint = const Value.absent(),
    this.asrModelId = const Value.absent(),
    this.transcriptionError = const Value.absent(),
    this.speakerCountHint = const Value.absent(),
    this.activeRunId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       durationMs = Value(durationMs),
       fileName = Value(fileName),
       sampleRate = Value(sampleRate),
       status = Value(status);
  static Insertable<Recording> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<int>? durationMs,
    Expression<String>? fileName,
    Expression<int>? sampleRate,
    Expression<String>? status,
    Expression<String>? transcriptionStatus,
    Expression<String>? languageHint,
    Expression<String>? asrModelId,
    Expression<String>? transcriptionError,
    Expression<int>? speakerCountHint,
    Expression<String>? activeRunId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (fileName != null) 'file_name': fileName,
      if (sampleRate != null) 'sample_rate': sampleRate,
      if (status != null) 'status': status,
      if (transcriptionStatus != null)
        'transcription_status': transcriptionStatus,
      if (languageHint != null) 'language_hint': languageHint,
      if (asrModelId != null) 'asr_model_id': asrModelId,
      if (transcriptionError != null) 'transcription_error': transcriptionError,
      if (speakerCountHint != null) 'speaker_count_hint': speakerCountHint,
      if (activeRunId != null) 'active_run_id': activeRunId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecordingsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<int>? durationMs,
    Value<String>? fileName,
    Value<int>? sampleRate,
    Value<RecordingStatus>? status,
    Value<TranscriptionStatus>? transcriptionStatus,
    Value<LanguageHint>? languageHint,
    Value<String?>? asrModelId,
    Value<String?>? transcriptionError,
    Value<int?>? speakerCountHint,
    Value<String?>? activeRunId,
    Value<int>? rowid,
  }) {
    return RecordingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      durationMs: durationMs ?? this.durationMs,
      fileName: fileName ?? this.fileName,
      sampleRate: sampleRate ?? this.sampleRate,
      status: status ?? this.status,
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      languageHint: languageHint ?? this.languageHint,
      asrModelId: asrModelId ?? this.asrModelId,
      transcriptionError: transcriptionError ?? this.transcriptionError,
      speakerCountHint: speakerCountHint ?? this.speakerCountHint,
      activeRunId: activeRunId ?? this.activeRunId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (sampleRate.present) {
      map['sample_rate'] = Variable<int>(sampleRate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RecordingsTable.$converterstatus.toSql(status.value),
      );
    }
    if (transcriptionStatus.present) {
      map['transcription_status'] = Variable<String>(
        $RecordingsTable.$convertertranscriptionStatus.toSql(
          transcriptionStatus.value,
        ),
      );
    }
    if (languageHint.present) {
      map['language_hint'] = Variable<String>(
        $RecordingsTable.$converterlanguageHint.toSql(languageHint.value),
      );
    }
    if (asrModelId.present) {
      map['asr_model_id'] = Variable<String>(asrModelId.value);
    }
    if (transcriptionError.present) {
      map['transcription_error'] = Variable<String>(transcriptionError.value);
    }
    if (speakerCountHint.present) {
      map['speaker_count_hint'] = Variable<int>(speakerCountHint.value);
    }
    if (activeRunId.present) {
      map['active_run_id'] = Variable<String>(activeRunId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordingsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileName: $fileName, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('status: $status, ')
          ..write('transcriptionStatus: $transcriptionStatus, ')
          ..write('languageHint: $languageHint, ')
          ..write('asrModelId: $asrModelId, ')
          ..write('transcriptionError: $transcriptionError, ')
          ..write('speakerCountHint: $speakerCountHint, ')
          ..write('activeRunId: $activeRunId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranscriptionRunsTable extends TranscriptionRuns
    with TableInfo<$TranscriptionRunsTable, TranscriptionRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptionRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _asrModelIdMeta = const VerificationMeta(
    'asrModelId',
  );
  @override
  late final GeneratedColumn<String> asrModelId = GeneratedColumn<String>(
    'asr_model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LanguageHint, String>
  languageHint = GeneratedColumn<String>(
    'language_hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LanguageHint>($TranscriptionRunsTable.$converterlanguageHint);
  static const VerificationMeta _speakerCountHintMeta = const VerificationMeta(
    'speakerCountHint',
  );
  @override
  late final GeneratedColumn<int> speakerCountHint = GeneratedColumn<int>(
    'speaker_count_hint',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diarizedMeta = const VerificationMeta(
    'diarized',
  );
  @override
  late final GeneratedColumn<bool> diarized = GeneratedColumn<bool>(
    'diarized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("diarized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TranscriptionStatus, String>
  status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TranscriptionStatus>(
        $TranscriptionRunsTable.$converterstatus,
      );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processingMsMeta = const VerificationMeta(
    'processingMs',
  );
  @override
  late final GeneratedColumn<int> processingMs = GeneratedColumn<int>(
    'processing_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordingId,
    createdAt,
    completedAt,
    asrModelId,
    languageHint,
    speakerCountHint,
    diarized,
    status,
    error,
    processingMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcription_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranscriptionRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('asr_model_id')) {
      context.handle(
        _asrModelIdMeta,
        asrModelId.isAcceptableOrUnknown(
          data['asr_model_id']!,
          _asrModelIdMeta,
        ),
      );
    }
    if (data.containsKey('speaker_count_hint')) {
      context.handle(
        _speakerCountHintMeta,
        speakerCountHint.isAcceptableOrUnknown(
          data['speaker_count_hint']!,
          _speakerCountHintMeta,
        ),
      );
    }
    if (data.containsKey('diarized')) {
      context.handle(
        _diarizedMeta,
        diarized.isAcceptableOrUnknown(data['diarized']!, _diarizedMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('processing_ms')) {
      context.handle(
        _processingMsMeta,
        processingMs.isAcceptableOrUnknown(
          data['processing_ms']!,
          _processingMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranscriptionRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptionRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      asrModelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asr_model_id'],
      ),
      languageHint: $TranscriptionRunsTable.$converterlanguageHint.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}language_hint'],
        )!,
      ),
      speakerCountHint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaker_count_hint'],
      ),
      diarized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}diarized'],
      )!,
      status: $TranscriptionRunsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      processingMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processing_ms'],
      )!,
    );
  }

  @override
  $TranscriptionRunsTable createAlias(String alias) {
    return $TranscriptionRunsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LanguageHint, String, String>
  $converterlanguageHint = const EnumNameConverter<LanguageHint>(
    LanguageHint.values,
  );
  static JsonTypeConverter2<TranscriptionStatus, String, String>
  $converterstatus = const EnumNameConverter<TranscriptionStatus>(
    TranscriptionStatus.values,
  );
}

class TranscriptionRun extends DataClass
    implements Insertable<TranscriptionRun> {
  final String id;
  final String recordingId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? asrModelId;
  final LanguageHint languageHint;
  final int? speakerCountHint;
  final bool diarized;
  final TranscriptionStatus status;
  final String? error;
  final int processingMs;
  const TranscriptionRun({
    required this.id,
    required this.recordingId,
    required this.createdAt,
    this.completedAt,
    this.asrModelId,
    required this.languageHint,
    this.speakerCountHint,
    required this.diarized,
    required this.status,
    this.error,
    required this.processingMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recording_id'] = Variable<String>(recordingId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || asrModelId != null) {
      map['asr_model_id'] = Variable<String>(asrModelId);
    }
    {
      map['language_hint'] = Variable<String>(
        $TranscriptionRunsTable.$converterlanguageHint.toSql(languageHint),
      );
    }
    if (!nullToAbsent || speakerCountHint != null) {
      map['speaker_count_hint'] = Variable<int>(speakerCountHint);
    }
    map['diarized'] = Variable<bool>(diarized);
    {
      map['status'] = Variable<String>(
        $TranscriptionRunsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['processing_ms'] = Variable<int>(processingMs);
    return map;
  }

  TranscriptionRunsCompanion toCompanion(bool nullToAbsent) {
    return TranscriptionRunsCompanion(
      id: Value(id),
      recordingId: Value(recordingId),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      asrModelId: asrModelId == null && nullToAbsent
          ? const Value.absent()
          : Value(asrModelId),
      languageHint: Value(languageHint),
      speakerCountHint: speakerCountHint == null && nullToAbsent
          ? const Value.absent()
          : Value(speakerCountHint),
      diarized: Value(diarized),
      status: Value(status),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      processingMs: Value(processingMs),
    );
  }

  factory TranscriptionRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptionRun(
      id: serializer.fromJson<String>(json['id']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      asrModelId: serializer.fromJson<String?>(json['asrModelId']),
      languageHint: $TranscriptionRunsTable.$converterlanguageHint.fromJson(
        serializer.fromJson<String>(json['languageHint']),
      ),
      speakerCountHint: serializer.fromJson<int?>(json['speakerCountHint']),
      diarized: serializer.fromJson<bool>(json['diarized']),
      status: $TranscriptionRunsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      error: serializer.fromJson<String?>(json['error']),
      processingMs: serializer.fromJson<int>(json['processingMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recordingId': serializer.toJson<String>(recordingId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'asrModelId': serializer.toJson<String?>(asrModelId),
      'languageHint': serializer.toJson<String>(
        $TranscriptionRunsTable.$converterlanguageHint.toJson(languageHint),
      ),
      'speakerCountHint': serializer.toJson<int?>(speakerCountHint),
      'diarized': serializer.toJson<bool>(diarized),
      'status': serializer.toJson<String>(
        $TranscriptionRunsTable.$converterstatus.toJson(status),
      ),
      'error': serializer.toJson<String?>(error),
      'processingMs': serializer.toJson<int>(processingMs),
    };
  }

  TranscriptionRun copyWith({
    String? id,
    String? recordingId,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> asrModelId = const Value.absent(),
    LanguageHint? languageHint,
    Value<int?> speakerCountHint = const Value.absent(),
    bool? diarized,
    TranscriptionStatus? status,
    Value<String?> error = const Value.absent(),
    int? processingMs,
  }) => TranscriptionRun(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    asrModelId: asrModelId.present ? asrModelId.value : this.asrModelId,
    languageHint: languageHint ?? this.languageHint,
    speakerCountHint: speakerCountHint.present
        ? speakerCountHint.value
        : this.speakerCountHint,
    diarized: diarized ?? this.diarized,
    status: status ?? this.status,
    error: error.present ? error.value : this.error,
    processingMs: processingMs ?? this.processingMs,
  );
  TranscriptionRun copyWithCompanion(TranscriptionRunsCompanion data) {
    return TranscriptionRun(
      id: data.id.present ? data.id.value : this.id,
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      asrModelId: data.asrModelId.present
          ? data.asrModelId.value
          : this.asrModelId,
      languageHint: data.languageHint.present
          ? data.languageHint.value
          : this.languageHint,
      speakerCountHint: data.speakerCountHint.present
          ? data.speakerCountHint.value
          : this.speakerCountHint,
      diarized: data.diarized.present ? data.diarized.value : this.diarized,
      status: data.status.present ? data.status.value : this.status,
      error: data.error.present ? data.error.value : this.error,
      processingMs: data.processingMs.present
          ? data.processingMs.value
          : this.processingMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptionRun(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('asrModelId: $asrModelId, ')
          ..write('languageHint: $languageHint, ')
          ..write('speakerCountHint: $speakerCountHint, ')
          ..write('diarized: $diarized, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('processingMs: $processingMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordingId,
    createdAt,
    completedAt,
    asrModelId,
    languageHint,
    speakerCountHint,
    diarized,
    status,
    error,
    processingMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptionRun &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.asrModelId == this.asrModelId &&
          other.languageHint == this.languageHint &&
          other.speakerCountHint == this.speakerCountHint &&
          other.diarized == this.diarized &&
          other.status == this.status &&
          other.error == this.error &&
          other.processingMs == this.processingMs);
}

class TranscriptionRunsCompanion extends UpdateCompanion<TranscriptionRun> {
  final Value<String> id;
  final Value<String> recordingId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<String?> asrModelId;
  final Value<LanguageHint> languageHint;
  final Value<int?> speakerCountHint;
  final Value<bool> diarized;
  final Value<TranscriptionStatus> status;
  final Value<String?> error;
  final Value<int> processingMs;
  final Value<int> rowid;
  const TranscriptionRunsCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.asrModelId = const Value.absent(),
    this.languageHint = const Value.absent(),
    this.speakerCountHint = const Value.absent(),
    this.diarized = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.processingMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranscriptionRunsCompanion.insert({
    required String id,
    required String recordingId,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.asrModelId = const Value.absent(),
    required LanguageHint languageHint,
    this.speakerCountHint = const Value.absent(),
    this.diarized = const Value.absent(),
    required TranscriptionStatus status,
    this.error = const Value.absent(),
    this.processingMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recordingId = Value(recordingId),
       createdAt = Value(createdAt),
       languageHint = Value(languageHint),
       status = Value(status);
  static Insertable<TranscriptionRun> custom({
    Expression<String>? id,
    Expression<String>? recordingId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<String>? asrModelId,
    Expression<String>? languageHint,
    Expression<int>? speakerCountHint,
    Expression<bool>? diarized,
    Expression<String>? status,
    Expression<String>? error,
    Expression<int>? processingMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordingId != null) 'recording_id': recordingId,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (asrModelId != null) 'asr_model_id': asrModelId,
      if (languageHint != null) 'language_hint': languageHint,
      if (speakerCountHint != null) 'speaker_count_hint': speakerCountHint,
      if (diarized != null) 'diarized': diarized,
      if (status != null) 'status': status,
      if (error != null) 'error': error,
      if (processingMs != null) 'processing_ms': processingMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranscriptionRunsCompanion copyWith({
    Value<String>? id,
    Value<String>? recordingId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<String?>? asrModelId,
    Value<LanguageHint>? languageHint,
    Value<int?>? speakerCountHint,
    Value<bool>? diarized,
    Value<TranscriptionStatus>? status,
    Value<String?>? error,
    Value<int>? processingMs,
    Value<int>? rowid,
  }) {
    return TranscriptionRunsCompanion(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      asrModelId: asrModelId ?? this.asrModelId,
      languageHint: languageHint ?? this.languageHint,
      speakerCountHint: speakerCountHint ?? this.speakerCountHint,
      diarized: diarized ?? this.diarized,
      status: status ?? this.status,
      error: error ?? this.error,
      processingMs: processingMs ?? this.processingMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (asrModelId.present) {
      map['asr_model_id'] = Variable<String>(asrModelId.value);
    }
    if (languageHint.present) {
      map['language_hint'] = Variable<String>(
        $TranscriptionRunsTable.$converterlanguageHint.toSql(
          languageHint.value,
        ),
      );
    }
    if (speakerCountHint.present) {
      map['speaker_count_hint'] = Variable<int>(speakerCountHint.value);
    }
    if (diarized.present) {
      map['diarized'] = Variable<bool>(diarized.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TranscriptionRunsTable.$converterstatus.toSql(status.value),
      );
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (processingMs.present) {
      map['processing_ms'] = Variable<int>(processingMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptionRunsCompanion(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('asrModelId: $asrModelId, ')
          ..write('languageHint: $languageHint, ')
          ..write('speakerCountHint: $speakerCountHint, ')
          ..write('diarized: $diarized, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('processingMs: $processingMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunSpeakerEmbeddingsTable extends RunSpeakerEmbeddings
    with TableInfo<$RunSpeakerEmbeddingsTable, RunSpeakerEmbedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunSpeakerEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerMeta = const VerificationMeta(
    'speaker',
  );
  @override
  late final GeneratedColumn<int> speaker = GeneratedColumn<int>(
    'speaker',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _embeddingMeta = const VerificationMeta(
    'embedding',
  );
  @override
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
    'embedding',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speechMsMeta = const VerificationMeta(
    'speechMs',
  );
  @override
  late final GeneratedColumn<int> speechMs = GeneratedColumn<int>(
    'speech_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [runId, speaker, embedding, speechMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_speaker_embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunSpeakerEmbedding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('speaker')) {
      context.handle(
        _speakerMeta,
        speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta),
      );
    } else if (isInserting) {
      context.missing(_speakerMeta);
    }
    if (data.containsKey('embedding')) {
      context.handle(
        _embeddingMeta,
        embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta),
      );
    } else if (isInserting) {
      context.missing(_embeddingMeta);
    }
    if (data.containsKey('speech_ms')) {
      context.handle(
        _speechMsMeta,
        speechMs.isAcceptableOrUnknown(data['speech_ms']!, _speechMsMeta),
      );
    } else if (isInserting) {
      context.missing(_speechMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId, speaker};
  @override
  RunSpeakerEmbedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunSpeakerEmbedding(
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaker'],
      )!,
      embedding: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}embedding'],
      )!,
      speechMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speech_ms'],
      )!,
    );
  }

  @override
  $RunSpeakerEmbeddingsTable createAlias(String alias) {
    return $RunSpeakerEmbeddingsTable(attachedDatabase, alias);
  }
}

class RunSpeakerEmbedding extends DataClass
    implements Insertable<RunSpeakerEmbedding> {
  final String runId;
  final int speaker;
  final Uint8List embedding;
  final int speechMs;
  const RunSpeakerEmbedding({
    required this.runId,
    required this.speaker,
    required this.embedding,
    required this.speechMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['speaker'] = Variable<int>(speaker);
    map['embedding'] = Variable<Uint8List>(embedding);
    map['speech_ms'] = Variable<int>(speechMs);
    return map;
  }

  RunSpeakerEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return RunSpeakerEmbeddingsCompanion(
      runId: Value(runId),
      speaker: Value(speaker),
      embedding: Value(embedding),
      speechMs: Value(speechMs),
    );
  }

  factory RunSpeakerEmbedding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunSpeakerEmbedding(
      runId: serializer.fromJson<String>(json['runId']),
      speaker: serializer.fromJson<int>(json['speaker']),
      embedding: serializer.fromJson<Uint8List>(json['embedding']),
      speechMs: serializer.fromJson<int>(json['speechMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'speaker': serializer.toJson<int>(speaker),
      'embedding': serializer.toJson<Uint8List>(embedding),
      'speechMs': serializer.toJson<int>(speechMs),
    };
  }

  RunSpeakerEmbedding copyWith({
    String? runId,
    int? speaker,
    Uint8List? embedding,
    int? speechMs,
  }) => RunSpeakerEmbedding(
    runId: runId ?? this.runId,
    speaker: speaker ?? this.speaker,
    embedding: embedding ?? this.embedding,
    speechMs: speechMs ?? this.speechMs,
  );
  RunSpeakerEmbedding copyWithCompanion(RunSpeakerEmbeddingsCompanion data) {
    return RunSpeakerEmbedding(
      runId: data.runId.present ? data.runId.value : this.runId,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      speechMs: data.speechMs.present ? data.speechMs.value : this.speechMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunSpeakerEmbedding(')
          ..write('runId: $runId, ')
          ..write('speaker: $speaker, ')
          ..write('embedding: $embedding, ')
          ..write('speechMs: $speechMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(runId, speaker, $driftBlobEquality.hash(embedding), speechMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunSpeakerEmbedding &&
          other.runId == this.runId &&
          other.speaker == this.speaker &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.speechMs == this.speechMs);
}

class RunSpeakerEmbeddingsCompanion
    extends UpdateCompanion<RunSpeakerEmbedding> {
  final Value<String> runId;
  final Value<int> speaker;
  final Value<Uint8List> embedding;
  final Value<int> speechMs;
  final Value<int> rowid;
  const RunSpeakerEmbeddingsCompanion({
    this.runId = const Value.absent(),
    this.speaker = const Value.absent(),
    this.embedding = const Value.absent(),
    this.speechMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunSpeakerEmbeddingsCompanion.insert({
    required String runId,
    required int speaker,
    required Uint8List embedding,
    required int speechMs,
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       speaker = Value(speaker),
       embedding = Value(embedding),
       speechMs = Value(speechMs);
  static Insertable<RunSpeakerEmbedding> custom({
    Expression<String>? runId,
    Expression<int>? speaker,
    Expression<Uint8List>? embedding,
    Expression<int>? speechMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (speaker != null) 'speaker': speaker,
      if (embedding != null) 'embedding': embedding,
      if (speechMs != null) 'speech_ms': speechMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunSpeakerEmbeddingsCompanion copyWith({
    Value<String>? runId,
    Value<int>? speaker,
    Value<Uint8List>? embedding,
    Value<int>? speechMs,
    Value<int>? rowid,
  }) {
    return RunSpeakerEmbeddingsCompanion(
      runId: runId ?? this.runId,
      speaker: speaker ?? this.speaker,
      embedding: embedding ?? this.embedding,
      speechMs: speechMs ?? this.speechMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<int>(speaker.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (speechMs.present) {
      map['speech_ms'] = Variable<int>(speechMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunSpeakerEmbeddingsCompanion(')
          ..write('runId: $runId, ')
          ..write('speaker: $speaker, ')
          ..write('embedding: $embedding, ')
          ..write('speechMs: $speechMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, PeopleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeopleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeopleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeopleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class PeopleData extends DataClass implements Insertable<PeopleData> {
  final String id;
  final String name;
  final DateTime createdAt;
  const PeopleData({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PeopleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeopleData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PeopleData copyWith({String? id, String? name, DateTime? createdAt}) =>
      PeopleData(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  PeopleData copyWithCompanion(PeopleCompanion data) {
    return PeopleData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeopleData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeopleData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PeopleCompanion extends UpdateCompanion<PeopleData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PeopleData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonVoiceprintsTable extends PersonVoiceprints
    with TableInfo<$PersonVoiceprintsTable, PersonVoiceprint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonVoiceprintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _embeddingMeta = const VerificationMeta(
    'embedding',
  );
  @override
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
    'embedding',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRunIdMeta = const VerificationMeta(
    'sourceRunId',
  );
  @override
  late final GeneratedColumn<String> sourceRunId = GeneratedColumn<String>(
    'source_run_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceSpeakerMeta = const VerificationMeta(
    'sourceSpeaker',
  );
  @override
  late final GeneratedColumn<int> sourceSpeaker = GeneratedColumn<int>(
    'source_speaker',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speechMsMeta = const VerificationMeta(
    'speechMs',
  );
  @override
  late final GeneratedColumn<int> speechMs = GeneratedColumn<int>(
    'speech_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    embedding,
    sourceRunId,
    sourceSpeaker,
    speechMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_voiceprints';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonVoiceprint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('embedding')) {
      context.handle(
        _embeddingMeta,
        embedding.isAcceptableOrUnknown(data['embedding']!, _embeddingMeta),
      );
    } else if (isInserting) {
      context.missing(_embeddingMeta);
    }
    if (data.containsKey('source_run_id')) {
      context.handle(
        _sourceRunIdMeta,
        sourceRunId.isAcceptableOrUnknown(
          data['source_run_id']!,
          _sourceRunIdMeta,
        ),
      );
    }
    if (data.containsKey('source_speaker')) {
      context.handle(
        _sourceSpeakerMeta,
        sourceSpeaker.isAcceptableOrUnknown(
          data['source_speaker']!,
          _sourceSpeakerMeta,
        ),
      );
    }
    if (data.containsKey('speech_ms')) {
      context.handle(
        _speechMsMeta,
        speechMs.isAcceptableOrUnknown(data['speech_ms']!, _speechMsMeta),
      );
    } else if (isInserting) {
      context.missing(_speechMsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonVoiceprint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonVoiceprint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      embedding: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}embedding'],
      )!,
      sourceRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_run_id'],
      ),
      sourceSpeaker: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_speaker'],
      ),
      speechMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speech_ms'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PersonVoiceprintsTable createAlias(String alias) {
    return $PersonVoiceprintsTable(attachedDatabase, alias);
  }
}

class PersonVoiceprint extends DataClass
    implements Insertable<PersonVoiceprint> {
  final int id;
  final String personId;
  final Uint8List embedding;
  final String? sourceRunId;
  final int? sourceSpeaker;
  final int speechMs;
  final DateTime createdAt;
  const PersonVoiceprint({
    required this.id,
    required this.personId,
    required this.embedding,
    this.sourceRunId,
    this.sourceSpeaker,
    required this.speechMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_id'] = Variable<String>(personId);
    map['embedding'] = Variable<Uint8List>(embedding);
    if (!nullToAbsent || sourceRunId != null) {
      map['source_run_id'] = Variable<String>(sourceRunId);
    }
    if (!nullToAbsent || sourceSpeaker != null) {
      map['source_speaker'] = Variable<int>(sourceSpeaker);
    }
    map['speech_ms'] = Variable<int>(speechMs);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonVoiceprintsCompanion toCompanion(bool nullToAbsent) {
    return PersonVoiceprintsCompanion(
      id: Value(id),
      personId: Value(personId),
      embedding: Value(embedding),
      sourceRunId: sourceRunId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRunId),
      sourceSpeaker: sourceSpeaker == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSpeaker),
      speechMs: Value(speechMs),
      createdAt: Value(createdAt),
    );
  }

  factory PersonVoiceprint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonVoiceprint(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      embedding: serializer.fromJson<Uint8List>(json['embedding']),
      sourceRunId: serializer.fromJson<String?>(json['sourceRunId']),
      sourceSpeaker: serializer.fromJson<int?>(json['sourceSpeaker']),
      speechMs: serializer.fromJson<int>(json['speechMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<String>(personId),
      'embedding': serializer.toJson<Uint8List>(embedding),
      'sourceRunId': serializer.toJson<String?>(sourceRunId),
      'sourceSpeaker': serializer.toJson<int?>(sourceSpeaker),
      'speechMs': serializer.toJson<int>(speechMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonVoiceprint copyWith({
    int? id,
    String? personId,
    Uint8List? embedding,
    Value<String?> sourceRunId = const Value.absent(),
    Value<int?> sourceSpeaker = const Value.absent(),
    int? speechMs,
    DateTime? createdAt,
  }) => PersonVoiceprint(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    embedding: embedding ?? this.embedding,
    sourceRunId: sourceRunId.present ? sourceRunId.value : this.sourceRunId,
    sourceSpeaker: sourceSpeaker.present
        ? sourceSpeaker.value
        : this.sourceSpeaker,
    speechMs: speechMs ?? this.speechMs,
    createdAt: createdAt ?? this.createdAt,
  );
  PersonVoiceprint copyWithCompanion(PersonVoiceprintsCompanion data) {
    return PersonVoiceprint(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      sourceRunId: data.sourceRunId.present
          ? data.sourceRunId.value
          : this.sourceRunId,
      sourceSpeaker: data.sourceSpeaker.present
          ? data.sourceSpeaker.value
          : this.sourceSpeaker,
      speechMs: data.speechMs.present ? data.speechMs.value : this.speechMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonVoiceprint(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('embedding: $embedding, ')
          ..write('sourceRunId: $sourceRunId, ')
          ..write('sourceSpeaker: $sourceSpeaker, ')
          ..write('speechMs: $speechMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    $driftBlobEquality.hash(embedding),
    sourceRunId,
    sourceSpeaker,
    speechMs,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonVoiceprint &&
          other.id == this.id &&
          other.personId == this.personId &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.sourceRunId == this.sourceRunId &&
          other.sourceSpeaker == this.sourceSpeaker &&
          other.speechMs == this.speechMs &&
          other.createdAt == this.createdAt);
}

class PersonVoiceprintsCompanion extends UpdateCompanion<PersonVoiceprint> {
  final Value<int> id;
  final Value<String> personId;
  final Value<Uint8List> embedding;
  final Value<String?> sourceRunId;
  final Value<int?> sourceSpeaker;
  final Value<int> speechMs;
  final Value<DateTime> createdAt;
  const PersonVoiceprintsCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.embedding = const Value.absent(),
    this.sourceRunId = const Value.absent(),
    this.sourceSpeaker = const Value.absent(),
    this.speechMs = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PersonVoiceprintsCompanion.insert({
    this.id = const Value.absent(),
    required String personId,
    required Uint8List embedding,
    this.sourceRunId = const Value.absent(),
    this.sourceSpeaker = const Value.absent(),
    required int speechMs,
    required DateTime createdAt,
  }) : personId = Value(personId),
       embedding = Value(embedding),
       speechMs = Value(speechMs),
       createdAt = Value(createdAt);
  static Insertable<PersonVoiceprint> custom({
    Expression<int>? id,
    Expression<String>? personId,
    Expression<Uint8List>? embedding,
    Expression<String>? sourceRunId,
    Expression<int>? sourceSpeaker,
    Expression<int>? speechMs,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (embedding != null) 'embedding': embedding,
      if (sourceRunId != null) 'source_run_id': sourceRunId,
      if (sourceSpeaker != null) 'source_speaker': sourceSpeaker,
      if (speechMs != null) 'speech_ms': speechMs,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PersonVoiceprintsCompanion copyWith({
    Value<int>? id,
    Value<String>? personId,
    Value<Uint8List>? embedding,
    Value<String?>? sourceRunId,
    Value<int?>? sourceSpeaker,
    Value<int>? speechMs,
    Value<DateTime>? createdAt,
  }) {
    return PersonVoiceprintsCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      embedding: embedding ?? this.embedding,
      sourceRunId: sourceRunId ?? this.sourceRunId,
      sourceSpeaker: sourceSpeaker ?? this.sourceSpeaker,
      speechMs: speechMs ?? this.speechMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (sourceRunId.present) {
      map['source_run_id'] = Variable<String>(sourceRunId.value);
    }
    if (sourceSpeaker.present) {
      map['source_speaker'] = Variable<int>(sourceSpeaker.value);
    }
    if (speechMs.present) {
      map['speech_ms'] = Variable<int>(speechMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonVoiceprintsCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('embedding: $embedding, ')
          ..write('sourceRunId: $sourceRunId, ')
          ..write('sourceSpeaker: $sourceSpeaker, ')
          ..write('speechMs: $speechMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TranscriptSegmentsTable extends TranscriptSegments
    with TableInfo<$TranscriptSegmentsTable, TranscriptSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speakerMeta = const VerificationMeta(
    'speaker',
  );
  @override
  late final GeneratedColumn<int> speaker = GeneratedColumn<int>(
    'speaker',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordingId,
    runId,
    idx,
    startMs,
    endMs,
    content,
    lang,
    speaker,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcript_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranscriptSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['text']!, _contentMeta),
      );
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    }
    if (data.containsKey('speaker')) {
      context.handle(
        _speakerMeta,
        speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {runId, idx},
  ];
  @override
  TranscriptSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      ),
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      ),
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      ),
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaker'],
      ),
    );
  }

  @override
  $TranscriptSegmentsTable createAlias(String alias) {
    return $TranscriptSegmentsTable(attachedDatabase, alias);
  }
}

class TranscriptSegment extends DataClass
    implements Insertable<TranscriptSegment> {
  final int id;
  final String recordingId;
  final String? runId;
  final int idx;
  final int startMs;
  final int endMs;
  final String? content;
  final String? lang;
  final int? speaker;
  const TranscriptSegment({
    required this.id,
    required this.recordingId,
    this.runId,
    required this.idx,
    required this.startMs,
    required this.endMs,
    this.content,
    this.lang,
    this.speaker,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recording_id'] = Variable<String>(recordingId);
    if (!nullToAbsent || runId != null) {
      map['run_id'] = Variable<String>(runId);
    }
    map['idx'] = Variable<int>(idx);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    if (!nullToAbsent || content != null) {
      map['text'] = Variable<String>(content);
    }
    if (!nullToAbsent || lang != null) {
      map['lang'] = Variable<String>(lang);
    }
    if (!nullToAbsent || speaker != null) {
      map['speaker'] = Variable<int>(speaker);
    }
    return map;
  }

  TranscriptSegmentsCompanion toCompanion(bool nullToAbsent) {
    return TranscriptSegmentsCompanion(
      id: Value(id),
      recordingId: Value(recordingId),
      runId: runId == null && nullToAbsent
          ? const Value.absent()
          : Value(runId),
      idx: Value(idx),
      startMs: Value(startMs),
      endMs: Value(endMs),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      lang: lang == null && nullToAbsent ? const Value.absent() : Value(lang),
      speaker: speaker == null && nullToAbsent
          ? const Value.absent()
          : Value(speaker),
    );
  }

  factory TranscriptSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptSegment(
      id: serializer.fromJson<int>(json['id']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      runId: serializer.fromJson<String?>(json['runId']),
      idx: serializer.fromJson<int>(json['idx']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      content: serializer.fromJson<String?>(json['content']),
      lang: serializer.fromJson<String?>(json['lang']),
      speaker: serializer.fromJson<int?>(json['speaker']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordingId': serializer.toJson<String>(recordingId),
      'runId': serializer.toJson<String?>(runId),
      'idx': serializer.toJson<int>(idx),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'content': serializer.toJson<String?>(content),
      'lang': serializer.toJson<String?>(lang),
      'speaker': serializer.toJson<int?>(speaker),
    };
  }

  TranscriptSegment copyWith({
    int? id,
    String? recordingId,
    Value<String?> runId = const Value.absent(),
    int? idx,
    int? startMs,
    int? endMs,
    Value<String?> content = const Value.absent(),
    Value<String?> lang = const Value.absent(),
    Value<int?> speaker = const Value.absent(),
  }) => TranscriptSegment(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
    runId: runId.present ? runId.value : this.runId,
    idx: idx ?? this.idx,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    content: content.present ? content.value : this.content,
    lang: lang.present ? lang.value : this.lang,
    speaker: speaker.present ? speaker.value : this.speaker,
  );
  TranscriptSegment copyWithCompanion(TranscriptSegmentsCompanion data) {
    return TranscriptSegment(
      id: data.id.present ? data.id.value : this.id,
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      runId: data.runId.present ? data.runId.value : this.runId,
      idx: data.idx.present ? data.idx.value : this.idx,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      content: data.content.present ? data.content.value : this.content,
      lang: data.lang.present ? data.lang.value : this.lang,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegment(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('runId: $runId, ')
          ..write('idx: $idx, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('content: $content, ')
          ..write('lang: $lang, ')
          ..write('speaker: $speaker')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordingId,
    runId,
    idx,
    startMs,
    endMs,
    content,
    lang,
    speaker,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptSegment &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
          other.runId == this.runId &&
          other.idx == this.idx &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.content == this.content &&
          other.lang == this.lang &&
          other.speaker == this.speaker);
}

class TranscriptSegmentsCompanion extends UpdateCompanion<TranscriptSegment> {
  final Value<int> id;
  final Value<String> recordingId;
  final Value<String?> runId;
  final Value<int> idx;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String?> content;
  final Value<String?> lang;
  final Value<int?> speaker;
  const TranscriptSegmentsCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.runId = const Value.absent(),
    this.idx = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.content = const Value.absent(),
    this.lang = const Value.absent(),
    this.speaker = const Value.absent(),
  });
  TranscriptSegmentsCompanion.insert({
    this.id = const Value.absent(),
    required String recordingId,
    this.runId = const Value.absent(),
    required int idx,
    required int startMs,
    required int endMs,
    this.content = const Value.absent(),
    this.lang = const Value.absent(),
    this.speaker = const Value.absent(),
  }) : recordingId = Value(recordingId),
       idx = Value(idx),
       startMs = Value(startMs),
       endMs = Value(endMs);
  static Insertable<TranscriptSegment> custom({
    Expression<int>? id,
    Expression<String>? recordingId,
    Expression<String>? runId,
    Expression<int>? idx,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? content,
    Expression<String>? lang,
    Expression<int>? speaker,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordingId != null) 'recording_id': recordingId,
      if (runId != null) 'run_id': runId,
      if (idx != null) 'idx': idx,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (content != null) 'text': content,
      if (lang != null) 'lang': lang,
      if (speaker != null) 'speaker': speaker,
    });
  }

  TranscriptSegmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? recordingId,
    Value<String?>? runId,
    Value<int>? idx,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<String?>? content,
    Value<String?>? lang,
    Value<int?>? speaker,
  }) {
    return TranscriptSegmentsCompanion(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      runId: runId ?? this.runId,
      idx: idx ?? this.idx,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      content: content ?? this.content,
      lang: lang ?? this.lang,
      speaker: speaker ?? this.speaker,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<int>(speaker.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('runId: $runId, ')
          ..write('idx: $idx, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('content: $content, ')
          ..write('lang: $lang, ')
          ..write('speaker: $speaker')
          ..write(')'))
        .toString();
  }
}

class $SpeakerNamesTable extends SpeakerNames
    with TableInfo<$SpeakerNamesTable, SpeakerName> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeakerNamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerMeta = const VerificationMeta(
    'speaker',
  );
  @override
  late final GeneratedColumn<int> speaker = GeneratedColumn<int>(
    'speaker',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _matchScoreMeta = const VerificationMeta(
    'matchScore',
  );
  @override
  late final GeneratedColumn<double> matchScore = GeneratedColumn<double>(
    'match_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    recordingId,
    runId,
    speaker,
    name,
    personId,
    source,
    matchScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'speaker_names';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeakerName> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('speaker')) {
      context.handle(
        _speakerMeta,
        speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta),
      );
    } else if (isInserting) {
      context.missing(_speakerMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('match_score')) {
      context.handle(
        _matchScoreMeta,
        matchScore.isAcceptableOrUnknown(data['match_score']!, _matchScoreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId, speaker};
  @override
  SpeakerName map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeakerName(
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaker'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      matchScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}match_score'],
      ),
    );
  }

  @override
  $SpeakerNamesTable createAlias(String alias) {
    return $SpeakerNamesTable(attachedDatabase, alias);
  }
}

class SpeakerName extends DataClass implements Insertable<SpeakerName> {
  final String recordingId;
  final String runId;
  final int speaker;
  final String name;
  final String? personId;
  final String source;
  final double? matchScore;
  const SpeakerName({
    required this.recordingId,
    required this.runId,
    required this.speaker,
    required this.name,
    this.personId,
    required this.source,
    this.matchScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recording_id'] = Variable<String>(recordingId);
    map['run_id'] = Variable<String>(runId);
    map['speaker'] = Variable<int>(speaker);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || matchScore != null) {
      map['match_score'] = Variable<double>(matchScore);
    }
    return map;
  }

  SpeakerNamesCompanion toCompanion(bool nullToAbsent) {
    return SpeakerNamesCompanion(
      recordingId: Value(recordingId),
      runId: Value(runId),
      speaker: Value(speaker),
      name: Value(name),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      source: Value(source),
      matchScore: matchScore == null && nullToAbsent
          ? const Value.absent()
          : Value(matchScore),
    );
  }

  factory SpeakerName.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeakerName(
      recordingId: serializer.fromJson<String>(json['recordingId']),
      runId: serializer.fromJson<String>(json['runId']),
      speaker: serializer.fromJson<int>(json['speaker']),
      name: serializer.fromJson<String>(json['name']),
      personId: serializer.fromJson<String?>(json['personId']),
      source: serializer.fromJson<String>(json['source']),
      matchScore: serializer.fromJson<double?>(json['matchScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recordingId': serializer.toJson<String>(recordingId),
      'runId': serializer.toJson<String>(runId),
      'speaker': serializer.toJson<int>(speaker),
      'name': serializer.toJson<String>(name),
      'personId': serializer.toJson<String?>(personId),
      'source': serializer.toJson<String>(source),
      'matchScore': serializer.toJson<double?>(matchScore),
    };
  }

  SpeakerName copyWith({
    String? recordingId,
    String? runId,
    int? speaker,
    String? name,
    Value<String?> personId = const Value.absent(),
    String? source,
    Value<double?> matchScore = const Value.absent(),
  }) => SpeakerName(
    recordingId: recordingId ?? this.recordingId,
    runId: runId ?? this.runId,
    speaker: speaker ?? this.speaker,
    name: name ?? this.name,
    personId: personId.present ? personId.value : this.personId,
    source: source ?? this.source,
    matchScore: matchScore.present ? matchScore.value : this.matchScore,
  );
  SpeakerName copyWithCompanion(SpeakerNamesCompanion data) {
    return SpeakerName(
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      runId: data.runId.present ? data.runId.value : this.runId,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      name: data.name.present ? data.name.value : this.name,
      personId: data.personId.present ? data.personId.value : this.personId,
      source: data.source.present ? data.source.value : this.source,
      matchScore: data.matchScore.present
          ? data.matchScore.value
          : this.matchScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeakerName(')
          ..write('recordingId: $recordingId, ')
          ..write('runId: $runId, ')
          ..write('speaker: $speaker, ')
          ..write('name: $name, ')
          ..write('personId: $personId, ')
          ..write('source: $source, ')
          ..write('matchScore: $matchScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recordingId,
    runId,
    speaker,
    name,
    personId,
    source,
    matchScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeakerName &&
          other.recordingId == this.recordingId &&
          other.runId == this.runId &&
          other.speaker == this.speaker &&
          other.name == this.name &&
          other.personId == this.personId &&
          other.source == this.source &&
          other.matchScore == this.matchScore);
}

class SpeakerNamesCompanion extends UpdateCompanion<SpeakerName> {
  final Value<String> recordingId;
  final Value<String> runId;
  final Value<int> speaker;
  final Value<String> name;
  final Value<String?> personId;
  final Value<String> source;
  final Value<double?> matchScore;
  final Value<int> rowid;
  const SpeakerNamesCompanion({
    this.recordingId = const Value.absent(),
    this.runId = const Value.absent(),
    this.speaker = const Value.absent(),
    this.name = const Value.absent(),
    this.personId = const Value.absent(),
    this.source = const Value.absent(),
    this.matchScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeakerNamesCompanion.insert({
    required String recordingId,
    required String runId,
    required int speaker,
    required String name,
    this.personId = const Value.absent(),
    this.source = const Value.absent(),
    this.matchScore = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : recordingId = Value(recordingId),
       runId = Value(runId),
       speaker = Value(speaker),
       name = Value(name);
  static Insertable<SpeakerName> custom({
    Expression<String>? recordingId,
    Expression<String>? runId,
    Expression<int>? speaker,
    Expression<String>? name,
    Expression<String>? personId,
    Expression<String>? source,
    Expression<double>? matchScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recordingId != null) 'recording_id': recordingId,
      if (runId != null) 'run_id': runId,
      if (speaker != null) 'speaker': speaker,
      if (name != null) 'name': name,
      if (personId != null) 'person_id': personId,
      if (source != null) 'source': source,
      if (matchScore != null) 'match_score': matchScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeakerNamesCompanion copyWith({
    Value<String>? recordingId,
    Value<String>? runId,
    Value<int>? speaker,
    Value<String>? name,
    Value<String?>? personId,
    Value<String>? source,
    Value<double?>? matchScore,
    Value<int>? rowid,
  }) {
    return SpeakerNamesCompanion(
      recordingId: recordingId ?? this.recordingId,
      runId: runId ?? this.runId,
      speaker: speaker ?? this.speaker,
      name: name ?? this.name,
      personId: personId ?? this.personId,
      source: source ?? this.source,
      matchScore: matchScore ?? this.matchScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<int>(speaker.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (matchScore.present) {
      map['match_score'] = Variable<double>(matchScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeakerNamesCompanion(')
          ..write('recordingId: $recordingId, ')
          ..write('runId: $runId, ')
          ..write('speaker: $speaker, ')
          ..write('name: $name, ')
          ..write('personId: $personId, ')
          ..write('source: $source, ')
          ..write('matchScore: $matchScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordingId,
    positionMs,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_id'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final String recordingId;
  final int positionMs;
  final String? label;
  final DateTime createdAt;
  const Bookmark({
    required this.id,
    required this.recordingId,
    required this.positionMs,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recording_id'] = Variable<String>(recordingId);
    map['position_ms'] = Variable<int>(positionMs);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      recordingId: Value(recordingId),
      positionMs: Value(positionMs),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordingId': serializer.toJson<String>(recordingId),
      'positionMs': serializer.toJson<int>(positionMs),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith({
    int? id,
    String? recordingId,
    int? positionMs,
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => Bookmark(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
    positionMs: positionMs ?? this.positionMs,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('positionMs: $positionMs, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recordingId, positionMs, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
          other.positionMs == this.positionMs &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<String> recordingId;
  final Value<int> positionMs;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required String recordingId,
    required int positionMs,
    this.label = const Value.absent(),
    required DateTime createdAt,
  }) : recordingId = Value(recordingId),
       positionMs = Value(positionMs),
       createdAt = Value(createdAt);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<String>? recordingId,
    Expression<int>? positionMs,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordingId != null) 'recording_id': recordingId,
      if (positionMs != null) 'position_ms': positionMs,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<String>? recordingId,
    Value<int>? positionMs,
    Value<String?>? label,
    Value<DateTime>? createdAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      positionMs: positionMs ?? this.positionMs,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('positionMs: $positionMs, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecordingsTable recordings = $RecordingsTable(this);
  late final $TranscriptionRunsTable transcriptionRuns =
      $TranscriptionRunsTable(this);
  late final $RunSpeakerEmbeddingsTable runSpeakerEmbeddings =
      $RunSpeakerEmbeddingsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $PersonVoiceprintsTable personVoiceprints =
      $PersonVoiceprintsTable(this);
  late final $TranscriptSegmentsTable transcriptSegments =
      $TranscriptSegmentsTable(this);
  late final $SpeakerNamesTable speakerNames = $SpeakerNamesTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recordings,
    transcriptionRuns,
    runSpeakerEmbeddings,
    people,
    personVoiceprints,
    transcriptSegments,
    speakerNames,
    bookmarks,
  ];
}

typedef $$RecordingsTableCreateCompanionBuilder =
    RecordingsCompanion Function({
      required String id,
      required String title,
      required DateTime createdAt,
      required int durationMs,
      required String fileName,
      required int sampleRate,
      required RecordingStatus status,
      Value<TranscriptionStatus> transcriptionStatus,
      Value<LanguageHint> languageHint,
      Value<String?> asrModelId,
      Value<String?> transcriptionError,
      Value<int?> speakerCountHint,
      Value<String?> activeRunId,
      Value<int> rowid,
    });
typedef $$RecordingsTableUpdateCompanionBuilder =
    RecordingsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<DateTime> createdAt,
      Value<int> durationMs,
      Value<String> fileName,
      Value<int> sampleRate,
      Value<RecordingStatus> status,
      Value<TranscriptionStatus> transcriptionStatus,
      Value<LanguageHint> languageHint,
      Value<String?> asrModelId,
      Value<String?> transcriptionError,
      Value<int?> speakerCountHint,
      Value<String?> activeRunId,
      Value<int> rowid,
    });

class $$RecordingsTableFilterComposer
    extends Composer<_$AppDatabase, $RecordingsTable> {
  $$RecordingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecordingStatus, RecordingStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TranscriptionStatus,
    TranscriptionStatus,
    String
  >
  get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LanguageHint, LanguageHint, String>
  get languageHint => $composableBuilder(
    column: $table.languageHint,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get asrModelId => $composableBuilder(
    column: $table.asrModelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptionError => $composableBuilder(
    column: $table.transcriptionError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speakerCountHint => $composableBuilder(
    column: $table.speakerCountHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeRunId => $composableBuilder(
    column: $table.activeRunId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecordingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecordingsTable> {
  $$RecordingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageHint => $composableBuilder(
    column: $table.languageHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asrModelId => $composableBuilder(
    column: $table.asrModelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptionError => $composableBuilder(
    column: $table.transcriptionError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speakerCountHint => $composableBuilder(
    column: $table.speakerCountHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeRunId => $composableBuilder(
    column: $table.activeRunId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecordingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecordingsTable> {
  $$RecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RecordingStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TranscriptionStatus, String>
  get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LanguageHint, String> get languageHint =>
      $composableBuilder(
        column: $table.languageHint,
        builder: (column) => column,
      );

  GeneratedColumn<String> get asrModelId => $composableBuilder(
    column: $table.asrModelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcriptionError => $composableBuilder(
    column: $table.transcriptionError,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speakerCountHint => $composableBuilder(
    column: $table.speakerCountHint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeRunId => $composableBuilder(
    column: $table.activeRunId,
    builder: (column) => column,
  );
}

class $$RecordingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecordingsTable,
          Recording,
          $$RecordingsTableFilterComposer,
          $$RecordingsTableOrderingComposer,
          $$RecordingsTableAnnotationComposer,
          $$RecordingsTableCreateCompanionBuilder,
          $$RecordingsTableUpdateCompanionBuilder,
          (
            Recording,
            BaseReferences<_$AppDatabase, $RecordingsTable, Recording>,
          ),
          Recording,
          PrefetchHooks Function()
        > {
  $$RecordingsTableTableManager(_$AppDatabase db, $RecordingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> sampleRate = const Value.absent(),
                Value<RecordingStatus> status = const Value.absent(),
                Value<TranscriptionStatus> transcriptionStatus =
                    const Value.absent(),
                Value<LanguageHint> languageHint = const Value.absent(),
                Value<String?> asrModelId = const Value.absent(),
                Value<String?> transcriptionError = const Value.absent(),
                Value<int?> speakerCountHint = const Value.absent(),
                Value<String?> activeRunId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecordingsCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                durationMs: durationMs,
                fileName: fileName,
                sampleRate: sampleRate,
                status: status,
                transcriptionStatus: transcriptionStatus,
                languageHint: languageHint,
                asrModelId: asrModelId,
                transcriptionError: transcriptionError,
                speakerCountHint: speakerCountHint,
                activeRunId: activeRunId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required DateTime createdAt,
                required int durationMs,
                required String fileName,
                required int sampleRate,
                required RecordingStatus status,
                Value<TranscriptionStatus> transcriptionStatus =
                    const Value.absent(),
                Value<LanguageHint> languageHint = const Value.absent(),
                Value<String?> asrModelId = const Value.absent(),
                Value<String?> transcriptionError = const Value.absent(),
                Value<int?> speakerCountHint = const Value.absent(),
                Value<String?> activeRunId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecordingsCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                durationMs: durationMs,
                fileName: fileName,
                sampleRate: sampleRate,
                status: status,
                transcriptionStatus: transcriptionStatus,
                languageHint: languageHint,
                asrModelId: asrModelId,
                transcriptionError: transcriptionError,
                speakerCountHint: speakerCountHint,
                activeRunId: activeRunId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecordingsTable, Recording>(table),
                  BaseReferences<_$AppDatabase, $RecordingsTable, Recording>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecordingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecordingsTable,
      Recording,
      $$RecordingsTableFilterComposer,
      $$RecordingsTableOrderingComposer,
      $$RecordingsTableAnnotationComposer,
      $$RecordingsTableCreateCompanionBuilder,
      $$RecordingsTableUpdateCompanionBuilder,
      (Recording, BaseReferences<_$AppDatabase, $RecordingsTable, Recording>),
      Recording,
      PrefetchHooks Function()
    >;
typedef $$TranscriptionRunsTableCreateCompanionBuilder =
    TranscriptionRunsCompanion Function({
      required String id,
      required String recordingId,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<String?> asrModelId,
      required LanguageHint languageHint,
      Value<int?> speakerCountHint,
      Value<bool> diarized,
      required TranscriptionStatus status,
      Value<String?> error,
      Value<int> processingMs,
      Value<int> rowid,
    });
typedef $$TranscriptionRunsTableUpdateCompanionBuilder =
    TranscriptionRunsCompanion Function({
      Value<String> id,
      Value<String> recordingId,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<String?> asrModelId,
      Value<LanguageHint> languageHint,
      Value<int?> speakerCountHint,
      Value<bool> diarized,
      Value<TranscriptionStatus> status,
      Value<String?> error,
      Value<int> processingMs,
      Value<int> rowid,
    });

class $$TranscriptionRunsTableFilterComposer
    extends Composer<_$AppDatabase, $TranscriptionRunsTable> {
  $$TranscriptionRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asrModelId => $composableBuilder(
    column: $table.asrModelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LanguageHint, LanguageHint, String>
  get languageHint => $composableBuilder(
    column: $table.languageHint,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get speakerCountHint => $composableBuilder(
    column: $table.speakerCountHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get diarized => $composableBuilder(
    column: $table.diarized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TranscriptionStatus,
    TranscriptionStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processingMs => $composableBuilder(
    column: $table.processingMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranscriptionRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranscriptionRunsTable> {
  $$TranscriptionRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asrModelId => $composableBuilder(
    column: $table.asrModelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageHint => $composableBuilder(
    column: $table.languageHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speakerCountHint => $composableBuilder(
    column: $table.speakerCountHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get diarized => $composableBuilder(
    column: $table.diarized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processingMs => $composableBuilder(
    column: $table.processingMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranscriptionRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranscriptionRunsTable> {
  $$TranscriptionRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get asrModelId => $composableBuilder(
    column: $table.asrModelId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LanguageHint, String> get languageHint =>
      $composableBuilder(
        column: $table.languageHint,
        builder: (column) => column,
      );

  GeneratedColumn<int> get speakerCountHint => $composableBuilder(
    column: $table.speakerCountHint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get diarized =>
      $composableBuilder(column: $table.diarized, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TranscriptionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<int> get processingMs => $composableBuilder(
    column: $table.processingMs,
    builder: (column) => column,
  );
}

class $$TranscriptionRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranscriptionRunsTable,
          TranscriptionRun,
          $$TranscriptionRunsTableFilterComposer,
          $$TranscriptionRunsTableOrderingComposer,
          $$TranscriptionRunsTableAnnotationComposer,
          $$TranscriptionRunsTableCreateCompanionBuilder,
          $$TranscriptionRunsTableUpdateCompanionBuilder,
          (
            TranscriptionRun,
            BaseReferences<
              _$AppDatabase,
              $TranscriptionRunsTable,
              TranscriptionRun
            >,
          ),
          TranscriptionRun,
          PrefetchHooks Function()
        > {
  $$TranscriptionRunsTableTableManager(
    _$AppDatabase db,
    $TranscriptionRunsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptionRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptionRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptionRunsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recordingId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> asrModelId = const Value.absent(),
                Value<LanguageHint> languageHint = const Value.absent(),
                Value<int?> speakerCountHint = const Value.absent(),
                Value<bool> diarized = const Value.absent(),
                Value<TranscriptionStatus> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> processingMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptionRunsCompanion(
                id: id,
                recordingId: recordingId,
                createdAt: createdAt,
                completedAt: completedAt,
                asrModelId: asrModelId,
                languageHint: languageHint,
                speakerCountHint: speakerCountHint,
                diarized: diarized,
                status: status,
                error: error,
                processingMs: processingMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recordingId,
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> asrModelId = const Value.absent(),
                required LanguageHint languageHint,
                Value<int?> speakerCountHint = const Value.absent(),
                Value<bool> diarized = const Value.absent(),
                required TranscriptionStatus status,
                Value<String?> error = const Value.absent(),
                Value<int> processingMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptionRunsCompanion.insert(
                id: id,
                recordingId: recordingId,
                createdAt: createdAt,
                completedAt: completedAt,
                asrModelId: asrModelId,
                languageHint: languageHint,
                speakerCountHint: speakerCountHint,
                diarized: diarized,
                status: status,
                error: error,
                processingMs: processingMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TranscriptionRunsTable, TranscriptionRun>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TranscriptionRunsTable,
                    TranscriptionRun
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranscriptionRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranscriptionRunsTable,
      TranscriptionRun,
      $$TranscriptionRunsTableFilterComposer,
      $$TranscriptionRunsTableOrderingComposer,
      $$TranscriptionRunsTableAnnotationComposer,
      $$TranscriptionRunsTableCreateCompanionBuilder,
      $$TranscriptionRunsTableUpdateCompanionBuilder,
      (
        TranscriptionRun,
        BaseReferences<
          _$AppDatabase,
          $TranscriptionRunsTable,
          TranscriptionRun
        >,
      ),
      TranscriptionRun,
      PrefetchHooks Function()
    >;
typedef $$RunSpeakerEmbeddingsTableCreateCompanionBuilder =
    RunSpeakerEmbeddingsCompanion Function({
      required String runId,
      required int speaker,
      required Uint8List embedding,
      required int speechMs,
      Value<int> rowid,
    });
typedef $$RunSpeakerEmbeddingsTableUpdateCompanionBuilder =
    RunSpeakerEmbeddingsCompanion Function({
      Value<String> runId,
      Value<int> speaker,
      Value<Uint8List> embedding,
      Value<int> speechMs,
      Value<int> rowid,
    });

class $$RunSpeakerEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $RunSpeakerEmbeddingsTable> {
  $$RunSpeakerEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speechMs => $composableBuilder(
    column: $table.speechMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunSpeakerEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RunSpeakerEmbeddingsTable> {
  $$RunSpeakerEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speechMs => $composableBuilder(
    column: $table.speechMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunSpeakerEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunSpeakerEmbeddingsTable> {
  $$RunSpeakerEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<int> get speechMs =>
      $composableBuilder(column: $table.speechMs, builder: (column) => column);
}

class $$RunSpeakerEmbeddingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunSpeakerEmbeddingsTable,
          RunSpeakerEmbedding,
          $$RunSpeakerEmbeddingsTableFilterComposer,
          $$RunSpeakerEmbeddingsTableOrderingComposer,
          $$RunSpeakerEmbeddingsTableAnnotationComposer,
          $$RunSpeakerEmbeddingsTableCreateCompanionBuilder,
          $$RunSpeakerEmbeddingsTableUpdateCompanionBuilder,
          (
            RunSpeakerEmbedding,
            BaseReferences<
              _$AppDatabase,
              $RunSpeakerEmbeddingsTable,
              RunSpeakerEmbedding
            >,
          ),
          RunSpeakerEmbedding,
          PrefetchHooks Function()
        > {
  $$RunSpeakerEmbeddingsTableTableManager(
    _$AppDatabase db,
    $RunSpeakerEmbeddingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunSpeakerEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunSpeakerEmbeddingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RunSpeakerEmbeddingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> runId = const Value.absent(),
                Value<int> speaker = const Value.absent(),
                Value<Uint8List> embedding = const Value.absent(),
                Value<int> speechMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunSpeakerEmbeddingsCompanion(
                runId: runId,
                speaker: speaker,
                embedding: embedding,
                speechMs: speechMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String runId,
                required int speaker,
                required Uint8List embedding,
                required int speechMs,
                Value<int> rowid = const Value.absent(),
              }) => RunSpeakerEmbeddingsCompanion.insert(
                runId: runId,
                speaker: speaker,
                embedding: embedding,
                speechMs: speechMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RunSpeakerEmbeddingsTable, RunSpeakerEmbedding>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $RunSpeakerEmbeddingsTable,
                    RunSpeakerEmbedding
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunSpeakerEmbeddingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunSpeakerEmbeddingsTable,
      RunSpeakerEmbedding,
      $$RunSpeakerEmbeddingsTableFilterComposer,
      $$RunSpeakerEmbeddingsTableOrderingComposer,
      $$RunSpeakerEmbeddingsTableAnnotationComposer,
      $$RunSpeakerEmbeddingsTableCreateCompanionBuilder,
      $$RunSpeakerEmbeddingsTableUpdateCompanionBuilder,
      (
        RunSpeakerEmbedding,
        BaseReferences<
          _$AppDatabase,
          $RunSpeakerEmbeddingsTable,
          RunSpeakerEmbedding
        >,
      ),
      RunSpeakerEmbedding,
      PrefetchHooks Function()
    >;
typedef $$PeopleTableCreateCompanionBuilder =
    PeopleCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PeopleTableUpdateCompanionBuilder =
    PeopleCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeopleTable,
          PeopleData,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (PeopleData, BaseReferences<_$AppDatabase, $PeopleTable, PeopleData>),
          PeopleData,
          PrefetchHooks Function()
        > {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeopleTable, PeopleData>(table),
                  BaseReferences<_$AppDatabase, $PeopleTable, PeopleData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeopleTable,
      PeopleData,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (PeopleData, BaseReferences<_$AppDatabase, $PeopleTable, PeopleData>),
      PeopleData,
      PrefetchHooks Function()
    >;
typedef $$PersonVoiceprintsTableCreateCompanionBuilder =
    PersonVoiceprintsCompanion Function({
      Value<int> id,
      required String personId,
      required Uint8List embedding,
      Value<String?> sourceRunId,
      Value<int?> sourceSpeaker,
      required int speechMs,
      required DateTime createdAt,
    });
typedef $$PersonVoiceprintsTableUpdateCompanionBuilder =
    PersonVoiceprintsCompanion Function({
      Value<int> id,
      Value<String> personId,
      Value<Uint8List> embedding,
      Value<String?> sourceRunId,
      Value<int?> sourceSpeaker,
      Value<int> speechMs,
      Value<DateTime> createdAt,
    });

class $$PersonVoiceprintsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonVoiceprintsTable> {
  $$PersonVoiceprintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRunId => $composableBuilder(
    column: $table.sourceRunId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceSpeaker => $composableBuilder(
    column: $table.sourceSpeaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speechMs => $composableBuilder(
    column: $table.speechMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonVoiceprintsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonVoiceprintsTable> {
  $$PersonVoiceprintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
    column: $table.embedding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRunId => $composableBuilder(
    column: $table.sourceRunId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceSpeaker => $composableBuilder(
    column: $table.sourceSpeaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speechMs => $composableBuilder(
    column: $table.speechMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonVoiceprintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonVoiceprintsTable> {
  $$PersonVoiceprintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<String> get sourceRunId => $composableBuilder(
    column: $table.sourceRunId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceSpeaker => $composableBuilder(
    column: $table.sourceSpeaker,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speechMs =>
      $composableBuilder(column: $table.speechMs, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PersonVoiceprintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonVoiceprintsTable,
          PersonVoiceprint,
          $$PersonVoiceprintsTableFilterComposer,
          $$PersonVoiceprintsTableOrderingComposer,
          $$PersonVoiceprintsTableAnnotationComposer,
          $$PersonVoiceprintsTableCreateCompanionBuilder,
          $$PersonVoiceprintsTableUpdateCompanionBuilder,
          (
            PersonVoiceprint,
            BaseReferences<
              _$AppDatabase,
              $PersonVoiceprintsTable,
              PersonVoiceprint
            >,
          ),
          PersonVoiceprint,
          PrefetchHooks Function()
        > {
  $$PersonVoiceprintsTableTableManager(
    _$AppDatabase db,
    $PersonVoiceprintsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonVoiceprintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonVoiceprintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonVoiceprintsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<Uint8List> embedding = const Value.absent(),
                Value<String?> sourceRunId = const Value.absent(),
                Value<int?> sourceSpeaker = const Value.absent(),
                Value<int> speechMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PersonVoiceprintsCompanion(
                id: id,
                personId: personId,
                embedding: embedding,
                sourceRunId: sourceRunId,
                sourceSpeaker: sourceSpeaker,
                speechMs: speechMs,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String personId,
                required Uint8List embedding,
                Value<String?> sourceRunId = const Value.absent(),
                Value<int?> sourceSpeaker = const Value.absent(),
                required int speechMs,
                required DateTime createdAt,
              }) => PersonVoiceprintsCompanion.insert(
                id: id,
                personId: personId,
                embedding: embedding,
                sourceRunId: sourceRunId,
                sourceSpeaker: sourceSpeaker,
                speechMs: speechMs,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonVoiceprintsTable, PersonVoiceprint>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PersonVoiceprintsTable,
                    PersonVoiceprint
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonVoiceprintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonVoiceprintsTable,
      PersonVoiceprint,
      $$PersonVoiceprintsTableFilterComposer,
      $$PersonVoiceprintsTableOrderingComposer,
      $$PersonVoiceprintsTableAnnotationComposer,
      $$PersonVoiceprintsTableCreateCompanionBuilder,
      $$PersonVoiceprintsTableUpdateCompanionBuilder,
      (
        PersonVoiceprint,
        BaseReferences<
          _$AppDatabase,
          $PersonVoiceprintsTable,
          PersonVoiceprint
        >,
      ),
      PersonVoiceprint,
      PrefetchHooks Function()
    >;
typedef $$TranscriptSegmentsTableCreateCompanionBuilder =
    TranscriptSegmentsCompanion Function({
      Value<int> id,
      required String recordingId,
      Value<String?> runId,
      required int idx,
      required int startMs,
      required int endMs,
      Value<String?> content,
      Value<String?> lang,
      Value<int?> speaker,
    });
typedef $$TranscriptSegmentsTableUpdateCompanionBuilder =
    TranscriptSegmentsCompanion Function({
      Value<int> id,
      Value<String> recordingId,
      Value<String?> runId,
      Value<int> idx,
      Value<int> startMs,
      Value<int> endMs,
      Value<String?> content,
      Value<String?> lang,
      Value<int?> speaker,
    });

class $$TranscriptSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranscriptSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranscriptSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<int> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);
}

class $$TranscriptSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranscriptSegmentsTable,
          TranscriptSegment,
          $$TranscriptSegmentsTableFilterComposer,
          $$TranscriptSegmentsTableOrderingComposer,
          $$TranscriptSegmentsTableAnnotationComposer,
          $$TranscriptSegmentsTableCreateCompanionBuilder,
          $$TranscriptSegmentsTableUpdateCompanionBuilder,
          (
            TranscriptSegment,
            BaseReferences<
              _$AppDatabase,
              $TranscriptSegmentsTable,
              TranscriptSegment
            >,
          ),
          TranscriptSegment,
          PrefetchHooks Function()
        > {
  $$TranscriptSegmentsTableTableManager(
    _$AppDatabase db,
    $TranscriptSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptSegmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordingId = const Value.absent(),
                Value<String?> runId = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<int?> speaker = const Value.absent(),
              }) => TranscriptSegmentsCompanion(
                id: id,
                recordingId: recordingId,
                runId: runId,
                idx: idx,
                startMs: startMs,
                endMs: endMs,
                content: content,
                lang: lang,
                speaker: speaker,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordingId,
                Value<String?> runId = const Value.absent(),
                required int idx,
                required int startMs,
                required int endMs,
                Value<String?> content = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<int?> speaker = const Value.absent(),
              }) => TranscriptSegmentsCompanion.insert(
                id: id,
                recordingId: recordingId,
                runId: runId,
                idx: idx,
                startMs: startMs,
                endMs: endMs,
                content: content,
                lang: lang,
                speaker: speaker,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TranscriptSegmentsTable, TranscriptSegment>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TranscriptSegmentsTable,
                    TranscriptSegment
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranscriptSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranscriptSegmentsTable,
      TranscriptSegment,
      $$TranscriptSegmentsTableFilterComposer,
      $$TranscriptSegmentsTableOrderingComposer,
      $$TranscriptSegmentsTableAnnotationComposer,
      $$TranscriptSegmentsTableCreateCompanionBuilder,
      $$TranscriptSegmentsTableUpdateCompanionBuilder,
      (
        TranscriptSegment,
        BaseReferences<
          _$AppDatabase,
          $TranscriptSegmentsTable,
          TranscriptSegment
        >,
      ),
      TranscriptSegment,
      PrefetchHooks Function()
    >;
typedef $$SpeakerNamesTableCreateCompanionBuilder =
    SpeakerNamesCompanion Function({
      required String recordingId,
      required String runId,
      required int speaker,
      required String name,
      Value<String?> personId,
      Value<String> source,
      Value<double?> matchScore,
      Value<int> rowid,
    });
typedef $$SpeakerNamesTableUpdateCompanionBuilder =
    SpeakerNamesCompanion Function({
      Value<String> recordingId,
      Value<String> runId,
      Value<int> speaker,
      Value<String> name,
      Value<String?> personId,
      Value<String> source,
      Value<double?> matchScore,
      Value<int> rowid,
    });

class $$SpeakerNamesTableFilterComposer
    extends Composer<_$AppDatabase, $SpeakerNamesTable> {
  $$SpeakerNamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get matchScore => $composableBuilder(
    column: $table.matchScore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeakerNamesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeakerNamesTable> {
  $$SpeakerNamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get matchScore => $composableBuilder(
    column: $table.matchScore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeakerNamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeakerNamesTable> {
  $$SpeakerNamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get matchScore => $composableBuilder(
    column: $table.matchScore,
    builder: (column) => column,
  );
}

class $$SpeakerNamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeakerNamesTable,
          SpeakerName,
          $$SpeakerNamesTableFilterComposer,
          $$SpeakerNamesTableOrderingComposer,
          $$SpeakerNamesTableAnnotationComposer,
          $$SpeakerNamesTableCreateCompanionBuilder,
          $$SpeakerNamesTableUpdateCompanionBuilder,
          (
            SpeakerName,
            BaseReferences<_$AppDatabase, $SpeakerNamesTable, SpeakerName>,
          ),
          SpeakerName,
          PrefetchHooks Function()
        > {
  $$SpeakerNamesTableTableManager(_$AppDatabase db, $SpeakerNamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeakerNamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeakerNamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeakerNamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> recordingId = const Value.absent(),
                Value<String> runId = const Value.absent(),
                Value<int> speaker = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double?> matchScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpeakerNamesCompanion(
                recordingId: recordingId,
                runId: runId,
                speaker: speaker,
                name: name,
                personId: personId,
                source: source,
                matchScore: matchScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String recordingId,
                required String runId,
                required int speaker,
                required String name,
                Value<String?> personId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double?> matchScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpeakerNamesCompanion.insert(
                recordingId: recordingId,
                runId: runId,
                speaker: speaker,
                name: name,
                personId: personId,
                source: source,
                matchScore: matchScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpeakerNamesTable, SpeakerName>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SpeakerNamesTable,
                    SpeakerName
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeakerNamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeakerNamesTable,
      SpeakerName,
      $$SpeakerNamesTableFilterComposer,
      $$SpeakerNamesTableOrderingComposer,
      $$SpeakerNamesTableAnnotationComposer,
      $$SpeakerNamesTableCreateCompanionBuilder,
      $$SpeakerNamesTableUpdateCompanionBuilder,
      (
        SpeakerName,
        BaseReferences<_$AppDatabase, $SpeakerNamesTable, SpeakerName>,
      ),
      SpeakerName,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      required String recordingId,
      required int positionMs,
      Value<String?> label,
      required DateTime createdAt,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<String> recordingId,
      Value<int> positionMs,
      Value<String?> label,
      Value<DateTime> createdAt,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordingId => $composableBuilder(
    column: $table.recordingId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordingId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                recordingId: recordingId,
                positionMs: positionMs,
                label: label,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordingId,
                required int positionMs,
                Value<String?> label = const Value.absent(),
                required DateTime createdAt,
              }) => BookmarksCompanion.insert(
                id: id,
                recordingId: recordingId,
                positionMs: positionMs,
                label: label,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarksTable, Bookmark>(table),
                  BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecordingsTableTableManager get recordings =>
      $$RecordingsTableTableManager(_db, _db.recordings);
  $$TranscriptionRunsTableTableManager get transcriptionRuns =>
      $$TranscriptionRunsTableTableManager(_db, _db.transcriptionRuns);
  $$RunSpeakerEmbeddingsTableTableManager get runSpeakerEmbeddings =>
      $$RunSpeakerEmbeddingsTableTableManager(_db, _db.runSpeakerEmbeddings);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$PersonVoiceprintsTableTableManager get personVoiceprints =>
      $$PersonVoiceprintsTableTableManager(_db, _db.personVoiceprints);
  $$TranscriptSegmentsTableTableManager get transcriptSegments =>
      $$TranscriptSegmentsTableTableManager(_db, _db.transcriptSegments);
  $$SpeakerNamesTableTableManager get speakerNames =>
      $$SpeakerNamesTableTableManager(_db, _db.speakerNames);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
}
