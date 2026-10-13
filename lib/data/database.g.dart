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
          ..write('speakerCountHint: $speakerCountHint')
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
          other.speakerCountHint == this.speakerCountHint);
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
          ..write('rowid: $rowid')
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
    {recordingId, idx},
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
  final int idx;
  final int startMs;
  final int endMs;
  final String? content;
  final String? lang;
  final int? speaker;
  const TranscriptSegment({
    required this.id,
    required this.recordingId,
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
    int? idx,
    int? startMs,
    int? endMs,
    Value<String?> content = const Value.absent(),
    Value<String?> lang = const Value.absent(),
    Value<int?> speaker = const Value.absent(),
  }) => TranscriptSegment(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
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
  int get hashCode =>
      Object.hash(id, recordingId, idx, startMs, endMs, content, lang, speaker);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptSegment &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
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
  final Value<int> idx;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String?> content;
  final Value<String?> lang;
  final Value<int?> speaker;
  const TranscriptSegmentsCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
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
  @override
  List<GeneratedColumn> get $columns => [recordingId, speaker, name];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recordingId, speaker};
  @override
  SpeakerName map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeakerName(
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_id'],
      )!,
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speaker'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $SpeakerNamesTable createAlias(String alias) {
    return $SpeakerNamesTable(attachedDatabase, alias);
  }
}

class SpeakerName extends DataClass implements Insertable<SpeakerName> {
  final String recordingId;
  final int speaker;
  final String name;
  const SpeakerName({
    required this.recordingId,
    required this.speaker,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recording_id'] = Variable<String>(recordingId);
    map['speaker'] = Variable<int>(speaker);
    map['name'] = Variable<String>(name);
    return map;
  }

  SpeakerNamesCompanion toCompanion(bool nullToAbsent) {
    return SpeakerNamesCompanion(
      recordingId: Value(recordingId),
      speaker: Value(speaker),
      name: Value(name),
    );
  }

  factory SpeakerName.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeakerName(
      recordingId: serializer.fromJson<String>(json['recordingId']),
      speaker: serializer.fromJson<int>(json['speaker']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recordingId': serializer.toJson<String>(recordingId),
      'speaker': serializer.toJson<int>(speaker),
      'name': serializer.toJson<String>(name),
    };
  }

  SpeakerName copyWith({String? recordingId, int? speaker, String? name}) =>
      SpeakerName(
        recordingId: recordingId ?? this.recordingId,
        speaker: speaker ?? this.speaker,
        name: name ?? this.name,
      );
  SpeakerName copyWithCompanion(SpeakerNamesCompanion data) {
    return SpeakerName(
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeakerName(')
          ..write('recordingId: $recordingId, ')
          ..write('speaker: $speaker, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(recordingId, speaker, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeakerName &&
          other.recordingId == this.recordingId &&
          other.speaker == this.speaker &&
          other.name == this.name);
}

class SpeakerNamesCompanion extends UpdateCompanion<SpeakerName> {
  final Value<String> recordingId;
  final Value<int> speaker;
  final Value<String> name;
  final Value<int> rowid;
  const SpeakerNamesCompanion({
    this.recordingId = const Value.absent(),
    this.speaker = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeakerNamesCompanion.insert({
    required String recordingId,
    required int speaker,
    required String name,
    this.rowid = const Value.absent(),
  }) : recordingId = Value(recordingId),
       speaker = Value(speaker),
       name = Value(name);
  static Insertable<SpeakerName> custom({
    Expression<String>? recordingId,
    Expression<int>? speaker,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recordingId != null) 'recording_id': recordingId,
      if (speaker != null) 'speaker': speaker,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeakerNamesCompanion copyWith({
    Value<String>? recordingId,
    Value<int>? speaker,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return SpeakerNamesCompanion(
      recordingId: recordingId ?? this.recordingId,
      speaker: speaker ?? this.speaker,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<int>(speaker.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
          ..write('speaker: $speaker, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecordingsTable recordings = $RecordingsTable(this);
  late final $TranscriptSegmentsTable transcriptSegments =
      $TranscriptSegmentsTable(this);
  late final $SpeakerNamesTable speakerNames = $SpeakerNamesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recordings,
    transcriptSegments,
    speakerNames,
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
typedef $$TranscriptSegmentsTableCreateCompanionBuilder =
    TranscriptSegmentsCompanion Function({
      Value<int> id,
      required String recordingId,
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
                Value<int> idx = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<int?> speaker = const Value.absent(),
              }) => TranscriptSegmentsCompanion(
                id: id,
                recordingId: recordingId,
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
                required int idx,
                required int startMs,
                required int endMs,
                Value<String?> content = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<int?> speaker = const Value.absent(),
              }) => TranscriptSegmentsCompanion.insert(
                id: id,
                recordingId: recordingId,
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
      required int speaker,
      required String name,
      Value<int> rowid,
    });
typedef $$SpeakerNamesTableUpdateCompanionBuilder =
    SpeakerNamesCompanion Function({
      Value<String> recordingId,
      Value<int> speaker,
      Value<String> name,
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

  ColumnFilters<int> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<int> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  GeneratedColumn<int> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
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
                Value<int> speaker = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpeakerNamesCompanion(
                recordingId: recordingId,
                speaker: speaker,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String recordingId,
                required int speaker,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => SpeakerNamesCompanion.insert(
                recordingId: recordingId,
                speaker: speaker,
                name: name,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecordingsTableTableManager get recordings =>
      $$RecordingsTableTableManager(_db, _db.recordings);
  $$TranscriptSegmentsTableTableManager get transcriptSegments =>
      $$TranscriptSegmentsTableTableManager(_db, _db.transcriptSegments);
  $$SpeakerNamesTableTableManager get speakerNames =>
      $$SpeakerNamesTableTableManager(_db, _db.speakerNames);
}
