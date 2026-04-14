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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    syncId,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    syncVersion,
    isDirty,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
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
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      notes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}notes'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      dataPath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}data_path'],
          )!,
      isAssessment:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_assessment'],
          )!,
      sessionType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}session_type'],
          )!,
      duration:
          attachedDatabase.typeMapping.read(
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      syncVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sync_version'],
          )!,
      isDirty:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_dirty'],
          )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
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
  final String? syncId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  final int syncVersion;
  final bool isDirty;
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
    this.syncId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deviceId,
    required this.syncVersion,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
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
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_dirty'] = Variable<bool>(isDirty);
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
      repeaterSets:
          repeaterSets == null && nullToAbsent
              ? const Value.absent()
              : Value(repeaterSets),
      repeaterReps:
          repeaterReps == null && nullToAbsent
              ? const Value.absent()
              : Value(repeaterReps),
      repeaterWorkTime:
          repeaterWorkTime == null && nullToAbsent
              ? const Value.absent()
              : Value(repeaterWorkTime),
      repeaterRestTime:
          repeaterRestTime == null && nullToAbsent
              ? const Value.absent()
              : Value(repeaterRestTime),
      repeaterSetRest:
          repeaterSetRest == null && nullToAbsent
              ? const Value.absent()
              : Value(repeaterSetRest),
      repeaterSplitHand:
          repeaterSplitHand == null && nullToAbsent
              ? const Value.absent()
              : Value(repeaterSplitHand),
      syncId:
          syncId == null && nullToAbsent ? const Value.absent() : Value(syncId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      deviceId:
          deviceId == null && nullToAbsent
              ? const Value.absent()
              : Value(deviceId),
      syncVersion: Value(syncVersion),
      isDirty: Value(isDirty),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
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
      syncId: serializer.fromJson<String?>(json['syncId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
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
      'syncId': serializer.toJson<String?>(syncId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Session copyWith({
    int? id,
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
    Value<String?> syncId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    int? syncVersion,
    bool? isDirty,
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
    repeaterWorkTime:
        repeaterWorkTime.present
            ? repeaterWorkTime.value
            : this.repeaterWorkTime,
    repeaterRestTime:
        repeaterRestTime.present
            ? repeaterRestTime.value
            : this.repeaterRestTime,
    repeaterSetRest:
        repeaterSetRest.present ? repeaterSetRest.value : this.repeaterSetRest,
    repeaterSplitHand:
        repeaterSplitHand.present
            ? repeaterSplitHand.value
            : this.repeaterSplitHand,
    syncId: syncId.present ? syncId.value : this.syncId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    syncVersion: syncVersion ?? this.syncVersion,
    isDirty: isDirty ?? this.isDirty,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      date: data.date.present ? data.date.value : this.date,
      dataPath: data.dataPath.present ? data.dataPath.value : this.dataPath,
      isAssessment:
          data.isAssessment.present
              ? data.isAssessment.value
              : this.isAssessment,
      sessionType:
          data.sessionType.present ? data.sessionType.value : this.sessionType,
      duration: data.duration.present ? data.duration.value : this.duration,
      repeaterSets:
          data.repeaterSets.present
              ? data.repeaterSets.value
              : this.repeaterSets,
      repeaterReps:
          data.repeaterReps.present
              ? data.repeaterReps.value
              : this.repeaterReps,
      repeaterWorkTime:
          data.repeaterWorkTime.present
              ? data.repeaterWorkTime.value
              : this.repeaterWorkTime,
      repeaterRestTime:
          data.repeaterRestTime.present
              ? data.repeaterRestTime.value
              : this.repeaterRestTime,
      repeaterSetRest:
          data.repeaterSetRest.present
              ? data.repeaterSetRest.value
              : this.repeaterSetRest,
      repeaterSplitHand:
          data.repeaterSplitHand.present
              ? data.repeaterSplitHand.value
              : this.repeaterSplitHand,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncVersion:
          data.syncVersion.present ? data.syncVersion.value : this.syncVersion,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
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
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    syncId,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    syncVersion,
    isDirty,
  ]);
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
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.syncVersion == this.syncVersion &&
          other.isDirty == this.isDirty);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
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
  final Value<String?> syncId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> syncVersion;
  final Value<bool> isDirty;
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
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDirty = const Value.absent(),
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
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDirty = const Value.absent(),
  }) : name = Value(name),
       notes = Value(notes),
       dataPath = Value(dataPath);
  static Insertable<Session> custom({
    Expression<int>? id,
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
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? syncVersion,
    Expression<bool>? isDirty,
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
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDirty != null) 'is_dirty': isDirty,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
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
    Value<String?>? syncId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? syncVersion,
    Value<bool>? isDirty,
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
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      syncVersion: syncVersion ?? this.syncVersion,
      isDirty: isDirty ?? this.isDirty,
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
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
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
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDirty: $isDirty')
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
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    rightValue,
    leftValue,
    sessionId,
    gripPosition,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assessment(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
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
      sessionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}session_id'],
          )!,
      gripPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grip_position'],
      ),
    );
  }

  @override
  $AssessmentsTable createAlias(String alias) {
    return $AssessmentsTable(attachedDatabase, alias);
  }
}

class Assessment extends DataClass implements Insertable<Assessment> {
  final int id;
  final int type;
  final double? rightValue;
  final double? leftValue;
  final int sessionId;
  final int? gripPosition;
  const Assessment({
    required this.id,
    required this.type,
    this.rightValue,
    this.leftValue,
    required this.sessionId,
    this.gripPosition,
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
    return map;
  }

  AssessmentsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentsCompanion(
      id: Value(id),
      type: Value(type),
      rightValue:
          rightValue == null && nullToAbsent
              ? const Value.absent()
              : Value(rightValue),
      leftValue:
          leftValue == null && nullToAbsent
              ? const Value.absent()
              : Value(leftValue),
      sessionId: Value(sessionId),
      gripPosition:
          gripPosition == null && nullToAbsent
              ? const Value.absent()
              : Value(gripPosition),
    );
  }

  factory Assessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assessment(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      rightValue: serializer.fromJson<double?>(json['rightValue']),
      leftValue: serializer.fromJson<double?>(json['leftValue']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      gripPosition: serializer.fromJson<int?>(json['gripPosition']),
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
    };
  }

  Assessment copyWith({
    int? id,
    int? type,
    Value<double?> rightValue = const Value.absent(),
    Value<double?> leftValue = const Value.absent(),
    int? sessionId,
    Value<int?> gripPosition = const Value.absent(),
  }) => Assessment(
    id: id ?? this.id,
    type: type ?? this.type,
    rightValue: rightValue.present ? rightValue.value : this.rightValue,
    leftValue: leftValue.present ? leftValue.value : this.leftValue,
    sessionId: sessionId ?? this.sessionId,
    gripPosition: gripPosition.present ? gripPosition.value : this.gripPosition,
  );
  Assessment copyWithCompanion(AssessmentsCompanion data) {
    return Assessment(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      rightValue:
          data.rightValue.present ? data.rightValue.value : this.rightValue,
      leftValue: data.leftValue.present ? data.leftValue.value : this.leftValue,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      gripPosition:
          data.gripPosition.present
              ? data.gripPosition.value
              : this.gripPosition,
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
          ..write('gripPosition: $gripPosition')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, rightValue, leftValue, sessionId, gripPosition);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assessment &&
          other.id == this.id &&
          other.type == this.type &&
          other.rightValue == this.rightValue &&
          other.leftValue == this.leftValue &&
          other.sessionId == this.sessionId &&
          other.gripPosition == this.gripPosition);
}

class AssessmentsCompanion extends UpdateCompanion<Assessment> {
  final Value<int> id;
  final Value<int> type;
  final Value<double?> rightValue;
  final Value<double?> leftValue;
  final Value<int> sessionId;
  final Value<int?> gripPosition;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.gripPosition = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    this.id = const Value.absent(),
    required int type,
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    required int sessionId,
    this.gripPosition = const Value.absent(),
  }) : type = Value(type),
       sessionId = Value(sessionId);
  static Insertable<Assessment> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<double>? rightValue,
    Expression<double>? leftValue,
    Expression<int>? sessionId,
    Expression<int>? gripPosition,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (rightValue != null) 'right_value': rightValue,
      if (leftValue != null) 'left_value': leftValue,
      if (sessionId != null) 'session_id': sessionId,
      if (gripPosition != null) 'grip_position': gripPosition,
    });
  }

  AssessmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? type,
    Value<double?>? rightValue,
    Value<double?>? leftValue,
    Value<int>? sessionId,
    Value<int?>? gripPosition,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      rightValue: rightValue ?? this.rightValue,
      leftValue: leftValue ?? this.leftValue,
      sessionId: sessionId ?? this.sessionId,
      gripPosition: gripPosition ?? this.gripPosition,
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
          ..write('gripPosition: $gripPosition')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    syncId,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    syncVersion,
    isDirty,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
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
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      sets:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sets'],
          )!,
      reps:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}reps'],
          )!,
      worktime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}worktime'],
          )!,
      resttime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}resttime'],
          )!,
      setRest:
          attachedDatabase.typeMapping.read(
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
      splitHand:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}split_hand'],
          )!,
      gripPosition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}grip_position'],
          )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      syncVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sync_version'],
          )!,
      isDirty:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_dirty'],
          )!,
    );
  }

  @override
  $RepeatersTable createAlias(String alias) {
    return $RepeatersTable(attachedDatabase, alias);
  }
}

