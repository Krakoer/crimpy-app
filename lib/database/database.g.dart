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
  static const VerificationMeta _sessionTypeMeta = const VerificationMeta(
    'sessionType',
  );
  @override
  late final GeneratedColumn<int> sessionType = GeneratedColumn<int>(
    'session_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _repeaterSetsMeta = const VerificationMeta(
    'repeaterSets',
  );
  @override
  late final GeneratedColumn<int> repeaterSets = GeneratedColumn<int>(
    'repeater_sets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeaterRepsMeta = const VerificationMeta(
    'repeaterReps',
  );
  @override
  late final GeneratedColumn<int> repeaterReps = GeneratedColumn<int>(
    'repeater_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeaterWorkTimeMeta = const VerificationMeta(
    'repeaterWorkTime',
  );
  @override
  late final GeneratedColumn<int> repeaterWorkTime = GeneratedColumn<int>(
    'repeater_work_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeaterRestTimeMeta = const VerificationMeta(
    'repeaterRestTime',
  );
  @override
  late final GeneratedColumn<int> repeaterRestTime = GeneratedColumn<int>(
    'repeater_rest_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeaterSetRestMeta = const VerificationMeta(
    'repeaterSetRest',
  );
  @override
  late final GeneratedColumn<int> repeaterSetRest = GeneratedColumn<int>(
    'repeater_set_rest',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeaterSplitHandMeta = const VerificationMeta(
    'repeaterSplitHand',
  );
  @override
  late final GeneratedColumn<bool> repeaterSplitHand = GeneratedColumn<bool>(
    'repeater_split_hand',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeater_split_hand" IN (0, 1))',
    ),
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
    sessionType,
    duration,
    repeaterSets,
    repeaterReps,
    repeaterWorkTime,
    repeaterRestTime,
    repeaterSetRest,
    repeaterSplitHand,
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
    if (data.containsKey('session_type')) {
      context.handle(
        _sessionTypeMeta,
        sessionType.isAcceptableOrUnknown(
          data['session_type']!,
          _sessionTypeMeta,
        ),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('repeater_sets')) {
      context.handle(
        _repeaterSetsMeta,
        repeaterSets.isAcceptableOrUnknown(
          data['repeater_sets']!,
          _repeaterSetsMeta,
        ),
      );
    }
    if (data.containsKey('repeater_reps')) {
      context.handle(
        _repeaterRepsMeta,
        repeaterReps.isAcceptableOrUnknown(
          data['repeater_reps']!,
          _repeaterRepsMeta,
        ),
      );
    }
    if (data.containsKey('repeater_work_time')) {
      context.handle(
        _repeaterWorkTimeMeta,
        repeaterWorkTime.isAcceptableOrUnknown(
          data['repeater_work_time']!,
          _repeaterWorkTimeMeta,
        ),
      );
    }
    if (data.containsKey('repeater_rest_time')) {
      context.handle(
        _repeaterRestTimeMeta,
        repeaterRestTime.isAcceptableOrUnknown(
          data['repeater_rest_time']!,
          _repeaterRestTimeMeta,
        ),
      );
    }
    if (data.containsKey('repeater_set_rest')) {
      context.handle(
        _repeaterSetRestMeta,
        repeaterSetRest.isAcceptableOrUnknown(
          data['repeater_set_rest']!,
          _repeaterSetRestMeta,
        ),
      );
    }
    if (data.containsKey('repeater_split_hand')) {
      context.handle(
        _repeaterSplitHandMeta,
        repeaterSplitHand.isAcceptableOrUnknown(
          data['repeater_split_hand']!,
          _repeaterSplitHandMeta,
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
      sessionType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_type'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      repeaterSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeater_sets'],
      ),
      repeaterReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeater_reps'],
      ),
      repeaterWorkTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeater_work_time'],
      ),
      repeaterRestTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeater_rest_time'],
      ),
      repeaterSetRest: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeater_set_rest'],
      ),
      repeaterSplitHand: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeater_split_hand'],
      ),
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
  final int sessionType;
  final int duration;
  final int? repeaterSets;
  final int? repeaterReps;
  final int? repeaterWorkTime;
  final int? repeaterRestTime;
  final int? repeaterSetRest;
  final bool? repeaterSplitHand;
  final DateTime updatedAt;
  const Session({
    required this.id,
    required this.name,
    required this.notes,
    required this.date,
    required this.dataPath,
    required this.isAssessment,
    required this.sessionType,
    required this.duration,
    this.repeaterSets,
    this.repeaterReps,
    this.repeaterWorkTime,
    this.repeaterRestTime,
    this.repeaterSetRest,
    this.repeaterSplitHand,
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
    map['session_type'] = Variable<int>(sessionType);
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || repeaterSets != null) {
      map['repeater_sets'] = Variable<int>(repeaterSets);
    }
    if (!nullToAbsent || repeaterReps != null) {
      map['repeater_reps'] = Variable<int>(repeaterReps);
    }
    if (!nullToAbsent || repeaterWorkTime != null) {
      map['repeater_work_time'] = Variable<int>(repeaterWorkTime);
    }
    if (!nullToAbsent || repeaterRestTime != null) {
      map['repeater_rest_time'] = Variable<int>(repeaterRestTime);
    }
    if (!nullToAbsent || repeaterSetRest != null) {
      map['repeater_set_rest'] = Variable<int>(repeaterSetRest);
    }
    if (!nullToAbsent || repeaterSplitHand != null) {
      map['repeater_split_hand'] = Variable<bool>(repeaterSplitHand);
    }
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
      sessionType: Value(sessionType),
      duration: Value(duration),
      repeaterSets: repeaterSets == null && nullToAbsent
          ? const Value.absent()
          : Value(repeaterSets),
      repeaterReps: repeaterReps == null && nullToAbsent
          ? const Value.absent()
          : Value(repeaterReps),
      repeaterWorkTime: repeaterWorkTime == null && nullToAbsent
          ? const Value.absent()
          : Value(repeaterWorkTime),
      repeaterRestTime: repeaterRestTime == null && nullToAbsent
          ? const Value.absent()
          : Value(repeaterRestTime),
      repeaterSetRest: repeaterSetRest == null && nullToAbsent
          ? const Value.absent()
          : Value(repeaterSetRest),
      repeaterSplitHand: repeaterSplitHand == null && nullToAbsent
          ? const Value.absent()
          : Value(repeaterSplitHand),
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
      sessionType: serializer.fromJson<int>(json['sessionType']),
      duration: serializer.fromJson<int>(json['duration']),
      repeaterSets: serializer.fromJson<int?>(json['repeaterSets']),
      repeaterReps: serializer.fromJson<int?>(json['repeaterReps']),
      repeaterWorkTime: serializer.fromJson<int?>(json['repeaterWorkTime']),
      repeaterRestTime: serializer.fromJson<int?>(json['repeaterRestTime']),
      repeaterSetRest: serializer.fromJson<int?>(json['repeaterSetRest']),
      repeaterSplitHand: serializer.fromJson<bool?>(json['repeaterSplitHand']),
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
      'sessionType': serializer.toJson<int>(sessionType),
      'duration': serializer.toJson<int>(duration),
      'repeaterSets': serializer.toJson<int?>(repeaterSets),
      'repeaterReps': serializer.toJson<int?>(repeaterReps),
      'repeaterWorkTime': serializer.toJson<int?>(repeaterWorkTime),
      'repeaterRestTime': serializer.toJson<int?>(repeaterRestTime),
      'repeaterSetRest': serializer.toJson<int?>(repeaterSetRest),
      'repeaterSplitHand': serializer.toJson<bool?>(repeaterSplitHand),
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
    int? sessionType,
    int? duration,
    Value<int?> repeaterSets = const Value.absent(),
    Value<int?> repeaterReps = const Value.absent(),
    Value<int?> repeaterWorkTime = const Value.absent(),
    Value<int?> repeaterRestTime = const Value.absent(),
    Value<int?> repeaterSetRest = const Value.absent(),
    Value<bool?> repeaterSplitHand = const Value.absent(),
    DateTime? updatedAt,
  }) => Session(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    date: date ?? this.date,
    dataPath: dataPath ?? this.dataPath,
    isAssessment: isAssessment ?? this.isAssessment,
    sessionType: sessionType ?? this.sessionType,
    duration: duration ?? this.duration,
    repeaterSets: repeaterSets.present ? repeaterSets.value : this.repeaterSets,
    repeaterReps: repeaterReps.present ? repeaterReps.value : this.repeaterReps,
    repeaterWorkTime: repeaterWorkTime.present
        ? repeaterWorkTime.value
        : this.repeaterWorkTime,
    repeaterRestTime: repeaterRestTime.present
        ? repeaterRestTime.value
        : this.repeaterRestTime,
    repeaterSetRest: repeaterSetRest.present
        ? repeaterSetRest.value
        : this.repeaterSetRest,
    repeaterSplitHand: repeaterSplitHand.present
        ? repeaterSplitHand.value
        : this.repeaterSplitHand,
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
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      duration: data.duration.present ? data.duration.value : this.duration,
      repeaterSets: data.repeaterSets.present
          ? data.repeaterSets.value
          : this.repeaterSets,
      repeaterReps: data.repeaterReps.present
          ? data.repeaterReps.value
          : this.repeaterReps,
      repeaterWorkTime: data.repeaterWorkTime.present
          ? data.repeaterWorkTime.value
          : this.repeaterWorkTime,
      repeaterRestTime: data.repeaterRestTime.present
          ? data.repeaterRestTime.value
          : this.repeaterRestTime,
      repeaterSetRest: data.repeaterSetRest.present
          ? data.repeaterSetRest.value
          : this.repeaterSetRest,
      repeaterSplitHand: data.repeaterSplitHand.present
          ? data.repeaterSplitHand.value
          : this.repeaterSplitHand,
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
          ..write('sessionType: $sessionType, ')
          ..write('duration: $duration, ')
          ..write('repeaterSets: $repeaterSets, ')
          ..write('repeaterReps: $repeaterReps, ')
          ..write('repeaterWorkTime: $repeaterWorkTime, ')
          ..write('repeaterRestTime: $repeaterRestTime, ')
          ..write('repeaterSetRest: $repeaterSetRest, ')
          ..write('repeaterSplitHand: $repeaterSplitHand, ')
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
    sessionType,
    duration,
    repeaterSets,
    repeaterReps,
    repeaterWorkTime,
    repeaterRestTime,
    repeaterSetRest,
    repeaterSplitHand,
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
          other.sessionType == this.sessionType &&
          other.duration == this.duration &&
          other.repeaterSets == this.repeaterSets &&
          other.repeaterReps == this.repeaterReps &&
          other.repeaterWorkTime == this.repeaterWorkTime &&
          other.repeaterRestTime == this.repeaterRestTime &&
          other.repeaterSetRest == this.repeaterSetRest &&
          other.repeaterSplitHand == this.repeaterSplitHand &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> notes;
  final Value<DateTime> date;
  final Value<String> dataPath;
  final Value<bool> isAssessment;
  final Value<int> sessionType;
  final Value<int> duration;
  final Value<int?> repeaterSets;
  final Value<int?> repeaterReps;
  final Value<int?> repeaterWorkTime;
  final Value<int?> repeaterRestTime;
  final Value<int?> repeaterSetRest;
  final Value<bool?> repeaterSplitHand;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.date = const Value.absent(),
    this.dataPath = const Value.absent(),
    this.isAssessment = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.duration = const Value.absent(),
    this.repeaterSets = const Value.absent(),
    this.repeaterReps = const Value.absent(),
    this.repeaterWorkTime = const Value.absent(),
    this.repeaterRestTime = const Value.absent(),
    this.repeaterSetRest = const Value.absent(),
    this.repeaterSplitHand = const Value.absent(),
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
    this.sessionType = const Value.absent(),
    this.duration = const Value.absent(),
    this.repeaterSets = const Value.absent(),
    this.repeaterReps = const Value.absent(),
    this.repeaterWorkTime = const Value.absent(),
    this.repeaterRestTime = const Value.absent(),
    this.repeaterSetRest = const Value.absent(),
    this.repeaterSplitHand = const Value.absent(),
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
    Expression<int>? sessionType,
    Expression<int>? duration,
    Expression<int>? repeaterSets,
    Expression<int>? repeaterReps,
    Expression<int>? repeaterWorkTime,
    Expression<int>? repeaterRestTime,
    Expression<int>? repeaterSetRest,
    Expression<bool>? repeaterSplitHand,
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
      if (sessionType != null) 'session_type': sessionType,
      if (duration != null) 'duration': duration,
      if (repeaterSets != null) 'repeater_sets': repeaterSets,
      if (repeaterReps != null) 'repeater_reps': repeaterReps,
      if (repeaterWorkTime != null) 'repeater_work_time': repeaterWorkTime,
      if (repeaterRestTime != null) 'repeater_rest_time': repeaterRestTime,
      if (repeaterSetRest != null) 'repeater_set_rest': repeaterSetRest,
      if (repeaterSplitHand != null) 'repeater_split_hand': repeaterSplitHand,
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
    Value<int>? sessionType,
    Value<int>? duration,
    Value<int?>? repeaterSets,
    Value<int?>? repeaterReps,
    Value<int?>? repeaterWorkTime,
    Value<int?>? repeaterRestTime,
    Value<int?>? repeaterSetRest,
    Value<bool?>? repeaterSplitHand,
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
      sessionType: sessionType ?? this.sessionType,
      duration: duration ?? this.duration,
      repeaterSets: repeaterSets ?? this.repeaterSets,
      repeaterReps: repeaterReps ?? this.repeaterReps,
      repeaterWorkTime: repeaterWorkTime ?? this.repeaterWorkTime,
      repeaterRestTime: repeaterRestTime ?? this.repeaterRestTime,
      repeaterSetRest: repeaterSetRest ?? this.repeaterSetRest,
      repeaterSplitHand: repeaterSplitHand ?? this.repeaterSplitHand,
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
    if (sessionType.present) {
      map['session_type'] = Variable<int>(sessionType.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (repeaterSets.present) {
      map['repeater_sets'] = Variable<int>(repeaterSets.value);
    }
    if (repeaterReps.present) {
      map['repeater_reps'] = Variable<int>(repeaterReps.value);
    }
    if (repeaterWorkTime.present) {
      map['repeater_work_time'] = Variable<int>(repeaterWorkTime.value);
    }
    if (repeaterRestTime.present) {
      map['repeater_rest_time'] = Variable<int>(repeaterRestTime.value);
    }
    if (repeaterSetRest.present) {
      map['repeater_set_rest'] = Variable<int>(repeaterSetRest.value);
    }
    if (repeaterSplitHand.present) {
      map['repeater_split_hand'] = Variable<bool>(repeaterSplitHand.value);
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
          ..write('sessionType: $sessionType, ')
          ..write('duration: $duration, ')
          ..write('repeaterSets: $repeaterSets, ')
          ..write('repeaterReps: $repeaterReps, ')
          ..write('repeaterWorkTime: $repeaterWorkTime, ')
          ..write('repeaterRestTime: $repeaterRestTime, ')
          ..write('repeaterSetRest: $repeaterSetRest, ')
          ..write('repeaterSplitHand: $repeaterSplitHand, ')
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

class $RepeatersTable extends Repeaters
    with TableInfo<$RepeatersTable, Repeater> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepeatersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _worktimeMeta = const VerificationMeta(
    'worktime',
  );
  @override
  late final GeneratedColumn<int> worktime = GeneratedColumn<int>(
    'worktime',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resttimeMeta = const VerificationMeta(
    'resttime',
  );
  @override
  late final GeneratedColumn<int> resttime = GeneratedColumn<int>(
    'resttime',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setRestMeta = const VerificationMeta(
    'setRest',
  );
  @override
  late final GeneratedColumn<int> setRest = GeneratedColumn<int>(
    'set_rest',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeigthRightMeta = const VerificationMeta(
    'targetWeigthRight',
  );
  @override
  late final GeneratedColumn<double> targetWeigthRight =
      GeneratedColumn<double>(
        'target_weigth_right',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _targetWeigthLeftMeta = const VerificationMeta(
    'targetWeigthLeft',
  );
  @override
  late final GeneratedColumn<double> targetWeigthLeft = GeneratedColumn<double>(
    'target_weigth_left',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _splitHandMeta = const VerificationMeta(
    'splitHand',
  );
  @override
  late final GeneratedColumn<bool> splitHand = GeneratedColumn<bool>(
    'split_hand',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("split_hand" IN (0, 1))',
    ),
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
    sets,
    reps,
    worktime,
    resttime,
    setRest,
    targetWeigthRight,
    targetWeigthLeft,
    splitHand,
    gripPosition,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repeaters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Repeater> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    } else if (isInserting) {
      context.missing(_setsMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('worktime')) {
      context.handle(
        _worktimeMeta,
        worktime.isAcceptableOrUnknown(data['worktime']!, _worktimeMeta),
      );
    } else if (isInserting) {
      context.missing(_worktimeMeta);
    }
    if (data.containsKey('resttime')) {
      context.handle(
        _resttimeMeta,
        resttime.isAcceptableOrUnknown(data['resttime']!, _resttimeMeta),
      );
    } else if (isInserting) {
      context.missing(_resttimeMeta);
    }
    if (data.containsKey('set_rest')) {
      context.handle(
        _setRestMeta,
        setRest.isAcceptableOrUnknown(data['set_rest']!, _setRestMeta),
      );
    } else if (isInserting) {
      context.missing(_setRestMeta);
    }
    if (data.containsKey('target_weigth_right')) {
      context.handle(
        _targetWeigthRightMeta,
        targetWeigthRight.isAcceptableOrUnknown(
          data['target_weigth_right']!,
          _targetWeigthRightMeta,
        ),
      );
    }
    if (data.containsKey('target_weigth_left')) {
      context.handle(
        _targetWeigthLeftMeta,
        targetWeigthLeft.isAcceptableOrUnknown(
          data['target_weigth_left']!,
          _targetWeigthLeftMeta,
        ),
      );
    }
    if (data.containsKey('split_hand')) {
      context.handle(
        _splitHandMeta,
        splitHand.isAcceptableOrUnknown(data['split_hand']!, _splitHandMeta),
      );
    } else if (isInserting) {
      context.missing(_splitHandMeta);
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
  Repeater map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Repeater(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      worktime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}worktime'],
      )!,
      resttime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resttime'],
      )!,
      setRest: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_rest'],
      )!,
      targetWeigthRight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weigth_right'],
      ),
      targetWeigthLeft: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weigth_left'],
      ),
      splitHand: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}split_hand'],
      )!,
      gripPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grip_position'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RepeatersTable createAlias(String alias) {
    return $RepeatersTable(attachedDatabase, alias);
  }
}

class Repeater extends DataClass implements Insertable<Repeater> {
  final String id;
  final int sets;
  final int reps;
  final int worktime;
  final int resttime;
  final int setRest;
  final double? targetWeigthRight;
  final double? targetWeigthLeft;
  final bool splitHand;
  final int gripPosition;
  final DateTime updatedAt;
  const Repeater({
    required this.id,
    required this.sets,
    required this.reps,
    required this.worktime,
    required this.resttime,
    required this.setRest,
    this.targetWeigthRight,
    this.targetWeigthLeft,
    required this.splitHand,
    required this.gripPosition,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sets'] = Variable<int>(sets);
    map['reps'] = Variable<int>(reps);
    map['worktime'] = Variable<int>(worktime);
    map['resttime'] = Variable<int>(resttime);
    map['set_rest'] = Variable<int>(setRest);
    if (!nullToAbsent || targetWeigthRight != null) {
      map['target_weigth_right'] = Variable<double>(targetWeigthRight);
    }
    if (!nullToAbsent || targetWeigthLeft != null) {
      map['target_weigth_left'] = Variable<double>(targetWeigthLeft);
    }
    map['split_hand'] = Variable<bool>(splitHand);
    map['grip_position'] = Variable<int>(gripPosition);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RepeatersCompanion toCompanion(bool nullToAbsent) {
    return RepeatersCompanion(
      id: Value(id),
      sets: Value(sets),
      reps: Value(reps),
      worktime: Value(worktime),
      resttime: Value(resttime),
      setRest: Value(setRest),
      targetWeigthRight: targetWeigthRight == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeigthRight),
      targetWeigthLeft: targetWeigthLeft == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeigthLeft),
      splitHand: Value(splitHand),
      gripPosition: Value(gripPosition),
      updatedAt: Value(updatedAt),
    );
  }

  factory Repeater.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Repeater(
      id: serializer.fromJson<String>(json['id']),
      sets: serializer.fromJson<int>(json['sets']),
      reps: serializer.fromJson<int>(json['reps']),
      worktime: serializer.fromJson<int>(json['worktime']),
      resttime: serializer.fromJson<int>(json['resttime']),
      setRest: serializer.fromJson<int>(json['setRest']),
      targetWeigthRight: serializer.fromJson<double?>(
        json['targetWeigthRight'],
      ),
      targetWeigthLeft: serializer.fromJson<double?>(json['targetWeigthLeft']),
      splitHand: serializer.fromJson<bool>(json['splitHand']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sets': serializer.toJson<int>(sets),
      'reps': serializer.toJson<int>(reps),
      'worktime': serializer.toJson<int>(worktime),
      'resttime': serializer.toJson<int>(resttime),
      'setRest': serializer.toJson<int>(setRest),
      'targetWeigthRight': serializer.toJson<double?>(targetWeigthRight),
      'targetWeigthLeft': serializer.toJson<double?>(targetWeigthLeft),
      'splitHand': serializer.toJson<bool>(splitHand),
      'gripPosition': serializer.toJson<int>(gripPosition),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Repeater copyWith({
    String? id,
    int? sets,
    int? reps,
    int? worktime,
    int? resttime,
    int? setRest,
    Value<double?> targetWeigthRight = const Value.absent(),
    Value<double?> targetWeigthLeft = const Value.absent(),
    bool? splitHand,
    int? gripPosition,
    DateTime? updatedAt,
  }) => Repeater(
    id: id ?? this.id,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    worktime: worktime ?? this.worktime,
    resttime: resttime ?? this.resttime,
    setRest: setRest ?? this.setRest,
    targetWeigthRight: targetWeigthRight.present
        ? targetWeigthRight.value
        : this.targetWeigthRight,
    targetWeigthLeft: targetWeigthLeft.present
        ? targetWeigthLeft.value
        : this.targetWeigthLeft,
    splitHand: splitHand ?? this.splitHand,
    gripPosition: gripPosition ?? this.gripPosition,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Repeater copyWithCompanion(RepeatersCompanion data) {
    return Repeater(
      id: data.id.present ? data.id.value : this.id,
      sets: data.sets.present ? data.sets.value : this.sets,
      reps: data.reps.present ? data.reps.value : this.reps,
      worktime: data.worktime.present ? data.worktime.value : this.worktime,
      resttime: data.resttime.present ? data.resttime.value : this.resttime,
      setRest: data.setRest.present ? data.setRest.value : this.setRest,
      targetWeigthRight: data.targetWeigthRight.present
          ? data.targetWeigthRight.value
          : this.targetWeigthRight,
      targetWeigthLeft: data.targetWeigthLeft.present
          ? data.targetWeigthLeft.value
          : this.targetWeigthLeft,
      splitHand: data.splitHand.present ? data.splitHand.value : this.splitHand,
      gripPosition: data.gripPosition.present
          ? data.gripPosition.value
          : this.gripPosition,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Repeater(')
          ..write('id: $id, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('worktime: $worktime, ')
          ..write('resttime: $resttime, ')
          ..write('setRest: $setRest, ')
          ..write('targetWeigthRight: $targetWeigthRight, ')
          ..write('targetWeigthLeft: $targetWeigthLeft, ')
          ..write('splitHand: $splitHand, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sets,
    reps,
    worktime,
    resttime,
    setRest,
    targetWeigthRight,
    targetWeigthLeft,
    splitHand,
    gripPosition,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Repeater &&
          other.id == this.id &&
          other.sets == this.sets &&
          other.reps == this.reps &&
          other.worktime == this.worktime &&
          other.resttime == this.resttime &&
          other.setRest == this.setRest &&
          other.targetWeigthRight == this.targetWeigthRight &&
          other.targetWeigthLeft == this.targetWeigthLeft &&
          other.splitHand == this.splitHand &&
          other.gripPosition == this.gripPosition &&
          other.updatedAt == this.updatedAt);
}

class RepeatersCompanion extends UpdateCompanion<Repeater> {
  final Value<String> id;
  final Value<int> sets;
  final Value<int> reps;
  final Value<int> worktime;
  final Value<int> resttime;
  final Value<int> setRest;
  final Value<double?> targetWeigthRight;
  final Value<double?> targetWeigthLeft;
  final Value<bool> splitHand;
  final Value<int> gripPosition;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RepeatersCompanion({
    this.id = const Value.absent(),
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.worktime = const Value.absent(),
    this.resttime = const Value.absent(),
    this.setRest = const Value.absent(),
    this.targetWeigthRight = const Value.absent(),
    this.targetWeigthLeft = const Value.absent(),
    this.splitHand = const Value.absent(),
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepeatersCompanion.insert({
    this.id = const Value.absent(),
    required int sets,
    required int reps,
    required int worktime,
    required int resttime,
    required int setRest,
    this.targetWeigthRight = const Value.absent(),
    this.targetWeigthLeft = const Value.absent(),
    required bool splitHand,
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sets = Value(sets),
       reps = Value(reps),
       worktime = Value(worktime),
       resttime = Value(resttime),
       setRest = Value(setRest),
       splitHand = Value(splitHand);
  static Insertable<Repeater> custom({
    Expression<String>? id,
    Expression<int>? sets,
    Expression<int>? reps,
    Expression<int>? worktime,
    Expression<int>? resttime,
    Expression<int>? setRest,
    Expression<double>? targetWeigthRight,
    Expression<double>? targetWeigthLeft,
    Expression<bool>? splitHand,
    Expression<int>? gripPosition,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (worktime != null) 'worktime': worktime,
      if (resttime != null) 'resttime': resttime,
      if (setRest != null) 'set_rest': setRest,
      if (targetWeigthRight != null) 'target_weigth_right': targetWeigthRight,
      if (targetWeigthLeft != null) 'target_weigth_left': targetWeigthLeft,
      if (splitHand != null) 'split_hand': splitHand,
      if (gripPosition != null) 'grip_position': gripPosition,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepeatersCompanion copyWith({
    Value<String>? id,
    Value<int>? sets,
    Value<int>? reps,
    Value<int>? worktime,
    Value<int>? resttime,
    Value<int>? setRest,
    Value<double?>? targetWeigthRight,
    Value<double?>? targetWeigthLeft,
    Value<bool>? splitHand,
    Value<int>? gripPosition,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RepeatersCompanion(
      id: id ?? this.id,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      worktime: worktime ?? this.worktime,
      resttime: resttime ?? this.resttime,
      setRest: setRest ?? this.setRest,
      targetWeigthRight: targetWeigthRight ?? this.targetWeigthRight,
      targetWeigthLeft: targetWeigthLeft ?? this.targetWeigthLeft,
      splitHand: splitHand ?? this.splitHand,
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
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (worktime.present) {
      map['worktime'] = Variable<int>(worktime.value);
    }
    if (resttime.present) {
      map['resttime'] = Variable<int>(resttime.value);
    }
    if (setRest.present) {
      map['set_rest'] = Variable<int>(setRest.value);
    }
    if (targetWeigthRight.present) {
      map['target_weigth_right'] = Variable<double>(targetWeigthRight.value);
    }
    if (targetWeigthLeft.present) {
      map['target_weigth_left'] = Variable<double>(targetWeigthLeft.value);
    }
    if (splitHand.present) {
      map['split_hand'] = Variable<bool>(splitHand.value);
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
    return (StringBuffer('RepeatersCompanion(')
          ..write('id: $id, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('worktime: $worktime, ')
          ..write('resttime: $resttime, ')
          ..write('setRest: $setRest, ')
          ..write('targetWeigthRight: $targetWeigthRight, ')
          ..write('targetWeigthLeft: $targetWeigthLeft, ')
          ..write('splitHand: $splitHand, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrainingsTable extends Trainings
    with TableInfo<$TrainingsTable, Training> {
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeaterIdMeta = const VerificationMeta(
    'repeaterId',
  );
  @override
  late final GeneratedColumn<String> repeaterId = GeneratedColumn<String>(
    'repeater_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    repeaterId,
    isBuiltin,
    isFavorite,
    isAssessment,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trainings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Training> instance, {
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
    if (data.containsKey('repeater_id')) {
      context.handle(
        _repeaterIdMeta,
        repeaterId.isAcceptableOrUnknown(data['repeater_id']!, _repeaterIdMeta),
      );
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
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
  Training map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Training(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      repeaterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeater_id'],
      ),
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isAssessment: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_assessment'],
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

class Training extends DataClass implements Insertable<Training> {
  final String id;
  final String name;
  final String? repeaterId;
  final bool isBuiltin;
  final bool isFavorite;
  final bool isAssessment;
  final DateTime updatedAt;
  const Training({
    required this.id,
    required this.name,
    this.repeaterId,
    required this.isBuiltin,
    required this.isFavorite,
    required this.isAssessment,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || repeaterId != null) {
      map['repeater_id'] = Variable<String>(repeaterId);
    }
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_assessment'] = Variable<bool>(isAssessment);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrainingsCompanion toCompanion(bool nullToAbsent) {
    return TrainingsCompanion(
      id: Value(id),
      name: Value(name),
      repeaterId: repeaterId == null && nullToAbsent
          ? const Value.absent()
          : Value(repeaterId),
      isBuiltin: Value(isBuiltin),
      isFavorite: Value(isFavorite),
      isAssessment: Value(isAssessment),
      updatedAt: Value(updatedAt),
    );
  }

  factory Training.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Training(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      repeaterId: serializer.fromJson<String?>(json['repeaterId']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isAssessment: serializer.fromJson<bool>(json['isAssessment']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'repeaterId': serializer.toJson<String?>(repeaterId),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isAssessment': serializer.toJson<bool>(isAssessment),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Training copyWith({
    String? id,
    String? name,
    Value<String?> repeaterId = const Value.absent(),
    bool? isBuiltin,
    bool? isFavorite,
    bool? isAssessment,
    DateTime? updatedAt,
  }) => Training(
    id: id ?? this.id,
    name: name ?? this.name,
    repeaterId: repeaterId.present ? repeaterId.value : this.repeaterId,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    isFavorite: isFavorite ?? this.isFavorite,
    isAssessment: isAssessment ?? this.isAssessment,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Training copyWithCompanion(TrainingsCompanion data) {
    return Training(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      repeaterId: data.repeaterId.present
          ? data.repeaterId.value
          : this.repeaterId,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isAssessment: data.isAssessment.present
          ? data.isAssessment.value
          : this.isAssessment,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Training(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('repeaterId: $repeaterId, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isAssessment: $isAssessment, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    repeaterId,
    isBuiltin,
    isFavorite,
    isAssessment,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Training &&
          other.id == this.id &&
          other.name == this.name &&
          other.repeaterId == this.repeaterId &&
          other.isBuiltin == this.isBuiltin &&
          other.isFavorite == this.isFavorite &&
          other.isAssessment == this.isAssessment &&
          other.updatedAt == this.updatedAt);
}

class TrainingsCompanion extends UpdateCompanion<Training> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> repeaterId;
  final Value<bool> isBuiltin;
  final Value<bool> isFavorite;
  final Value<bool> isAssessment;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TrainingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.repeaterId = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isAssessment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrainingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.repeaterId = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isAssessment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Training> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? repeaterId,
    Expression<bool>? isBuiltin,
    Expression<bool>? isFavorite,
    Expression<bool>? isAssessment,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (repeaterId != null) 'repeater_id': repeaterId,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isAssessment != null) 'is_assessment': isAssessment,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrainingsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? repeaterId,
    Value<bool>? isBuiltin,
    Value<bool>? isFavorite,
    Value<bool>? isAssessment,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TrainingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      repeaterId: repeaterId ?? this.repeaterId,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      isFavorite: isFavorite ?? this.isFavorite,
      isAssessment: isAssessment ?? this.isAssessment,
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
    if (repeaterId.present) {
      map['repeater_id'] = Variable<String>(repeaterId.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isAssessment.present) {
      map['is_assessment'] = Variable<bool>(isAssessment.value);
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
          ..write('name: $name, ')
          ..write('repeaterId: $repeaterId, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isAssessment: $isAssessment, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RepTemplatesTable extends RepTemplates
    with TableInfo<$RepTemplatesTable, RepTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepTemplatesTable(this.attachedDatabase, [this._alias]);
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
    isRest,
    rightHand,
    duration,
    trainingId,
    targetWeight,
    index,
    gripPosition,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rep_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('training_id')) {
      context.handle(
        _trainingIdMeta,
        trainingId.isAcceptableOrUnknown(data['training_id']!, _trainingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trainingIdMeta);
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
  RepTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
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
      trainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_id'],
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RepTemplatesTable createAlias(String alias) {
    return $RepTemplatesTable(attachedDatabase, alias);
  }
}

class RepTemplate extends DataClass implements Insertable<RepTemplate> {
  final String id;
  final bool isRest;
  final bool rightHand;
  final int duration;
  final String trainingId;
  final double targetWeight;
  final int index;
  final int gripPosition;
  final DateTime updatedAt;
  const RepTemplate({
    required this.id,
    required this.isRest,
    required this.rightHand,
    required this.duration,
    required this.trainingId,
    required this.targetWeight,
    required this.index,
    required this.gripPosition,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['is_rest'] = Variable<bool>(isRest);
    map['right_hand'] = Variable<bool>(rightHand);
    map['duration'] = Variable<int>(duration);
    map['training_id'] = Variable<String>(trainingId);
    map['target_weight'] = Variable<double>(targetWeight);
    map['index'] = Variable<int>(index);
    map['grip_position'] = Variable<int>(gripPosition);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RepTemplatesCompanion toCompanion(bool nullToAbsent) {
    return RepTemplatesCompanion(
      id: Value(id),
      isRest: Value(isRest),
      rightHand: Value(rightHand),
      duration: Value(duration),
      trainingId: Value(trainingId),
      targetWeight: Value(targetWeight),
      index: Value(index),
      gripPosition: Value(gripPosition),
      updatedAt: Value(updatedAt),
    );
  }

  factory RepTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepTemplate(
      id: serializer.fromJson<String>(json['id']),
      isRest: serializer.fromJson<bool>(json['isRest']),
      rightHand: serializer.fromJson<bool>(json['rightHand']),
      duration: serializer.fromJson<int>(json['duration']),
      trainingId: serializer.fromJson<String>(json['trainingId']),
      targetWeight: serializer.fromJson<double>(json['targetWeight']),
      index: serializer.fromJson<int>(json['index']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'isRest': serializer.toJson<bool>(isRest),
      'rightHand': serializer.toJson<bool>(rightHand),
      'duration': serializer.toJson<int>(duration),
      'trainingId': serializer.toJson<String>(trainingId),
      'targetWeight': serializer.toJson<double>(targetWeight),
      'index': serializer.toJson<int>(index),
      'gripPosition': serializer.toJson<int>(gripPosition),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RepTemplate copyWith({
    String? id,
    bool? isRest,
    bool? rightHand,
    int? duration,
    String? trainingId,
    double? targetWeight,
    int? index,
    int? gripPosition,
    DateTime? updatedAt,
  }) => RepTemplate(
    id: id ?? this.id,
    isRest: isRest ?? this.isRest,
    rightHand: rightHand ?? this.rightHand,
    duration: duration ?? this.duration,
    trainingId: trainingId ?? this.trainingId,
    targetWeight: targetWeight ?? this.targetWeight,
    index: index ?? this.index,
    gripPosition: gripPosition ?? this.gripPosition,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RepTemplate copyWithCompanion(RepTemplatesCompanion data) {
    return RepTemplate(
      id: data.id.present ? data.id.value : this.id,
      isRest: data.isRest.present ? data.isRest.value : this.isRest,
      rightHand: data.rightHand.present ? data.rightHand.value : this.rightHand,
      duration: data.duration.present ? data.duration.value : this.duration,
      trainingId: data.trainingId.present
          ? data.trainingId.value
          : this.trainingId,
      targetWeight: data.targetWeight.present
          ? data.targetWeight.value
          : this.targetWeight,
      index: data.index.present ? data.index.value : this.index,
      gripPosition: data.gripPosition.present
          ? data.gripPosition.value
          : this.gripPosition,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepTemplate(')
          ..write('id: $id, ')
          ..write('isRest: $isRest, ')
          ..write('rightHand: $rightHand, ')
          ..write('duration: $duration, ')
          ..write('trainingId: $trainingId, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('index: $index, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    isRest,
    rightHand,
    duration,
    trainingId,
    targetWeight,
    index,
    gripPosition,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepTemplate &&
          other.id == this.id &&
          other.isRest == this.isRest &&
          other.rightHand == this.rightHand &&
          other.duration == this.duration &&
          other.trainingId == this.trainingId &&
          other.targetWeight == this.targetWeight &&
          other.index == this.index &&
          other.gripPosition == this.gripPosition &&
          other.updatedAt == this.updatedAt);
}

class RepTemplatesCompanion extends UpdateCompanion<RepTemplate> {
  final Value<String> id;
  final Value<bool> isRest;
  final Value<bool> rightHand;
  final Value<int> duration;
  final Value<String> trainingId;
  final Value<double> targetWeight;
  final Value<int> index;
  final Value<int> gripPosition;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RepTemplatesCompanion({
    this.id = const Value.absent(),
    this.isRest = const Value.absent(),
    this.rightHand = const Value.absent(),
    this.duration = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.index = const Value.absent(),
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required bool isRest,
    required bool rightHand,
    required int duration,
    required String trainingId,
    required double targetWeight,
    required int index,
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : isRest = Value(isRest),
       rightHand = Value(rightHand),
       duration = Value(duration),
       trainingId = Value(trainingId),
       targetWeight = Value(targetWeight),
       index = Value(index);
  static Insertable<RepTemplate> custom({
    Expression<String>? id,
    Expression<bool>? isRest,
    Expression<bool>? rightHand,
    Expression<int>? duration,
    Expression<String>? trainingId,
    Expression<double>? targetWeight,
    Expression<int>? index,
    Expression<int>? gripPosition,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isRest != null) 'is_rest': isRest,
      if (rightHand != null) 'right_hand': rightHand,
      if (duration != null) 'duration': duration,
      if (trainingId != null) 'training_id': trainingId,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (index != null) 'index': index,
      if (gripPosition != null) 'grip_position': gripPosition,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepTemplatesCompanion copyWith({
    Value<String>? id,
    Value<bool>? isRest,
    Value<bool>? rightHand,
    Value<int>? duration,
    Value<String>? trainingId,
    Value<double>? targetWeight,
    Value<int>? index,
    Value<int>? gripPosition,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RepTemplatesCompanion(
      id: id ?? this.id,
      isRest: isRest ?? this.isRest,
      rightHand: rightHand ?? this.rightHand,
      duration: duration ?? this.duration,
      trainingId: trainingId ?? this.trainingId,
      targetWeight: targetWeight ?? this.targetWeight,
      index: index ?? this.index,
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
    if (isRest.present) {
      map['is_rest'] = Variable<bool>(isRest.value);
    }
    if (rightHand.present) {
      map['right_hand'] = Variable<bool>(rightHand.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (trainingId.present) {
      map['training_id'] = Variable<String>(trainingId.value);
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
    return (StringBuffer('RepTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('isRest: $isRest, ')
          ..write('rightHand: $rightHand, ')
          ..write('duration: $duration, ')
          ..write('trainingId: $trainingId, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('index: $index, ')
          ..write('gripPosition: $gripPosition, ')
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
  late final $RepeatersTable repeaters = $RepeatersTable(this);
  late final $TrainingsTable trainings = $TrainingsTable(this);
  late final $RepTemplatesTable repTemplates = $RepTemplatesTable(this);
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
    repeaters,
    trainings,
    repTemplates,
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
      Value<int> sessionType,
      Value<int> duration,
      Value<int?> repeaterSets,
      Value<int?> repeaterReps,
      Value<int?> repeaterWorkTime,
      Value<int?> repeaterRestTime,
      Value<int?> repeaterSetRest,
      Value<bool?> repeaterSplitHand,
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
      Value<int> sessionType,
      Value<int> duration,
      Value<int?> repeaterSets,
      Value<int?> repeaterReps,
      Value<int?> repeaterWorkTime,
      Value<int?> repeaterRestTime,
      Value<int?> repeaterSetRest,
      Value<bool?> repeaterSplitHand,
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

  ColumnFilters<int> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeaterSets => $composableBuilder(
    column: $table.repeaterSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeaterReps => $composableBuilder(
    column: $table.repeaterReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeaterWorkTime => $composableBuilder(
    column: $table.repeaterWorkTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeaterRestTime => $composableBuilder(
    column: $table.repeaterRestTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeaterSetRest => $composableBuilder(
    column: $table.repeaterSetRest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeaterSplitHand => $composableBuilder(
    column: $table.repeaterSplitHand,
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

  ColumnOrderings<int> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeaterSets => $composableBuilder(
    column: $table.repeaterSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeaterReps => $composableBuilder(
    column: $table.repeaterReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeaterWorkTime => $composableBuilder(
    column: $table.repeaterWorkTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeaterRestTime => $composableBuilder(
    column: $table.repeaterRestTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeaterSetRest => $composableBuilder(
    column: $table.repeaterSetRest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeaterSplitHand => $composableBuilder(
    column: $table.repeaterSplitHand,
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

  GeneratedColumn<int> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get repeaterSets => $composableBuilder(
    column: $table.repeaterSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeaterReps => $composableBuilder(
    column: $table.repeaterReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeaterWorkTime => $composableBuilder(
    column: $table.repeaterWorkTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeaterRestTime => $composableBuilder(
    column: $table.repeaterRestTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeaterSetRest => $composableBuilder(
    column: $table.repeaterSetRest,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get repeaterSplitHand => $composableBuilder(
    column: $table.repeaterSplitHand,
    builder: (column) => column,
  );

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
                Value<int> sessionType = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int?> repeaterSets = const Value.absent(),
                Value<int?> repeaterReps = const Value.absent(),
                Value<int?> repeaterWorkTime = const Value.absent(),
                Value<int?> repeaterRestTime = const Value.absent(),
                Value<int?> repeaterSetRest = const Value.absent(),
                Value<bool?> repeaterSplitHand = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                name: name,
                notes: notes,
                date: date,
                dataPath: dataPath,
                isAssessment: isAssessment,
                sessionType: sessionType,
                duration: duration,
                repeaterSets: repeaterSets,
                repeaterReps: repeaterReps,
                repeaterWorkTime: repeaterWorkTime,
                repeaterRestTime: repeaterRestTime,
                repeaterSetRest: repeaterSetRest,
                repeaterSplitHand: repeaterSplitHand,
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
                Value<int> sessionType = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int?> repeaterSets = const Value.absent(),
                Value<int?> repeaterReps = const Value.absent(),
                Value<int?> repeaterWorkTime = const Value.absent(),
                Value<int?> repeaterRestTime = const Value.absent(),
                Value<int?> repeaterSetRest = const Value.absent(),
                Value<bool?> repeaterSplitHand = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                name: name,
                notes: notes,
                date: date,
                dataPath: dataPath,
                isAssessment: isAssessment,
                sessionType: sessionType,
                duration: duration,
                repeaterSets: repeaterSets,
                repeaterReps: repeaterReps,
                repeaterWorkTime: repeaterWorkTime,
                repeaterRestTime: repeaterRestTime,
                repeaterSetRest: repeaterSetRest,
                repeaterSplitHand: repeaterSplitHand,
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
typedef $$RepeatersTableCreateCompanionBuilder =
    RepeatersCompanion Function({
      Value<String> id,
      required int sets,
      required int reps,
      required int worktime,
      required int resttime,
      required int setRest,
      Value<double?> targetWeigthRight,
      Value<double?> targetWeigthLeft,
      required bool splitHand,
      Value<int> gripPosition,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RepeatersTableUpdateCompanionBuilder =
    RepeatersCompanion Function({
      Value<String> id,
      Value<int> sets,
      Value<int> reps,
      Value<int> worktime,
      Value<int> resttime,
      Value<int> setRest,
      Value<double?> targetWeigthRight,
      Value<double?> targetWeigthLeft,
      Value<bool> splitHand,
      Value<int> gripPosition,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RepeatersTableFilterComposer
    extends Composer<_$AppDatabase, $RepeatersTable> {
  $$RepeatersTableFilterComposer({
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

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get worktime => $composableBuilder(
    column: $table.worktime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resttime => $composableBuilder(
    column: $table.resttime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setRest => $composableBuilder(
    column: $table.setRest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeigthRight => $composableBuilder(
    column: $table.targetWeigthRight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeigthLeft => $composableBuilder(
    column: $table.targetWeigthLeft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get splitHand => $composableBuilder(
    column: $table.splitHand,
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

class $$RepeatersTableOrderingComposer
    extends Composer<_$AppDatabase, $RepeatersTable> {
  $$RepeatersTableOrderingComposer({
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

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get worktime => $composableBuilder(
    column: $table.worktime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resttime => $composableBuilder(
    column: $table.resttime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setRest => $composableBuilder(
    column: $table.setRest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeigthRight => $composableBuilder(
    column: $table.targetWeigthRight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeigthLeft => $composableBuilder(
    column: $table.targetWeigthLeft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get splitHand => $composableBuilder(
    column: $table.splitHand,
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

class $$RepeatersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepeatersTable> {
  $$RepeatersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get worktime =>
      $composableBuilder(column: $table.worktime, builder: (column) => column);

  GeneratedColumn<int> get resttime =>
      $composableBuilder(column: $table.resttime, builder: (column) => column);

  GeneratedColumn<int> get setRest =>
      $composableBuilder(column: $table.setRest, builder: (column) => column);

  GeneratedColumn<double> get targetWeigthRight => $composableBuilder(
    column: $table.targetWeigthRight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeigthLeft => $composableBuilder(
    column: $table.targetWeigthLeft,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get splitHand =>
      $composableBuilder(column: $table.splitHand, builder: (column) => column);

  GeneratedColumn<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RepeatersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepeatersTable,
          Repeater,
          $$RepeatersTableFilterComposer,
          $$RepeatersTableOrderingComposer,
          $$RepeatersTableAnnotationComposer,
          $$RepeatersTableCreateCompanionBuilder,
          $$RepeatersTableUpdateCompanionBuilder,
          (Repeater, BaseReferences<_$AppDatabase, $RepeatersTable, Repeater>),
          Repeater,
          PrefetchHooks Function()
        > {
  $$RepeatersTableTableManager(_$AppDatabase db, $RepeatersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepeatersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepeatersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepeatersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> worktime = const Value.absent(),
                Value<int> resttime = const Value.absent(),
                Value<int> setRest = const Value.absent(),
                Value<double?> targetWeigthRight = const Value.absent(),
                Value<double?> targetWeigthLeft = const Value.absent(),
                Value<bool> splitHand = const Value.absent(),
                Value<int> gripPosition = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepeatersCompanion(
                id: id,
                sets: sets,
                reps: reps,
                worktime: worktime,
                resttime: resttime,
                setRest: setRest,
                targetWeigthRight: targetWeigthRight,
                targetWeigthLeft: targetWeigthLeft,
                splitHand: splitHand,
                gripPosition: gripPosition,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required int sets,
                required int reps,
                required int worktime,
                required int resttime,
                required int setRest,
                Value<double?> targetWeigthRight = const Value.absent(),
                Value<double?> targetWeigthLeft = const Value.absent(),
                required bool splitHand,
                Value<int> gripPosition = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepeatersCompanion.insert(
                id: id,
                sets: sets,
                reps: reps,
                worktime: worktime,
                resttime: resttime,
                setRest: setRest,
                targetWeigthRight: targetWeigthRight,
                targetWeigthLeft: targetWeigthLeft,
                splitHand: splitHand,
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

typedef $$RepeatersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepeatersTable,
      Repeater,
      $$RepeatersTableFilterComposer,
      $$RepeatersTableOrderingComposer,
      $$RepeatersTableAnnotationComposer,
      $$RepeatersTableCreateCompanionBuilder,
      $$RepeatersTableUpdateCompanionBuilder,
      (Repeater, BaseReferences<_$AppDatabase, $RepeatersTable, Repeater>),
      Repeater,
      PrefetchHooks Function()
    >;
typedef $$TrainingsTableCreateCompanionBuilder =
    TrainingsCompanion Function({
      Value<String> id,
      required String name,
      Value<String?> repeaterId,
      Value<bool> isBuiltin,
      Value<bool> isFavorite,
      Value<bool> isAssessment,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TrainingsTableUpdateCompanionBuilder =
    TrainingsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> repeaterId,
      Value<bool> isBuiltin,
      Value<bool> isFavorite,
      Value<bool> isAssessment,
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeaterId => $composableBuilder(
    column: $table.repeaterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAssessment => $composableBuilder(
    column: $table.isAssessment,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeaterId => $composableBuilder(
    column: $table.repeaterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAssessment => $composableBuilder(
    column: $table.isAssessment,
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get repeaterId => $composableBuilder(
    column: $table.repeaterId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAssessment => $composableBuilder(
    column: $table.isAssessment,
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
          Training,
          $$TrainingsTableFilterComposer,
          $$TrainingsTableOrderingComposer,
          $$TrainingsTableAnnotationComposer,
          $$TrainingsTableCreateCompanionBuilder,
          $$TrainingsTableUpdateCompanionBuilder,
          (Training, BaseReferences<_$AppDatabase, $TrainingsTable, Training>),
          Training,
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
                Value<String> name = const Value.absent(),
                Value<String?> repeaterId = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isAssessment = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingsCompanion(
                id: id,
                name: name,
                repeaterId: repeaterId,
                isBuiltin: isBuiltin,
                isFavorite: isFavorite,
                isAssessment: isAssessment,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<String?> repeaterId = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isAssessment = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingsCompanion.insert(
                id: id,
                name: name,
                repeaterId: repeaterId,
                isBuiltin: isBuiltin,
                isFavorite: isFavorite,
                isAssessment: isAssessment,
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
      Training,
      $$TrainingsTableFilterComposer,
      $$TrainingsTableOrderingComposer,
      $$TrainingsTableAnnotationComposer,
      $$TrainingsTableCreateCompanionBuilder,
      $$TrainingsTableUpdateCompanionBuilder,
      (Training, BaseReferences<_$AppDatabase, $TrainingsTable, Training>),
      Training,
      PrefetchHooks Function()
    >;
typedef $$RepTemplatesTableCreateCompanionBuilder =
    RepTemplatesCompanion Function({
      Value<String> id,
      required bool isRest,
      required bool rightHand,
      required int duration,
      required String trainingId,
      required double targetWeight,
      required int index,
      Value<int> gripPosition,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RepTemplatesTableUpdateCompanionBuilder =
    RepTemplatesCompanion Function({
      Value<String> id,
      Value<bool> isRest,
      Value<bool> rightHand,
      Value<int> duration,
      Value<String> trainingId,
      Value<double> targetWeight,
      Value<int> index,
      Value<int> gripPosition,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RepTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $RepTemplatesTable> {
  $$RepTemplatesTableFilterComposer({
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

  ColumnFilters<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RepTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RepTemplatesTable> {
  $$RepTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RepTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepTemplatesTable> {
  $$RepTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isRest =>
      $composableBuilder(column: $table.isRest, builder: (column) => column);

  GeneratedColumn<bool> get rightHand =>
      $composableBuilder(column: $table.rightHand, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => column,
  );

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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RepTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepTemplatesTable,
          RepTemplate,
          $$RepTemplatesTableFilterComposer,
          $$RepTemplatesTableOrderingComposer,
          $$RepTemplatesTableAnnotationComposer,
          $$RepTemplatesTableCreateCompanionBuilder,
          $$RepTemplatesTableUpdateCompanionBuilder,
          (
            RepTemplate,
            BaseReferences<_$AppDatabase, $RepTemplatesTable, RepTemplate>,
          ),
          RepTemplate,
          PrefetchHooks Function()
        > {
  $$RepTemplatesTableTableManager(_$AppDatabase db, $RepTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> isRest = const Value.absent(),
                Value<bool> rightHand = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String> trainingId = const Value.absent(),
                Value<double> targetWeight = const Value.absent(),
                Value<int> index = const Value.absent(),
                Value<int> gripPosition = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepTemplatesCompanion(
                id: id,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                trainingId: trainingId,
                targetWeight: targetWeight,
                index: index,
                gripPosition: gripPosition,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required bool isRest,
                required bool rightHand,
                required int duration,
                required String trainingId,
                required double targetWeight,
                required int index,
                Value<int> gripPosition = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepTemplatesCompanion.insert(
                id: id,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                trainingId: trainingId,
                targetWeight: targetWeight,
                index: index,
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

typedef $$RepTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepTemplatesTable,
      RepTemplate,
      $$RepTemplatesTableFilterComposer,
      $$RepTemplatesTableOrderingComposer,
      $$RepTemplatesTableAnnotationComposer,
      $$RepTemplatesTableCreateCompanionBuilder,
      $$RepTemplatesTableUpdateCompanionBuilder,
      (
        RepTemplate,
        BaseReferences<_$AppDatabase, $RepTemplatesTable, RepTemplate>,
      ),
      RepTemplate,
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
  $$RepeatersTableTableManager get repeaters =>
      $$RepeatersTableTableManager(_db, _db.repeaters);
  $$TrainingsTableTableManager get trainings =>
      $$TrainingsTableTableManager(_db, _db.trainings);
  $$RepTemplatesTableTableManager get repTemplates =>
      $$RepTemplatesTableTableManager(_db, _db.repTemplates);
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
