// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Sessions extends Table with TableInfo<Sessions, SessionsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Sessions(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<String> dataPath = GeneratedColumn<String>(
    'data_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> isAssessment = GeneratedColumn<int>(
    'is_assessment',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_assessment IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> sessionType = GeneratedColumn<int>(
    'session_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> repeaterSets = GeneratedColumn<int>(
    'repeater_sets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> repeaterReps = GeneratedColumn<int>(
    'repeater_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> repeaterWorkTime = GeneratedColumn<int>(
    'repeater_work_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> repeaterRestTime = GeneratedColumn<int>(
    'repeater_rest_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> repeaterSetRest = GeneratedColumn<int>(
    'repeater_set_rest',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> repeaterSplitHand = GeneratedColumn<int>(
    'repeater_split_hand',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL CHECK (repeater_split_hand IN (0, 1))',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      dataPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_path'],
      )!,
      isAssessment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}repeater_split_hand'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  Sessions createAlias(String alias) {
    return Sessions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SessionsData extends DataClass implements Insertable<SessionsData> {
  final int id;
  final String name;
  final String notes;
  final int date;
  final String dataPath;
  final int isAssessment;
  final int sessionType;
  final int duration;
  final int? repeaterSets;
  final int? repeaterReps;
  final int? repeaterWorkTime;
  final int? repeaterRestTime;
  final int? repeaterSetRest;
  final int? repeaterSplitHand;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const SessionsData({
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
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    map['date'] = Variable<int>(date);
    map['data_path'] = Variable<String>(dataPath);
    map['is_assessment'] = Variable<int>(isAssessment);
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
      map['repeater_split_hand'] = Variable<int>(repeaterSplitHand);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory SessionsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionsData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
      date: serializer.fromJson<int>(json['date']),
      dataPath: serializer.fromJson<String>(json['dataPath']),
      isAssessment: serializer.fromJson<int>(json['isAssessment']),
      sessionType: serializer.fromJson<int>(json['sessionType']),
      duration: serializer.fromJson<int>(json['duration']),
      repeaterSets: serializer.fromJson<int?>(json['repeaterSets']),
      repeaterReps: serializer.fromJson<int?>(json['repeaterReps']),
      repeaterWorkTime: serializer.fromJson<int?>(json['repeaterWorkTime']),
      repeaterRestTime: serializer.fromJson<int?>(json['repeaterRestTime']),
      repeaterSetRest: serializer.fromJson<int?>(json['repeaterSetRest']),
      repeaterSplitHand: serializer.fromJson<int?>(json['repeaterSplitHand']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
      'date': serializer.toJson<int>(date),
      'dataPath': serializer.toJson<String>(dataPath),
      'isAssessment': serializer.toJson<int>(isAssessment),
      'sessionType': serializer.toJson<int>(sessionType),
      'duration': serializer.toJson<int>(duration),
      'repeaterSets': serializer.toJson<int?>(repeaterSets),
      'repeaterReps': serializer.toJson<int?>(repeaterReps),
      'repeaterWorkTime': serializer.toJson<int?>(repeaterWorkTime),
      'repeaterRestTime': serializer.toJson<int?>(repeaterRestTime),
      'repeaterSetRest': serializer.toJson<int?>(repeaterSetRest),
      'repeaterSplitHand': serializer.toJson<int?>(repeaterSplitHand),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  SessionsData copyWith({
    int? id,
    String? name,
    String? notes,
    int? date,
    String? dataPath,
    int? isAssessment,
    int? sessionType,
    int? duration,
    Value<int?> repeaterSets = const Value.absent(),
    Value<int?> repeaterReps = const Value.absent(),
    Value<int?> repeaterWorkTime = const Value.absent(),
    Value<int?> repeaterRestTime = const Value.absent(),
    Value<int?> repeaterSetRest = const Value.absent(),
    Value<int?> repeaterSplitHand = const Value.absent(),
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => SessionsData(
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
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  SessionsData copyWithCompanion(SessionsCompanion data) {
    return SessionsData(
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
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionsData(')
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
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
    deletedAt,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionsData &&
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
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class SessionsCompanion extends UpdateCompanion<SessionsData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> notes;
  final Value<int> date;
  final Value<String> dataPath;
  final Value<int> isAssessment;
  final Value<int> sessionType;
  final Value<int> duration;
  final Value<int?> repeaterSets;
  final Value<int?> repeaterReps;
  final Value<int?> repeaterWorkTime;
  final Value<int?> repeaterRestTime;
  final Value<int?> repeaterSetRest;
  final Value<int?> repeaterSplitHand;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
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
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
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
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : name = Value(name),
       notes = Value(notes),
       dataPath = Value(dataPath),
       remoteId = Value(remoteId);
  static Insertable<SessionsData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<int>? date,
    Expression<String>? dataPath,
    Expression<int>? isAssessment,
    Expression<int>? sessionType,
    Expression<int>? duration,
    Expression<int>? repeaterSets,
    Expression<int>? repeaterReps,
    Expression<int>? repeaterWorkTime,
    Expression<int>? repeaterRestTime,
    Expression<int>? repeaterSetRest,
    Expression<int>? repeaterSplitHand,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
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
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? notes,
    Value<int>? date,
    Value<String>? dataPath,
    Value<int>? isAssessment,
    Value<int>? sessionType,
    Value<int>? duration,
    Value<int?>? repeaterSets,
    Value<int?>? repeaterReps,
    Value<int?>? repeaterWorkTime,
    Value<int?>? repeaterRestTime,
    Value<int?>? repeaterSetRest,
    Value<int?>? repeaterSplitHand,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
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
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (dataPath.present) {
      map['data_path'] = Variable<String>(dataPath.value);
    }
    if (isAssessment.present) {
      map['is_assessment'] = Variable<int>(isAssessment.value);
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
      map['repeater_split_hand'] = Variable<int>(repeaterSplitHand.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class Assessments extends Table with TableInfo<Assessments, AssessmentsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Assessments(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<double> rightValue = GeneratedColumn<double>(
    'right_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<double> leftValue = GeneratedColumn<double>(
    'left_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sessions(id)',
  );
  late final GeneratedColumn<int> gripPosition = GeneratedColumn<int>(
    'grip_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessments';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      gripPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grip_position'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  Assessments createAlias(String alias) {
    return Assessments(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AssessmentsData extends DataClass implements Insertable<AssessmentsData> {
  final int id;
  final int type;
  final double? rightValue;
  final double? leftValue;
  final int sessionId;
  final int? gripPosition;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const AssessmentsData({
    required this.id,
    required this.type,
    this.rightValue,
    this.leftValue,
    required this.sessionId,
    this.gripPosition,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || rightValue != null) {
      map['right_value'] = Variable<double>(rightValue);
    }
    if (!nullToAbsent || leftValue != null) {
      map['left_value'] = Variable<double>(leftValue);
    }
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || gripPosition != null) {
      map['grip_position'] = Variable<int>(gripPosition);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory AssessmentsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentsData(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      rightValue: serializer.fromJson<double?>(json['rightValue']),
      leftValue: serializer.fromJson<double?>(json['leftValue']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      gripPosition: serializer.fromJson<int?>(json['gripPosition']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<int>(type),
      'rightValue': serializer.toJson<double?>(rightValue),
      'leftValue': serializer.toJson<double?>(leftValue),
      'sessionId': serializer.toJson<int>(sessionId),
      'gripPosition': serializer.toJson<int?>(gripPosition),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  AssessmentsData copyWith({
    int? id,
    int? type,
    Value<double?> rightValue = const Value.absent(),
    Value<double?> leftValue = const Value.absent(),
    int? sessionId,
    Value<int?> gripPosition = const Value.absent(),
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => AssessmentsData(
    id: id ?? this.id,
    type: type ?? this.type,
    rightValue: rightValue.present ? rightValue.value : this.rightValue,
    leftValue: leftValue.present ? leftValue.value : this.leftValue,
    sessionId: sessionId ?? this.sessionId,
    gripPosition: gripPosition.present ? gripPosition.value : this.gripPosition,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  AssessmentsData copyWithCompanion(AssessmentsCompanion data) {
    return AssessmentsData(
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
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentsData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rightValue: $rightValue, ')
          ..write('leftValue: $leftValue, ')
          ..write('sessionId: $sessionId, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
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
    deletedAt,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentsData &&
          other.id == this.id &&
          other.type == this.type &&
          other.rightValue == this.rightValue &&
          other.leftValue == this.leftValue &&
          other.sessionId == this.sessionId &&
          other.gripPosition == this.gripPosition &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class AssessmentsCompanion extends UpdateCompanion<AssessmentsData> {
  final Value<int> id;
  final Value<int> type;
  final Value<double?> rightValue;
  final Value<double?> leftValue;
  final Value<int> sessionId;
  final Value<int?> gripPosition;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    this.id = const Value.absent(),
    required int type,
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    required int sessionId,
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : type = Value(type),
       sessionId = Value(sessionId),
       remoteId = Value(remoteId);
  static Insertable<AssessmentsData> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<double>? rightValue,
    Expression<double>? leftValue,
    Expression<int>? sessionId,
    Expression<int>? gripPosition,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (rightValue != null) 'right_value': rightValue,
      if (leftValue != null) 'left_value': leftValue,
      if (sessionId != null) 'session_id': sessionId,
      if (gripPosition != null) 'grip_position': gripPosition,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  AssessmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? type,
    Value<double?>? rightValue,
    Value<double?>? leftValue,
    Value<int>? sessionId,
    Value<int?>? gripPosition,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      rightValue: rightValue ?? this.rightValue,
      leftValue: leftValue ?? this.leftValue,
      sessionId: sessionId ?? this.sessionId,
      gripPosition: gripPosition ?? this.gripPosition,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (gripPosition.present) {
      map['grip_position'] = Variable<int>(gripPosition.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class Repeaters extends Table with TableInfo<Repeaters, RepeatersData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Repeaters(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> worktime = GeneratedColumn<int>(
    'worktime',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> resttime = GeneratedColumn<int>(
    'resttime',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> setRest = GeneratedColumn<int>(
    'set_rest',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<double> targetWeigthRight =
      GeneratedColumn<double>(
        'target_weigth_right',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        $customConstraints: 'NULL',
      );
  late final GeneratedColumn<double> targetWeigthLeft = GeneratedColumn<double>(
    'target_weigth_left',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> splitHand = GeneratedColumn<int>(
    'split_hand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (split_hand IN (0, 1))',
  );
  late final GeneratedColumn<int> gripPosition = GeneratedColumn<int>(
    'grip_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repeaters';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepeatersData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepeatersData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}split_hand'],
      )!,
      gripPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grip_position'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  Repeaters createAlias(String alias) {
    return Repeaters(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class RepeatersData extends DataClass implements Insertable<RepeatersData> {
  final int id;
  final int sets;
  final int reps;
  final int worktime;
  final int resttime;
  final int setRest;
  final double? targetWeigthRight;
  final double? targetWeigthLeft;
  final int splitHand;
  final int gripPosition;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const RepeatersData({
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
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
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
    map['split_hand'] = Variable<int>(splitHand);
    map['grip_position'] = Variable<int>(gripPosition);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory RepeatersData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepeatersData(
      id: serializer.fromJson<int>(json['id']),
      sets: serializer.fromJson<int>(json['sets']),
      reps: serializer.fromJson<int>(json['reps']),
      worktime: serializer.fromJson<int>(json['worktime']),
      resttime: serializer.fromJson<int>(json['resttime']),
      setRest: serializer.fromJson<int>(json['setRest']),
      targetWeigthRight: serializer.fromJson<double?>(
        json['targetWeigthRight'],
      ),
      targetWeigthLeft: serializer.fromJson<double?>(json['targetWeigthLeft']),
      splitHand: serializer.fromJson<int>(json['splitHand']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sets': serializer.toJson<int>(sets),
      'reps': serializer.toJson<int>(reps),
      'worktime': serializer.toJson<int>(worktime),
      'resttime': serializer.toJson<int>(resttime),
      'setRest': serializer.toJson<int>(setRest),
      'targetWeigthRight': serializer.toJson<double?>(targetWeigthRight),
      'targetWeigthLeft': serializer.toJson<double?>(targetWeigthLeft),
      'splitHand': serializer.toJson<int>(splitHand),
      'gripPosition': serializer.toJson<int>(gripPosition),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  RepeatersData copyWith({
    int? id,
    int? sets,
    int? reps,
    int? worktime,
    int? resttime,
    int? setRest,
    Value<double?> targetWeigthRight = const Value.absent(),
    Value<double?> targetWeigthLeft = const Value.absent(),
    int? splitHand,
    int? gripPosition,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => RepeatersData(
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
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  RepeatersData copyWithCompanion(RepeatersCompanion data) {
    return RepeatersData(
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
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepeatersData(')
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
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
    deletedAt,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepeatersData &&
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
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class RepeatersCompanion extends UpdateCompanion<RepeatersData> {
  final Value<int> id;
  final Value<int> sets;
  final Value<int> reps;
  final Value<int> worktime;
  final Value<int> resttime;
  final Value<int> setRest;
  final Value<double?> targetWeigthRight;
  final Value<double?> targetWeigthLeft;
  final Value<int> splitHand;
  final Value<int> gripPosition;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
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
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
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
    required int splitHand,
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : sets = Value(sets),
       reps = Value(reps),
       worktime = Value(worktime),
       resttime = Value(resttime),
       setRest = Value(setRest),
       splitHand = Value(splitHand),
       remoteId = Value(remoteId);
  static Insertable<RepeatersData> custom({
    Expression<int>? id,
    Expression<int>? sets,
    Expression<int>? reps,
    Expression<int>? worktime,
    Expression<int>? resttime,
    Expression<int>? setRest,
    Expression<double>? targetWeigthRight,
    Expression<double>? targetWeigthLeft,
    Expression<int>? splitHand,
    Expression<int>? gripPosition,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
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
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  RepeatersCompanion copyWith({
    Value<int>? id,
    Value<int>? sets,
    Value<int>? reps,
    Value<int>? worktime,
    Value<int>? resttime,
    Value<int>? setRest,
    Value<double?>? targetWeigthRight,
    Value<double?>? targetWeigthLeft,
    Value<int>? splitHand,
    Value<int>? gripPosition,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
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
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
      map['split_hand'] = Variable<int>(splitHand.value);
    }
    if (gripPosition.present) {
      map['grip_position'] = Variable<int>(gripPosition.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class Trainings extends Table with TableInfo<Trainings, TrainingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Trainings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> repeaterId = GeneratedColumn<int>(
    'repeater_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL REFERENCES repeaters(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<int> isBuiltin = GeneratedColumn<int>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_builtin IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> isFavorite = GeneratedColumn<int>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_favorite IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> isAssessment = GeneratedColumn<int>(
    'is_assessment',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_assessment IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trainings';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      repeaterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeater_id'],
      ),
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_builtin'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_favorite'],
      )!,
      isAssessment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_assessment'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  Trainings createAlias(String alias) {
    return Trainings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TrainingsData extends DataClass implements Insertable<TrainingsData> {
  final int id;
  final String name;
  final int? repeaterId;
  final int isBuiltin;
  final int isFavorite;
  final int isAssessment;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const TrainingsData({
    required this.id,
    required this.name,
    this.repeaterId,
    required this.isBuiltin,
    required this.isFavorite,
    required this.isAssessment,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || repeaterId != null) {
      map['repeater_id'] = Variable<int>(repeaterId);
    }
    map['is_builtin'] = Variable<int>(isBuiltin);
    map['is_favorite'] = Variable<int>(isFavorite);
    map['is_assessment'] = Variable<int>(isAssessment);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory TrainingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingsData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      repeaterId: serializer.fromJson<int?>(json['repeaterId']),
      isBuiltin: serializer.fromJson<int>(json['isBuiltin']),
      isFavorite: serializer.fromJson<int>(json['isFavorite']),
      isAssessment: serializer.fromJson<int>(json['isAssessment']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'repeaterId': serializer.toJson<int?>(repeaterId),
      'isBuiltin': serializer.toJson<int>(isBuiltin),
      'isFavorite': serializer.toJson<int>(isFavorite),
      'isAssessment': serializer.toJson<int>(isAssessment),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  TrainingsData copyWith({
    int? id,
    String? name,
    Value<int?> repeaterId = const Value.absent(),
    int? isBuiltin,
    int? isFavorite,
    int? isAssessment,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => TrainingsData(
    id: id ?? this.id,
    name: name ?? this.name,
    repeaterId: repeaterId.present ? repeaterId.value : this.repeaterId,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    isFavorite: isFavorite ?? this.isFavorite,
    isAssessment: isAssessment ?? this.isAssessment,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  TrainingsData copyWithCompanion(TrainingsCompanion data) {
    return TrainingsData(
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
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingsData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('repeaterId: $repeaterId, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isAssessment: $isAssessment, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
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
    deletedAt,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.repeaterId == this.repeaterId &&
          other.isBuiltin == this.isBuiltin &&
          other.isFavorite == this.isFavorite &&
          other.isAssessment == this.isAssessment &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class TrainingsCompanion extends UpdateCompanion<TrainingsData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> repeaterId;
  final Value<int> isBuiltin;
  final Value<int> isFavorite;
  final Value<int> isAssessment;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
  const TrainingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.repeaterId = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isAssessment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  TrainingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.repeaterId = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isAssessment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : name = Value(name),
       remoteId = Value(remoteId);
  static Insertable<TrainingsData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? repeaterId,
    Expression<int>? isBuiltin,
    Expression<int>? isFavorite,
    Expression<int>? isAssessment,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (repeaterId != null) 'repeater_id': repeaterId,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isAssessment != null) 'is_assessment': isAssessment,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  TrainingsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? repeaterId,
    Value<int>? isBuiltin,
    Value<int>? isFavorite,
    Value<int>? isAssessment,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
  }) {
    return TrainingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      repeaterId: repeaterId ?? this.repeaterId,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      isFavorite: isFavorite ?? this.isFavorite,
      isAssessment: isAssessment ?? this.isAssessment,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (repeaterId.present) {
      map['repeater_id'] = Variable<int>(repeaterId.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<int>(isBuiltin.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<int>(isFavorite.value);
    }
    if (isAssessment.present) {
      map['is_assessment'] = Variable<int>(isAssessment.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class RepTemplates extends Table
    with TableInfo<RepTemplates, RepTemplatesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RepTemplates(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<int> isRest = GeneratedColumn<int>(
    'is_rest',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (is_rest IN (0, 1))',
  );
  late final GeneratedColumn<int> rightHand = GeneratedColumn<int>(
    'right_hand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (right_hand IN (0, 1))',
  );
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> trainingId = GeneratedColumn<int>(
    'training_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES trainings(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<double> targetWeight = GeneratedColumn<double>(
    'target_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
    'index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> gripPosition = GeneratedColumn<int>(
    'grip_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rep_templates';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepTemplatesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepTemplatesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      isRest: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_rest'],
      )!,
      rightHand: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}right_hand'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      trainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  RepTemplates createAlias(String alias) {
    return RepTemplates(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class RepTemplatesData extends DataClass
    implements Insertable<RepTemplatesData> {
  final int id;
  final int isRest;
  final int rightHand;
  final int duration;
  final int trainingId;
  final double targetWeight;
  final int index;
  final int gripPosition;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const RepTemplatesData({
    required this.id,
    required this.isRest,
    required this.rightHand,
    required this.duration,
    required this.trainingId,
    required this.targetWeight,
    required this.index,
    required this.gripPosition,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['is_rest'] = Variable<int>(isRest);
    map['right_hand'] = Variable<int>(rightHand);
    map['duration'] = Variable<int>(duration);
    map['training_id'] = Variable<int>(trainingId);
    map['target_weight'] = Variable<double>(targetWeight);
    map['index'] = Variable<int>(index);
    map['grip_position'] = Variable<int>(gripPosition);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory RepTemplatesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepTemplatesData(
      id: serializer.fromJson<int>(json['id']),
      isRest: serializer.fromJson<int>(json['isRest']),
      rightHand: serializer.fromJson<int>(json['rightHand']),
      duration: serializer.fromJson<int>(json['duration']),
      trainingId: serializer.fromJson<int>(json['trainingId']),
      targetWeight: serializer.fromJson<double>(json['targetWeight']),
      index: serializer.fromJson<int>(json['index']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isRest': serializer.toJson<int>(isRest),
      'rightHand': serializer.toJson<int>(rightHand),
      'duration': serializer.toJson<int>(duration),
      'trainingId': serializer.toJson<int>(trainingId),
      'targetWeight': serializer.toJson<double>(targetWeight),
      'index': serializer.toJson<int>(index),
      'gripPosition': serializer.toJson<int>(gripPosition),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  RepTemplatesData copyWith({
    int? id,
    int? isRest,
    int? rightHand,
    int? duration,
    int? trainingId,
    double? targetWeight,
    int? index,
    int? gripPosition,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => RepTemplatesData(
    id: id ?? this.id,
    isRest: isRest ?? this.isRest,
    rightHand: rightHand ?? this.rightHand,
    duration: duration ?? this.duration,
    trainingId: trainingId ?? this.trainingId,
    targetWeight: targetWeight ?? this.targetWeight,
    index: index ?? this.index,
    gripPosition: gripPosition ?? this.gripPosition,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  RepTemplatesData copyWithCompanion(RepTemplatesCompanion data) {
    return RepTemplatesData(
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
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepTemplatesData(')
          ..write('id: $id, ')
          ..write('isRest: $isRest, ')
          ..write('rightHand: $rightHand, ')
          ..write('duration: $duration, ')
          ..write('trainingId: $trainingId, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('index: $index, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
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
    deletedAt,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepTemplatesData &&
          other.id == this.id &&
          other.isRest == this.isRest &&
          other.rightHand == this.rightHand &&
          other.duration == this.duration &&
          other.trainingId == this.trainingId &&
          other.targetWeight == this.targetWeight &&
          other.index == this.index &&
          other.gripPosition == this.gripPosition &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class RepTemplatesCompanion extends UpdateCompanion<RepTemplatesData> {
  final Value<int> id;
  final Value<int> isRest;
  final Value<int> rightHand;
  final Value<int> duration;
  final Value<int> trainingId;
  final Value<double> targetWeight;
  final Value<int> index;
  final Value<int> gripPosition;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
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
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  RepTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required int isRest,
    required int rightHand,
    required int duration,
    required int trainingId,
    required double targetWeight,
    required int index,
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : isRest = Value(isRest),
       rightHand = Value(rightHand),
       duration = Value(duration),
       trainingId = Value(trainingId),
       targetWeight = Value(targetWeight),
       index = Value(index),
       remoteId = Value(remoteId);
  static Insertable<RepTemplatesData> custom({
    Expression<int>? id,
    Expression<int>? isRest,
    Expression<int>? rightHand,
    Expression<int>? duration,
    Expression<int>? trainingId,
    Expression<double>? targetWeight,
    Expression<int>? index,
    Expression<int>? gripPosition,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
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
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  RepTemplatesCompanion copyWith({
    Value<int>? id,
    Value<int>? isRest,
    Value<int>? rightHand,
    Value<int>? duration,
    Value<int>? trainingId,
    Value<double>? targetWeight,
    Value<int>? index,
    Value<int>? gripPosition,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
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
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (isRest.present) {
      map['is_rest'] = Variable<int>(isRest.value);
    }
    if (rightHand.present) {
      map['right_hand'] = Variable<int>(rightHand.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (trainingId.present) {
      map['training_id'] = Variable<int>(trainingId.value);
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
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class RepDatas extends Table with TableInfo<RepDatas, RepDatasData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RepDatas(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<double> averageWeight = GeneratedColumn<double>(
    'average_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES sessions(id)',
  );
  late final GeneratedColumn<int> isRest = GeneratedColumn<int>(
    'is_rest',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (is_rest IN (0, 1))',
  );
  late final GeneratedColumn<int> rightHand = GeneratedColumn<int>(
    'right_hand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (right_hand IN (0, 1))',
  );
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<double> targetWeight = GeneratedColumn<double>(
    'target_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
    'index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> gripPosition = GeneratedColumn<int>(
    'grip_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rep_datas';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepDatasData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepDatasData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      averageWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_weight'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      isRest: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_rest'],
      )!,
      rightHand: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  RepDatas createAlias(String alias) {
    return RepDatas(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class RepDatasData extends DataClass implements Insertable<RepDatasData> {
  final int id;
  final double averageWeight;
  final int sessionId;
  final int isRest;
  final int rightHand;
  final int duration;
  final double targetWeight;
  final int index;
  final int gripPosition;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const RepDatasData({
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
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['average_weight'] = Variable<double>(averageWeight);
    map['session_id'] = Variable<int>(sessionId);
    map['is_rest'] = Variable<int>(isRest);
    map['right_hand'] = Variable<int>(rightHand);
    map['duration'] = Variable<int>(duration);
    map['target_weight'] = Variable<double>(targetWeight);
    map['index'] = Variable<int>(index);
    map['grip_position'] = Variable<int>(gripPosition);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory RepDatasData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepDatasData(
      id: serializer.fromJson<int>(json['id']),
      averageWeight: serializer.fromJson<double>(json['averageWeight']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      isRest: serializer.fromJson<int>(json['isRest']),
      rightHand: serializer.fromJson<int>(json['rightHand']),
      duration: serializer.fromJson<int>(json['duration']),
      targetWeight: serializer.fromJson<double>(json['targetWeight']),
      index: serializer.fromJson<int>(json['index']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'averageWeight': serializer.toJson<double>(averageWeight),
      'sessionId': serializer.toJson<int>(sessionId),
      'isRest': serializer.toJson<int>(isRest),
      'rightHand': serializer.toJson<int>(rightHand),
      'duration': serializer.toJson<int>(duration),
      'targetWeight': serializer.toJson<double>(targetWeight),
      'index': serializer.toJson<int>(index),
      'gripPosition': serializer.toJson<int>(gripPosition),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  RepDatasData copyWith({
    int? id,
    double? averageWeight,
    int? sessionId,
    int? isRest,
    int? rightHand,
    int? duration,
    double? targetWeight,
    int? index,
    int? gripPosition,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => RepDatasData(
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
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  RepDatasData copyWithCompanion(RepDatasCompanion data) {
    return RepDatasData(
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
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepDatasData(')
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
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
    deletedAt,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepDatasData &&
          other.id == this.id &&
          other.averageWeight == this.averageWeight &&
          other.sessionId == this.sessionId &&
          other.isRest == this.isRest &&
          other.rightHand == this.rightHand &&
          other.duration == this.duration &&
          other.targetWeight == this.targetWeight &&
          other.index == this.index &&
          other.gripPosition == this.gripPosition &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class RepDatasCompanion extends UpdateCompanion<RepDatasData> {
  final Value<int> id;
  final Value<double> averageWeight;
  final Value<int> sessionId;
  final Value<int> isRest;
  final Value<int> rightHand;
  final Value<int> duration;
  final Value<double> targetWeight;
  final Value<int> index;
  final Value<int> gripPosition;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
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
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  RepDatasCompanion.insert({
    this.id = const Value.absent(),
    required double averageWeight,
    required int sessionId,
    required int isRest,
    required int rightHand,
    required int duration,
    required double targetWeight,
    required int index,
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : averageWeight = Value(averageWeight),
       sessionId = Value(sessionId),
       isRest = Value(isRest),
       rightHand = Value(rightHand),
       duration = Value(duration),
       targetWeight = Value(targetWeight),
       index = Value(index),
       remoteId = Value(remoteId);
  static Insertable<RepDatasData> custom({
    Expression<int>? id,
    Expression<double>? averageWeight,
    Expression<int>? sessionId,
    Expression<int>? isRest,
    Expression<int>? rightHand,
    Expression<int>? duration,
    Expression<double>? targetWeight,
    Expression<int>? index,
    Expression<int>? gripPosition,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
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
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  RepDatasCompanion copyWith({
    Value<int>? id,
    Value<double>? averageWeight,
    Value<int>? sessionId,
    Value<int>? isRest,
    Value<int>? rightHand,
    Value<int>? duration,
    Value<double>? targetWeight,
    Value<int>? index,
    Value<int>? gripPosition,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
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
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (averageWeight.present) {
      map['average_weight'] = Variable<double>(averageWeight.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (isRest.present) {
      map['is_rest'] = Variable<int>(isRest.value);
    }
    if (rightHand.present) {
      map['right_hand'] = Variable<int>(rightHand.value);
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
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class SensorConfigs extends Table
    with TableInfo<SensorConfigs, SensorConfigsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SensorConfigs(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
    'index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<double> tare = GeneratedColumn<double>(
    'tare',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<double> coef = GeneratedColumn<double>(
    'coef',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    index,
    tare,
    coef,
    updatedAt,
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_configs';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorConfigsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorConfigsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  SensorConfigs createAlias(String alias) {
    return SensorConfigs(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SensorConfigsData extends DataClass
    implements Insertable<SensorConfigsData> {
  final int id;
  final String name;
  final int index;
  final double tare;
  final double coef;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const SensorConfigsData({
    required this.id,
    required this.name,
    required this.index,
    required this.tare,
    required this.coef,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['index'] = Variable<int>(index);
    map['tare'] = Variable<double>(tare);
    map['coef'] = Variable<double>(coef);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory SensorConfigsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorConfigsData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      index: serializer.fromJson<int>(json['index']),
      tare: serializer.fromJson<double>(json['tare']),
      coef: serializer.fromJson<double>(json['coef']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'index': serializer.toJson<int>(index),
      'tare': serializer.toJson<double>(tare),
      'coef': serializer.toJson<double>(coef),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  SensorConfigsData copyWith({
    int? id,
    String? name,
    int? index,
    double? tare,
    double? coef,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => SensorConfigsData(
    id: id ?? this.id,
    name: name ?? this.name,
    index: index ?? this.index,
    tare: tare ?? this.tare,
    coef: coef ?? this.coef,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  SensorConfigsData copyWithCompanion(SensorConfigsCompanion data) {
    return SensorConfigsData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      index: data.index.present ? data.index.value : this.index,
      tare: data.tare.present ? data.tare.value : this.tare,
      coef: data.coef.present ? data.coef.value : this.coef,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorConfigsData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('index: $index, ')
          ..write('tare: $tare, ')
          ..write('coef: $coef, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    index,
    tare,
    coef,
    updatedAt,
    deletedAt,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorConfigsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.index == this.index &&
          other.tare == this.tare &&
          other.coef == this.coef &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class SensorConfigsCompanion extends UpdateCompanion<SensorConfigsData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> index;
  final Value<double> tare;
  final Value<double> coef;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
  const SensorConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.index = const Value.absent(),
    this.tare = const Value.absent(),
    this.coef = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  SensorConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int index,
    required double tare,
    required double coef,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : name = Value(name),
       index = Value(index),
       tare = Value(tare),
       coef = Value(coef),
       remoteId = Value(remoteId);
  static Insertable<SensorConfigsData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? index,
    Expression<double>? tare,
    Expression<double>? coef,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (index != null) 'index': index,
      if (tare != null) 'tare': tare,
      if (coef != null) 'coef': coef,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  SensorConfigsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? index,
    Value<double>? tare,
    Value<double>? coef,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
  }) {
    return SensorConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      index: index ?? this.index,
      tare: tare ?? this.tare,
      coef: coef ?? this.coef,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class BuiltinTrainingWeights extends Table
    with TableInfo<BuiltinTrainingWeights, BuiltinTrainingWeightsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BuiltinTrainingWeights(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<int> builtinTrainingId = GeneratedColumn<int>(
    'builtin_training_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES trainings(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<double> customWeightRight =
      GeneratedColumn<double>(
        'custom_weight_right',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        $customConstraints: 'NULL',
      );
  late final GeneratedColumn<double> customWeightLeft = GeneratedColumn<double>(
    'custom_weight_left',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    builtinTrainingId,
    customWeightRight,
    customWeightLeft,
    updatedAt,
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'builtin_training_weights';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuiltinTrainingWeightsData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuiltinTrainingWeightsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      builtinTrainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  BuiltinTrainingWeights createAlias(String alias) {
    return BuiltinTrainingWeights(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class BuiltinTrainingWeightsData extends DataClass
    implements Insertable<BuiltinTrainingWeightsData> {
  final int id;
  final int builtinTrainingId;
  final double? customWeightRight;
  final double? customWeightLeft;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const BuiltinTrainingWeightsData({
    required this.id,
    required this.builtinTrainingId,
    this.customWeightRight,
    this.customWeightLeft,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['builtin_training_id'] = Variable<int>(builtinTrainingId);
    if (!nullToAbsent || customWeightRight != null) {
      map['custom_weight_right'] = Variable<double>(customWeightRight);
    }
    if (!nullToAbsent || customWeightLeft != null) {
      map['custom_weight_left'] = Variable<double>(customWeightLeft);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
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
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory BuiltinTrainingWeightsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuiltinTrainingWeightsData(
      id: serializer.fromJson<int>(json['id']),
      builtinTrainingId: serializer.fromJson<int>(json['builtinTrainingId']),
      customWeightRight: serializer.fromJson<double?>(
        json['customWeightRight'],
      ),
      customWeightLeft: serializer.fromJson<double?>(json['customWeightLeft']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'builtinTrainingId': serializer.toJson<int>(builtinTrainingId),
      'customWeightRight': serializer.toJson<double?>(customWeightRight),
      'customWeightLeft': serializer.toJson<double?>(customWeightLeft),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  BuiltinTrainingWeightsData copyWith({
    int? id,
    int? builtinTrainingId,
    Value<double?> customWeightRight = const Value.absent(),
    Value<double?> customWeightLeft = const Value.absent(),
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => BuiltinTrainingWeightsData(
    id: id ?? this.id,
    builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
    customWeightRight: customWeightRight.present
        ? customWeightRight.value
        : this.customWeightRight,
    customWeightLeft: customWeightLeft.present
        ? customWeightLeft.value
        : this.customWeightLeft,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  BuiltinTrainingWeightsData copyWithCompanion(
    BuiltinTrainingWeightsCompanion data,
  ) {
    return BuiltinTrainingWeightsData(
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
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinTrainingWeightsData(')
          ..write('id: $id, ')
          ..write('builtinTrainingId: $builtinTrainingId, ')
          ..write('customWeightRight: $customWeightRight, ')
          ..write('customWeightLeft: $customWeightLeft, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
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
    deletedAt,
    dirty,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuiltinTrainingWeightsData &&
          other.id == this.id &&
          other.builtinTrainingId == this.builtinTrainingId &&
          other.customWeightRight == this.customWeightRight &&
          other.customWeightLeft == this.customWeightLeft &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class BuiltinTrainingWeightsCompanion
    extends UpdateCompanion<BuiltinTrainingWeightsData> {
  final Value<int> id;
  final Value<int> builtinTrainingId;
  final Value<double?> customWeightRight;
  final Value<double?> customWeightLeft;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
  const BuiltinTrainingWeightsCompanion({
    this.id = const Value.absent(),
    this.builtinTrainingId = const Value.absent(),
    this.customWeightRight = const Value.absent(),
    this.customWeightLeft = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  BuiltinTrainingWeightsCompanion.insert({
    this.id = const Value.absent(),
    required int builtinTrainingId,
    this.customWeightRight = const Value.absent(),
    this.customWeightLeft = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : builtinTrainingId = Value(builtinTrainingId),
       remoteId = Value(remoteId);
  static Insertable<BuiltinTrainingWeightsData> custom({
    Expression<int>? id,
    Expression<int>? builtinTrainingId,
    Expression<double>? customWeightRight,
    Expression<double>? customWeightLeft,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (builtinTrainingId != null) 'builtin_training_id': builtinTrainingId,
      if (customWeightRight != null) 'custom_weight_right': customWeightRight,
      if (customWeightLeft != null) 'custom_weight_left': customWeightLeft,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  BuiltinTrainingWeightsCompanion copyWith({
    Value<int>? id,
    Value<int>? builtinTrainingId,
    Value<double?>? customWeightRight,
    Value<double?>? customWeightLeft,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
  }) {
    return BuiltinTrainingWeightsCompanion(
      id: id ?? this.id,
      builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
      customWeightRight: customWeightRight ?? this.customWeightRight,
      customWeightLeft: customWeightLeft ?? this.customWeightLeft,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (builtinTrainingId.present) {
      map['builtin_training_id'] = Variable<int>(builtinTrainingId.value);
    }
    if (customWeightRight.present) {
      map['custom_weight_right'] = Variable<double>(customWeightRight.value);
    }
    if (customWeightLeft.present) {
      map['custom_weight_left'] = Variable<double>(customWeightLeft.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class PinnedBuiltinTrainings extends Table
    with TableInfo<PinnedBuiltinTrainings, PinnedBuiltinTrainingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PinnedBuiltinTrainings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> builtinTrainingId = GeneratedColumn<int>(
    'builtin_training_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> dirty = GeneratedColumn<int>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    builtinTrainingId,
    updatedAt,
    deletedAt,
    dirty,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pinned_builtin_trainings';
  @override
  Set<GeneratedColumn> get $primaryKey => {builtinTrainingId};
  @override
  PinnedBuiltinTrainingsData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinnedBuiltinTrainingsData(
      builtinTrainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}builtin_training_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dirty'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
    );
  }

  @override
  PinnedBuiltinTrainings createAlias(String alias) {
    return PinnedBuiltinTrainings(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(builtin_training_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class PinnedBuiltinTrainingsData extends DataClass
    implements Insertable<PinnedBuiltinTrainingsData> {
  final int builtinTrainingId;
  final int updatedAt;
  final int? deletedAt;
  final int dirty;
  final String remoteId;
  const PinnedBuiltinTrainingsData({
    required this.builtinTrainingId,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    required this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['builtin_training_id'] = Variable<int>(builtinTrainingId);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['dirty'] = Variable<int>(dirty);
    map['remote_id'] = Variable<String>(remoteId);
    return map;
  }

  PinnedBuiltinTrainingsCompanion toCompanion(bool nullToAbsent) {
    return PinnedBuiltinTrainingsCompanion(
      builtinTrainingId: Value(builtinTrainingId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      dirty: Value(dirty),
      remoteId: Value(remoteId),
    );
  }

  factory PinnedBuiltinTrainingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedBuiltinTrainingsData(
      builtinTrainingId: serializer.fromJson<int>(json['builtinTrainingId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      dirty: serializer.fromJson<int>(json['dirty']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'builtinTrainingId': serializer.toJson<int>(builtinTrainingId),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'dirty': serializer.toJson<int>(dirty),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  PinnedBuiltinTrainingsData copyWith({
    int? builtinTrainingId,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? dirty,
    String? remoteId,
  }) => PinnedBuiltinTrainingsData(
    builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    remoteId: remoteId ?? this.remoteId,
  );
  PinnedBuiltinTrainingsData copyWithCompanion(
    PinnedBuiltinTrainingsCompanion data,
  ) {
    return PinnedBuiltinTrainingsData(
      builtinTrainingId: data.builtinTrainingId.present
          ? data.builtinTrainingId.value
          : this.builtinTrainingId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedBuiltinTrainingsData(')
          ..write('builtinTrainingId: $builtinTrainingId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(builtinTrainingId, updatedAt, deletedAt, dirty, remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedBuiltinTrainingsData &&
          other.builtinTrainingId == this.builtinTrainingId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.remoteId == this.remoteId);
}

class PinnedBuiltinTrainingsCompanion
    extends UpdateCompanion<PinnedBuiltinTrainingsData> {
  final Value<int> builtinTrainingId;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> dirty;
  final Value<String> remoteId;
  const PinnedBuiltinTrainingsCompanion({
    this.builtinTrainingId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  PinnedBuiltinTrainingsCompanion.insert({
    this.builtinTrainingId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    required String remoteId,
  }) : remoteId = Value(remoteId);
  static Insertable<PinnedBuiltinTrainingsData> custom({
    Expression<int>? builtinTrainingId,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? dirty,
    Expression<String>? remoteId,
  }) {
    return RawValuesInsertable({
      if (builtinTrainingId != null) 'builtin_training_id': builtinTrainingId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  PinnedBuiltinTrainingsCompanion copyWith({
    Value<int>? builtinTrainingId,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? dirty,
    Value<String>? remoteId,
  }) {
    return PinnedBuiltinTrainingsCompanion(
      builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (builtinTrainingId.present) {
      map['builtin_training_id'] = Variable<int>(builtinTrainingId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<int>(dirty.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinnedBuiltinTrainingsCompanion(')
          ..write('builtinTrainingId: $builtinTrainingId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class Users extends Table with TableInfo<Users, UsersData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Users(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> firstname = GeneratedColumn<String>(
    'firstname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> lastname = GeneratedColumn<String>(
    'lastname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> emailVerified = GeneratedColumn<int>(
    'email_verified',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (email_verified IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> isAdmin = GeneratedColumn<int>(
    'is_admin',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_admin IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> isCoach = GeneratedColumn<int>(
    'is_coach',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_coach IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> coachValidated = GeneratedColumn<int>(
    'coach_validated',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (coach_validated IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER))',
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsersData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersData(
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
        DriftSqlType.int,
        data['${effectivePrefix}email_verified'],
      )!,
      isAdmin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_admin'],
      )!,
      isCoach: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_coach'],
      )!,
      coachValidated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coach_validated'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Users createAlias(String alias) {
    return Users(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class UsersData extends DataClass implements Insertable<UsersData> {
  final String id;
  final String email;
  final String firstname;
  final String lastname;
  final int emailVerified;
  final int isAdmin;
  final int isCoach;
  final int coachValidated;
  final int createdAt;
  const UsersData({
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
    map['email_verified'] = Variable<int>(emailVerified);
    map['is_admin'] = Variable<int>(isAdmin);
    map['is_coach'] = Variable<int>(isCoach);
    map['coach_validated'] = Variable<int>(coachValidated);
    map['created_at'] = Variable<int>(createdAt);
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

  factory UsersData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersData(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      firstname: serializer.fromJson<String>(json['firstname']),
      lastname: serializer.fromJson<String>(json['lastname']),
      emailVerified: serializer.fromJson<int>(json['emailVerified']),
      isAdmin: serializer.fromJson<int>(json['isAdmin']),
      isCoach: serializer.fromJson<int>(json['isCoach']),
      coachValidated: serializer.fromJson<int>(json['coachValidated']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
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
      'emailVerified': serializer.toJson<int>(emailVerified),
      'isAdmin': serializer.toJson<int>(isAdmin),
      'isCoach': serializer.toJson<int>(isCoach),
      'coachValidated': serializer.toJson<int>(coachValidated),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  UsersData copyWith({
    String? id,
    String? email,
    String? firstname,
    String? lastname,
    int? emailVerified,
    int? isAdmin,
    int? isCoach,
    int? coachValidated,
    int? createdAt,
  }) => UsersData(
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
  UsersData copyWithCompanion(UsersCompanion data) {
    return UsersData(
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
    return (StringBuffer('UsersData(')
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
      (other is UsersData &&
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

class UsersCompanion extends UpdateCompanion<UsersData> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> firstname;
  final Value<String> lastname;
  final Value<int> emailVerified;
  final Value<int> isAdmin;
  final Value<int> isCoach;
  final Value<int> coachValidated;
  final Value<int> createdAt;
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
  static Insertable<UsersData> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? firstname,
    Expression<String>? lastname,
    Expression<int>? emailVerified,
    Expression<int>? isAdmin,
    Expression<int>? isCoach,
    Expression<int>? coachValidated,
    Expression<int>? createdAt,
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
    Value<int>? emailVerified,
    Value<int>? isAdmin,
    Value<int>? isCoach,
    Value<int>? coachValidated,
    Value<int>? createdAt,
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
      map['email_verified'] = Variable<int>(emailVerified.value);
    }
    if (isAdmin.present) {
      map['is_admin'] = Variable<int>(isAdmin.value);
    }
    if (isCoach.present) {
      map['is_coach'] = Variable<int>(isCoach.value);
    }
    if (coachValidated.present) {
      map['coach_validated'] = Variable<int>(coachValidated.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
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

class DatabaseAtV1 extends GeneratedDatabase {
  DatabaseAtV1(QueryExecutor e) : super(e);
  late final Sessions sessions = Sessions(this);
  late final Assessments assessments = Assessments(this);
  late final Repeaters repeaters = Repeaters(this);
  late final Trainings trainings = Trainings(this);
  late final RepTemplates repTemplates = RepTemplates(this);
  late final RepDatas repDatas = RepDatas(this);
  late final SensorConfigs sensorConfigs = SensorConfigs(this);
  late final BuiltinTrainingWeights builtinTrainingWeights =
      BuiltinTrainingWeights(this);
  late final PinnedBuiltinTrainings pinnedBuiltinTrainings =
      PinnedBuiltinTrainings(this);
  late final Users users = Users(this);
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
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'repeaters',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trainings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trainings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rep_templates', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trainings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('builtin_training_weights', kind: UpdateKind.delete),
      ],
    ),
  ]);
  @override
  int get schemaVersion => 1;
}