class Repeater extends DataClass implements Insertable<Repeater> {
  final int id;
  final int sets;
  final int reps;
  final int worktime;
  final int resttime;
  final int setRest;
  final double? targetWeigthRight;
  final double? targetWeigthLeft;
  final bool splitHand;
  final int gripPosition;
  final String? syncId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  final int syncVersion;
  final bool isDirty;
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
    this.syncId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deviceId,
    required this.syncVersion,
    required this.isDirty,
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
    map['split_hand'] = Variable<bool>(splitHand);
    map['grip_position'] = Variable<int>(gripPosition);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_dirty'] = Variable<bool>(isDirty);
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
      targetWeigthRight:
          targetWeigthRight == null && nullToAbsent
              ? const Value.absent()
              : Value(targetWeigthRight),
      targetWeigthLeft:
          targetWeigthLeft == null && nullToAbsent
              ? const Value.absent()
              : Value(targetWeigthLeft),
      splitHand: Value(splitHand),
      gripPosition: Value(gripPosition),
      syncId:
          syncId == null && nullToAbsent ? const Value.absent() : Value(syncId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      deviceId:
          deviceId == null && nullToAbsent
              ? const Value.absent()
              : Value(deviceId),
      syncVersion: Value(syncVersion),
      isDirty: Value(isDirty),
    );
  }

  factory Repeater.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Repeater(
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
      splitHand: serializer.fromJson<bool>(json['splitHand']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
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
      'splitHand': serializer.toJson<bool>(splitHand),
      'gripPosition': serializer.toJson<int>(gripPosition),
      'syncId': serializer.toJson<String?>(syncId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Repeater copyWith({
    int? id,
    int? sets,
    int? reps,
    int? worktime,
    int? resttime,
    int? setRest,
    Value<double?> targetWeigthRight = const Value.absent(),
    Value<double?> targetWeigthLeft = const Value.absent(),
    bool? splitHand,
    int? gripPosition,
    Value<String?> syncId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    int? syncVersion,
    bool? isDirty,
  }) => Repeater(
    id: id ?? this.id,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    worktime: worktime ?? this.worktime,
    resttime: resttime ?? this.resttime,
    setRest: setRest ?? this.setRest,
    targetWeigthRight:
        targetWeigthRight.present
            ? targetWeigthRight.value
            : this.targetWeigthRight,
    targetWeigthLeft:
        targetWeigthLeft.present
            ? targetWeigthLeft.value
            : this.targetWeigthLeft,
    splitHand: splitHand ?? this.splitHand,
    gripPosition: gripPosition ?? this.gripPosition,
    syncId: syncId.present ? syncId.value : this.syncId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    syncVersion: syncVersion ?? this.syncVersion,
    isDirty: isDirty ?? this.isDirty,
  );
  Repeater copyWithCompanion(RepeatersCompanion data) {
    return Repeater(
      id: data.id.present ? data.id.value : this.id,
      sets: data.sets.present ? data.sets.value : this.sets,
      reps: data.reps.present ? data.reps.value : this.reps,
      worktime: data.worktime.present ? data.worktime.value : this.worktime,
      resttime: data.resttime.present ? data.resttime.value : this.resttime,
      setRest: data.setRest.present ? data.setRest.value : this.setRest,
      targetWeigthRight:
          data.targetWeigthRight.present
              ? data.targetWeigthRight.value
              : this.targetWeigthRight,
      targetWeigthLeft:
          data.targetWeigthLeft.present
              ? data.targetWeigthLeft.value
              : this.targetWeigthLeft,
      splitHand: data.splitHand.present ? data.splitHand.value : this.splitHand,
      gripPosition:
          data.gripPosition.present
              ? data.gripPosition.value
              : this.gripPosition,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncVersion:
          data.syncVersion.present ? data.syncVersion.value : this.syncVersion,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
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
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDirty: $isDirty')
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
    syncId,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    syncVersion,
    isDirty,
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
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.syncVersion == this.syncVersion &&
          other.isDirty == this.isDirty);
}

class RepeatersCompanion extends UpdateCompanion<Repeater> {
  final Value<int> id;
  final Value<int> sets;
  final Value<int> reps;
  final Value<int> worktime;
  final Value<int> resttime;
  final Value<int> setRest;
  final Value<double?> targetWeigthRight;
  final Value<double?> targetWeigthLeft;
  final Value<bool> splitHand;
  final Value<int> gripPosition;
  final Value<String?> syncId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> syncVersion;
  final Value<bool> isDirty;
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
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDirty = const Value.absent(),
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
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDirty = const Value.absent(),
  }) : sets = Value(sets),
       reps = Value(reps),
       worktime = Value(worktime),
       resttime = Value(resttime),
       setRest = Value(setRest),
       splitHand = Value(splitHand);
  static Insertable<Repeater> custom({
    Expression<int>? id,
    Expression<int>? sets,
    Expression<int>? reps,
    Expression<int>? worktime,
    Expression<int>? resttime,
    Expression<int>? setRest,
    Expression<double>? targetWeigthRight,
    Expression<double>? targetWeigthLeft,
    Expression<bool>? splitHand,
    Expression<int>? gripPosition,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? syncVersion,
    Expression<bool>? isDirty,
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
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDirty != null) 'is_dirty': isDirty,
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
    Value<bool>? splitHand,
    Value<int>? gripPosition,
    Value<String?>? syncId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? syncVersion,
    Value<bool>? isDirty,
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
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      syncVersion: syncVersion ?? this.syncVersion,
      isDirty: isDirty ?? this.isDirty,
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
      map['split_hand'] = Variable<bool>(splitHand.value);
    }
    if (gripPosition.present) {
      map['grip_position'] = Variable<int>(gripPosition.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
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
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDirty: $isDirty')
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
  late final GeneratedColumn<int> repeaterId = GeneratedColumn<int>(
    'repeater_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES repeaters (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    repeaterId,
    isBuiltin,
    isFavorite,
    isAssessment,
    syncId,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    syncVersion,
    isDirty,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
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
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      repeaterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeater_id'],
      ),
      isBuiltin:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_builtin'],
          )!,
      isFavorite:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_favorite'],
          )!,
      isAssessment:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_assessment'],
          )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      syncVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sync_version'],
          )!,
      isDirty:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_dirty'],
          )!,
    );
  }

  @override
  $TrainingsTable createAlias(String alias) {
    return $TrainingsTable(attachedDatabase, alias);
  }
}

class Training extends DataClass implements Insertable<Training> {
  final int id;
  final String name;
  final int? repeaterId;
  final bool isBuiltin;
  final bool isFavorite;
  final bool isAssessment;
  final String? syncId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? deviceId;
  final int syncVersion;
  final bool isDirty;
  const Training({
    required this.id,
    required this.name,
    this.repeaterId,
    required this.isBuiltin,
    required this.isFavorite,
    required this.isAssessment,
    this.syncId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deviceId,
    required this.syncVersion,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || repeaterId != null) {
      map['repeater_id'] = Variable<int>(repeaterId);
    }
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_assessment'] = Variable<bool>(isAssessment);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  TrainingsCompanion toCompanion(bool nullToAbsent) {
    return TrainingsCompanion(
      id: Value(id),
      name: Value(name),
      repeaterId:
          repeaterId == null && nullToAbsent
              ? const Value.absent()
              : Value(repeaterId),
      isBuiltin: Value(isBuiltin),
      isFavorite: Value(isFavorite),
      isAssessment: Value(isAssessment),
      syncId:
          syncId == null && nullToAbsent ? const Value.absent() : Value(syncId),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      deviceId:
          deviceId == null && nullToAbsent
              ? const Value.absent()
              : Value(deviceId),
      syncVersion: Value(syncVersion),
      isDirty: Value(isDirty),
    );
  }

  factory Training.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Training(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      repeaterId: serializer.fromJson<int?>(json['repeaterId']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isAssessment: serializer.fromJson<bool>(json['isAssessment']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'repeaterId': serializer.toJson<int?>(repeaterId),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isAssessment': serializer.toJson<bool>(isAssessment),
      'syncId': serializer.toJson<String?>(syncId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String?>(deviceId),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Training copyWith({
    int? id,
    String? name,
    Value<int?> repeaterId = const Value.absent(),
    bool? isBuiltin,
    bool? isFavorite,
    bool? isAssessment,
    Value<String?> syncId = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    int? syncVersion,
    bool? isDirty,
  }) => Training(
    id: id ?? this.id,
    name: name ?? this.name,
    repeaterId: repeaterId.present ? repeaterId.value : this.repeaterId,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    isFavorite: isFavorite ?? this.isFavorite,
    isAssessment: isAssessment ?? this.isAssessment,
    syncId: syncId.present ? syncId.value : this.syncId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    syncVersion: syncVersion ?? this.syncVersion,
    isDirty: isDirty ?? this.isDirty,
  );
  Training copyWithCompanion(TrainingsCompanion data) {
    return Training(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      repeaterId:
          data.repeaterId.present ? data.repeaterId.value : this.repeaterId,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isAssessment:
          data.isAssessment.present
              ? data.isAssessment.value
              : this.isAssessment,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      syncVersion:
          data.syncVersion.present ? data.syncVersion.value : this.syncVersion,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
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
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDirty: $isDirty')
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
    syncId,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
    syncVersion,
    isDirty,
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
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.syncVersion == this.syncVersion &&
          other.isDirty == this.isDirty);
}

class TrainingsCompanion extends UpdateCompanion<Training> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> repeaterId;
  final Value<bool> isBuiltin;
  final Value<bool> isFavorite;
  final Value<bool> isAssessment;
  final Value<String?> syncId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deviceId;
  final Value<int> syncVersion;
  final Value<bool> isDirty;
  const TrainingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.repeaterId = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isAssessment = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDirty = const Value.absent(),
  });
  TrainingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.repeaterId = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isAssessment = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.isDirty = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Training> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? repeaterId,
    Expression<bool>? isBuiltin,
    Expression<bool>? isFavorite,
    Expression<bool>? isAssessment,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? syncVersion,
    Expression<bool>? isDirty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (repeaterId != null) 'repeater_id': repeaterId,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isAssessment != null) 'is_assessment': isAssessment,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (isDirty != null) 'is_dirty': isDirty,
    });
  }

  TrainingsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? repeaterId,
    Value<bool>? isBuiltin,
    Value<bool>? isFavorite,
    Value<bool>? isAssessment,
    Value<String?>? syncId,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deviceId,
    Value<int>? syncVersion,
    Value<bool>? isDirty,
  }) {
    return TrainingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      repeaterId: repeaterId ?? this.repeaterId,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      isFavorite: isFavorite ?? this.isFavorite,
      isAssessment: isAssessment ?? this.isAssessment,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      syncVersion: syncVersion ?? this.syncVersion,
      isDirty: isDirty ?? this.isDirty,
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
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isAssessment.present) {
      map['is_assessment'] = Variable<bool>(isAssessment.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
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
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('isDirty: $isDirty')
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
  late final GeneratedColumn<int> trainingId = GeneratedColumn<int>(
    'training_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trainings (id) ON DELETE CASCADE',
    ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepTemplate(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      isRest:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_rest'],
          )!,
      rightHand:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}right_hand'],
          )!,
      duration:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}duration'],
          )!,
      trainingId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}training_id'],
          )!,
      targetWeight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}target_weight'],
          )!,
      index:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}index'],
          )!,
      gripPosition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}grip_position'],
          )!,
    );
  }

  @override
  $RepTemplatesTable createAlias(String alias) {
    return $RepTemplatesTable(attachedDatabase, alias);
  }
}

