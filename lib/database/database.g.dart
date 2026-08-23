// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Uuid().v4(),
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dataPathMeta = const VerificationMeta(
    'dataPath',
  );
  @override
  late final GeneratedColumn<String> dataPath = GeneratedColumn<String>(
    'data_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAssessmentMeta = const VerificationMeta(
    'isAssessment',
  );
  @override
  late final GeneratedColumn<bool> isAssessment = GeneratedColumn<bool>(
    'is_assessment',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_assessment" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  @override
  late final GeneratedColumn<int> activity = GeneratedColumn<int>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('logged'),
  );
  static const VerificationMeta _trainingIdMeta = const VerificationMeta(
    'trainingId',
  );
  @override
  late final GeneratedColumn<String> trainingId = GeneratedColumn<String>(
    'training_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _programSessionIdMeta = const VerificationMeta(
    'programSessionId',
  );
  @override
  late final GeneratedColumn<String> programSessionId = GeneratedColumn<String>(
    'program_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    notes,
    date,
    dataPath,
    isAssessment,
    activity,
    origin,
    trainingId,
    programSessionId,
    duration,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('data_path')) {
      context.handle(
        _dataPathMeta,
        dataPath.isAcceptableOrUnknown(data['data_path']!, _dataPathMeta),
      );
    } else if (isInserting) {
      context.missing(_dataPathMeta);
    }
    if (data.containsKey('is_assessment')) {
      context.handle(
        _isAssessmentMeta,
        isAssessment.isAcceptableOrUnknown(
          data['is_assessment']!,
          _isAssessmentMeta,
        ),
      );
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('training_id')) {
      context.handle(
        _trainingIdMeta,
        trainingId.isAcceptableOrUnknown(data['training_id']!, _trainingIdMeta),
      );
    }
    if (data.containsKey('program_session_id')) {
      context.handle(
        _programSessionIdMeta,
        programSessionId.isAcceptableOrUnknown(
          data['program_session_id']!,
          _programSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      dataPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_path'],
      )!,
      isAssessment: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_assessment'],
      )!,
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      trainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_id'],
      ),
      programSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_session_id'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String name;
  final String notes;
  final DateTime date;
  final String dataPath;
  final bool isAssessment;
  final int activity;
  final String origin;
  final String? trainingId;
  final String? programSessionId;
  final int duration;
  final DateTime updatedAt;
  const Session({
    required this.id,
    required this.name,
    required this.notes,
    required this.date,
    required this.dataPath,
    required this.isAssessment,
    required this.activity,
    required this.origin,
    this.trainingId,
    this.programSessionId,
    required this.duration,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    map['date'] = Variable<DateTime>(date);
    map['data_path'] = Variable<String>(dataPath);
    map['is_assessment'] = Variable<bool>(isAssessment);
    map['activity'] = Variable<int>(activity);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || trainingId != null) {
      map['training_id'] = Variable<String>(trainingId);
    }
    if (!nullToAbsent || programSessionId != null) {
      map['program_session_id'] = Variable<String>(programSessionId);
    }
    map['duration'] = Variable<int>(duration);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      name: Value(name),
      notes: Value(notes),
      date: Value(date),
      dataPath: Value(dataPath),
      isAssessment: Value(isAssessment),
      activity: Value(activity),
      origin: Value(origin),
      trainingId: trainingId == null && nullToAbsent
          ? const Value.absent()
          : Value(trainingId),
      programSessionId: programSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(programSessionId),
      duration: Value(duration),
      updatedAt: Value(updatedAt),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
      date: serializer.fromJson<DateTime>(json['date']),
      dataPath: serializer.fromJson<String>(json['dataPath']),
      isAssessment: serializer.fromJson<bool>(json['isAssessment']),
      activity: serializer.fromJson<int>(json['activity']),
      origin: serializer.fromJson<String>(json['origin']),
      trainingId: serializer.fromJson<String?>(json['trainingId']),
      programSessionId: serializer.fromJson<String?>(json['programSessionId']),
      duration: serializer.fromJson<int>(json['duration']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
      'date': serializer.toJson<DateTime>(date),
      'dataPath': serializer.toJson<String>(dataPath),
      'isAssessment': serializer.toJson<bool>(isAssessment),
      'activity': serializer.toJson<int>(activity),
      'origin': serializer.toJson<String>(origin),
      'trainingId': serializer.toJson<String?>(trainingId),
      'programSessionId': serializer.toJson<String?>(programSessionId),
      'duration': serializer.toJson<int>(duration),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Session copyWith({
    String? id,
    String? name,
    String? notes,
    DateTime? date,
    String? dataPath,
    bool? isAssessment,
    int? activity,
    String? origin,
    Value<String?> trainingId = const Value.absent(),
    Value<String?> programSessionId = const Value.absent(),
    int? duration,
    DateTime? updatedAt,
  }) => Session(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    date: date ?? this.date,
    dataPath: dataPath ?? this.dataPath,
    isAssessment: isAssessment ?? this.isAssessment,
    activity: activity ?? this.activity,
    origin: origin ?? this.origin,
    trainingId: trainingId.present ? trainingId.value : this.trainingId,
    programSessionId: programSessionId.present
        ? programSessionId.value
        : this.programSessionId,
    duration: duration ?? this.duration,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      date: data.date.present ? data.date.value : this.date,
      dataPath: data.dataPath.present ? data.dataPath.value : this.dataPath,
      isAssessment: data.isAssessment.present
          ? data.isAssessment.value
          : this.isAssessment,
      activity: data.activity.present ? data.activity.value : this.activity,
      origin: data.origin.present ? data.origin.value : this.origin,
      trainingId: data.trainingId.present
          ? data.trainingId.value
          : this.trainingId,
      programSessionId: data.programSessionId.present
          ? data.programSessionId.value
          : this.programSessionId,
      duration: data.duration.present ? data.duration.value : this.duration,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('date: $date, ')
          ..write('dataPath: $dataPath, ')
          ..write('isAssessment: $isAssessment, ')
          ..write('activity: $activity, ')
          ..write('origin: $origin, ')
          ..write('trainingId: $trainingId, ')
          ..write('programSessionId: $programSessionId, ')
          ..write('duration: $duration, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    notes,
    date,
    dataPath,
    isAssessment,
    activity,
    origin,
    trainingId,
    programSessionId,
    duration,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.date == this.date &&
          other.dataPath == this.dataPath &&
          other.isAssessment == this.isAssessment &&
          other.activity == this.activity &&
          other.origin == this.origin &&
          other.trainingId == this.trainingId &&
          other.programSessionId == this.programSessionId &&
          other.duration == this.duration &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> notes;
  final Value<DateTime> date;
  final Value<String> dataPath;
  final Value<bool> isAssessment;
  final Value<int> activity;
  final Value<String> origin;
  final Value<String?> trainingId;
  final Value<String?> programSessionId;
  final Value<int> duration;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.date = const Value.absent(),
    this.dataPath = const Value.absent(),
    this.isAssessment = const Value.absent(),
    this.activity = const Value.absent(),
    this.origin = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.programSessionId = const Value.absent(),
    this.duration = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String notes,
    this.date = const Value.absent(),
    required String dataPath,
    this.isAssessment = const Value.absent(),
    this.activity = const Value.absent(),
    this.origin = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.programSessionId = const Value.absent(),
    this.duration = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       notes = Value(notes),
       dataPath = Value(dataPath);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<DateTime>? date,
    Expression<String>? dataPath,
    Expression<bool>? isAssessment,
    Expression<int>? activity,
    Expression<String>? origin,
    Expression<String>? trainingId,
    Expression<String>? programSessionId,
    Expression<int>? duration,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date,
      if (dataPath != null) 'data_path': dataPath,
      if (isAssessment != null) 'is_assessment': isAssessment,
      if (activity != null) 'activity': activity,
      if (origin != null) 'origin': origin,
      if (trainingId != null) 'training_id': trainingId,
      if (programSessionId != null) 'program_session_id': programSessionId,
      if (duration != null) 'duration': duration,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? notes,
    Value<DateTime>? date,
    Value<String>? dataPath,
    Value<bool>? isAssessment,
    Value<int>? activity,
    Value<String>? origin,
    Value<String?>? trainingId,
    Value<String?>? programSessionId,
    Value<int>? duration,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      dataPath: dataPath ?? this.dataPath,
      isAssessment: isAssessment ?? this.isAssessment,
      activity: activity ?? this.activity,
      origin: origin ?? this.origin,
      trainingId: trainingId ?? this.trainingId,
      programSessionId: programSessionId ?? this.programSessionId,
      duration: duration ?? this.duration,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dataPath.present) {
      map['data_path'] = Variable<String>(dataPath.value);
    }
    if (isAssessment.present) {
      map['is_assessment'] = Variable<bool>(isAssessment.value);
    }
    if (activity.present) {
      map['activity'] = Variable<int>(activity.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (trainingId.present) {
      map['training_id'] = Variable<String>(trainingId.value);
    }
    if (programSessionId.present) {
      map['program_session_id'] = Variable<String>(programSessionId.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('date: $date, ')
          ..write('dataPath: $dataPath, ')
          ..write('isAssessment: $isAssessment, ')
          ..write('activity: $activity, ')
          ..write('origin: $origin, ')
          ..write('trainingId: $trainingId, ')
          ..write('programSessionId: $programSessionId, ')
          ..write('duration: $duration, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssessmentsTable extends Assessments
    with TableInfo<$AssessmentsTable, Assessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Uuid().v4(),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rightValueMeta = const VerificationMeta(
    'rightValue',
  );
  @override
  late final GeneratedColumn<double> rightValue = GeneratedColumn<double>(
    'right_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftValueMeta = const VerificationMeta(
    'leftValue',
  );
  @override
  late final GeneratedColumn<double> leftValue = GeneratedColumn<double>(
    'left_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gripPositionMeta = const VerificationMeta(
    'gripPosition',
  );
  @override
  late final GeneratedColumn<int> gripPosition = GeneratedColumn<int>(
    'grip_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    rightValue,
    leftValue,
    sessionId,
    gripPosition,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Assessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('right_value')) {
      context.handle(
        _rightValueMeta,
        rightValue.isAcceptableOrUnknown(data['right_value']!, _rightValueMeta),
      );
    }
    if (data.containsKey('left_value')) {
      context.handle(
        _leftValueMeta,
        leftValue.isAcceptableOrUnknown(data['left_value']!, _leftValueMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('grip_position')) {
      context.handle(
        _gripPositionMeta,
        gripPosition.isAcceptableOrUnknown(
          data['grip_position']!,
          _gripPositionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assessment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      rightValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_value'],
      ),
      leftValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_value'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      gripPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grip_position'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AssessmentsTable createAlias(String alias) {
    return $AssessmentsTable(attachedDatabase, alias);
  }
}

class Assessment extends DataClass implements Insertable<Assessment> {
  final String id;
  final int type;
  final double? rightValue;
  final double? leftValue;
  final String sessionId;
  final int? gripPosition;
  final DateTime updatedAt;
  const Assessment({
    required this.id,
    required this.type,
    this.rightValue,
    this.leftValue,
    required this.sessionId,
    this.gripPosition,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || rightValue != null) {
      map['right_value'] = Variable<double>(rightValue);
    }
    if (!nullToAbsent || leftValue != null) {
      map['left_value'] = Variable<double>(leftValue);
    }
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || gripPosition != null) {
      map['grip_position'] = Variable<int>(gripPosition);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AssessmentsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentsCompanion(
      id: Value(id),
      type: Value(type),
      rightValue: rightValue == null && nullToAbsent
          ? const Value.absent()
          : Value(rightValue),
      leftValue: leftValue == null && nullToAbsent
          ? const Value.absent()
          : Value(leftValue),
      sessionId: Value(sessionId),
      gripPosition: gripPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(gripPosition),
      updatedAt: Value(updatedAt),
    );
  }

  factory Assessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assessment(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      rightValue: serializer.fromJson<double?>(json['rightValue']),
      leftValue: serializer.fromJson<double?>(json['leftValue']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      gripPosition: serializer.fromJson<int?>(json['gripPosition']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<int>(type),
      'rightValue': serializer.toJson<double?>(rightValue),
      'leftValue': serializer.toJson<double?>(leftValue),
      'sessionId': serializer.toJson<String>(sessionId),
      'gripPosition': serializer.toJson<int?>(gripPosition),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Assessment copyWith({
    String? id,
    int? type,
    Value<double?> rightValue = const Value.absent(),
    Value<double?> leftValue = const Value.absent(),
    String? sessionId,
    Value<int?> gripPosition = const Value.absent(),
    DateTime? updatedAt,
  }) => Assessment(
    id: id ?? this.id,
    type: type ?? this.type,
    rightValue: rightValue.present ? rightValue.value : this.rightValue,
    leftValue: leftValue.present ? leftValue.value : this.leftValue,
    sessionId: sessionId ?? this.sessionId,
    gripPosition: gripPosition.present ? gripPosition.value : this.gripPosition,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Assessment copyWithCompanion(AssessmentsCompanion data) {
    return Assessment(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      rightValue: data.rightValue.present
          ? data.rightValue.value
          : this.rightValue,
      leftValue: data.leftValue.present ? data.leftValue.value : this.leftValue,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      gripPosition: data.gripPosition.present
          ? data.gripPosition.value
          : this.gripPosition,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assessment(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rightValue: $rightValue, ')
          ..write('leftValue: $leftValue, ')
          ..write('sessionId: $sessionId, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    rightValue,
    leftValue,
    sessionId,
    gripPosition,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assessment &&
          other.id == this.id &&
          other.type == this.type &&
          other.rightValue == this.rightValue &&
          other.leftValue == this.leftValue &&
          other.sessionId == this.sessionId &&
          other.gripPosition == this.gripPosition &&
          other.updatedAt == this.updatedAt);
}

class AssessmentsCompanion extends UpdateCompanion<Assessment> {
  final Value<String> id;
  final Value<int> type;
  final Value<double?> rightValue;
  final Value<double?> leftValue;
  final Value<String> sessionId;
  final Value<int?> gripPosition;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    this.id = const Value.absent(),
    required int type,
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    required String sessionId,
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       sessionId = Value(sessionId);
  static Insertable<Assessment> custom({
    Expression<String>? id,
    Expression<int>? type,
    Expression<double>? rightValue,
    Expression<double>? leftValue,
    Expression<String>? sessionId,
    Expression<int>? gripPosition,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (rightValue != null) 'right_value': rightValue,
      if (leftValue != null) 'left_value': leftValue,
      if (sessionId != null) 'session_id': sessionId,
      if (gripPosition != null) 'grip_position': gripPosition,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentsCompanion copyWith({
    Value<String>? id,
    Value<int>? type,
    Value<double?>? rightValue,
    Value<double?>? leftValue,
    Value<String>? sessionId,
    Value<int?>? gripPosition,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      rightValue: rightValue ?? this.rightValue,
      leftValue: leftValue ?? this.leftValue,
      sessionId: sessionId ?? this.sessionId,
      gripPosition: gripPosition ?? this.gripPosition,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (rightValue.present) {
      map['right_value'] = Variable<double>(rightValue.value);
    }
    if (leftValue.present) {
      map['left_value'] = Variable<double>(leftValue.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (gripPosition.present) {
      map['grip_position'] = Variable<int>(gripPosition.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rightValue: $rightValue, ')
          ..write('leftValue: $leftValue, ')
          ..write('sessionId: $sessionId, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrainingsTable extends Trainings
    with TableInfo<$TrainingsTable, TrainingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Uuid().v4(),
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    isFavorite,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trainings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TrainingsTable createAlias(String alias) {
    return $TrainingsTable(attachedDatabase, alias);
  }
}

class TrainingRow extends DataClass implements Insertable<TrainingRow> {
  final String id;
  final String title;
  final String? description;
  final bool isFavorite;
  final DateTime updatedAt;
  const TrainingRow({
    required this.id,
    required this.title,
    this.description,
    required this.isFavorite,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrainingsCompanion toCompanion(bool nullToAbsent) {
    return TrainingsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isFavorite: Value(isFavorite),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrainingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrainingRow copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    bool? isFavorite,
    DateTime? updatedAt,
  }) => TrainingRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    isFavorite: isFavorite ?? this.isFavorite,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrainingRow copyWithCompanion(TrainingsCompanion data) {
    return TrainingRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, isFavorite, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.isFavorite == this.isFavorite &&
          other.updatedAt == this.updatedAt);
}

class TrainingsCompanion extends UpdateCompanion<TrainingRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> isFavorite;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrainingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrainingsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : title = Value(title);
  static Insertable<TrainingRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isFavorite,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrainingsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<bool>? isFavorite,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TrainingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrainingItemsTable extends TrainingItems
    with TableInfo<$TrainingItemsTable, TrainingItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Uuid().v4(),
  );
  static const VerificationMeta _trainingIdMeta = const VerificationMeta(
    'trainingId',
  );
  @override
  late final GeneratedColumn<String> trainingId = GeneratedColumn<String>(
    'training_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cyclesMeta = const VerificationMeta('cycles');
  @override
  late final GeneratedColumn<int> cycles = GeneratedColumn<int>(
    'cycles',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cycleRestSecondsMeta = const VerificationMeta(
    'cycleRestSeconds',
  );
  @override
  late final GeneratedColumn<int> cycleRestSeconds = GeneratedColumn<int>(
    'cycle_rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _worktimeSecondsMeta = const VerificationMeta(
    'worktimeSeconds',
  );
  @override
  late final GeneratedColumn<int> worktimeSeconds = GeneratedColumn<int>(
    'worktime_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _handMeta = const VerificationMeta('hand');
  @override
  late final GeneratedColumn<String> hand = GeneratedColumn<String>(
    'hand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _granularityMeta = const VerificationMeta(
    'granularity',
  );
  @override
  late final GeneratedColumn<String> granularity = GeneratedColumn<String>(
    'granularity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loadsJsonMeta = const VerificationMeta(
    'loadsJson',
  );
  @override
  late final GeneratedColumn<String> loadsJson = GeneratedColumn<String>(
    'loads_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftLoadsJsonMeta = const VerificationMeta(
    'leftLoadsJson',
  );
  @override
  late final GeneratedColumn<String> leftLoadsJson = GeneratedColumn<String>(
    'left_loads_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _handPositionsJsonMeta = const VerificationMeta(
    'handPositionsJson',
  );
  @override
  late final GeneratedColumn<String> handPositionsJson =
      GeneratedColumn<String>(
        'hand_positions_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _edgeSizesMmJsonMeta = const VerificationMeta(
    'edgeSizesMmJson',
  );
  @override
  late final GeneratedColumn<String> edgeSizesMmJson = GeneratedColumn<String>(
    'edge_sizes_mm_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loadIsMaxMeta = const VerificationMeta(
    'loadIsMax',
  );
  @override
  late final GeneratedColumn<bool> loadIsMax = GeneratedColumn<bool>(
    'load_is_max',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("load_is_max" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _freeTextMeta = const VerificationMeta(
    'freeText',
  );
  @override
  late final GeneratedColumn<String> freeText = GeneratedColumn<String>(
    'free_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupTitleMeta = const VerificationMeta(
    'groupTitle',
  );
  @override
  late final GeneratedColumn<String> groupTitle = GeneratedColumn<String>(
    'group_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trainingId,
    parentId,
    type,
    position,
    cycles,
    cycleRestSeconds,
    reps,
    duration,
    restSeconds,
    worktimeSeconds,
    hand,
    granularity,
    loadsJson,
    leftLoadsJson,
    handPositionsJson,
    edgeSizesMmJson,
    loadIsMax,
    freeText,
    exerciseId,
    groupTitle,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('training_id')) {
      context.handle(
        _trainingIdMeta,
        trainingId.isAcceptableOrUnknown(data['training_id']!, _trainingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trainingIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('cycles')) {
      context.handle(
        _cyclesMeta,
        cycles.isAcceptableOrUnknown(data['cycles']!, _cyclesMeta),
      );
    }
    if (data.containsKey('cycle_rest_seconds')) {
      context.handle(
        _cycleRestSecondsMeta,
        cycleRestSeconds.isAcceptableOrUnknown(
          data['cycle_rest_seconds']!,
          _cycleRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    if (data.containsKey('worktime_seconds')) {
      context.handle(
        _worktimeSecondsMeta,
        worktimeSeconds.isAcceptableOrUnknown(
          data['worktime_seconds']!,
          _worktimeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('hand')) {
      context.handle(
        _handMeta,
        hand.isAcceptableOrUnknown(data['hand']!, _handMeta),
      );
    }
    if (data.containsKey('granularity')) {
      context.handle(
        _granularityMeta,
        granularity.isAcceptableOrUnknown(
          data['granularity']!,
          _granularityMeta,
        ),
      );
    }
    if (data.containsKey('loads_json')) {
      context.handle(
        _loadsJsonMeta,
        loadsJson.isAcceptableOrUnknown(data['loads_json']!, _loadsJsonMeta),
      );
    }
    if (data.containsKey('left_loads_json')) {
      context.handle(
        _leftLoadsJsonMeta,
        leftLoadsJson.isAcceptableOrUnknown(
          data['left_loads_json']!,
          _leftLoadsJsonMeta,
        ),
      );
    }
    if (data.containsKey('hand_positions_json')) {
      context.handle(
        _handPositionsJsonMeta,
        handPositionsJson.isAcceptableOrUnknown(
          data['hand_positions_json']!,
          _handPositionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('edge_sizes_mm_json')) {
      context.handle(
        _edgeSizesMmJsonMeta,
        edgeSizesMmJson.isAcceptableOrUnknown(
          data['edge_sizes_mm_json']!,
          _edgeSizesMmJsonMeta,
        ),
      );
    }
    if (data.containsKey('load_is_max')) {
      context.handle(
        _loadIsMaxMeta,
        loadIsMax.isAcceptableOrUnknown(data['load_is_max']!, _loadIsMaxMeta),
      );
    }
    if (data.containsKey('free_text')) {
      context.handle(
        _freeTextMeta,
        freeText.isAcceptableOrUnknown(data['free_text']!, _freeTextMeta),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('group_title')) {
      context.handle(
        _groupTitleMeta,
        groupTitle.isAcceptableOrUnknown(data['group_title']!, _groupTitleMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      cycles: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycles'],
      ),
      cycleRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_rest_seconds'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      worktimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}worktime_seconds'],
      ),
      hand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hand'],
      ),
      granularity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}granularity'],
      ),
      loadsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loads_json'],
      ),
      leftLoadsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}left_loads_json'],
      ),
      handPositionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hand_positions_json'],
      ),
      edgeSizesMmJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edge_sizes_mm_json'],
      ),
      loadIsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}load_is_max'],
      )!,
      freeText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_text'],
      ),
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      ),
      groupTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_title'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TrainingItemsTable createAlias(String alias) {
    return $TrainingItemsTable(attachedDatabase, alias);
  }
}

class TrainingItemRow extends DataClass implements Insertable<TrainingItemRow> {
  final String id;
  final String trainingId;
  final String? parentId;
  final String type;
  final int position;
  final int? cycles;
  final int? cycleRestSeconds;
  final int? reps;
  final int? duration;
  final int? restSeconds;
  final int? worktimeSeconds;
  final String? hand;
  final String? granularity;
  final String? loadsJson;
  final String? leftLoadsJson;
  final String? handPositionsJson;
  final String? edgeSizesMmJson;
  final bool loadIsMax;
  final String? freeText;
  final String? exerciseId;
  final String? groupTitle;
  final DateTime updatedAt;
  const TrainingItemRow({
    required this.id,
    required this.trainingId,
    this.parentId,
    required this.type,
    required this.position,
    this.cycles,
    this.cycleRestSeconds,
    this.reps,
    this.duration,
    this.restSeconds,
    this.worktimeSeconds,
    this.hand,
    this.granularity,
    this.loadsJson,
    this.leftLoadsJson,
    this.handPositionsJson,
    this.edgeSizesMmJson,
    required this.loadIsMax,
    this.freeText,
    this.exerciseId,
    this.groupTitle,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['training_id'] = Variable<String>(trainingId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['type'] = Variable<String>(type);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || cycles != null) {
      map['cycles'] = Variable<int>(cycles);
    }
    if (!nullToAbsent || cycleRestSeconds != null) {
      map['cycle_rest_seconds'] = Variable<int>(cycleRestSeconds);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    if (!nullToAbsent || worktimeSeconds != null) {
      map['worktime_seconds'] = Variable<int>(worktimeSeconds);
    }
    if (!nullToAbsent || hand != null) {
      map['hand'] = Variable<String>(hand);
    }
    if (!nullToAbsent || granularity != null) {
      map['granularity'] = Variable<String>(granularity);
    }
    if (!nullToAbsent || loadsJson != null) {
      map['loads_json'] = Variable<String>(loadsJson);
    }
    if (!nullToAbsent || leftLoadsJson != null) {
      map['left_loads_json'] = Variable<String>(leftLoadsJson);
    }
    if (!nullToAbsent || handPositionsJson != null) {
      map['hand_positions_json'] = Variable<String>(handPositionsJson);
    }
    if (!nullToAbsent || edgeSizesMmJson != null) {
      map['edge_sizes_mm_json'] = Variable<String>(edgeSizesMmJson);
    }
    map['load_is_max'] = Variable<bool>(loadIsMax);
    if (!nullToAbsent || freeText != null) {
      map['free_text'] = Variable<String>(freeText);
    }
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    if (!nullToAbsent || groupTitle != null) {
      map['group_title'] = Variable<String>(groupTitle);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrainingItemsCompanion toCompanion(bool nullToAbsent) {
    return TrainingItemsCompanion(
      id: Value(id),
      trainingId: Value(trainingId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      type: Value(type),
      position: Value(position),
      cycles: cycles == null && nullToAbsent
          ? const Value.absent()
          : Value(cycles),
      cycleRestSeconds: cycleRestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(cycleRestSeconds),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
      worktimeSeconds: worktimeSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(worktimeSeconds),
      hand: hand == null && nullToAbsent ? const Value.absent() : Value(hand),
      granularity: granularity == null && nullToAbsent
          ? const Value.absent()
          : Value(granularity),
      loadsJson: loadsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(loadsJson),
      leftLoadsJson: leftLoadsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(leftLoadsJson),
      handPositionsJson: handPositionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(handPositionsJson),
      edgeSizesMmJson: edgeSizesMmJson == null && nullToAbsent
          ? const Value.absent()
          : Value(edgeSizesMmJson),
      loadIsMax: Value(loadIsMax),
      freeText: freeText == null && nullToAbsent
          ? const Value.absent()
          : Value(freeText),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
      groupTitle: groupTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(groupTitle),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrainingItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingItemRow(
      id: serializer.fromJson<String>(json['id']),
      trainingId: serializer.fromJson<String>(json['trainingId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      type: serializer.fromJson<String>(json['type']),
      position: serializer.fromJson<int>(json['position']),
      cycles: serializer.fromJson<int?>(json['cycles']),
      cycleRestSeconds: serializer.fromJson<int?>(json['cycleRestSeconds']),
      reps: serializer.fromJson<int?>(json['reps']),
      duration: serializer.fromJson<int?>(json['duration']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      worktimeSeconds: serializer.fromJson<int?>(json['worktimeSeconds']),
      hand: serializer.fromJson<String?>(json['hand']),
      granularity: serializer.fromJson<String?>(json['granularity']),
      loadsJson: serializer.fromJson<String?>(json['loadsJson']),
      leftLoadsJson: serializer.fromJson<String?>(json['leftLoadsJson']),
      handPositionsJson: serializer.fromJson<String?>(
        json['handPositionsJson'],
      ),
      edgeSizesMmJson: serializer.fromJson<String?>(json['edgeSizesMmJson']),
      loadIsMax: serializer.fromJson<bool>(json['loadIsMax']),
      freeText: serializer.fromJson<String?>(json['freeText']),
      exerciseId: serializer.fromJson<String?>(json['exerciseId']),
      groupTitle: serializer.fromJson<String?>(json['groupTitle']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trainingId': serializer.toJson<String>(trainingId),
      'parentId': serializer.toJson<String?>(parentId),
      'type': serializer.toJson<String>(type),
      'position': serializer.toJson<int>(position),
      'cycles': serializer.toJson<int?>(cycles),
      'cycleRestSeconds': serializer.toJson<int?>(cycleRestSeconds),
      'reps': serializer.toJson<int?>(reps),
      'duration': serializer.toJson<int?>(duration),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'worktimeSeconds': serializer.toJson<int?>(worktimeSeconds),
      'hand': serializer.toJson<String?>(hand),
      'granularity': serializer.toJson<String?>(granularity),
      'loadsJson': serializer.toJson<String?>(loadsJson),
      'leftLoadsJson': serializer.toJson<String?>(leftLoadsJson),
      'handPositionsJson': serializer.toJson<String?>(handPositionsJson),
      'edgeSizesMmJson': serializer.toJson<String?>(edgeSizesMmJson),
      'loadIsMax': serializer.toJson<bool>(loadIsMax),
      'freeText': serializer.toJson<String?>(freeText),
      'exerciseId': serializer.toJson<String?>(exerciseId),
      'groupTitle': serializer.toJson<String?>(groupTitle),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrainingItemRow copyWith({
    String? id,
    String? trainingId,
    Value<String?> parentId = const Value.absent(),
    String? type,
    int? position,
    Value<int?> cycles = const Value.absent(),
    Value<int?> cycleRestSeconds = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    Value<int?> worktimeSeconds = const Value.absent(),
    Value<String?> hand = const Value.absent(),
    Value<String?> granularity = const Value.absent(),
    Value<String?> loadsJson = const Value.absent(),
    Value<String?> leftLoadsJson = const Value.absent(),
    Value<String?> handPositionsJson = const Value.absent(),
    Value<String?> edgeSizesMmJson = const Value.absent(),
    bool? loadIsMax,
    Value<String?> freeText = const Value.absent(),
    Value<String?> exerciseId = const Value.absent(),
    Value<String?> groupTitle = const Value.absent(),
    DateTime? updatedAt,
  }) => TrainingItemRow(
    id: id ?? this.id,
    trainingId: trainingId ?? this.trainingId,
    parentId: parentId.present ? parentId.value : this.parentId,
    type: type ?? this.type,
    position: position ?? this.position,
    cycles: cycles.present ? cycles.value : this.cycles,
    cycleRestSeconds: cycleRestSeconds.present
        ? cycleRestSeconds.value
        : this.cycleRestSeconds,
    reps: reps.present ? reps.value : this.reps,
    duration: duration.present ? duration.value : this.duration,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    worktimeSeconds: worktimeSeconds.present
        ? worktimeSeconds.value
        : this.worktimeSeconds,
    hand: hand.present ? hand.value : this.hand,
    granularity: granularity.present ? granularity.value : this.granularity,
    loadsJson: loadsJson.present ? loadsJson.value : this.loadsJson,
    leftLoadsJson: leftLoadsJson.present
        ? leftLoadsJson.value
        : this.leftLoadsJson,
    handPositionsJson: handPositionsJson.present
        ? handPositionsJson.value
        : this.handPositionsJson,
    edgeSizesMmJson: edgeSizesMmJson.present
        ? edgeSizesMmJson.value
        : this.edgeSizesMmJson,
    loadIsMax: loadIsMax ?? this.loadIsMax,
    freeText: freeText.present ? freeText.value : this.freeText,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    groupTitle: groupTitle.present ? groupTitle.value : this.groupTitle,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrainingItemRow copyWithCompanion(TrainingItemsCompanion data) {
    return TrainingItemRow(
      id: data.id.present ? data.id.value : this.id,
      trainingId: data.trainingId.present
          ? data.trainingId.value
          : this.trainingId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      type: data.type.present ? data.type.value : this.type,
      position: data.position.present ? data.position.value : this.position,
      cycles: data.cycles.present ? data.cycles.value : this.cycles,
      cycleRestSeconds: data.cycleRestSeconds.present
          ? data.cycleRestSeconds.value
          : this.cycleRestSeconds,
      reps: data.reps.present ? data.reps.value : this.reps,
      duration: data.duration.present ? data.duration.value : this.duration,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      worktimeSeconds: data.worktimeSeconds.present
          ? data.worktimeSeconds.value
          : this.worktimeSeconds,
      hand: data.hand.present ? data.hand.value : this.hand,
      granularity: data.granularity.present
          ? data.granularity.value
          : this.granularity,
      loadsJson: data.loadsJson.present ? data.loadsJson.value : this.loadsJson,
      leftLoadsJson: data.leftLoadsJson.present
          ? data.leftLoadsJson.value
          : this.leftLoadsJson,
      handPositionsJson: data.handPositionsJson.present
          ? data.handPositionsJson.value
          : this.handPositionsJson,
      edgeSizesMmJson: data.edgeSizesMmJson.present
          ? data.edgeSizesMmJson.value
          : this.edgeSizesMmJson,
      loadIsMax: data.loadIsMax.present ? data.loadIsMax.value : this.loadIsMax,
      freeText: data.freeText.present ? data.freeText.value : this.freeText,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      groupTitle: data.groupTitle.present
          ? data.groupTitle.value
          : this.groupTitle,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingItemRow(')
          ..write('id: $id, ')
          ..write('trainingId: $trainingId, ')
          ..write('parentId: $parentId, ')
          ..write('type: $type, ')
          ..write('position: $position, ')
          ..write('cycles: $cycles, ')
          ..write('cycleRestSeconds: $cycleRestSeconds, ')
          ..write('reps: $reps, ')
          ..write('duration: $duration, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('worktimeSeconds: $worktimeSeconds, ')
          ..write('hand: $hand, ')
          ..write('granularity: $granularity, ')
          ..write('loadsJson: $loadsJson, ')
          ..write('leftLoadsJson: $leftLoadsJson, ')
          ..write('handPositionsJson: $handPositionsJson, ')
          ..write('edgeSizesMmJson: $edgeSizesMmJson, ')
          ..write('loadIsMax: $loadIsMax, ')
          ..write('freeText: $freeText, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('groupTitle: $groupTitle, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    trainingId,
    parentId,
    type,
    position,
    cycles,
    cycleRestSeconds,
    reps,
    duration,
    restSeconds,
    worktimeSeconds,
    hand,
    granularity,
    loadsJson,
    leftLoadsJson,
    handPositionsJson,
    edgeSizesMmJson,
    loadIsMax,
    freeText,
    exerciseId,
    groupTitle,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingItemRow &&
          other.id == this.id &&
          other.trainingId == this.trainingId &&
          other.parentId == this.parentId &&
          other.type == this.type &&
          other.position == this.position &&
          other.cycles == this.cycles &&
          other.cycleRestSeconds == this.cycleRestSeconds &&
          other.reps == this.reps &&
          other.duration == this.duration &&
          other.restSeconds == this.restSeconds &&
          other.worktimeSeconds == this.worktimeSeconds &&
          other.hand == this.hand &&
          other.granularity == this.granularity &&
          other.loadsJson == this.loadsJson &&
          other.leftLoadsJson == this.leftLoadsJson &&
          other.handPositionsJson == this.handPositionsJson &&
          other.edgeSizesMmJson == this.edgeSizesMmJson &&
          other.loadIsMax == this.loadIsMax &&
          other.freeText == this.freeText &&
          other.exerciseId == this.exerciseId &&
          other.groupTitle == this.groupTitle &&
          other.updatedAt == this.updatedAt);
}

class TrainingItemsCompanion extends UpdateCompanion<TrainingItemRow> {
  final Value<String> id;
  final Value<String> trainingId;
  final Value<String?> parentId;
  final Value<String> type;
  final Value<int> position;
  final Value<int?> cycles;
  final Value<int?> cycleRestSeconds;
  final Value<int?> reps;
  final Value<int?> duration;
  final Value<int?> restSeconds;
  final Value<int?> worktimeSeconds;
  final Value<String?> hand;
  final Value<String?> granularity;
  final Value<String?> loadsJson;
  final Value<String?> leftLoadsJson;
  final Value<String?> handPositionsJson;
  final Value<String?> edgeSizesMmJson;
  final Value<bool> loadIsMax;
  final Value<String?> freeText;
  final Value<String?> exerciseId;
  final Value<String?> groupTitle;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrainingItemsCompanion({
    this.id = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.type = const Value.absent(),
    this.position = const Value.absent(),
    this.cycles = const Value.absent(),
    this.cycleRestSeconds = const Value.absent(),
    this.reps = const Value.absent(),
    this.duration = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.worktimeSeconds = const Value.absent(),
    this.hand = const Value.absent(),
    this.granularity = const Value.absent(),
    this.loadsJson = const Value.absent(),
    this.leftLoadsJson = const Value.absent(),
    this.handPositionsJson = const Value.absent(),
    this.edgeSizesMmJson = const Value.absent(),
    this.loadIsMax = const Value.absent(),
    this.freeText = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.groupTitle = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrainingItemsCompanion.insert({
    this.id = const Value.absent(),
    required String trainingId,
    this.parentId = const Value.absent(),
    required String type,
    this.position = const Value.absent(),
    this.cycles = const Value.absent(),
    this.cycleRestSeconds = const Value.absent(),
    this.reps = const Value.absent(),
    this.duration = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.worktimeSeconds = const Value.absent(),
    this.hand = const Value.absent(),
    this.granularity = const Value.absent(),
    this.loadsJson = const Value.absent(),
    this.leftLoadsJson = const Value.absent(),
    this.handPositionsJson = const Value.absent(),
    this.edgeSizesMmJson = const Value.absent(),
    this.loadIsMax = const Value.absent(),
    this.freeText = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.groupTitle = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trainingId = Value(trainingId),
       type = Value(type);
  static Insertable<TrainingItemRow> custom({
    Expression<String>? id,
    Expression<String>? trainingId,
    Expression<String>? parentId,
    Expression<String>? type,
    Expression<int>? position,
    Expression<int>? cycles,
    Expression<int>? cycleRestSeconds,
    Expression<int>? reps,
    Expression<int>? duration,
    Expression<int>? restSeconds,
    Expression<int>? worktimeSeconds,
    Expression<String>? hand,
    Expression<String>? granularity,
    Expression<String>? loadsJson,
    Expression<String>? leftLoadsJson,
    Expression<String>? handPositionsJson,
    Expression<String>? edgeSizesMmJson,
    Expression<bool>? loadIsMax,
    Expression<String>? freeText,
    Expression<String>? exerciseId,
    Expression<String>? groupTitle,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trainingId != null) 'training_id': trainingId,
      if (parentId != null) 'parent_id': parentId,
      if (type != null) 'type': type,
      if (position != null) 'position': position,
      if (cycles != null) 'cycles': cycles,
      if (cycleRestSeconds != null) 'cycle_rest_seconds': cycleRestSeconds,
      if (reps != null) 'reps': reps,
      if (duration != null) 'duration': duration,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (worktimeSeconds != null) 'worktime_seconds': worktimeSeconds,
      if (hand != null) 'hand': hand,
      if (granularity != null) 'granularity': granularity,
      if (loadsJson != null) 'loads_json': loadsJson,
      if (leftLoadsJson != null) 'left_loads_json': leftLoadsJson,
      if (handPositionsJson != null) 'hand_positions_json': handPositionsJson,
      if (edgeSizesMmJson != null) 'edge_sizes_mm_json': edgeSizesMmJson,
      if (loadIsMax != null) 'load_is_max': loadIsMax,
      if (freeText != null) 'free_text': freeText,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (groupTitle != null) 'group_title': groupTitle,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrainingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? trainingId,
    Value<String?>? parentId,
    Value<String>? type,
    Value<int>? position,
    Value<int?>? cycles,
    Value<int?>? cycleRestSeconds,
    Value<int?>? reps,
    Value<int?>? duration,
    Value<int?>? restSeconds,
    Value<int?>? worktimeSeconds,
    Value<String?>? hand,
    Value<String?>? granularity,
    Value<String?>? loadsJson,
    Value<String?>? leftLoadsJson,
    Value<String?>? handPositionsJson,
    Value<String?>? edgeSizesMmJson,
    Value<bool>? loadIsMax,
    Value<String?>? freeText,
    Value<String?>? exerciseId,
    Value<String?>? groupTitle,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TrainingItemsCompanion(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      position: position ?? this.position,
      cycles: cycles ?? this.cycles,
      cycleRestSeconds: cycleRestSeconds ?? this.cycleRestSeconds,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      restSeconds: restSeconds ?? this.restSeconds,
      worktimeSeconds: worktimeSeconds ?? this.worktimeSeconds,
      hand: hand ?? this.hand,
      granularity: granularity ?? this.granularity,
      loadsJson: loadsJson ?? this.loadsJson,
      leftLoadsJson: leftLoadsJson ?? this.leftLoadsJson,
      handPositionsJson: handPositionsJson ?? this.handPositionsJson,
      edgeSizesMmJson: edgeSizesMmJson ?? this.edgeSizesMmJson,
      loadIsMax: loadIsMax ?? this.loadIsMax,
      freeText: freeText ?? this.freeText,
      exerciseId: exerciseId ?? this.exerciseId,
      groupTitle: groupTitle ?? this.groupTitle,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trainingId.present) {
      map['training_id'] = Variable<String>(trainingId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (cycles.present) {
      map['cycles'] = Variable<int>(cycles.value);
    }
    if (cycleRestSeconds.present) {
      map['cycle_rest_seconds'] = Variable<int>(cycleRestSeconds.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (worktimeSeconds.present) {
      map['worktime_seconds'] = Variable<int>(worktimeSeconds.value);
    }
    if (hand.present) {
      map['hand'] = Variable<String>(hand.value);
    }
    if (granularity.present) {
      map['granularity'] = Variable<String>(granularity.value);
    }
    if (loadsJson.present) {
      map['loads_json'] = Variable<String>(loadsJson.value);
    }
    if (leftLoadsJson.present) {
      map['left_loads_json'] = Variable<String>(leftLoadsJson.value);
    }
    if (handPositionsJson.present) {
      map['hand_positions_json'] = Variable<String>(handPositionsJson.value);
    }
    if (edgeSizesMmJson.present) {
      map['edge_sizes_mm_json'] = Variable<String>(edgeSizesMmJson.value);
    }
    if (loadIsMax.present) {
      map['load_is_max'] = Variable<bool>(loadIsMax.value);
    }
    if (freeText.present) {
      map['free_text'] = Variable<String>(freeText.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (groupTitle.present) {
      map['group_title'] = Variable<String>(groupTitle.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingItemsCompanion(')
          ..write('id: $id, ')
          ..write('trainingId: $trainingId, ')
          ..write('parentId: $parentId, ')
          ..write('type: $type, ')
          ..write('position: $position, ')
          ..write('cycles: $cycles, ')
          ..write('cycleRestSeconds: $cycleRestSeconds, ')
          ..write('reps: $reps, ')
          ..write('duration: $duration, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('worktimeSeconds: $worktimeSeconds, ')
          ..write('hand: $hand, ')
          ..write('granularity: $granularity, ')
          ..write('loadsJson: $loadsJson, ')
          ..write('leftLoadsJson: $leftLoadsJson, ')
          ..write('handPositionsJson: $handPositionsJson, ')
          ..write('edgeSizesMmJson: $edgeSizesMmJson, ')
          ..write('loadIsMax: $loadIsMax, ')
          ..write('freeText: $freeText, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('groupTitle: $groupTitle, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RepDatasTable extends RepDatas with TableInfo<$RepDatasTable, RepData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepDatasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Uuid().v4(),
  );
  static const VerificationMeta _averageWeightMeta = const VerificationMeta(
    'averageWeight',
  );
  @override
  late final GeneratedColumn<double> averageWeight = GeneratedColumn<double>(
    'average_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRestMeta = const VerificationMeta('isRest');
  @override
  late final GeneratedColumn<bool> isRest = GeneratedColumn<bool>(
    'is_rest',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_rest" IN (0, 1))',
    ),
  );
  static const VerificationMeta _rightHandMeta = const VerificationMeta(
    'rightHand',
  );
  @override
  late final GeneratedColumn<bool> rightHand = GeneratedColumn<bool>(
    'right_hand',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("right_hand" IN (0, 1))',
    ),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightMeta = const VerificationMeta(
    'targetWeight',
  );
  @override
  late final GeneratedColumn<double> targetWeight = GeneratedColumn<double>(
    'target_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  @override
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
    'index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gripPositionMeta = const VerificationMeta(
    'gripPosition',
  );
  @override
  late final GeneratedColumn<int> gripPosition = GeneratedColumn<int>(
    'grip_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _edgeSizeMmMeta = const VerificationMeta(
    'edgeSizeMm',
  );
  @override
  late final GeneratedColumn<int> edgeSizeMm = GeneratedColumn<int>(
    'edge_size_mm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trainingItemIdMeta = const VerificationMeta(
    'trainingItemId',
  );
  @override
  late final GeneratedColumn<String> trainingItemId = GeneratedColumn<String>(
    'training_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    averageWeight,
    sessionId,
    isRest,
    rightHand,
    duration,
    targetWeight,
    index,
    gripPosition,
    edgeSizeMm,
    trainingItemId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rep_datas';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('average_weight')) {
      context.handle(
        _averageWeightMeta,
        averageWeight.isAcceptableOrUnknown(
          data['average_weight']!,
          _averageWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageWeightMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('is_rest')) {
      context.handle(
        _isRestMeta,
        isRest.isAcceptableOrUnknown(data['is_rest']!, _isRestMeta),
      );
    } else if (isInserting) {
      context.missing(_isRestMeta);
    }
    if (data.containsKey('right_hand')) {
      context.handle(
        _rightHandMeta,
        rightHand.isAcceptableOrUnknown(data['right_hand']!, _rightHandMeta),
      );
    } else if (isInserting) {
      context.missing(_rightHandMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('target_weight')) {
      context.handle(
        _targetWeightMeta,
        targetWeight.isAcceptableOrUnknown(
          data['target_weight']!,
          _targetWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWeightMeta);
    }
    if (data.containsKey('index')) {
      context.handle(
        _indexMeta,
        index.isAcceptableOrUnknown(data['index']!, _indexMeta),
      );
    } else if (isInserting) {
      context.missing(_indexMeta);
    }
    if (data.containsKey('grip_position')) {
      context.handle(
        _gripPositionMeta,
        gripPosition.isAcceptableOrUnknown(
          data['grip_position']!,
          _gripPositionMeta,
        ),
      );
    }
    if (data.containsKey('edge_size_mm')) {
      context.handle(
        _edgeSizeMmMeta,
        edgeSizeMm.isAcceptableOrUnknown(
          data['edge_size_mm']!,
          _edgeSizeMmMeta,
        ),
      );
    }
    if (data.containsKey('training_item_id')) {
      context.handle(
        _trainingItemIdMeta,
        trainingItemId.isAcceptableOrUnknown(
          data['training_item_id']!,
          _trainingItemIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      averageWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_weight'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      isRest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_rest'],
      )!,
      rightHand: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}right_hand'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      targetWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight'],
      )!,
      index: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}index'],
      )!,
      gripPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grip_position'],
      )!,
      edgeSizeMm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edge_size_mm'],
      ),
      trainingItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_item_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RepDatasTable createAlias(String alias) {
    return $RepDatasTable(attachedDatabase, alias);
  }
}

class RepData extends DataClass implements Insertable<RepData> {
  final String id;
  final double averageWeight;
  final String sessionId;
  final bool isRest;
  final bool rightHand;
  final int duration;
  final double targetWeight;
  final int index;
  final int gripPosition;
  final int? edgeSizeMm;
  final String? trainingItemId;
  final DateTime updatedAt;
  const RepData({
    required this.id,
    required this.averageWeight,
    required this.sessionId,
    required this.isRest,
    required this.rightHand,
    required this.duration,
    required this.targetWeight,
    required this.index,
    required this.gripPosition,
    this.edgeSizeMm,
    this.trainingItemId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['average_weight'] = Variable<double>(averageWeight);
    map['session_id'] = Variable<String>(sessionId);
    map['is_rest'] = Variable<bool>(isRest);
    map['right_hand'] = Variable<bool>(rightHand);
    map['duration'] = Variable<int>(duration);
    map['target_weight'] = Variable<double>(targetWeight);
    map['index'] = Variable<int>(index);
    map['grip_position'] = Variable<int>(gripPosition);
    if (!nullToAbsent || edgeSizeMm != null) {
      map['edge_size_mm'] = Variable<int>(edgeSizeMm);
    }
    if (!nullToAbsent || trainingItemId != null) {
      map['training_item_id'] = Variable<String>(trainingItemId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RepDatasCompanion toCompanion(bool nullToAbsent) {
    return RepDatasCompanion(
      id: Value(id),
      averageWeight: Value(averageWeight),
      sessionId: Value(sessionId),
      isRest: Value(isRest),
      rightHand: Value(rightHand),
      duration: Value(duration),
      targetWeight: Value(targetWeight),
      index: Value(index),
      gripPosition: Value(gripPosition),
      edgeSizeMm: edgeSizeMm == null && nullToAbsent
          ? const Value.absent()
          : Value(edgeSizeMm),
      trainingItemId: trainingItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(trainingItemId),
      updatedAt: Value(updatedAt),
    );
  }

  factory RepData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepData(
      id: serializer.fromJson<String>(json['id']),
      averageWeight: serializer.fromJson<double>(json['averageWeight']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      isRest: serializer.fromJson<bool>(json['isRest']),
      rightHand: serializer.fromJson<bool>(json['rightHand']),
      duration: serializer.fromJson<int>(json['duration']),
      targetWeight: serializer.fromJson<double>(json['targetWeight']),
      index: serializer.fromJson<int>(json['index']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
      edgeSizeMm: serializer.fromJson<int?>(json['edgeSizeMm']),
      trainingItemId: serializer.fromJson<String?>(json['trainingItemId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'averageWeight': serializer.toJson<double>(averageWeight),
      'sessionId': serializer.toJson<String>(sessionId),
      'isRest': serializer.toJson<bool>(isRest),
      'rightHand': serializer.toJson<bool>(rightHand),
      'duration': serializer.toJson<int>(duration),
      'targetWeight': serializer.toJson<double>(targetWeight),
      'index': serializer.toJson<int>(index),
      'gripPosition': serializer.toJson<int>(gripPosition),
      'edgeSizeMm': serializer.toJson<int?>(edgeSizeMm),
      'trainingItemId': serializer.toJson<String?>(trainingItemId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RepData copyWith({
    String? id,
    double? averageWeight,
    String? sessionId,
    bool? isRest,
    bool? rightHand,
    int? duration,
    double? targetWeight,
    int? index,
    int? gripPosition,
    Value<int?> edgeSizeMm = const Value.absent(),
    Value<String?> trainingItemId = const Value.absent(),
    DateTime? updatedAt,
  }) => RepData(
    id: id ?? this.id,
    averageWeight: averageWeight ?? this.averageWeight,
    sessionId: sessionId ?? this.sessionId,
    isRest: isRest ?? this.isRest,
    rightHand: rightHand ?? this.rightHand,
    duration: duration ?? this.duration,
    targetWeight: targetWeight ?? this.targetWeight,
    index: index ?? this.index,
    gripPosition: gripPosition ?? this.gripPosition,
    edgeSizeMm: edgeSizeMm.present ? edgeSizeMm.value : this.edgeSizeMm,
    trainingItemId: trainingItemId.present
        ? trainingItemId.value
        : this.trainingItemId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RepData copyWithCompanion(RepDatasCompanion data) {
    return RepData(
      id: data.id.present ? data.id.value : this.id,
      averageWeight: data.averageWeight.present
          ? data.averageWeight.value
          : this.averageWeight,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      isRest: data.isRest.present ? data.isRest.value : this.isRest,
      rightHand: data.rightHand.present ? data.rightHand.value : this.rightHand,
      duration: data.duration.present ? data.duration.value : this.duration,
      targetWeight: data.targetWeight.present
          ? data.targetWeight.value
          : this.targetWeight,
      index: data.index.present ? data.index.value : this.index,
      gripPosition: data.gripPosition.present
          ? data.gripPosition.value
          : this.gripPosition,
      edgeSizeMm: data.edgeSizeMm.present
          ? data.edgeSizeMm.value
          : this.edgeSizeMm,
      trainingItemId: data.trainingItemId.present
          ? data.trainingItemId.value
          : this.trainingItemId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepData(')
          ..write('id: $id, ')
          ..write('averageWeight: $averageWeight, ')
          ..write('sessionId: $sessionId, ')
          ..write('isRest: $isRest, ')
          ..write('rightHand: $rightHand, ')
          ..write('duration: $duration, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('index: $index, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('edgeSizeMm: $edgeSizeMm, ')
          ..write('trainingItemId: $trainingItemId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    averageWeight,
    sessionId,
    isRest,
    rightHand,
    duration,
    targetWeight,
    index,
    gripPosition,
    edgeSizeMm,
    trainingItemId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepData &&
          other.id == this.id &&
          other.averageWeight == this.averageWeight &&
          other.sessionId == this.sessionId &&
          other.isRest == this.isRest &&
          other.rightHand == this.rightHand &&
          other.duration == this.duration &&
          other.targetWeight == this.targetWeight &&
          other.index == this.index &&
          other.gripPosition == this.gripPosition &&
          other.edgeSizeMm == this.edgeSizeMm &&
          other.trainingItemId == this.trainingItemId &&
          other.updatedAt == this.updatedAt);
}

class RepDatasCompanion extends UpdateCompanion<RepData> {
  final Value<String> id;
  final Value<double> averageWeight;
  final Value<String> sessionId;
  final Value<bool> isRest;
  final Value<bool> rightHand;
  final Value<int> duration;
  final Value<double> targetWeight;
  final Value<int> index;
  final Value<int> gripPosition;
  final Value<int?> edgeSizeMm;
  final Value<String?> trainingItemId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RepDatasCompanion({
    this.id = const Value.absent(),
    this.averageWeight = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.isRest = const Value.absent(),
    this.rightHand = const Value.absent(),
    this.duration = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.index = const Value.absent(),
    this.gripPosition = const Value.absent(),
    this.edgeSizeMm = const Value.absent(),
    this.trainingItemId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepDatasCompanion.insert({
    this.id = const Value.absent(),
    required double averageWeight,
    required String sessionId,
    required bool isRest,
    required bool rightHand,
    required int duration,
    required double targetWeight,
    required int index,
    this.gripPosition = const Value.absent(),
    this.edgeSizeMm = const Value.absent(),
    this.trainingItemId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : averageWeight = Value(averageWeight),
       sessionId = Value(sessionId),
       isRest = Value(isRest),
       rightHand = Value(rightHand),
       duration = Value(duration),
       targetWeight = Value(targetWeight),
       index = Value(index);
  static Insertable<RepData> custom({
    Expression<String>? id,
    Expression<double>? averageWeight,
    Expression<String>? sessionId,
    Expression<bool>? isRest,
    Expression<bool>? rightHand,
    Expression<int>? duration,
    Expression<double>? targetWeight,
    Expression<int>? index,
    Expression<int>? gripPosition,
    Expression<int>? edgeSizeMm,
    Expression<String>? trainingItemId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (averageWeight != null) 'average_weight': averageWeight,
      if (sessionId != null) 'session_id': sessionId,
      if (isRest != null) 'is_rest': isRest,
      if (rightHand != null) 'right_hand': rightHand,
      if (duration != null) 'duration': duration,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (index != null) 'index': index,
      if (gripPosition != null) 'grip_position': gripPosition,
      if (edgeSizeMm != null) 'edge_size_mm': edgeSizeMm,
      if (trainingItemId != null) 'training_item_id': trainingItemId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepDatasCompanion copyWith({
    Value<String>? id,
    Value<double>? averageWeight,
    Value<String>? sessionId,
    Value<bool>? isRest,
    Value<bool>? rightHand,
    Value<int>? duration,
    Value<double>? targetWeight,
    Value<int>? index,
    Value<int>? gripPosition,
    Value<int?>? edgeSizeMm,
    Value<String?>? trainingItemId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RepDatasCompanion(
      id: id ?? this.id,
      averageWeight: averageWeight ?? this.averageWeight,
      sessionId: sessionId ?? this.sessionId,
      isRest: isRest ?? this.isRest,
      rightHand: rightHand ?? this.rightHand,
      duration: duration ?? this.duration,
      targetWeight: targetWeight ?? this.targetWeight,
      index: index ?? this.index,
      gripPosition: gripPosition ?? this.gripPosition,
      edgeSizeMm: edgeSizeMm ?? this.edgeSizeMm,
      trainingItemId: trainingItemId ?? this.trainingItemId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (averageWeight.present) {
      map['average_weight'] = Variable<double>(averageWeight.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (isRest.present) {
      map['is_rest'] = Variable<bool>(isRest.value);
    }
    if (rightHand.present) {
      map['right_hand'] = Variable<bool>(rightHand.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (targetWeight.present) {
      map['target_weight'] = Variable<double>(targetWeight.value);
    }
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (gripPosition.present) {
      map['grip_position'] = Variable<int>(gripPosition.value);
    }
    if (edgeSizeMm.present) {
      map['edge_size_mm'] = Variable<int>(edgeSizeMm.value);
    }
    if (trainingItemId.present) {
      map['training_item_id'] = Variable<String>(trainingItemId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepDatasCompanion(')
          ..write('id: $id, ')
          ..write('averageWeight: $averageWeight, ')
          ..write('sessionId: $sessionId, ')
          ..write('isRest: $isRest, ')
          ..write('rightHand: $rightHand, ')
          ..write('duration: $duration, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('index: $index, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('edgeSizeMm: $edgeSizeMm, ')
          ..write('trainingItemId: $trainingItemId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SensorConfigsTable extends SensorConfigs
    with TableInfo<$SensorConfigsTable, SensorConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Uuid().v4(),
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
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  @override
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
    'index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tareMeta = const VerificationMeta('tare');
  @override
  late final GeneratedColumn<double> tare = GeneratedColumn<double>(
    'tare',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coefMeta = const VerificationMeta('coef');
  @override
  late final GeneratedColumn<double> coef = GeneratedColumn<double>(
    'coef',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    index,
    tare,
    coef,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('index')) {
      context.handle(
        _indexMeta,
        index.isAcceptableOrUnknown(data['index']!, _indexMeta),
      );
    } else if (isInserting) {
      context.missing(_indexMeta);
    }
    if (data.containsKey('tare')) {
      context.handle(
        _tareMeta,
        tare.isAcceptableOrUnknown(data['tare']!, _tareMeta),
      );
    } else if (isInserting) {
      context.missing(_tareMeta);
    }
    if (data.containsKey('coef')) {
      context.handle(
        _coefMeta,
        coef.isAcceptableOrUnknown(data['coef']!, _coefMeta),
      );
    } else if (isInserting) {
      context.missing(_coefMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      index: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}index'],
      )!,
      tare: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tare'],
      )!,
      coef: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}coef'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SensorConfigsTable createAlias(String alias) {
    return $SensorConfigsTable(attachedDatabase, alias);
  }
}

class SensorConfig extends DataClass implements Insertable<SensorConfig> {
  final String id;
  final String name;
  final int index;
  final double tare;
  final double coef;
  final DateTime updatedAt;
  const SensorConfig({
    required this.id,
    required this.name,
    required this.index,
    required this.tare,
    required this.coef,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['index'] = Variable<int>(index);
    map['tare'] = Variable<double>(tare);
    map['coef'] = Variable<double>(coef);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SensorConfigsCompanion toCompanion(bool nullToAbsent) {
    return SensorConfigsCompanion(
      id: Value(id),
      name: Value(name),
      index: Value(index),
      tare: Value(tare),
      coef: Value(coef),
      updatedAt: Value(updatedAt),
    );
  }

  factory SensorConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorConfig(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      index: serializer.fromJson<int>(json['index']),
      tare: serializer.fromJson<double>(json['tare']),
      coef: serializer.fromJson<double>(json['coef']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'index': serializer.toJson<int>(index),
      'tare': serializer.toJson<double>(tare),
      'coef': serializer.toJson<double>(coef),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SensorConfig copyWith({
    String? id,
    String? name,
    int? index,
    double? tare,
    double? coef,
    DateTime? updatedAt,
  }) => SensorConfig(
    id: id ?? this.id,
    name: name ?? this.name,
    index: index ?? this.index,
    tare: tare ?? this.tare,
    coef: coef ?? this.coef,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SensorConfig copyWithCompanion(SensorConfigsCompanion data) {
    return SensorConfig(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      index: data.index.present ? data.index.value : this.index,
      tare: data.tare.present ? data.tare.value : this.tare,
      coef: data.coef.present ? data.coef.value : this.coef,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorConfig(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('index: $index, ')
          ..write('tare: $tare, ')
          ..write('coef: $coef, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, index, tare, coef, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorConfig &&
          other.id == this.id &&
          other.name == this.name &&
          other.index == this.index &&
          other.tare == this.tare &&
          other.coef == this.coef &&
          other.updatedAt == this.updatedAt);
}

class SensorConfigsCompanion extends UpdateCompanion<SensorConfig> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> index;
  final Value<double> tare;
  final Value<double> coef;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SensorConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.index = const Value.absent(),
    this.tare = const Value.absent(),
    this.coef = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SensorConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int index,
    required double tare,
    required double coef,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       index = Value(index),
       tare = Value(tare),
       coef = Value(coef);
  static Insertable<SensorConfig> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? index,
    Expression<double>? tare,
    Expression<double>? coef,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (index != null) 'index': index,
      if (tare != null) 'tare': tare,
      if (coef != null) 'coef': coef,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SensorConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? index,
    Value<double>? tare,
    Value<double>? coef,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SensorConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      index: index ?? this.index,
      tare: tare ?? this.tare,
      coef: coef ?? this.coef,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (tare.present) {
      map['tare'] = Variable<double>(tare.value);
    }
    if (coef.present) {
      map['coef'] = Variable<double>(coef.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorConfigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('index: $index, ')
          ..write('tare: $tare, ')
          ..write('coef: $coef, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuiltinTrainingWeightsTable extends BuiltinTrainingWeights
    with TableInfo<$BuiltinTrainingWeightsTable, BuiltinTrainingWeight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuiltinTrainingWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => Uuid().v4(),
  );
  static const VerificationMeta _builtinTrainingIdMeta = const VerificationMeta(
    'builtinTrainingId',
  );
  @override
  late final GeneratedColumn<String> builtinTrainingId =
      GeneratedColumn<String>(
        'builtin_training_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _customWeightRightMeta = const VerificationMeta(
    'customWeightRight',
  );
  @override
  late final GeneratedColumn<double> customWeightRight =
      GeneratedColumn<double>(
        'custom_weight_right',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customWeightLeftMeta = const VerificationMeta(
    'customWeightLeft',
  );
  @override
  late final GeneratedColumn<double> customWeightLeft = GeneratedColumn<double>(
    'custom_weight_left',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    builtinTrainingId,
    customWeightRight,
    customWeightLeft,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'builtin_training_weights';
  @override
  VerificationContext validateIntegrity(
    Insertable<BuiltinTrainingWeight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('builtin_training_id')) {
      context.handle(
        _builtinTrainingIdMeta,
        builtinTrainingId.isAcceptableOrUnknown(
          data['builtin_training_id']!,
          _builtinTrainingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_builtinTrainingIdMeta);
    }
    if (data.containsKey('custom_weight_right')) {
      context.handle(
        _customWeightRightMeta,
        customWeightRight.isAcceptableOrUnknown(
          data['custom_weight_right']!,
          _customWeightRightMeta,
        ),
      );
    }
    if (data.containsKey('custom_weight_left')) {
      context.handle(
        _customWeightLeftMeta,
        customWeightLeft.isAcceptableOrUnknown(
          data['custom_weight_left']!,
          _customWeightLeftMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuiltinTrainingWeight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuiltinTrainingWeight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      builtinTrainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}builtin_training_id'],
      )!,
      customWeightRight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}custom_weight_right'],
      ),
      customWeightLeft: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}custom_weight_left'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BuiltinTrainingWeightsTable createAlias(String alias) {
    return $BuiltinTrainingWeightsTable(attachedDatabase, alias);
  }
}

class BuiltinTrainingWeight extends DataClass
    implements Insertable<BuiltinTrainingWeight> {
  final String id;
  final String builtinTrainingId;
  final double? customWeightRight;
  final double? customWeightLeft;
  final DateTime updatedAt;
  const BuiltinTrainingWeight({
    required this.id,
    required this.builtinTrainingId,
    this.customWeightRight,
    this.customWeightLeft,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['builtin_training_id'] = Variable<String>(builtinTrainingId);
    if (!nullToAbsent || customWeightRight != null) {
      map['custom_weight_right'] = Variable<double>(customWeightRight);
    }
    if (!nullToAbsent || customWeightLeft != null) {
      map['custom_weight_left'] = Variable<double>(customWeightLeft);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BuiltinTrainingWeightsCompanion toCompanion(bool nullToAbsent) {
    return BuiltinTrainingWeightsCompanion(
      id: Value(id),
      builtinTrainingId: Value(builtinTrainingId),
      customWeightRight: customWeightRight == null && nullToAbsent
          ? const Value.absent()
          : Value(customWeightRight),
      customWeightLeft: customWeightLeft == null && nullToAbsent
          ? const Value.absent()
          : Value(customWeightLeft),
      updatedAt: Value(updatedAt),
    );
  }

  factory BuiltinTrainingWeight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuiltinTrainingWeight(
      id: serializer.fromJson<String>(json['id']),
      builtinTrainingId: serializer.fromJson<String>(json['builtinTrainingId']),
      customWeightRight: serializer.fromJson<double?>(
        json['customWeightRight'],
      ),
      customWeightLeft: serializer.fromJson<double?>(json['customWeightLeft']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'builtinTrainingId': serializer.toJson<String>(builtinTrainingId),
      'customWeightRight': serializer.toJson<double?>(customWeightRight),
      'customWeightLeft': serializer.toJson<double?>(customWeightLeft),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BuiltinTrainingWeight copyWith({
    String? id,
    String? builtinTrainingId,
    Value<double?> customWeightRight = const Value.absent(),
    Value<double?> customWeightLeft = const Value.absent(),
    DateTime? updatedAt,
  }) => BuiltinTrainingWeight(
    id: id ?? this.id,
    builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
    customWeightRight: customWeightRight.present
        ? customWeightRight.value
        : this.customWeightRight,
    customWeightLeft: customWeightLeft.present
        ? customWeightLeft.value
        : this.customWeightLeft,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BuiltinTrainingWeight copyWithCompanion(
    BuiltinTrainingWeightsCompanion data,
  ) {
    return BuiltinTrainingWeight(
      id: data.id.present ? data.id.value : this.id,
      builtinTrainingId: data.builtinTrainingId.present
          ? data.builtinTrainingId.value
          : this.builtinTrainingId,
      customWeightRight: data.customWeightRight.present
          ? data.customWeightRight.value
          : this.customWeightRight,
      customWeightLeft: data.customWeightLeft.present
          ? data.customWeightLeft.value
          : this.customWeightLeft,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinTrainingWeight(')
          ..write('id: $id, ')
          ..write('builtinTrainingId: $builtinTrainingId, ')
          ..write('customWeightRight: $customWeightRight, ')
          ..write('customWeightLeft: $customWeightLeft, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    builtinTrainingId,
    customWeightRight,
    customWeightLeft,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuiltinTrainingWeight &&
          other.id == this.id &&
          other.builtinTrainingId == this.builtinTrainingId &&
          other.customWeightRight == this.customWeightRight &&
          other.customWeightLeft == this.customWeightLeft &&
          other.updatedAt == this.updatedAt);
}

class BuiltinTrainingWeightsCompanion
    extends UpdateCompanion<BuiltinTrainingWeight> {
  final Value<String> id;
  final Value<String> builtinTrainingId;
  final Value<double?> customWeightRight;
  final Value<double?> customWeightLeft;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BuiltinTrainingWeightsCompanion({
    this.id = const Value.absent(),
    this.builtinTrainingId = const Value.absent(),
    this.customWeightRight = const Value.absent(),
    this.customWeightLeft = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuiltinTrainingWeightsCompanion.insert({
    this.id = const Value.absent(),
    required String builtinTrainingId,
    this.customWeightRight = const Value.absent(),
    this.customWeightLeft = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : builtinTrainingId = Value(builtinTrainingId);
  static Insertable<BuiltinTrainingWeight> custom({
    Expression<String>? id,
    Expression<String>? builtinTrainingId,
    Expression<double>? customWeightRight,
    Expression<double>? customWeightLeft,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (builtinTrainingId != null) 'builtin_training_id': builtinTrainingId,
      if (customWeightRight != null) 'custom_weight_right': customWeightRight,
      if (customWeightLeft != null) 'custom_weight_left': customWeightLeft,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuiltinTrainingWeightsCompanion copyWith({
    Value<String>? id,
    Value<String>? builtinTrainingId,
    Value<double?>? customWeightRight,
    Value<double?>? customWeightLeft,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BuiltinTrainingWeightsCompanion(
      id: id ?? this.id,
      builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
      customWeightRight: customWeightRight ?? this.customWeightRight,
      customWeightLeft: customWeightLeft ?? this.customWeightLeft,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (builtinTrainingId.present) {
      map['builtin_training_id'] = Variable<String>(builtinTrainingId.value);
    }
    if (customWeightRight.present) {
      map['custom_weight_right'] = Variable<double>(customWeightRight.value);
    }
    if (customWeightLeft.present) {
      map['custom_weight_left'] = Variable<double>(customWeightLeft.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinTrainingWeightsCompanion(')
          ..write('id: $id, ')
          ..write('builtinTrainingId: $builtinTrainingId, ')
          ..write('customWeightRight: $customWeightRight, ')
          ..write('customWeightLeft: $customWeightLeft, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PinnedBuiltinTrainingsTable extends PinnedBuiltinTrainings
    with TableInfo<$PinnedBuiltinTrainingsTable, PinnedBuiltinTraining> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinnedBuiltinTrainingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _builtinTrainingIdMeta = const VerificationMeta(
    'builtinTrainingId',
  );
  @override
  late final GeneratedColumn<String> builtinTrainingId =
      GeneratedColumn<String>(
        'builtin_training_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [builtinTrainingId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pinned_builtin_trainings';
  @override
  VerificationContext validateIntegrity(
    Insertable<PinnedBuiltinTraining> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('builtin_training_id')) {
      context.handle(
        _builtinTrainingIdMeta,
        builtinTrainingId.isAcceptableOrUnknown(
          data['builtin_training_id']!,
          _builtinTrainingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_builtinTrainingIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {builtinTrainingId};
  @override
  PinnedBuiltinTraining map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinnedBuiltinTraining(
      builtinTrainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}builtin_training_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PinnedBuiltinTrainingsTable createAlias(String alias) {
    return $PinnedBuiltinTrainingsTable(attachedDatabase, alias);
  }
}

class PinnedBuiltinTraining extends DataClass
    implements Insertable<PinnedBuiltinTraining> {
  final String builtinTrainingId;
  final DateTime updatedAt;
  const PinnedBuiltinTraining({
    required this.builtinTrainingId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['builtin_training_id'] = Variable<String>(builtinTrainingId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PinnedBuiltinTrainingsCompanion toCompanion(bool nullToAbsent) {
    return PinnedBuiltinTrainingsCompanion(
      builtinTrainingId: Value(builtinTrainingId),
      updatedAt: Value(updatedAt),
    );
  }

  factory PinnedBuiltinTraining.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedBuiltinTraining(
      builtinTrainingId: serializer.fromJson<String>(json['builtinTrainingId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'builtinTrainingId': serializer.toJson<String>(builtinTrainingId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PinnedBuiltinTraining copyWith({
    String? builtinTrainingId,
    DateTime? updatedAt,
  }) => PinnedBuiltinTraining(
    builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PinnedBuiltinTraining copyWithCompanion(
    PinnedBuiltinTrainingsCompanion data,
  ) {
    return PinnedBuiltinTraining(
      builtinTrainingId: data.builtinTrainingId.present
          ? data.builtinTrainingId.value
          : this.builtinTrainingId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedBuiltinTraining(')
          ..write('builtinTrainingId: $builtinTrainingId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(builtinTrainingId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedBuiltinTraining &&
          other.builtinTrainingId == this.builtinTrainingId &&
          other.updatedAt == this.updatedAt);
}

class PinnedBuiltinTrainingsCompanion
    extends UpdateCompanion<PinnedBuiltinTraining> {
  final Value<String> builtinTrainingId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PinnedBuiltinTrainingsCompanion({
    this.builtinTrainingId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PinnedBuiltinTrainingsCompanion.insert({
    required String builtinTrainingId,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : builtinTrainingId = Value(builtinTrainingId);
  static Insertable<PinnedBuiltinTraining> custom({
    Expression<String>? builtinTrainingId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (builtinTrainingId != null) 'builtin_training_id': builtinTrainingId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PinnedBuiltinTrainingsCompanion copyWith({
    Value<String>? builtinTrainingId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PinnedBuiltinTrainingsCompanion(
      builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (builtinTrainingId.present) {
      map['builtin_training_id'] = Variable<String>(builtinTrainingId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinnedBuiltinTrainingsCompanion(')
          ..write('builtinTrainingId: $builtinTrainingId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstnameMeta = const VerificationMeta(
    'firstname',
  );
  @override
  late final GeneratedColumn<String> firstname = GeneratedColumn<String>(
    'firstname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastnameMeta = const VerificationMeta(
    'lastname',
  );
  @override
  late final GeneratedColumn<String> lastname = GeneratedColumn<String>(
    'lastname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailVerifiedMeta = const VerificationMeta(
    'emailVerified',
  );
  @override
  late final GeneratedColumn<bool> emailVerified = GeneratedColumn<bool>(
    'email_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("email_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAdminMeta = const VerificationMeta(
    'isAdmin',
  );
  @override
  late final GeneratedColumn<bool> isAdmin = GeneratedColumn<bool>(
    'is_admin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_admin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCoachMeta = const VerificationMeta(
    'isCoach',
  );
  @override
  late final GeneratedColumn<bool> isCoach = GeneratedColumn<bool>(
    'is_coach',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_coach" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _coachValidatedMeta = const VerificationMeta(
    'coachValidated',
  );
  @override
  late final GeneratedColumn<bool> coachValidated = GeneratedColumn<bool>(
    'coach_validated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("coach_validated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    firstname,
    lastname,
    emailVerified,
    isAdmin,
    isCoach,
    coachValidated,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('firstname')) {
      context.handle(
        _firstnameMeta,
        firstname.isAcceptableOrUnknown(data['firstname']!, _firstnameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstnameMeta);
    }
    if (data.containsKey('lastname')) {
      context.handle(
        _lastnameMeta,
        lastname.isAcceptableOrUnknown(data['lastname']!, _lastnameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastnameMeta);
    }
    if (data.containsKey('email_verified')) {
      context.handle(
        _emailVerifiedMeta,
        emailVerified.isAcceptableOrUnknown(
          data['email_verified']!,
          _emailVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('is_admin')) {
      context.handle(
        _isAdminMeta,
        isAdmin.isAcceptableOrUnknown(data['is_admin']!, _isAdminMeta),
      );
    }
    if (data.containsKey('is_coach')) {
      context.handle(
        _isCoachMeta,
        isCoach.isAcceptableOrUnknown(data['is_coach']!, _isCoachMeta),
      );
    }
    if (data.containsKey('coach_validated')) {
      context.handle(
        _coachValidatedMeta,
        coachValidated.isAcceptableOrUnknown(
          data['coach_validated']!,
          _coachValidatedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      firstname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firstname'],
      )!,
      lastname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lastname'],
      )!,
      emailVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}email_verified'],
      )!,
      isAdmin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_admin'],
      )!,
      isCoach: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_coach'],
      )!,
      coachValidated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}coach_validated'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String firstname;
  final String lastname;
  final bool emailVerified;
  final bool isAdmin;
  final bool isCoach;
  final bool coachValidated;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.emailVerified,
    required this.isAdmin,
    required this.isCoach,
    required this.coachValidated,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['firstname'] = Variable<String>(firstname);
    map['lastname'] = Variable<String>(lastname);
    map['email_verified'] = Variable<bool>(emailVerified);
    map['is_admin'] = Variable<bool>(isAdmin);
    map['is_coach'] = Variable<bool>(isCoach);
    map['coach_validated'] = Variable<bool>(coachValidated);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      firstname: Value(firstname),
      lastname: Value(lastname),
      emailVerified: Value(emailVerified),
      isAdmin: Value(isAdmin),
      isCoach: Value(isCoach),
      coachValidated: Value(coachValidated),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      firstname: serializer.fromJson<String>(json['firstname']),
      lastname: serializer.fromJson<String>(json['lastname']),
      emailVerified: serializer.fromJson<bool>(json['emailVerified']),
      isAdmin: serializer.fromJson<bool>(json['isAdmin']),
      isCoach: serializer.fromJson<bool>(json['isCoach']),
      coachValidated: serializer.fromJson<bool>(json['coachValidated']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'firstname': serializer.toJson<String>(firstname),
      'lastname': serializer.toJson<String>(lastname),
      'emailVerified': serializer.toJson<bool>(emailVerified),
      'isAdmin': serializer.toJson<bool>(isAdmin),
      'isCoach': serializer.toJson<bool>(isCoach),
      'coachValidated': serializer.toJson<bool>(coachValidated),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstname,
    String? lastname,
    bool? emailVerified,
    bool? isAdmin,
    bool? isCoach,
    bool? coachValidated,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    firstname: firstname ?? this.firstname,
    lastname: lastname ?? this.lastname,
    emailVerified: emailVerified ?? this.emailVerified,
    isAdmin: isAdmin ?? this.isAdmin,
    isCoach: isCoach ?? this.isCoach,
    coachValidated: coachValidated ?? this.coachValidated,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      firstname: data.firstname.present ? data.firstname.value : this.firstname,
      lastname: data.lastname.present ? data.lastname.value : this.lastname,
      emailVerified: data.emailVerified.present
          ? data.emailVerified.value
          : this.emailVerified,
      isAdmin: data.isAdmin.present ? data.isAdmin.value : this.isAdmin,
      isCoach: data.isCoach.present ? data.isCoach.value : this.isCoach,
      coachValidated: data.coachValidated.present
          ? data.coachValidated.value
          : this.coachValidated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstname: $firstname, ')
          ..write('lastname: $lastname, ')
          ..write('emailVerified: $emailVerified, ')
          ..write('isAdmin: $isAdmin, ')
          ..write('isCoach: $isCoach, ')
          ..write('coachValidated: $coachValidated, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    firstname,
    lastname,
    emailVerified,
    isAdmin,
    isCoach,
    coachValidated,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.firstname == this.firstname &&
          other.lastname == this.lastname &&
          other.emailVerified == this.emailVerified &&
          other.isAdmin == this.isAdmin &&
          other.isCoach == this.isCoach &&
          other.coachValidated == this.coachValidated &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> firstname;
  final Value<String> lastname;
  final Value<bool> emailVerified;
  final Value<bool> isAdmin;
  final Value<bool> isCoach;
  final Value<bool> coachValidated;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.firstname = const Value.absent(),
    this.lastname = const Value.absent(),
    this.emailVerified = const Value.absent(),
    this.isAdmin = const Value.absent(),
    this.isCoach = const Value.absent(),
    this.coachValidated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String firstname,
    required String lastname,
    this.emailVerified = const Value.absent(),
    this.isAdmin = const Value.absent(),
    this.isCoach = const Value.absent(),
    this.coachValidated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       firstname = Value(firstname),
       lastname = Value(lastname);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? firstname,
    Expression<String>? lastname,
    Expression<bool>? emailVerified,
    Expression<bool>? isAdmin,
    Expression<bool>? isCoach,
    Expression<bool>? coachValidated,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (firstname != null) 'firstname': firstname,
      if (lastname != null) 'lastname': lastname,
      if (emailVerified != null) 'email_verified': emailVerified,
      if (isAdmin != null) 'is_admin': isAdmin,
      if (isCoach != null) 'is_coach': isCoach,
      if (coachValidated != null) 'coach_validated': coachValidated,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? firstname,
    Value<String>? lastname,
    Value<bool>? emailVerified,
    Value<bool>? isAdmin,
    Value<bool>? isCoach,
    Value<bool>? coachValidated,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      emailVerified: emailVerified ?? this.emailVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      isCoach: isCoach ?? this.isCoach,
      coachValidated: coachValidated ?? this.coachValidated,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (firstname.present) {
      map['firstname'] = Variable<String>(firstname.value);
    }
    if (lastname.present) {
      map['lastname'] = Variable<String>(lastname.value);
    }
    if (emailVerified.present) {
      map['email_verified'] = Variable<bool>(emailVerified.value);
    }
    if (isAdmin.present) {
      map['is_admin'] = Variable<bool>(isAdmin.value);
    }
    if (isCoach.present) {
      map['is_coach'] = Variable<bool>(isCoach.value);
    }
    if (coachValidated.present) {
      map['coach_validated'] = Variable<bool>(coachValidated.value);
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
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstname: $firstname, ')
          ..write('lastname: $lastname, ')
          ..write('emailVerified: $emailVerified, ')
          ..write('isAdmin: $isAdmin, ')
          ..write('isCoach: $isCoach, ')
          ..write('coachValidated: $coachValidated, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $AssessmentsTable assessments = $AssessmentsTable(this);
  late final $TrainingsTable trainings = $TrainingsTable(this);
  late final $TrainingItemsTable trainingItems = $TrainingItemsTable(this);
  late final $RepDatasTable repDatas = $RepDatasTable(this);
  late final $SensorConfigsTable sensorConfigs = $SensorConfigsTable(this);
  late final $BuiltinTrainingWeightsTable builtinTrainingWeights =
      $BuiltinTrainingWeightsTable(this);
  late final $PinnedBuiltinTrainingsTable pinnedBuiltinTrainings =
      $PinnedBuiltinTrainingsTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    assessments,
    trainings,
    trainingItems,
    repDatas,
    sensorConfigs,
    builtinTrainingWeights,
    pinnedBuiltinTrainings,
    users,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      required String name,
      required String notes,
      Value<DateTime> date,
      required String dataPath,
      Value<bool> isAssessment,
      Value<int> activity,
      Value<String> origin,
      Value<String?> trainingId,
      Value<String?> programSessionId,
      Value<int> duration,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> notes,
      Value<DateTime> date,
      Value<String> dataPath,
      Value<bool> isAssessment,
      Value<int> activity,
      Value<String> origin,
      Value<String?> trainingId,
      Value<String?> programSessionId,
      Value<int> duration,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataPath => $composableBuilder(
    column: $table.dataPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAssessment => $composableBuilder(
    column: $table.isAssessment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programSessionId => $composableBuilder(
    column: $table.programSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataPath => $composableBuilder(
    column: $table.dataPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAssessment => $composableBuilder(
    column: $table.isAssessment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programSessionId => $composableBuilder(
    column: $table.programSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get dataPath =>
      $composableBuilder(column: $table.dataPath, builder: (column) => column);

  GeneratedColumn<bool> get isAssessment => $composableBuilder(
    column: $table.isAssessment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get programSessionId => $composableBuilder(
    column: $table.programSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> dataPath = const Value.absent(),
                Value<bool> isAssessment = const Value.absent(),
                Value<int> activity = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> trainingId = const Value.absent(),
                Value<String?> programSessionId = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                name: name,
                notes: notes,
                date: date,
                dataPath: dataPath,
                isAssessment: isAssessment,
                activity: activity,
                origin: origin,
                trainingId: trainingId,
                programSessionId: programSessionId,
                duration: duration,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String notes,
                Value<DateTime> date = const Value.absent(),
                required String dataPath,
                Value<bool> isAssessment = const Value.absent(),
                Value<int> activity = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> trainingId = const Value.absent(),
                Value<String?> programSessionId = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                name: name,
                notes: notes,
                date: date,
                dataPath: dataPath,
                isAssessment: isAssessment,
                activity: activity,
                origin: origin,
                trainingId: trainingId,
                programSessionId: programSessionId,
                duration: duration,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$AssessmentsTableCreateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<String> id,
      required int type,
      Value<double?> rightValue,
      Value<double?> leftValue,
      required String sessionId,
      Value<int?> gripPosition,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AssessmentsTableUpdateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<String> id,
      Value<int> type,
      Value<double?> rightValue,
      Value<double?> leftValue,
      Value<String> sessionId,
      Value<int?> gripPosition,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableFilterComposer({
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

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightValue => $composableBuilder(
    column: $table.rightValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftValue => $composableBuilder(
    column: $table.leftValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightValue => $composableBuilder(
    column: $table.rightValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftValue => $composableBuilder(
    column: $table.leftValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get rightValue => $composableBuilder(
    column: $table.rightValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leftValue =>
      $composableBuilder(column: $table.leftValue, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentsTable,
          Assessment,
          $$AssessmentsTableFilterComposer,
          $$AssessmentsTableOrderingComposer,
          $$AssessmentsTableAnnotationComposer,
          $$AssessmentsTableCreateCompanionBuilder,
          $$AssessmentsTableUpdateCompanionBuilder,
          (
            Assessment,
            BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment>,
          ),
          Assessment,
          PrefetchHooks Function()
        > {
  $$AssessmentsTableTableManager(_$AppDatabase db, $AssessmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssessmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssessmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<double?> rightValue = const Value.absent(),
                Value<double?> leftValue = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int?> gripPosition = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessmentsCompanion(
                id: id,
                type: type,
                rightValue: rightValue,
                leftValue: leftValue,
                sessionId: sessionId,
                gripPosition: gripPosition,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required int type,
                Value<double?> rightValue = const Value.absent(),
                Value<double?> leftValue = const Value.absent(),
                required String sessionId,
                Value<int?> gripPosition = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessmentsCompanion.insert(
                id: id,
                type: type,
                rightValue: rightValue,
                leftValue: leftValue,
                sessionId: sessionId,
                gripPosition: gripPosition,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentsTable,
      Assessment,
      $$AssessmentsTableFilterComposer,
      $$AssessmentsTableOrderingComposer,
      $$AssessmentsTableAnnotationComposer,
      $$AssessmentsTableCreateCompanionBuilder,
      $$AssessmentsTableUpdateCompanionBuilder,
      (
        Assessment,
        BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment>,
      ),
      Assessment,
      PrefetchHooks Function()
    >;
typedef $$TrainingsTableCreateCompanionBuilder =
    TrainingsCompanion Function({
      Value<String> id,
      required String title,
      Value<String?> description,
      Value<bool> isFavorite,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TrainingsTableUpdateCompanionBuilder =
    TrainingsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<bool> isFavorite,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TrainingsTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingsTable> {
  $$TrainingsTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrainingsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingsTable> {
  $$TrainingsTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingsTable> {
  $$TrainingsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrainingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingsTable,
          TrainingRow,
          $$TrainingsTableFilterComposer,
          $$TrainingsTableOrderingComposer,
          $$TrainingsTableAnnotationComposer,
          $$TrainingsTableCreateCompanionBuilder,
          $$TrainingsTableUpdateCompanionBuilder,
          (
            TrainingRow,
            BaseReferences<_$AppDatabase, $TrainingsTable, TrainingRow>,
          ),
          TrainingRow,
          PrefetchHooks Function()
        > {
  $$TrainingsTableTableManager(_$AppDatabase db, $TrainingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingsCompanion(
                id: id,
                title: title,
                description: description,
                isFavorite: isFavorite,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingsCompanion.insert(
                id: id,
                title: title,
                description: description,
                isFavorite: isFavorite,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrainingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingsTable,
      TrainingRow,
      $$TrainingsTableFilterComposer,
      $$TrainingsTableOrderingComposer,
      $$TrainingsTableAnnotationComposer,
      $$TrainingsTableCreateCompanionBuilder,
      $$TrainingsTableUpdateCompanionBuilder,
      (
        TrainingRow,
        BaseReferences<_$AppDatabase, $TrainingsTable, TrainingRow>,
      ),
      TrainingRow,
      PrefetchHooks Function()
    >;
typedef $$TrainingItemsTableCreateCompanionBuilder =
    TrainingItemsCompanion Function({
      Value<String> id,
      required String trainingId,
      Value<String?> parentId,
      required String type,
      Value<int> position,
      Value<int?> cycles,
      Value<int?> cycleRestSeconds,
      Value<int?> reps,
      Value<int?> duration,
      Value<int?> restSeconds,
      Value<int?> worktimeSeconds,
      Value<String?> hand,
      Value<String?> granularity,
      Value<String?> loadsJson,
      Value<String?> leftLoadsJson,
      Value<String?> handPositionsJson,
      Value<String?> edgeSizesMmJson,
      Value<bool> loadIsMax,
      Value<String?> freeText,
      Value<String?> exerciseId,
      Value<String?> groupTitle,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TrainingItemsTableUpdateCompanionBuilder =
    TrainingItemsCompanion Function({
      Value<String> id,
      Value<String> trainingId,
      Value<String?> parentId,
      Value<String> type,
      Value<int> position,
      Value<int?> cycles,
      Value<int?> cycleRestSeconds,
      Value<int?> reps,
      Value<int?> duration,
      Value<int?> restSeconds,
      Value<int?> worktimeSeconds,
      Value<String?> hand,
      Value<String?> granularity,
      Value<String?> loadsJson,
      Value<String?> leftLoadsJson,
      Value<String?> handPositionsJson,
      Value<String?> edgeSizesMmJson,
      Value<bool> loadIsMax,
      Value<String?> freeText,
      Value<String?> exerciseId,
      Value<String?> groupTitle,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TrainingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingItemsTable> {
  $$TrainingItemsTableFilterComposer({
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

  ColumnFilters<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycles => $composableBuilder(
    column: $table.cycles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycleRestSeconds => $composableBuilder(
    column: $table.cycleRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get worktimeSeconds => $composableBuilder(
    column: $table.worktimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hand => $composableBuilder(
    column: $table.hand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get granularity => $composableBuilder(
    column: $table.granularity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loadsJson => $composableBuilder(
    column: $table.loadsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leftLoadsJson => $composableBuilder(
    column: $table.leftLoadsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handPositionsJson => $composableBuilder(
    column: $table.handPositionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get edgeSizesMmJson => $composableBuilder(
    column: $table.edgeSizesMmJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get loadIsMax => $composableBuilder(
    column: $table.loadIsMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeText => $composableBuilder(
    column: $table.freeText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupTitle => $composableBuilder(
    column: $table.groupTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrainingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingItemsTable> {
  $$TrainingItemsTableOrderingComposer({
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

  ColumnOrderings<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycles => $composableBuilder(
    column: $table.cycles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycleRestSeconds => $composableBuilder(
    column: $table.cycleRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get worktimeSeconds => $composableBuilder(
    column: $table.worktimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hand => $composableBuilder(
    column: $table.hand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get granularity => $composableBuilder(
    column: $table.granularity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loadsJson => $composableBuilder(
    column: $table.loadsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leftLoadsJson => $composableBuilder(
    column: $table.leftLoadsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handPositionsJson => $composableBuilder(
    column: $table.handPositionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get edgeSizesMmJson => $composableBuilder(
    column: $table.edgeSizesMmJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get loadIsMax => $composableBuilder(
    column: $table.loadIsMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeText => $composableBuilder(
    column: $table.freeText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupTitle => $composableBuilder(
    column: $table.groupTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingItemsTable> {
  $$TrainingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get cycles =>
      $composableBuilder(column: $table.cycles, builder: (column) => column);

  GeneratedColumn<int> get cycleRestSeconds => $composableBuilder(
    column: $table.cycleRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get worktimeSeconds => $composableBuilder(
    column: $table.worktimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hand =>
      $composableBuilder(column: $table.hand, builder: (column) => column);

  GeneratedColumn<String> get granularity => $composableBuilder(
    column: $table.granularity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loadsJson =>
      $composableBuilder(column: $table.loadsJson, builder: (column) => column);

  GeneratedColumn<String> get leftLoadsJson => $composableBuilder(
    column: $table.leftLoadsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get handPositionsJson => $composableBuilder(
    column: $table.handPositionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get edgeSizesMmJson => $composableBuilder(
    column: $table.edgeSizesMmJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get loadIsMax =>
      $composableBuilder(column: $table.loadIsMax, builder: (column) => column);

  GeneratedColumn<String> get freeText =>
      $composableBuilder(column: $table.freeText, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupTitle => $composableBuilder(
    column: $table.groupTitle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrainingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingItemsTable,
          TrainingItemRow,
          $$TrainingItemsTableFilterComposer,
          $$TrainingItemsTableOrderingComposer,
          $$TrainingItemsTableAnnotationComposer,
          $$TrainingItemsTableCreateCompanionBuilder,
          $$TrainingItemsTableUpdateCompanionBuilder,
          (
            TrainingItemRow,
            BaseReferences<_$AppDatabase, $TrainingItemsTable, TrainingItemRow>,
          ),
          TrainingItemRow,
          PrefetchHooks Function()
        > {
  $$TrainingItemsTableTableManager(_$AppDatabase db, $TrainingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trainingId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> cycles = const Value.absent(),
                Value<int?> cycleRestSeconds = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<int?> worktimeSeconds = const Value.absent(),
                Value<String?> hand = const Value.absent(),
                Value<String?> granularity = const Value.absent(),
                Value<String?> loadsJson = const Value.absent(),
                Value<String?> leftLoadsJson = const Value.absent(),
                Value<String?> handPositionsJson = const Value.absent(),
                Value<String?> edgeSizesMmJson = const Value.absent(),
                Value<bool> loadIsMax = const Value.absent(),
                Value<String?> freeText = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
                Value<String?> groupTitle = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingItemsCompanion(
                id: id,
                trainingId: trainingId,
                parentId: parentId,
                type: type,
                position: position,
                cycles: cycles,
                cycleRestSeconds: cycleRestSeconds,
                reps: reps,
                duration: duration,
                restSeconds: restSeconds,
                worktimeSeconds: worktimeSeconds,
                hand: hand,
                granularity: granularity,
                loadsJson: loadsJson,
                leftLoadsJson: leftLoadsJson,
                handPositionsJson: handPositionsJson,
                edgeSizesMmJson: edgeSizesMmJson,
                loadIsMax: loadIsMax,
                freeText: freeText,
                exerciseId: exerciseId,
                groupTitle: groupTitle,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String trainingId,
                Value<String?> parentId = const Value.absent(),
                required String type,
                Value<int> position = const Value.absent(),
                Value<int?> cycles = const Value.absent(),
                Value<int?> cycleRestSeconds = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<int?> worktimeSeconds = const Value.absent(),
                Value<String?> hand = const Value.absent(),
                Value<String?> granularity = const Value.absent(),
                Value<String?> loadsJson = const Value.absent(),
                Value<String?> leftLoadsJson = const Value.absent(),
                Value<String?> handPositionsJson = const Value.absent(),
                Value<String?> edgeSizesMmJson = const Value.absent(),
                Value<bool> loadIsMax = const Value.absent(),
                Value<String?> freeText = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
                Value<String?> groupTitle = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingItemsCompanion.insert(
                id: id,
                trainingId: trainingId,
                parentId: parentId,
                type: type,
                position: position,
                cycles: cycles,
                cycleRestSeconds: cycleRestSeconds,
                reps: reps,
                duration: duration,
                restSeconds: restSeconds,
                worktimeSeconds: worktimeSeconds,
                hand: hand,
                granularity: granularity,
                loadsJson: loadsJson,
                leftLoadsJson: leftLoadsJson,
                handPositionsJson: handPositionsJson,
                edgeSizesMmJson: edgeSizesMmJson,
                loadIsMax: loadIsMax,
                freeText: freeText,
                exerciseId: exerciseId,
                groupTitle: groupTitle,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrainingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingItemsTable,
      TrainingItemRow,
      $$TrainingItemsTableFilterComposer,
      $$TrainingItemsTableOrderingComposer,
      $$TrainingItemsTableAnnotationComposer,
      $$TrainingItemsTableCreateCompanionBuilder,
      $$TrainingItemsTableUpdateCompanionBuilder,
      (
        TrainingItemRow,
        BaseReferences<_$AppDatabase, $TrainingItemsTable, TrainingItemRow>,
      ),
      TrainingItemRow,
      PrefetchHooks Function()
    >;
typedef $$RepDatasTableCreateCompanionBuilder =
    RepDatasCompanion Function({
      Value<String> id,
      required double averageWeight,
      required String sessionId,
      required bool isRest,
      required bool rightHand,
      required int duration,
      required double targetWeight,
      required int index,
      Value<int> gripPosition,
      Value<int?> edgeSizeMm,
      Value<String?> trainingItemId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RepDatasTableUpdateCompanionBuilder =
    RepDatasCompanion Function({
      Value<String> id,
      Value<double> averageWeight,
      Value<String> sessionId,
      Value<bool> isRest,
      Value<bool> rightHand,
      Value<int> duration,
      Value<double> targetWeight,
      Value<int> index,
      Value<int> gripPosition,
      Value<int?> edgeSizeMm,
      Value<String?> trainingItemId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RepDatasTableFilterComposer
    extends Composer<_$AppDatabase, $RepDatasTable> {
  $$RepDatasTableFilterComposer({
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

  ColumnFilters<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRest => $composableBuilder(
    column: $table.isRest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rightHand => $composableBuilder(
    column: $table.rightHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeight => $composableBuilder(
    column: $table.targetWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get index => $composableBuilder(
    column: $table.index,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get edgeSizeMm => $composableBuilder(
    column: $table.edgeSizeMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trainingItemId => $composableBuilder(
    column: $table.trainingItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RepDatasTableOrderingComposer
    extends Composer<_$AppDatabase, $RepDatasTable> {
  $$RepDatasTableOrderingComposer({
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

  ColumnOrderings<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRest => $composableBuilder(
    column: $table.isRest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rightHand => $composableBuilder(
    column: $table.rightHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeight => $composableBuilder(
    column: $table.targetWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get index => $composableBuilder(
    column: $table.index,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get edgeSizeMm => $composableBuilder(
    column: $table.edgeSizeMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trainingItemId => $composableBuilder(
    column: $table.trainingItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RepDatasTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepDatasTable> {
  $$RepDatasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<bool> get isRest =>
      $composableBuilder(column: $table.isRest, builder: (column) => column);

  GeneratedColumn<bool> get rightHand =>
      $composableBuilder(column: $table.rightHand, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<double> get targetWeight => $composableBuilder(
    column: $table.targetWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get index =>
      $composableBuilder(column: $table.index, builder: (column) => column);

  GeneratedColumn<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get edgeSizeMm => $composableBuilder(
    column: $table.edgeSizeMm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trainingItemId => $composableBuilder(
    column: $table.trainingItemId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RepDatasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepDatasTable,
          RepData,
          $$RepDatasTableFilterComposer,
          $$RepDatasTableOrderingComposer,
          $$RepDatasTableAnnotationComposer,
          $$RepDatasTableCreateCompanionBuilder,
          $$RepDatasTableUpdateCompanionBuilder,
          (RepData, BaseReferences<_$AppDatabase, $RepDatasTable, RepData>),
          RepData,
          PrefetchHooks Function()
        > {
  $$RepDatasTableTableManager(_$AppDatabase db, $RepDatasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepDatasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepDatasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepDatasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> averageWeight = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<bool> isRest = const Value.absent(),
                Value<bool> rightHand = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<double> targetWeight = const Value.absent(),
                Value<int> index = const Value.absent(),
                Value<int> gripPosition = const Value.absent(),
                Value<int?> edgeSizeMm = const Value.absent(),
                Value<String?> trainingItemId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepDatasCompanion(
                id: id,
                averageWeight: averageWeight,
                sessionId: sessionId,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                targetWeight: targetWeight,
                index: index,
                gripPosition: gripPosition,
                edgeSizeMm: edgeSizeMm,
                trainingItemId: trainingItemId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required double averageWeight,
                required String sessionId,
                required bool isRest,
                required bool rightHand,
                required int duration,
                required double targetWeight,
                required int index,
                Value<int> gripPosition = const Value.absent(),
                Value<int?> edgeSizeMm = const Value.absent(),
                Value<String?> trainingItemId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepDatasCompanion.insert(
                id: id,
                averageWeight: averageWeight,
                sessionId: sessionId,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                targetWeight: targetWeight,
                index: index,
                gripPosition: gripPosition,
                edgeSizeMm: edgeSizeMm,
                trainingItemId: trainingItemId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RepDatasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepDatasTable,
      RepData,
      $$RepDatasTableFilterComposer,
      $$RepDatasTableOrderingComposer,
      $$RepDatasTableAnnotationComposer,
      $$RepDatasTableCreateCompanionBuilder,
      $$RepDatasTableUpdateCompanionBuilder,
      (RepData, BaseReferences<_$AppDatabase, $RepDatasTable, RepData>),
      RepData,
      PrefetchHooks Function()
    >;
typedef $$SensorConfigsTableCreateCompanionBuilder =
    SensorConfigsCompanion Function({
      Value<String> id,
      required String name,
      required int index,
      required double tare,
      required double coef,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SensorConfigsTableUpdateCompanionBuilder =
    SensorConfigsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> index,
      Value<double> tare,
      Value<double> coef,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SensorConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $SensorConfigsTable> {
  $$SensorConfigsTableFilterComposer({
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

  ColumnFilters<int> get index => $composableBuilder(
    column: $table.index,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tare => $composableBuilder(
    column: $table.tare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coef => $composableBuilder(
    column: $table.coef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SensorConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorConfigsTable> {
  $$SensorConfigsTableOrderingComposer({
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

  ColumnOrderings<int> get index => $composableBuilder(
    column: $table.index,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tare => $composableBuilder(
    column: $table.tare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coef => $composableBuilder(
    column: $table.coef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SensorConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorConfigsTable> {
  $$SensorConfigsTableAnnotationComposer({
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

  GeneratedColumn<int> get index =>
      $composableBuilder(column: $table.index, builder: (column) => column);

  GeneratedColumn<double> get tare =>
      $composableBuilder(column: $table.tare, builder: (column) => column);

  GeneratedColumn<double> get coef =>
      $composableBuilder(column: $table.coef, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SensorConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorConfigsTable,
          SensorConfig,
          $$SensorConfigsTableFilterComposer,
          $$SensorConfigsTableOrderingComposer,
          $$SensorConfigsTableAnnotationComposer,
          $$SensorConfigsTableCreateCompanionBuilder,
          $$SensorConfigsTableUpdateCompanionBuilder,
          (
            SensorConfig,
            BaseReferences<_$AppDatabase, $SensorConfigsTable, SensorConfig>,
          ),
          SensorConfig,
          PrefetchHooks Function()
        > {
  $$SensorConfigsTableTableManager(_$AppDatabase db, $SensorConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SensorConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> index = const Value.absent(),
                Value<double> tare = const Value.absent(),
                Value<double> coef = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SensorConfigsCompanion(
                id: id,
                name: name,
                index: index,
                tare: tare,
                coef: coef,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required int index,
                required double tare,
                required double coef,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SensorConfigsCompanion.insert(
                id: id,
                name: name,
                index: index,
                tare: tare,
                coef: coef,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SensorConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorConfigsTable,
      SensorConfig,
      $$SensorConfigsTableFilterComposer,
      $$SensorConfigsTableOrderingComposer,
      $$SensorConfigsTableAnnotationComposer,
      $$SensorConfigsTableCreateCompanionBuilder,
      $$SensorConfigsTableUpdateCompanionBuilder,
      (
        SensorConfig,
        BaseReferences<_$AppDatabase, $SensorConfigsTable, SensorConfig>,
      ),
      SensorConfig,
      PrefetchHooks Function()
    >;
typedef $$BuiltinTrainingWeightsTableCreateCompanionBuilder =
    BuiltinTrainingWeightsCompanion Function({
      Value<String> id,
      required String builtinTrainingId,
      Value<double?> customWeightRight,
      Value<double?> customWeightLeft,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$BuiltinTrainingWeightsTableUpdateCompanionBuilder =
    BuiltinTrainingWeightsCompanion Function({
      Value<String> id,
      Value<String> builtinTrainingId,
      Value<double?> customWeightRight,
      Value<double?> customWeightLeft,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BuiltinTrainingWeightsTableFilterComposer
    extends Composer<_$AppDatabase, $BuiltinTrainingWeightsTable> {
  $$BuiltinTrainingWeightsTableFilterComposer({
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

  ColumnFilters<String> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get customWeightRight => $composableBuilder(
    column: $table.customWeightRight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get customWeightLeft => $composableBuilder(
    column: $table.customWeightLeft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BuiltinTrainingWeightsTableOrderingComposer
    extends Composer<_$AppDatabase, $BuiltinTrainingWeightsTable> {
  $$BuiltinTrainingWeightsTableOrderingComposer({
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

  ColumnOrderings<String> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get customWeightRight => $composableBuilder(
    column: $table.customWeightRight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get customWeightLeft => $composableBuilder(
    column: $table.customWeightLeft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuiltinTrainingWeightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuiltinTrainingWeightsTable> {
  $$BuiltinTrainingWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get customWeightRight => $composableBuilder(
    column: $table.customWeightRight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get customWeightLeft => $composableBuilder(
    column: $table.customWeightLeft,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BuiltinTrainingWeightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BuiltinTrainingWeightsTable,
          BuiltinTrainingWeight,
          $$BuiltinTrainingWeightsTableFilterComposer,
          $$BuiltinTrainingWeightsTableOrderingComposer,
          $$BuiltinTrainingWeightsTableAnnotationComposer,
          $$BuiltinTrainingWeightsTableCreateCompanionBuilder,
          $$BuiltinTrainingWeightsTableUpdateCompanionBuilder,
          (
            BuiltinTrainingWeight,
            BaseReferences<
              _$AppDatabase,
              $BuiltinTrainingWeightsTable,
              BuiltinTrainingWeight
            >,
          ),
          BuiltinTrainingWeight,
          PrefetchHooks Function()
        > {
  $$BuiltinTrainingWeightsTableTableManager(
    _$AppDatabase db,
    $BuiltinTrainingWeightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuiltinTrainingWeightsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BuiltinTrainingWeightsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BuiltinTrainingWeightsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> builtinTrainingId = const Value.absent(),
                Value<double?> customWeightRight = const Value.absent(),
                Value<double?> customWeightLeft = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuiltinTrainingWeightsCompanion(
                id: id,
                builtinTrainingId: builtinTrainingId,
                customWeightRight: customWeightRight,
                customWeightLeft: customWeightLeft,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String builtinTrainingId,
                Value<double?> customWeightRight = const Value.absent(),
                Value<double?> customWeightLeft = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuiltinTrainingWeightsCompanion.insert(
                id: id,
                builtinTrainingId: builtinTrainingId,
                customWeightRight: customWeightRight,
                customWeightLeft: customWeightLeft,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BuiltinTrainingWeightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BuiltinTrainingWeightsTable,
      BuiltinTrainingWeight,
      $$BuiltinTrainingWeightsTableFilterComposer,
      $$BuiltinTrainingWeightsTableOrderingComposer,
      $$BuiltinTrainingWeightsTableAnnotationComposer,
      $$BuiltinTrainingWeightsTableCreateCompanionBuilder,
      $$BuiltinTrainingWeightsTableUpdateCompanionBuilder,
      (
        BuiltinTrainingWeight,
        BaseReferences<
          _$AppDatabase,
          $BuiltinTrainingWeightsTable,
          BuiltinTrainingWeight
        >,
      ),
      BuiltinTrainingWeight,
      PrefetchHooks Function()
    >;
typedef $$PinnedBuiltinTrainingsTableCreateCompanionBuilder =
    PinnedBuiltinTrainingsCompanion Function({
      required String builtinTrainingId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PinnedBuiltinTrainingsTableUpdateCompanionBuilder =
    PinnedBuiltinTrainingsCompanion Function({
      Value<String> builtinTrainingId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PinnedBuiltinTrainingsTableFilterComposer
    extends Composer<_$AppDatabase, $PinnedBuiltinTrainingsTable> {
  $$PinnedBuiltinTrainingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PinnedBuiltinTrainingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PinnedBuiltinTrainingsTable> {
  $$PinnedBuiltinTrainingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PinnedBuiltinTrainingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PinnedBuiltinTrainingsTable> {
  $$PinnedBuiltinTrainingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PinnedBuiltinTrainingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PinnedBuiltinTrainingsTable,
          PinnedBuiltinTraining,
          $$PinnedBuiltinTrainingsTableFilterComposer,
          $$PinnedBuiltinTrainingsTableOrderingComposer,
          $$PinnedBuiltinTrainingsTableAnnotationComposer,
          $$PinnedBuiltinTrainingsTableCreateCompanionBuilder,
          $$PinnedBuiltinTrainingsTableUpdateCompanionBuilder,
          (
            PinnedBuiltinTraining,
            BaseReferences<
              _$AppDatabase,
              $PinnedBuiltinTrainingsTable,
              PinnedBuiltinTraining
            >,
          ),
          PinnedBuiltinTraining,
          PrefetchHooks Function()
        > {
  $$PinnedBuiltinTrainingsTableTableManager(
    _$AppDatabase db,
    $PinnedBuiltinTrainingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinnedBuiltinTrainingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PinnedBuiltinTrainingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PinnedBuiltinTrainingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> builtinTrainingId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PinnedBuiltinTrainingsCompanion(
                builtinTrainingId: builtinTrainingId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String builtinTrainingId,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PinnedBuiltinTrainingsCompanion.insert(
                builtinTrainingId: builtinTrainingId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PinnedBuiltinTrainingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PinnedBuiltinTrainingsTable,
      PinnedBuiltinTraining,
      $$PinnedBuiltinTrainingsTableFilterComposer,
      $$PinnedBuiltinTrainingsTableOrderingComposer,
      $$PinnedBuiltinTrainingsTableAnnotationComposer,
      $$PinnedBuiltinTrainingsTableCreateCompanionBuilder,
      $$PinnedBuiltinTrainingsTableUpdateCompanionBuilder,
      (
        PinnedBuiltinTraining,
        BaseReferences<
          _$AppDatabase,
          $PinnedBuiltinTrainingsTable,
          PinnedBuiltinTraining
        >,
      ),
      PinnedBuiltinTraining,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      required String firstname,
      required String lastname,
      Value<bool> emailVerified,
      Value<bool> isAdmin,
      Value<bool> isCoach,
      Value<bool> coachValidated,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> firstname,
      Value<String> lastname,
      Value<bool> emailVerified,
      Value<bool> isAdmin,
      Value<bool> isCoach,
      Value<bool> coachValidated,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstname => $composableBuilder(
    column: $table.firstname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastname => $composableBuilder(
    column: $table.lastname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get emailVerified => $composableBuilder(
    column: $table.emailVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdmin => $composableBuilder(
    column: $table.isAdmin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCoach => $composableBuilder(
    column: $table.isCoach,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get coachValidated => $composableBuilder(
    column: $table.coachValidated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstname => $composableBuilder(
    column: $table.firstname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastname => $composableBuilder(
    column: $table.lastname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get emailVerified => $composableBuilder(
    column: $table.emailVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdmin => $composableBuilder(
    column: $table.isAdmin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCoach => $composableBuilder(
    column: $table.isCoach,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get coachValidated => $composableBuilder(
    column: $table.coachValidated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get firstname =>
      $composableBuilder(column: $table.firstname, builder: (column) => column);

  GeneratedColumn<String> get lastname =>
      $composableBuilder(column: $table.lastname, builder: (column) => column);

  GeneratedColumn<bool> get emailVerified => $composableBuilder(
    column: $table.emailVerified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAdmin =>
      $composableBuilder(column: $table.isAdmin, builder: (column) => column);

  GeneratedColumn<bool> get isCoach =>
      $composableBuilder(column: $table.isCoach, builder: (column) => column);

  GeneratedColumn<bool> get coachValidated => $composableBuilder(
    column: $table.coachValidated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> firstname = const Value.absent(),
                Value<String> lastname = const Value.absent(),
                Value<bool> emailVerified = const Value.absent(),
                Value<bool> isAdmin = const Value.absent(),
                Value<bool> isCoach = const Value.absent(),
                Value<bool> coachValidated = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                firstname: firstname,
                lastname: lastname,
                emailVerified: emailVerified,
                isAdmin: isAdmin,
                isCoach: isCoach,
                coachValidated: coachValidated,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String firstname,
                required String lastname,
                Value<bool> emailVerified = const Value.absent(),
                Value<bool> isAdmin = const Value.absent(),
                Value<bool> isCoach = const Value.absent(),
                Value<bool> coachValidated = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                firstname: firstname,
                lastname: lastname,
                emailVerified: emailVerified,
                isAdmin: isAdmin,
                isCoach: isCoach,
                coachValidated: coachValidated,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$AssessmentsTableTableManager get assessments =>
      $$AssessmentsTableTableManager(_db, _db.assessments);
  $$TrainingsTableTableManager get trainings =>
      $$TrainingsTableTableManager(_db, _db.trainings);
  $$TrainingItemsTableTableManager get trainingItems =>
      $$TrainingItemsTableTableManager(_db, _db.trainingItems);
  $$RepDatasTableTableManager get repDatas =>
      $$RepDatasTableTableManager(_db, _db.repDatas);
  $$SensorConfigsTableTableManager get sensorConfigs =>
      $$SensorConfigsTableTableManager(_db, _db.sensorConfigs);
  $$BuiltinTrainingWeightsTableTableManager get builtinTrainingWeights =>
      $$BuiltinTrainingWeightsTableTableManager(
        _db,
        _db.builtinTrainingWeights,
      );
  $$PinnedBuiltinTrainingsTableTableManager get pinnedBuiltinTrainings =>
      $$PinnedBuiltinTrainingsTableTableManager(
        _db,
        _db.pinnedBuiltinTrainings,
      );
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