class RepTemplate extends DataClass implements Insertable<RepTemplate> {
  final int id;
  final bool isRest;
  final bool rightHand;
  final int duration;
  final int trainingId;
  final double targetWeight;
  final int index;
  final int gripPosition;
  const RepTemplate({
    required this.id,
    required this.isRest,
    required this.rightHand,
    required this.duration,
    required this.trainingId,
    required this.targetWeight,
    required this.index,
    required this.gripPosition,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['is_rest'] = Variable<bool>(isRest);
    map['right_hand'] = Variable<bool>(rightHand);
    map['duration'] = Variable<int>(duration);
    map['training_id'] = Variable<int>(trainingId);
    map['target_weight'] = Variable<double>(targetWeight);
    map['index'] = Variable<int>(index);
    map['grip_position'] = Variable<int>(gripPosition);
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
    );
  }

  factory RepTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepTemplate(
      id: serializer.fromJson<int>(json['id']),
      isRest: serializer.fromJson<bool>(json['isRest']),
      rightHand: serializer.fromJson<bool>(json['rightHand']),
      duration: serializer.fromJson<int>(json['duration']),
      trainingId: serializer.fromJson<int>(json['trainingId']),
      targetWeight: serializer.fromJson<double>(json['targetWeight']),
      index: serializer.fromJson<int>(json['index']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isRest': serializer.toJson<bool>(isRest),
      'rightHand': serializer.toJson<bool>(rightHand),
      'duration': serializer.toJson<int>(duration),
      'trainingId': serializer.toJson<int>(trainingId),
      'targetWeight': serializer.toJson<double>(targetWeight),
      'index': serializer.toJson<int>(index),
      'gripPosition': serializer.toJson<int>(gripPosition),
    };
  }

  RepTemplate copyWith({
    int? id,
    bool? isRest,
    bool? rightHand,
    int? duration,
    int? trainingId,
    double? targetWeight,
    int? index,
    int? gripPosition,
  }) => RepTemplate(
    id: id ?? this.id,
    isRest: isRest ?? this.isRest,
    rightHand: rightHand ?? this.rightHand,
    duration: duration ?? this.duration,
    trainingId: trainingId ?? this.trainingId,
    targetWeight: targetWeight ?? this.targetWeight,
    index: index ?? this.index,
    gripPosition: gripPosition ?? this.gripPosition,
  );
  RepTemplate copyWithCompanion(RepTemplatesCompanion data) {
    return RepTemplate(
      id: data.id.present ? data.id.value : this.id,
      isRest: data.isRest.present ? data.isRest.value : this.isRest,
      rightHand: data.rightHand.present ? data.rightHand.value : this.rightHand,
      duration: data.duration.present ? data.duration.value : this.duration,
      trainingId:
          data.trainingId.present ? data.trainingId.value : this.trainingId,
      targetWeight:
          data.targetWeight.present
              ? data.targetWeight.value
              : this.targetWeight,
      index: data.index.present ? data.index.value : this.index,
      gripPosition:
          data.gripPosition.present
              ? data.gripPosition.value
              : this.gripPosition,
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
          ..write('gripPosition: $gripPosition')
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
          other.gripPosition == this.gripPosition);
}

class RepTemplatesCompanion extends UpdateCompanion<RepTemplate> {
  final Value<int> id;
  final Value<bool> isRest;
  final Value<bool> rightHand;
  final Value<int> duration;
  final Value<int> trainingId;
  final Value<double> targetWeight;
  final Value<int> index;
  final Value<int> gripPosition;
  const RepTemplatesCompanion({
    this.id = const Value.absent(),
    this.isRest = const Value.absent(),
    this.rightHand = const Value.absent(),
    this.duration = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.index = const Value.absent(),
    this.gripPosition = const Value.absent(),
  });
  RepTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required bool isRest,
    required bool rightHand,
    required int duration,
    required int trainingId,
    required double targetWeight,
    required int index,
    this.gripPosition = const Value.absent(),
  }) : isRest = Value(isRest),
       rightHand = Value(rightHand),
       duration = Value(duration),
       trainingId = Value(trainingId),
       targetWeight = Value(targetWeight),
       index = Value(index);
  static Insertable<RepTemplate> custom({
    Expression<int>? id,
    Expression<bool>? isRest,
    Expression<bool>? rightHand,
    Expression<int>? duration,
    Expression<int>? trainingId,
    Expression<double>? targetWeight,
    Expression<int>? index,
    Expression<int>? gripPosition,
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
    });
  }

  RepTemplatesCompanion copyWith({
    Value<int>? id,
    Value<bool>? isRest,
    Value<bool>? rightHand,
    Value<int>? duration,
    Value<int>? trainingId,
    Value<double>? targetWeight,
    Value<int>? index,
    Value<int>? gripPosition,
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
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
          ..write('gripPosition: $gripPosition')
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
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      averageWeight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}average_weight'],
          )!,
      sessionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}session_id'],
          )!,
      isRest:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_rest'],
          )!,
      rightHand:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}right_hand'],
          )!,
      duration:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}duration'],
          )!,
      targetWeight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}target_weight'],
          )!,
      index:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}index'],
          )!,
      gripPosition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}grip_position'],
          )!,
    );
  }

  @override
  $RepDatasTable createAlias(String alias) {
    return $RepDatasTable(attachedDatabase, alias);
  }
}

class RepData extends DataClass implements Insertable<RepData> {
  final int id;
  final double averageWeight;
  final int sessionId;
  final bool isRest;
  final bool rightHand;
  final int duration;
  final double targetWeight;
  final int index;
  final int gripPosition;
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
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['average_weight'] = Variable<double>(averageWeight);
    map['session_id'] = Variable<int>(sessionId);
    map['is_rest'] = Variable<bool>(isRest);
    map['right_hand'] = Variable<bool>(rightHand);
    map['duration'] = Variable<int>(duration);
    map['target_weight'] = Variable<double>(targetWeight);
    map['index'] = Variable<int>(index);
    map['grip_position'] = Variable<int>(gripPosition);
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
    );
  }

  factory RepData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepData(
      id: serializer.fromJson<int>(json['id']),
      averageWeight: serializer.fromJson<double>(json['averageWeight']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      isRest: serializer.fromJson<bool>(json['isRest']),
      rightHand: serializer.fromJson<bool>(json['rightHand']),
      duration: serializer.fromJson<int>(json['duration']),
      targetWeight: serializer.fromJson<double>(json['targetWeight']),
      index: serializer.fromJson<int>(json['index']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'averageWeight': serializer.toJson<double>(averageWeight),
      'sessionId': serializer.toJson<int>(sessionId),
      'isRest': serializer.toJson<bool>(isRest),
      'rightHand': serializer.toJson<bool>(rightHand),
      'duration': serializer.toJson<int>(duration),
      'targetWeight': serializer.toJson<double>(targetWeight),
      'index': serializer.toJson<int>(index),
      'gripPosition': serializer.toJson<int>(gripPosition),
    };
  }

  RepData copyWith({
    int? id,
    double? averageWeight,
    int? sessionId,
    bool? isRest,
    bool? rightHand,
    int? duration,
    double? targetWeight,
    int? index,
    int? gripPosition,
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
  );
  RepData copyWithCompanion(RepDatasCompanion data) {
    return RepData(
      id: data.id.present ? data.id.value : this.id,
      averageWeight:
          data.averageWeight.present
              ? data.averageWeight.value
              : this.averageWeight,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      isRest: data.isRest.present ? data.isRest.value : this.isRest,
      rightHand: data.rightHand.present ? data.rightHand.value : this.rightHand,
      duration: data.duration.present ? data.duration.value : this.duration,
      targetWeight:
          data.targetWeight.present
              ? data.targetWeight.value
              : this.targetWeight,
      index: data.index.present ? data.index.value : this.index,
      gripPosition:
          data.gripPosition.present
              ? data.gripPosition.value
              : this.gripPosition,
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
          ..write('gripPosition: $gripPosition')
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
          other.gripPosition == this.gripPosition);
}

class RepDatasCompanion extends UpdateCompanion<RepData> {
  final Value<int> id;
  final Value<double> averageWeight;
  final Value<int> sessionId;
  final Value<bool> isRest;
  final Value<bool> rightHand;
  final Value<int> duration;
  final Value<double> targetWeight;
  final Value<int> index;
  final Value<int> gripPosition;
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
  });
  RepDatasCompanion.insert({
    this.id = const Value.absent(),
    required double averageWeight,
    required int sessionId,
    required bool isRest,
    required bool rightHand,
    required int duration,
    required double targetWeight,
    required int index,
    this.gripPosition = const Value.absent(),
  }) : averageWeight = Value(averageWeight),
       sessionId = Value(sessionId),
       isRest = Value(isRest),
       rightHand = Value(rightHand),
       duration = Value(duration),
       targetWeight = Value(targetWeight),
       index = Value(index);
  static Insertable<RepData> custom({
    Expression<int>? id,
    Expression<double>? averageWeight,
    Expression<int>? sessionId,
    Expression<bool>? isRest,
    Expression<bool>? rightHand,
    Expression<int>? duration,
    Expression<double>? targetWeight,
    Expression<int>? index,
    Expression<int>? gripPosition,
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
    });
  }

  RepDatasCompanion copyWith({
    Value<int>? id,
    Value<double>? averageWeight,
    Value<int>? sessionId,
    Value<bool>? isRest,
    Value<bool>? rightHand,
    Value<int>? duration,
    Value<double>? targetWeight,
    Value<int>? index,
    Value<int>? gripPosition,
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
          ..write('gripPosition: $gripPosition')
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
  @override
  List<GeneratedColumn> get $columns => [id, name, index, tare, coef];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorConfig(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      index:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}index'],
          )!,
      tare:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}tare'],
          )!,
      coef:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}coef'],
          )!,
    );
  }

  @override
  $SensorConfigsTable createAlias(String alias) {
    return $SensorConfigsTable(attachedDatabase, alias);
  }
}

class SensorConfig extends DataClass implements Insertable<SensorConfig> {
  final int id;
  final String name;
  final int index;
  final double tare;
  final double coef;
  const SensorConfig({
    required this.id,
    required this.name,
    required this.index,
    required this.tare,
    required this.coef,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['index'] = Variable<int>(index);
    map['tare'] = Variable<double>(tare);
    map['coef'] = Variable<double>(coef);
    return map;
  }

  SensorConfigsCompanion toCompanion(bool nullToAbsent) {
    return SensorConfigsCompanion(
      id: Value(id),
      name: Value(name),
      index: Value(index),
      tare: Value(tare),
      coef: Value(coef),
    );
  }

  factory SensorConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorConfig(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      index: serializer.fromJson<int>(json['index']),
      tare: serializer.fromJson<double>(json['tare']),
      coef: serializer.fromJson<double>(json['coef']),
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
    };
  }

  SensorConfig copyWith({
    int? id,
    String? name,
    int? index,
    double? tare,
    double? coef,
  }) => SensorConfig(
    id: id ?? this.id,
    name: name ?? this.name,
    index: index ?? this.index,
    tare: tare ?? this.tare,
    coef: coef ?? this.coef,
  );
  SensorConfig copyWithCompanion(SensorConfigsCompanion data) {
    return SensorConfig(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      index: data.index.present ? data.index.value : this.index,
      tare: data.tare.present ? data.tare.value : this.tare,
      coef: data.coef.present ? data.coef.value : this.coef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorConfig(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('index: $index, ')
          ..write('tare: $tare, ')
          ..write('coef: $coef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, index, tare, coef);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorConfig &&
          other.id == this.id &&
          other.name == this.name &&
          other.index == this.index &&
          other.tare == this.tare &&
          other.coef == this.coef);
}

class SensorConfigsCompanion extends UpdateCompanion<SensorConfig> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> index;
  final Value<double> tare;
  final Value<double> coef;
  const SensorConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.index = const Value.absent(),
    this.tare = const Value.absent(),
    this.coef = const Value.absent(),
  });
  SensorConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int index,
    required double tare,
    required double coef,
  }) : name = Value(name),
       index = Value(index),
       tare = Value(tare),
       coef = Value(coef);
  static Insertable<SensorConfig> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? index,
    Expression<double>? tare,
    Expression<double>? coef,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (index != null) 'index': index,
      if (tare != null) 'tare': tare,
      if (coef != null) 'coef': coef,
    });
  }

  SensorConfigsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? index,
    Value<double>? tare,
    Value<double>? coef,
  }) {
    return SensorConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      index: index ?? this.index,
      tare: tare ?? this.tare,
      coef: coef ?? this.coef,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorConfigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('index: $index, ')
          ..write('tare: $tare, ')
          ..write('coef: $coef')
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
  static const VerificationMeta _builtinTrainingIdMeta = const VerificationMeta(
    'builtinTrainingId',
  );
  @override
  late final GeneratedColumn<int> builtinTrainingId = GeneratedColumn<int>(
    'builtin_training_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trainings (id) ON DELETE CASCADE',
    ),
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
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      builtinTrainingId:
          attachedDatabase.typeMapping.read(
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
      updatedAt:
          attachedDatabase.typeMapping.read(
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
  final int id;
  final int builtinTrainingId;
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
    map['id'] = Variable<int>(id);
    map['builtin_training_id'] = Variable<int>(builtinTrainingId);
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
      customWeightRight:
          customWeightRight == null && nullToAbsent
              ? const Value.absent()
              : Value(customWeightRight),
      customWeightLeft:
          customWeightLeft == null && nullToAbsent
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
      id: serializer.fromJson<int>(json['id']),
      builtinTrainingId: serializer.fromJson<int>(json['builtinTrainingId']),
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
      'id': serializer.toJson<int>(id),
      'builtinTrainingId': serializer.toJson<int>(builtinTrainingId),
      'customWeightRight': serializer.toJson<double?>(customWeightRight),
      'customWeightLeft': serializer.toJson<double?>(customWeightLeft),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BuiltinTrainingWeight copyWith({
    int? id,
    int? builtinTrainingId,
    Value<double?> customWeightRight = const Value.absent(),
    Value<double?> customWeightLeft = const Value.absent(),
    DateTime? updatedAt,
  }) => BuiltinTrainingWeight(
    id: id ?? this.id,
    builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
    customWeightRight:
        customWeightRight.present
            ? customWeightRight.value
            : this.customWeightRight,
    customWeightLeft:
        customWeightLeft.present
            ? customWeightLeft.value
            : this.customWeightLeft,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BuiltinTrainingWeight copyWithCompanion(
    BuiltinTrainingWeightsCompanion data,
  ) {
    return BuiltinTrainingWeight(
      id: data.id.present ? data.id.value : this.id,
      builtinTrainingId:
          data.builtinTrainingId.present
              ? data.builtinTrainingId.value
              : this.builtinTrainingId,
      customWeightRight:
          data.customWeightRight.present
              ? data.customWeightRight.value
              : this.customWeightRight,
      customWeightLeft:
          data.customWeightLeft.present
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
  final Value<int> id;
  final Value<int> builtinTrainingId;
  final Value<double?> customWeightRight;
  final Value<double?> customWeightLeft;
  final Value<DateTime> updatedAt;
  const BuiltinTrainingWeightsCompanion({
    this.id = const Value.absent(),
    this.builtinTrainingId = const Value.absent(),
    this.customWeightRight = const Value.absent(),
    this.customWeightLeft = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BuiltinTrainingWeightsCompanion.insert({
    this.id = const Value.absent(),
    required int builtinTrainingId,
    this.customWeightRight = const Value.absent(),
    this.customWeightLeft = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : builtinTrainingId = Value(builtinTrainingId);
  static Insertable<BuiltinTrainingWeight> custom({
    Expression<int>? id,
    Expression<int>? builtinTrainingId,
    Expression<double>? customWeightRight,
    Expression<double>? customWeightLeft,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (builtinTrainingId != null) 'builtin_training_id': builtinTrainingId,
      if (customWeightRight != null) 'custom_weight_right': customWeightRight,
      if (customWeightLeft != null) 'custom_weight_left': customWeightLeft,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BuiltinTrainingWeightsCompanion copyWith({
    Value<int>? id,
    Value<int>? builtinTrainingId,
    Value<double?>? customWeightRight,
    Value<double?>? customWeightLeft,
    Value<DateTime>? updatedAt,
  }) {
    return BuiltinTrainingWeightsCompanion(
      id: id ?? this.id,
      builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
      customWeightRight: customWeightRight ?? this.customWeightRight,
      customWeightLeft: customWeightLeft ?? this.customWeightLeft,
      updatedAt: updatedAt ?? this.updatedAt,
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
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('updatedAt: $updatedAt')
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
  late final GeneratedColumn<int> builtinTrainingId = GeneratedColumn<int>(
    'builtin_training_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [builtinTrainingId];
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {builtinTrainingId};
  @override
  PinnedBuiltinTraining map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinnedBuiltinTraining(
      builtinTrainingId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}builtin_training_id'],
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
  final int builtinTrainingId;
  const PinnedBuiltinTraining({required this.builtinTrainingId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['builtin_training_id'] = Variable<int>(builtinTrainingId);
    return map;
  }

  PinnedBuiltinTrainingsCompanion toCompanion(bool nullToAbsent) {
    return PinnedBuiltinTrainingsCompanion(
      builtinTrainingId: Value(builtinTrainingId),
    );
  }

  factory PinnedBuiltinTraining.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedBuiltinTraining(
      builtinTrainingId: serializer.fromJson<int>(json['builtinTrainingId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'builtinTrainingId': serializer.toJson<int>(builtinTrainingId),
    };
  }

  PinnedBuiltinTraining copyWith({int? builtinTrainingId}) =>
      PinnedBuiltinTraining(
        builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
      );
  PinnedBuiltinTraining copyWithCompanion(
    PinnedBuiltinTrainingsCompanion data,
  ) {
    return PinnedBuiltinTraining(
      builtinTrainingId:
          data.builtinTrainingId.present
              ? data.builtinTrainingId.value
              : this.builtinTrainingId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedBuiltinTraining(')
          ..write('builtinTrainingId: $builtinTrainingId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => builtinTrainingId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedBuiltinTraining &&
          other.builtinTrainingId == this.builtinTrainingId);
}

class PinnedBuiltinTrainingsCompanion
    extends UpdateCompanion<PinnedBuiltinTraining> {
  final Value<int> builtinTrainingId;
  const PinnedBuiltinTrainingsCompanion({
    this.builtinTrainingId = const Value.absent(),
  });
  PinnedBuiltinTrainingsCompanion.insert({
    this.builtinTrainingId = const Value.absent(),
  });
  static Insertable<PinnedBuiltinTraining> custom({
    Expression<int>? builtinTrainingId,
  }) {
    return RawValuesInsertable({
      if (builtinTrainingId != null) 'builtin_training_id': builtinTrainingId,
    });
  }

  PinnedBuiltinTrainingsCompanion copyWith({Value<int>? builtinTrainingId}) {
    return PinnedBuiltinTrainingsCompanion(
      builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (builtinTrainingId.present) {
      map['builtin_training_id'] = Variable<int>(builtinTrainingId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinnedBuiltinTrainingsCompanion(')
          ..write('builtinTrainingId: $builtinTrainingId')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsUploadMeta = const VerificationMeta(
    'needsUpload',
  );
  @override
  late final GeneratedColumn<bool> needsUpload = GeneratedColumn<bool>(
    'needs_upload',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_upload" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsDownloadMeta = const VerificationMeta(
    'needsDownload',
  );
  @override
  late final GeneratedColumn<bool> needsDownload = GeneratedColumn<bool>(
    'needs_download',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_download" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pendingOperationMeta = const VerificationMeta(
    'pendingOperation',
  );
  @override
  late final GeneratedColumn<String> pendingOperation = GeneratedColumn<String>(
    'pending_operation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    localId,
    remoteId,
    lastSyncedAt,
    needsUpload,
    needsDownload,
    pendingOperation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('needs_upload')) {
      context.handle(
        _needsUploadMeta,
        needsUpload.isAcceptableOrUnknown(
          data['needs_upload']!,
          _needsUploadMeta,
        ),
      );
    }
    if (data.containsKey('needs_download')) {
      context.handle(
        _needsDownloadMeta,
        needsDownload.isAcceptableOrUnknown(
          data['needs_download']!,
          _needsDownloadMeta,
        ),
      );
    }
    if (data.containsKey('pending_operation')) {
      context.handle(
        _pendingOperationMeta,
        pendingOperation.isAcceptableOrUnknown(
          data['pending_operation']!,
          _pendingOperationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      entityTable:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_table'],
          )!,
      localId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_id'],
          )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      needsUpload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}needs_upload'],
          )!,
      needsDownload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}needs_download'],
          )!,
      pendingOperation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_operation'],
      ),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final int id;
  final String entityTable;
  final int localId;
  final int? remoteId;
  final DateTime? lastSyncedAt;
  final bool needsUpload;
  final bool needsDownload;
  final String? pendingOperation;
  const SyncMetadataData({
    required this.id,
    required this.entityTable,
    required this.localId,
    this.remoteId,
    this.lastSyncedAt,
    required this.needsUpload,
    required this.needsDownload,
    this.pendingOperation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_upload'] = Variable<bool>(needsUpload);
    map['needs_download'] = Variable<bool>(needsDownload);
    if (!nullToAbsent || pendingOperation != null) {
      map['pending_operation'] = Variable<String>(pendingOperation);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      localId: Value(localId),
      remoteId:
          remoteId == null && nullToAbsent
              ? const Value.absent()
              : Value(remoteId),
      lastSyncedAt:
          lastSyncedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSyncedAt),
      needsUpload: Value(needsUpload),
      needsDownload: Value(needsDownload),
      pendingOperation:
          pendingOperation == null && nullToAbsent
              ? const Value.absent()
              : Value(pendingOperation),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      id: serializer.fromJson<int>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      localId: serializer.fromJson<int>(json['localId']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsUpload: serializer.fromJson<bool>(json['needsUpload']),
      needsDownload: serializer.fromJson<bool>(json['needsDownload']),
      pendingOperation: serializer.fromJson<String?>(json['pendingOperation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'localId': serializer.toJson<int>(localId),
      'remoteId': serializer.toJson<int?>(remoteId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsUpload': serializer.toJson<bool>(needsUpload),
      'needsDownload': serializer.toJson<bool>(needsDownload),
      'pendingOperation': serializer.toJson<String?>(pendingOperation),
    };
  }

  SyncMetadataData copyWith({
    int? id,
    String? entityTable,
    int? localId,
    Value<int?> remoteId = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    bool? needsUpload,
    bool? needsDownload,
    Value<String?> pendingOperation = const Value.absent(),
  }) => SyncMetadataData(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    localId: localId ?? this.localId,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    needsUpload: needsUpload ?? this.needsUpload,
    needsDownload: needsDownload ?? this.needsDownload,
    pendingOperation:
        pendingOperation.present
            ? pendingOperation.value
            : this.pendingOperation,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      id: data.id.present ? data.id.value : this.id,
      entityTable:
          data.entityTable.present ? data.entityTable.value : this.entityTable,
      localId: data.localId.present ? data.localId.value : this.localId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      lastSyncedAt:
          data.lastSyncedAt.present
              ? data.lastSyncedAt.value
              : this.lastSyncedAt,
      needsUpload:
          data.needsUpload.present ? data.needsUpload.value : this.needsUpload,
      needsDownload:
          data.needsDownload.present
              ? data.needsDownload.value
              : this.needsDownload,
      pendingOperation:
          data.pendingOperation.present
              ? data.pendingOperation.value
              : this.pendingOperation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsUpload: $needsUpload, ')
          ..write('needsDownload: $needsDownload, ')
          ..write('pendingOperation: $pendingOperation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    localId,
    remoteId,
    lastSyncedAt,
    needsUpload,
    needsDownload,
    pendingOperation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.localId == this.localId &&
          other.remoteId == this.remoteId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsUpload == this.needsUpload &&
          other.needsDownload == this.needsDownload &&
          other.pendingOperation == this.pendingOperation);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<int> id;
  final Value<String> entityTable;
  final Value<int> localId;
  final Value<int?> remoteId;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsUpload;
  final Value<bool> needsDownload;
  final Value<String?> pendingOperation;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.localId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsUpload = const Value.absent(),
    this.needsDownload = const Value.absent(),
    this.pendingOperation = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    this.id = const Value.absent(),
    required String entityTable,
    required int localId,
    this.remoteId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsUpload = const Value.absent(),
    this.needsDownload = const Value.absent(),
    this.pendingOperation = const Value.absent(),
  }) : entityTable = Value(entityTable),
       localId = Value(localId);
  static Insertable<SyncMetadataData> custom({
    Expression<int>? id,
    Expression<String>? entityTable,
    Expression<int>? localId,
    Expression<int>? remoteId,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsUpload,
    Expression<bool>? needsDownload,
    Expression<String>? pendingOperation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (localId != null) 'local_id': localId,
      if (remoteId != null) 'remote_id': remoteId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsUpload != null) 'needs_upload': needsUpload,
      if (needsDownload != null) 'needs_download': needsDownload,
      if (pendingOperation != null) 'pending_operation': pendingOperation,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<int>? id,
    Value<String>? entityTable,
    Value<int>? localId,
    Value<int?>? remoteId,
    Value<DateTime?>? lastSyncedAt,
    Value<bool>? needsUpload,
    Value<bool>? needsDownload,
    Value<String?>? pendingOperation,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsUpload: needsUpload ?? this.needsUpload,
      needsDownload: needsDownload ?? this.needsDownload,
      pendingOperation: pendingOperation ?? this.pendingOperation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsUpload.present) {
      map['needs_upload'] = Variable<bool>(needsUpload.value);
    }
    if (needsDownload.present) {
      map['needs_download'] = Variable<bool>(needsDownload.value);
    }
    if (pendingOperation.present) {
      map['pending_operation'] = Variable<String>(pendingOperation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsUpload: $needsUpload, ')
          ..write('needsDownload: $needsDownload, ')
          ..write('pendingOperation: $pendingOperation')
          ..write(')'))
        .toString();
  }
}

class $OfflineQueueTable extends OfflineQueue
    with TableInfo<$OfflineQueueTable, OfflineQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineQueueTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operation,
    payload,
    createdAt,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineQueueData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      operation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation'],
          )!,
      payload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      retryCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}retry_count'],
          )!,
    );
  }

  @override
  $OfflineQueueTable createAlias(String alias) {
    return $OfflineQueueTable(attachedDatabase, alias);
  }
}

class OfflineQueueData extends DataClass
    implements Insertable<OfflineQueueData> {
  final int id;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  const OfflineQueueData({
    required this.id,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  OfflineQueueCompanion toCompanion(bool nullToAbsent) {
    return OfflineQueueCompanion(
      id: Value(id),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory OfflineQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineQueueData(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  OfflineQueueData copyWith({
    int? id,
    String? operation,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
  }) => OfflineQueueData(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  OfflineQueueData copyWithCompanion(OfflineQueueCompanion data) {
    return OfflineQueueData(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueueData(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, operation, payload, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineQueueData &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class OfflineQueueCompanion extends UpdateCompanion<OfflineQueueData> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const OfflineQueueCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  OfflineQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  }) : operation = Value(operation),
       payload = Value(payload);
  static Insertable<OfflineQueueData> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  OfflineQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return OfflineQueueCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueueCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String key;
  final String? value;
  const SyncMetaData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SyncMetaData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => SyncMetaData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTable extends UserProfile
    with TableInfo<$UserProfileTable, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastnameMeta = const VerificationMeta(
    'lastname',
  );
  @override
  late final GeneratedColumn<String> lastname = GeneratedColumn<String>(
    'lastname',
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
    email,
    firstname,
    lastname,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileData> instance, {
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
    }
    if (data.containsKey('lastname')) {
      context.handle(
        _lastnameMeta,
        lastname.isAcceptableOrUnknown(data['lastname']!, _lastnameMeta),
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
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      email:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}email'],
          )!,
      firstname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firstname'],
      ),
      lastname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lastname'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $UserProfileTable createAlias(String alias) {
    return $UserProfileTable(attachedDatabase, alias);
  }
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  final String id;
  final String email;
  final String? firstname;
  final String? lastname;
  final DateTime createdAt;
  const UserProfileData({
    required this.id,
    required this.email,
    this.firstname,
    this.lastname,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || firstname != null) {
      map['firstname'] = Variable<String>(firstname);
    }
    if (!nullToAbsent || lastname != null) {
      map['lastname'] = Variable<String>(lastname);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfileCompanion toCompanion(bool nullToAbsent) {
    return UserProfileCompanion(
      id: Value(id),
      email: Value(email),
      firstname:
          firstname == null && nullToAbsent
              ? const Value.absent()
              : Value(firstname),
      lastname:
          lastname == null && nullToAbsent
              ? const Value.absent()
              : Value(lastname),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      firstname: serializer.fromJson<String?>(json['firstname']),
      lastname: serializer.fromJson<String?>(json['lastname']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'firstname': serializer.toJson<String?>(firstname),
      'lastname': serializer.toJson<String?>(lastname),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfileData copyWith({
    String? id,
    String? email,
    Value<String?> firstname = const Value.absent(),
    Value<String?> lastname = const Value.absent(),
    DateTime? createdAt,
  }) => UserProfileData(
    id: id ?? this.id,
    email: email ?? this.email,
    firstname: firstname.present ? firstname.value : this.firstname,
    lastname: lastname.present ? lastname.value : this.lastname,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfileData copyWithCompanion(UserProfileCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      firstname: data.firstname.present ? data.firstname.value : this.firstname,
      lastname: data.lastname.present ? data.lastname.value : this.lastname,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstname: $firstname, ')
          ..write('lastname: $lastname, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, firstname, lastname, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.email == this.email &&
          other.firstname == this.firstname &&
          other.lastname == this.lastname &&
          other.createdAt == this.createdAt);
}

class UserProfileCompanion extends UpdateCompanion<UserProfileData> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> firstname;
  final Value<String?> lastname;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserProfileCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.firstname = const Value.absent(),
    this.lastname = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfileCompanion.insert({
    required String id,
    required String email,
    this.firstname = const Value.absent(),
    this.lastname = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       createdAt = Value(createdAt);
  static Insertable<UserProfileData> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? firstname,
    Expression<String>? lastname,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (firstname != null) 'firstname': firstname,
      if (lastname != null) 'lastname': lastname,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfileCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String?>? firstname,
    Value<String?>? lastname,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserProfileCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
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
    return (StringBuffer('UserProfileCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('firstname: $firstname, ')
          ..write('lastname: $lastname, ')
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
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $OfflineQueueTable offlineQueue = $OfflineQueueTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $UserProfileTable userProfile = $UserProfileTable(this);
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
    syncMetadata,
    offlineQueue,
    syncMeta,
    userProfile,
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
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
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
      Value<String?> syncId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> syncVersion,
      Value<bool> isDirty,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
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
      Value<String?> syncId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> syncVersion,
      Value<bool> isDirty,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssessmentsTable, List<Assessment>>
  _assessmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessments,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.assessments.sessionId),
  );

  $$AssessmentsTableProcessedTableManager get assessmentsRefs {
    final manager = $$AssessmentsTableTableManager(
      $_db,
      $_db.assessments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assessmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RepDatasTable, List<RepData>> _repDatasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.repDatas,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.repDatas.sessionId),
  );

  $$RepDatasTableProcessedTableManager get repDatasRefs {
    final manager = $$RepDatasTableTableManager(
      $_db,
      $_db.repDatas,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repDatasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentsRefs(
    Expression<bool> Function($$AssessmentsTableFilterComposer f) f,
  ) {
    final $$AssessmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableFilterComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> repDatasRefs(
    Expression<bool> Function($$RepDatasTableFilterComposer f) f,
  ) {
    final $$RepDatasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repDatas,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepDatasTableFilterComposer(
            $db: $db,
            $table: $db.repDatas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
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
  GeneratedColumn<int> get id =>
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  Expression<T> assessmentsRefs<T extends Object>(
    Expression<T> Function($$AssessmentsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> repDatasRefs<T extends Object>(
    Expression<T> Function($$RepDatasTableAnnotationComposer a) f,
  ) {
    final $$RepDatasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repDatas,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepDatasTableAnnotationComposer(
            $db: $db,
            $table: $db.repDatas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool assessmentsRefs, bool repDatasRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
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
                Value<String?> syncId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
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
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncVersion: syncVersion,
                isDirty: isDirty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
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
                Value<String?> syncId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
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
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncVersion: syncVersion,
                isDirty: isDirty,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$SessionsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            assessmentsRefs = false,
            repDatasRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentsRefs) db.assessments,
                if (repDatasRefs) db.repDatas,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentsRefs)
                    await $_getPrefetchedData<
                      Session,
                      $SessionsTable,
                      Assessment
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._assessmentsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (repDatasRefs)
                    await $_getPrefetchedData<Session, $SessionsTable, RepData>(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._repDatasRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).repDatasRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.sessionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool assessmentsRefs, bool repDatasRefs})
    >;
typedef $$AssessmentsTableCreateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      required int type,
      Value<double?> rightValue,
      Value<double?> leftValue,
      required int sessionId,
      Value<int?> gripPosition,
    });
typedef $$AssessmentsTableUpdateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      Value<int> type,
      Value<double?> rightValue,
      Value<double?> leftValue,
      Value<int> sessionId,
      Value<int?> gripPosition,
    });

final class $$AssessmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment> {
  $$AssessmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.assessments.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableFilterComposer({
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

  ColumnFilters<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
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

  ColumnOrderings<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get rightValue => $composableBuilder(
    column: $table.rightValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leftValue =>
      $composableBuilder(column: $table.leftValue, builder: (column) => column);

  GeneratedColumn<int> get gripPosition => $composableBuilder(
    column: $table.gripPosition,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (Assessment, $$AssessmentsTableReferences),
          Assessment,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AssessmentsTableTableManager(_$AppDatabase db, $AssessmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AssessmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$AssessmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<double?> rightValue = const Value.absent(),
                Value<double?> leftValue = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int?> gripPosition = const Value.absent(),
              }) => AssessmentsCompanion(
                id: id,
                type: type,
                rightValue: rightValue,
                leftValue: leftValue,
                sessionId: sessionId,
                gripPosition: gripPosition,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int type,
                Value<double?> rightValue = const Value.absent(),
                Value<double?> leftValue = const Value.absent(),
                required int sessionId,
                Value<int?> gripPosition = const Value.absent(),
              }) => AssessmentsCompanion.insert(
                id: id,
                type: type,
                rightValue: rightValue,
                leftValue: leftValue,
                sessionId: sessionId,
                gripPosition: gripPosition,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AssessmentsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (sessionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$AssessmentsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn:
                                $$AssessmentsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (Assessment, $$AssessmentsTableReferences),
      Assessment,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$RepeatersTableCreateCompanionBuilder =
    RepeatersCompanion Function({
      Value<int> id,
      required int sets,
      required int reps,
      required int worktime,
      required int resttime,
      required int setRest,
      Value<double?> targetWeigthRight,
      Value<double?> targetWeigthLeft,
      required bool splitHand,
      Value<int> gripPosition,
      Value<String?> syncId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> syncVersion,
      Value<bool> isDirty,
    });
typedef $$RepeatersTableUpdateCompanionBuilder =
    RepeatersCompanion Function({
      Value<int> id,
      Value<int> sets,
      Value<int> reps,
      Value<int> worktime,
      Value<int> resttime,
      Value<int> setRest,
      Value<double?> targetWeigthRight,
      Value<double?> targetWeigthLeft,
      Value<bool> splitHand,
      Value<int> gripPosition,
      Value<String?> syncId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> syncVersion,
      Value<bool> isDirty,
    });

final class $$RepeatersTableReferences
    extends BaseReferences<_$AppDatabase, $RepeatersTable, Repeater> {
  $$RepeatersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrainingsTable, List<Training>>
  _trainingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trainings,
    aliasName: $_aliasNameGenerator(db.repeaters.id, db.trainings.repeaterId),
  );

  $$TrainingsTableProcessedTableManager get trainingsRefs {
    final manager = $$TrainingsTableTableManager(
      $_db,
      $_db.trainings,
    ).filter((f) => f.repeaterId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trainingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RepeatersTableFilterComposer
    extends Composer<_$AppDatabase, $RepeatersTable> {
  $$RepeatersTableFilterComposer({
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trainingsRefs(
    Expression<bool> Function($$TrainingsTableFilterComposer f) f,
  ) {
    final $$TrainingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainings,
      getReferencedColumn: (t) => t.repeaterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingsTableFilterComposer(
            $db: $db,
            $table: $db.trainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
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
  GeneratedColumn<int> get id =>
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  Expression<T> trainingsRefs<T extends Object>(
    Expression<T> Function($$TrainingsTableAnnotationComposer a) f,
  ) {
    final $$TrainingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainings,
      getReferencedColumn: (t) => t.repeaterId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (Repeater, $$RepeatersTableReferences),
          Repeater,
          PrefetchHooks Function({bool trainingsRefs})
        > {
  $$RepeatersTableTableManager(_$AppDatabase db, $RepeatersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RepeatersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RepeatersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RepeatersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> worktime = const Value.absent(),
                Value<int> resttime = const Value.absent(),
                Value<int> setRest = const Value.absent(),
                Value<double?> targetWeigthRight = const Value.absent(),
                Value<double?> targetWeigthLeft = const Value.absent(),
                Value<bool> splitHand = const Value.absent(),
                Value<int> gripPosition = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
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
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncVersion: syncVersion,
                isDirty: isDirty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sets,
                required int reps,
                required int worktime,
                required int resttime,
                required int setRest,
                Value<double?> targetWeigthRight = const Value.absent(),
                Value<double?> targetWeigthLeft = const Value.absent(),
                required bool splitHand,
                Value<int> gripPosition = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
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
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncVersion: syncVersion,
                isDirty: isDirty,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$RepeatersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({trainingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (trainingsRefs) db.trainings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trainingsRefs)
                    await $_getPrefetchedData<
                      Repeater,
                      $RepeatersTable,
                      Training
                    >(
                      currentTable: table,
                      referencedTable: $$RepeatersTableReferences
                          ._trainingsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$RepeatersTableReferences(
                                db,
                                table,
                                p0,
                              ).trainingsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.repeaterId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (Repeater, $$RepeatersTableReferences),
      Repeater,
      PrefetchHooks Function({bool trainingsRefs})
    >;
typedef $$TrainingsTableCreateCompanionBuilder =
    TrainingsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> repeaterId,
      Value<bool> isBuiltin,
      Value<bool> isFavorite,
      Value<bool> isAssessment,
      Value<String?> syncId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> syncVersion,
      Value<bool> isDirty,
    });
typedef $$TrainingsTableUpdateCompanionBuilder =
    TrainingsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> repeaterId,
      Value<bool> isBuiltin,
      Value<bool> isFavorite,
      Value<bool> isAssessment,
      Value<String?> syncId,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deviceId,
      Value<int> syncVersion,
      Value<bool> isDirty,
    });

final class $$TrainingsTableReferences
    extends BaseReferences<_$AppDatabase, $TrainingsTable, Training> {
  $$TrainingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RepeatersTable _repeaterIdTable(_$AppDatabase db) =>
      db.repeaters.createAlias(
        $_aliasNameGenerator(db.trainings.repeaterId, db.repeaters.id),
      );

  $$RepeatersTableProcessedTableManager? get repeaterId {
    final $_column = $_itemColumn<int>('repeater_id');
    if ($_column == null) return null;
    final manager = $$RepeatersTableTableManager(
      $_db,
      $_db.repeaters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_repeaterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RepTemplatesTable, List<RepTemplate>>
  _repTemplatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repTemplates,
    aliasName: $_aliasNameGenerator(
      db.trainings.id,
      db.repTemplates.trainingId,
    ),
  );

  $$RepTemplatesTableProcessedTableManager get repTemplatesRefs {
    final manager = $$RepTemplatesTableTableManager(
      $_db,
      $_db.repTemplates,
    ).filter((f) => f.trainingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repTemplatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BuiltinTrainingWeightsTable,
    List<BuiltinTrainingWeight>
  >
  _builtinTrainingWeightsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.builtinTrainingWeights,
        aliasName: $_aliasNameGenerator(
          db.trainings.id,
          db.builtinTrainingWeights.builtinTrainingId,
        ),
      );

  $$BuiltinTrainingWeightsTableProcessedTableManager
  get builtinTrainingWeightsRefs {
    final manager = $$BuiltinTrainingWeightsTableTableManager(
      $_db,
      $_db.builtinTrainingWeights,
    ).filter((f) => f.builtinTrainingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _builtinTrainingWeightsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrainingsTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingsTable> {
  $$TrainingsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  $$RepeatersTableFilterComposer get repeaterId {
    final $$RepeatersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.repeaterId,
      referencedTable: $db.repeaters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepeatersTableFilterComposer(
            $db: $db,
            $table: $db.repeaters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> repTemplatesRefs(
    Expression<bool> Function($$RepTemplatesTableFilterComposer f) f,
  ) {
    final $$RepTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repTemplates,
      getReferencedColumn: (t) => t.trainingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.repTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> builtinTrainingWeightsRefs(
    Expression<bool> Function($$BuiltinTrainingWeightsTableFilterComposer f) f,
  ) {
    final $$BuiltinTrainingWeightsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.builtinTrainingWeights,
          getReferencedColumn: (t) => t.builtinTrainingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BuiltinTrainingWeightsTableFilterComposer(
                $db: $db,
                $table: $db.builtinTrainingWeights,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  $$RepeatersTableOrderingComposer get repeaterId {
    final $$RepeatersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.repeaterId,
      referencedTable: $db.repeaters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepeatersTableOrderingComposer(
            $db: $db,
            $table: $db.repeaters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  $$RepeatersTableAnnotationComposer get repeaterId {
    final $$RepeatersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.repeaterId,
      referencedTable: $db.repeaters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepeatersTableAnnotationComposer(
            $db: $db,
            $table: $db.repeaters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> repTemplatesRefs<T extends Object>(
    Expression<T> Function($$RepTemplatesTableAnnotationComposer a) f,
  ) {
    final $$RepTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repTemplates,
      getReferencedColumn: (t) => t.trainingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.repTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> builtinTrainingWeightsRefs<T extends Object>(
    Expression<T> Function($$BuiltinTrainingWeightsTableAnnotationComposer a) f,
  ) {
    final $$BuiltinTrainingWeightsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.builtinTrainingWeights,
          getReferencedColumn: (t) => t.builtinTrainingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BuiltinTrainingWeightsTableAnnotationComposer(
                $db: $db,
                $table: $db.builtinTrainingWeights,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (Training, $$TrainingsTableReferences),
          Training,
          PrefetchHooks Function({
            bool repeaterId,
            bool repTemplatesRefs,
            bool builtinTrainingWeightsRefs,
          })
        > {
  $$TrainingsTableTableManager(_$AppDatabase db, $TrainingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TrainingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TrainingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TrainingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> repeaterId = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isAssessment = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
              }) => TrainingsCompanion(
                id: id,
                name: name,
                repeaterId: repeaterId,
                isBuiltin: isBuiltin,
                isFavorite: isFavorite,
                isAssessment: isAssessment,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncVersion: syncVersion,
                isDirty: isDirty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> repeaterId = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isAssessment = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
              }) => TrainingsCompanion.insert(
                id: id,
                name: name,
                repeaterId: repeaterId,
                isBuiltin: isBuiltin,
                isFavorite: isFavorite,
                isAssessment: isAssessment,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                syncVersion: syncVersion,
                isDirty: isDirty,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TrainingsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            repeaterId = false,
            repTemplatesRefs = false,
            builtinTrainingWeightsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (repTemplatesRefs) db.repTemplates,
                if (builtinTrainingWeightsRefs) db.builtinTrainingWeights,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (repeaterId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.repeaterId,
                            referencedTable: $$TrainingsTableReferences
                                ._repeaterIdTable(db),
                            referencedColumn:
                                $$TrainingsTableReferences
                                    ._repeaterIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (repTemplatesRefs)
                    await $_getPrefetchedData<
                      Training,
                      $TrainingsTable,
                      RepTemplate
                    >(
                      currentTable: table,
                      referencedTable: $$TrainingsTableReferences
                          ._repTemplatesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$TrainingsTableReferences(
                                db,
                                table,
                                p0,
                              ).repTemplatesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.trainingId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (builtinTrainingWeightsRefs)
                    await $_getPrefetchedData<
                      Training,
                      $TrainingsTable,
                      BuiltinTrainingWeight
                    >(
                      currentTable: table,
                      referencedTable: $$TrainingsTableReferences
                          ._builtinTrainingWeightsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$TrainingsTableReferences(
                                db,
                                table,
                                p0,
                              ).builtinTrainingWeightsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.builtinTrainingId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
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
      (Training, $$TrainingsTableReferences),
      Training,
      PrefetchHooks Function({
        bool repeaterId,
        bool repTemplatesRefs,
        bool builtinTrainingWeightsRefs,
      })
    >;
typedef $$RepTemplatesTableCreateCompanionBuilder =
    RepTemplatesCompanion Function({
      Value<int> id,
      required bool isRest,
      required bool rightHand,
      required int duration,
      required int trainingId,
      required double targetWeight,
      required int index,
      Value<int> gripPosition,
    });
typedef $$RepTemplatesTableUpdateCompanionBuilder =
    RepTemplatesCompanion Function({
      Value<int> id,
      Value<bool> isRest,
      Value<bool> rightHand,
      Value<int> duration,
      Value<int> trainingId,
      Value<double> targetWeight,
      Value<int> index,
      Value<int> gripPosition,
    });

final class $$RepTemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $RepTemplatesTable, RepTemplate> {
  $$RepTemplatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrainingsTable _trainingIdTable(_$AppDatabase db) =>
      db.trainings.createAlias(
        $_aliasNameGenerator(db.repTemplates.trainingId, db.trainings.id),
      );

  $$TrainingsTableProcessedTableManager get trainingId {
    final $_column = $_itemColumn<int>('training_id')!;

    final manager = $$TrainingsTableTableManager(
      $_db,
      $_db.trainings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trainingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RepTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $RepTemplatesTable> {
  $$RepTemplatesTableFilterComposer({
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

  $$TrainingsTableFilterComposer get trainingId {
    final $$TrainingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingId,
      referencedTable: $db.trainings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingsTableFilterComposer(
            $db: $db,
            $table: $db.trainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
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

  $$TrainingsTableOrderingComposer get trainingId {
    final $$TrainingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingId,
      referencedTable: $db.trainings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingsTableOrderingComposer(
            $db: $db,
            $table: $db.trainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

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

  $$TrainingsTableAnnotationComposer get trainingId {
    final $$TrainingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trainingId,
      referencedTable: $db.trainings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (RepTemplate, $$RepTemplatesTableReferences),
          RepTemplate,
          PrefetchHooks Function({bool trainingId})
        > {
  $$RepTemplatesTableTableManager(_$AppDatabase db, $RepTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RepTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RepTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$RepTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> isRest = const Value.absent(),
                Value<bool> rightHand = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> trainingId = const Value.absent(),
                Value<double> targetWeight = const Value.absent(),
                Value<int> index = const Value.absent(),
                Value<int> gripPosition = const Value.absent(),
              }) => RepTemplatesCompanion(
                id: id,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                trainingId: trainingId,
                targetWeight: targetWeight,
                index: index,
                gripPosition: gripPosition,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool isRest,
                required bool rightHand,
                required int duration,
                required int trainingId,
                required double targetWeight,
                required int index,
                Value<int> gripPosition = const Value.absent(),
              }) => RepTemplatesCompanion.insert(
                id: id,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                trainingId: trainingId,
                targetWeight: targetWeight,
                index: index,
                gripPosition: gripPosition,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$RepTemplatesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({trainingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (trainingId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.trainingId,
                            referencedTable: $$RepTemplatesTableReferences
                                ._trainingIdTable(db),
                            referencedColumn:
                                $$RepTemplatesTableReferences
                                    ._trainingIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (RepTemplate, $$RepTemplatesTableReferences),
      RepTemplate,
      PrefetchHooks Function({bool trainingId})
    >;
typedef $$RepDatasTableCreateCompanionBuilder =
    RepDatasCompanion Function({
      Value<int> id,
      required double averageWeight,
      required int sessionId,
      required bool isRest,
      required bool rightHand,
      required int duration,
      required double targetWeight,
      required int index,
      Value<int> gripPosition,
    });
typedef $$RepDatasTableUpdateCompanionBuilder =
    RepDatasCompanion Function({
      Value<int> id,
      Value<double> averageWeight,
      Value<int> sessionId,
      Value<bool> isRest,
      Value<bool> rightHand,
      Value<int> duration,
      Value<double> targetWeight,
      Value<int> index,
      Value<int> gripPosition,
    });

final class $$RepDatasTableReferences
    extends BaseReferences<_$AppDatabase, $RepDatasTable, RepData> {
  $$RepDatasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) => db.sessions
      .createAlias($_aliasNameGenerator(db.repDatas.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RepDatasTableFilterComposer
    extends Composer<_$AppDatabase, $RepDatasTable> {
  $$RepDatasTableFilterComposer({
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

  ColumnFilters<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
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

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
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

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get averageWeight => $composableBuilder(
    column: $table.averageWeight,
    builder: (column) => column,
  );

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

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (RepData, $$RepDatasTableReferences),
          RepData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RepDatasTableTableManager(_$AppDatabase db, $RepDatasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RepDatasTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RepDatasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RepDatasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> averageWeight = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<bool> isRest = const Value.absent(),
                Value<bool> rightHand = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<double> targetWeight = const Value.absent(),
                Value<int> index = const Value.absent(),
                Value<int> gripPosition = const Value.absent(),
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
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double averageWeight,
                required int sessionId,
                required bool isRest,
                required bool rightHand,
                required int duration,
                required double targetWeight,
                required int index,
                Value<int> gripPosition = const Value.absent(),
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
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$RepDatasTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (sessionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$RepDatasTableReferences
                                ._sessionIdTable(db),
                            referencedColumn:
                                $$RepDatasTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (RepData, $$RepDatasTableReferences),
      RepData,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SensorConfigsTableCreateCompanionBuilder =
    SensorConfigsCompanion Function({
      Value<int> id,
      required String name,
      required int index,
      required double tare,
      required double coef,
    });
typedef $$SensorConfigsTableUpdateCompanionBuilder =
    SensorConfigsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> index,
      Value<double> tare,
      Value<double> coef,
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
  ColumnFilters<int> get id => $composableBuilder(
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
  ColumnOrderings<int> get id => $composableBuilder(
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get index =>
      $composableBuilder(column: $table.index, builder: (column) => column);

  GeneratedColumn<double> get tare =>
      $composableBuilder(column: $table.tare, builder: (column) => column);

  GeneratedColumn<double> get coef =>
      $composableBuilder(column: $table.coef, builder: (column) => column);
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
          createFilteringComposer:
              () => $$SensorConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SensorConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SensorConfigsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> index = const Value.absent(),
                Value<double> tare = const Value.absent(),
                Value<double> coef = const Value.absent(),
              }) => SensorConfigsCompanion(
                id: id,
                name: name,
                index: index,
                tare: tare,
                coef: coef,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int index,
                required double tare,
                required double coef,
              }) => SensorConfigsCompanion.insert(
                id: id,
                name: name,
                index: index,
                tare: tare,
                coef: coef,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
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
      Value<int> id,
      required int builtinTrainingId,
      Value<double?> customWeightRight,
      Value<double?> customWeightLeft,
      Value<DateTime> updatedAt,
    });
typedef $$BuiltinTrainingWeightsTableUpdateCompanionBuilder =
    BuiltinTrainingWeightsCompanion Function({
      Value<int> id,
      Value<int> builtinTrainingId,
      Value<double?> customWeightRight,
      Value<double?> customWeightLeft,
      Value<DateTime> updatedAt,
    });

final class $$BuiltinTrainingWeightsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BuiltinTrainingWeightsTable,
          BuiltinTrainingWeight
        > {
  $$BuiltinTrainingWeightsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrainingsTable _builtinTrainingIdTable(_$AppDatabase db) =>
      db.trainings.createAlias(
        $_aliasNameGenerator(
          db.builtinTrainingWeights.builtinTrainingId,
          db.trainings.id,
        ),
      );

  $$TrainingsTableProcessedTableManager get builtinTrainingId {
    final $_column = $_itemColumn<int>('builtin_training_id')!;

    final manager = $$TrainingsTableTableManager(
      $_db,
      $_db.trainings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_builtinTrainingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BuiltinTrainingWeightsTableFilterComposer
    extends Composer<_$AppDatabase, $BuiltinTrainingWeightsTable> {
  $$BuiltinTrainingWeightsTableFilterComposer({
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

  $$TrainingsTableFilterComposer get builtinTrainingId {
    final $$TrainingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.builtinTrainingId,
      referencedTable: $db.trainings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingsTableFilterComposer(
            $db: $db,
            $table: $db.trainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
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

  $$TrainingsTableOrderingComposer get builtinTrainingId {
    final $$TrainingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.builtinTrainingId,
      referencedTable: $db.trainings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingsTableOrderingComposer(
            $db: $db,
            $table: $db.trainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

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

  $$TrainingsTableAnnotationComposer get builtinTrainingId {
    final $$TrainingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.builtinTrainingId,
      referencedTable: $db.trainings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (BuiltinTrainingWeight, $$BuiltinTrainingWeightsTableReferences),
          BuiltinTrainingWeight,
          PrefetchHooks Function({bool builtinTrainingId})
        > {
  $$BuiltinTrainingWeightsTableTableManager(
    _$AppDatabase db,
    $BuiltinTrainingWeightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BuiltinTrainingWeightsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$BuiltinTrainingWeightsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$BuiltinTrainingWeightsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> builtinTrainingId = const Value.absent(),
                Value<double?> customWeightRight = const Value.absent(),
                Value<double?> customWeightLeft = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BuiltinTrainingWeightsCompanion(
                id: id,
                builtinTrainingId: builtinTrainingId,
                customWeightRight: customWeightRight,
                customWeightLeft: customWeightLeft,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int builtinTrainingId,
                Value<double?> customWeightRight = const Value.absent(),
                Value<double?> customWeightLeft = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BuiltinTrainingWeightsCompanion.insert(
                id: id,
                builtinTrainingId: builtinTrainingId,
                customWeightRight: customWeightRight,
                customWeightLeft: customWeightLeft,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$BuiltinTrainingWeightsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({builtinTrainingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (builtinTrainingId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.builtinTrainingId,
                            referencedTable:
                                $$BuiltinTrainingWeightsTableReferences
                                    ._builtinTrainingIdTable(db),
                            referencedColumn:
                                $$BuiltinTrainingWeightsTableReferences
                                    ._builtinTrainingIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (BuiltinTrainingWeight, $$BuiltinTrainingWeightsTableReferences),
      BuiltinTrainingWeight,
      PrefetchHooks Function({bool builtinTrainingId})
    >;
typedef $$PinnedBuiltinTrainingsTableCreateCompanionBuilder =
    PinnedBuiltinTrainingsCompanion Function({Value<int> builtinTrainingId});
typedef $$PinnedBuiltinTrainingsTableUpdateCompanionBuilder =
    PinnedBuiltinTrainingsCompanion Function({Value<int> builtinTrainingId});

class $$PinnedBuiltinTrainingsTableFilterComposer
    extends Composer<_$AppDatabase, $PinnedBuiltinTrainingsTable> {
  $$PinnedBuiltinTrainingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
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
  ColumnOrderings<int> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
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
  GeneratedColumn<int> get builtinTrainingId => $composableBuilder(
    column: $table.builtinTrainingId,
    builder: (column) => column,
  );
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
          createFilteringComposer:
              () => $$PinnedBuiltinTrainingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$PinnedBuiltinTrainingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PinnedBuiltinTrainingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({Value<int> builtinTrainingId = const Value.absent()}) =>
                  PinnedBuiltinTrainingsCompanion(
                    builtinTrainingId: builtinTrainingId,
                  ),
          createCompanionCallback:
              ({Value<int> builtinTrainingId = const Value.absent()}) =>
                  PinnedBuiltinTrainingsCompanion.insert(
                    builtinTrainingId: builtinTrainingId,
                  ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
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
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      required String entityTable,
      required int localId,
      Value<int?> remoteId,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsUpload,
      Value<bool> needsDownload,
      Value<String?> pendingOperation,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      Value<String> entityTable,
      Value<int> localId,
      Value<int?> remoteId,
      Value<DateTime?> lastSyncedAt,
      Value<bool> needsUpload,
      Value<bool> needsDownload,
      Value<String?> pendingOperation,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
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

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsUpload => $composableBuilder(
    column: $table.needsUpload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsDownload => $composableBuilder(
    column: $table.needsDownload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingOperation => $composableBuilder(
    column: $table.pendingOperation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
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

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsUpload => $composableBuilder(
    column: $table.needsUpload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsDownload => $composableBuilder(
    column: $table.needsDownload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingOperation => $composableBuilder(
    column: $table.pendingOperation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsUpload => $composableBuilder(
    column: $table.needsUpload,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsDownload => $composableBuilder(
    column: $table.needsDownload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingOperation => $composableBuilder(
    column: $table.pendingOperation,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<int> localId = const Value.absent(),
                Value<int?> remoteId = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsUpload = const Value.absent(),
                Value<bool> needsDownload = const Value.absent(),
                Value<String?> pendingOperation = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                entityTable: entityTable,
                localId: localId,
                remoteId: remoteId,
                lastSyncedAt: lastSyncedAt,
                needsUpload: needsUpload,
                needsDownload: needsDownload,
                pendingOperation: pendingOperation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityTable,
                required int localId,
                Value<int?> remoteId = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<bool> needsUpload = const Value.absent(),
                Value<bool> needsDownload = const Value.absent(),
                Value<String?> pendingOperation = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                id: id,
                entityTable: entityTable,
                localId: localId,
                remoteId: remoteId,
                lastSyncedAt: lastSyncedAt,
                needsUpload: needsUpload,
                needsDownload: needsDownload,
                pendingOperation: pendingOperation,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$OfflineQueueTableCreateCompanionBuilder =
    OfflineQueueCompanion Function({
      Value<int> id,
      required String operation,
      required String payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });
typedef $$OfflineQueueTableUpdateCompanionBuilder =
    OfflineQueueCompanion Function({
      Value<int> id,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });

class $$OfflineQueueTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableFilterComposer({
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

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableOrderingComposer({
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

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$OfflineQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfflineQueueTable,
          OfflineQueueData,
          $$OfflineQueueTableFilterComposer,
          $$OfflineQueueTableOrderingComposer,
          $$OfflineQueueTableAnnotationComposer,
          $$OfflineQueueTableCreateCompanionBuilder,
          $$OfflineQueueTableUpdateCompanionBuilder,
          (
            OfflineQueueData,
            BaseReferences<_$AppDatabase, $OfflineQueueTable, OfflineQueueData>,
          ),
          OfflineQueueData,
          PrefetchHooks Function()
        > {
  $$OfflineQueueTableTableManager(_$AppDatabase db, $OfflineQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$OfflineQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$OfflineQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$OfflineQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => OfflineQueueCompanion(
                id: id,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operation,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => OfflineQueueCompanion.insert(
                id: id,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfflineQueueTable,
      OfflineQueueData,
      $$OfflineQueueTableFilterComposer,
      $$OfflineQueueTableOrderingComposer,
      $$OfflineQueueTableAnnotationComposer,
      $$OfflineQueueTableCreateCompanionBuilder,
      $$OfflineQueueTableUpdateCompanionBuilder,
      (
        OfflineQueueData,
        BaseReferences<_$AppDatabase, $OfflineQueueTable, OfflineQueueData>,
      ),
      OfflineQueueData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaData,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
          ),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaData,
        BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
      ),
      SyncMetaData,
      PrefetchHooks Function()
    >;
typedef $$UserProfileTableCreateCompanionBuilder =
    UserProfileCompanion Function({
      required String id,
      required String email,
      Value<String?> firstname,
      Value<String?> lastname,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UserProfileTableUpdateCompanionBuilder =
    UserProfileCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String?> firstname,
      Value<String?> lastname,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UserProfileTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfileTable,
          UserProfileData,
          $$UserProfileTableFilterComposer,
          $$UserProfileTableOrderingComposer,
          $$UserProfileTableAnnotationComposer,
          $$UserProfileTableCreateCompanionBuilder,
          $$UserProfileTableUpdateCompanionBuilder,
          (
            UserProfileData,
            BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>,
          ),
          UserProfileData,
          PrefetchHooks Function()
        > {
  $$UserProfileTableTableManager(_$AppDatabase db, $UserProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$UserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> firstname = const Value.absent(),
                Value<String?> lastname = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfileCompanion(
                id: id,
                email: email,
                firstname: firstname,
                lastname: lastname,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                Value<String?> firstname = const Value.absent(),
                Value<String?> lastname = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfileCompanion.insert(
                id: id,
                email: email,
                firstname: firstname,
                lastname: lastname,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfileTable,
      UserProfileData,
      $$UserProfileTableFilterComposer,
      $$UserProfileTableOrderingComposer,
      $$UserProfileTableAnnotationComposer,
      $$UserProfileTableCreateCompanionBuilder,
      $$UserProfileTableUpdateCompanionBuilder,
      (
        UserProfileData,
        BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>,
      ),
      UserProfileData,
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
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$OfflineQueueTableTableManager get offlineQueue =>
      $$OfflineQueueTableTableManager(_db, _db.offlineQueue);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$UserProfileTableTableManager get userProfile =>
      $$UserProfileTableTableManager(_db, _db.userProfile);
}
