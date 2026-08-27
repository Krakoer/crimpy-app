// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Sessions extends Table with TableInfo<Sessions, SessionsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Sessions(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
  late final GeneratedColumn<int> activity = GeneratedColumn<int>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'logged\'',
    defaultValue: const CustomExpression('\'logged\''),
  );
  late final GeneratedColumn<String> trainingId = GeneratedColumn<String>(
    'training_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> programSessionId = GeneratedColumn<String>(
    'program_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
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
  late final GeneratedColumn<String> prescriptionJson = GeneratedColumn<String>(
    'prescription_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    prescriptionJson,
    updatedAt,
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
      prescriptionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescription_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Sessions createAlias(String alias) {
    return Sessions(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class SessionsData extends DataClass implements Insertable<SessionsData> {
  final String id;
  final String name;
  final String notes;
  final int date;
  final String dataPath;
  final int isAssessment;
  final int activity;
  final String origin;
  final String? trainingId;
  final String? programSessionId;
  final int duration;
  final String? prescriptionJson;
  final int updatedAt;
  const SessionsData({
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
    this.prescriptionJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    map['date'] = Variable<int>(date);
    map['data_path'] = Variable<String>(dataPath);
    map['is_assessment'] = Variable<int>(isAssessment);
    map['activity'] = Variable<int>(activity);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || trainingId != null) {
      map['training_id'] = Variable<String>(trainingId);
    }
    if (!nullToAbsent || programSessionId != null) {
      map['program_session_id'] = Variable<String>(programSessionId);
    }
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || prescriptionJson != null) {
      map['prescription_json'] = Variable<String>(prescriptionJson);
    }
    map['updated_at'] = Variable<int>(updatedAt);
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
      prescriptionJson: prescriptionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriptionJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionsData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
      date: serializer.fromJson<int>(json['date']),
      dataPath: serializer.fromJson<String>(json['dataPath']),
      isAssessment: serializer.fromJson<int>(json['isAssessment']),
      activity: serializer.fromJson<int>(json['activity']),
      origin: serializer.fromJson<String>(json['origin']),
      trainingId: serializer.fromJson<String?>(json['trainingId']),
      programSessionId: serializer.fromJson<String?>(json['programSessionId']),
      duration: serializer.fromJson<int>(json['duration']),
      prescriptionJson: serializer.fromJson<String?>(json['prescriptionJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
      'date': serializer.toJson<int>(date),
      'dataPath': serializer.toJson<String>(dataPath),
      'isAssessment': serializer.toJson<int>(isAssessment),
      'activity': serializer.toJson<int>(activity),
      'origin': serializer.toJson<String>(origin),
      'trainingId': serializer.toJson<String?>(trainingId),
      'programSessionId': serializer.toJson<String?>(programSessionId),
      'duration': serializer.toJson<int>(duration),
      'prescriptionJson': serializer.toJson<String?>(prescriptionJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SessionsData copyWith({
    String? id,
    String? name,
    String? notes,
    int? date,
    String? dataPath,
    int? isAssessment,
    int? activity,
    String? origin,
    Value<String?> trainingId = const Value.absent(),
    Value<String?> programSessionId = const Value.absent(),
    int? duration,
    Value<String?> prescriptionJson = const Value.absent(),
    int? updatedAt,
  }) => SessionsData(
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
    prescriptionJson: prescriptionJson.present
        ? prescriptionJson.value
        : this.prescriptionJson,
    updatedAt: updatedAt ?? this.updatedAt,
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
      activity: data.activity.present ? data.activity.value : this.activity,
      origin: data.origin.present ? data.origin.value : this.origin,
      trainingId: data.trainingId.present
          ? data.trainingId.value
          : this.trainingId,
      programSessionId: data.programSessionId.present
          ? data.programSessionId.value
          : this.programSessionId,
      duration: data.duration.present ? data.duration.value : this.duration,
      prescriptionJson: data.prescriptionJson.present
          ? data.prescriptionJson.value
          : this.prescriptionJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
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
          ..write('activity: $activity, ')
          ..write('origin: $origin, ')
          ..write('trainingId: $trainingId, ')
          ..write('programSessionId: $programSessionId, ')
          ..write('duration: $duration, ')
          ..write('prescriptionJson: $prescriptionJson, ')
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
    prescriptionJson,
    updatedAt,
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
          other.activity == this.activity &&
          other.origin == this.origin &&
          other.trainingId == this.trainingId &&
          other.programSessionId == this.programSessionId &&
          other.duration == this.duration &&
          other.prescriptionJson == this.prescriptionJson &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<SessionsData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> notes;
  final Value<int> date;
  final Value<String> dataPath;
  final Value<int> isAssessment;
  final Value<int> activity;
  final Value<String> origin;
  final Value<String?> trainingId;
  final Value<String?> programSessionId;
  final Value<int> duration;
  final Value<String?> prescriptionJson;
  final Value<int> updatedAt;
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
    this.prescriptionJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
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
    this.prescriptionJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       notes = Value(notes),
       dataPath = Value(dataPath);
  static Insertable<SessionsData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<int>? date,
    Expression<String>? dataPath,
    Expression<int>? isAssessment,
    Expression<int>? activity,
    Expression<String>? origin,
    Expression<String>? trainingId,
    Expression<String>? programSessionId,
    Expression<int>? duration,
    Expression<String>? prescriptionJson,
    Expression<int>? updatedAt,
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
      if (prescriptionJson != null) 'prescription_json': prescriptionJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? notes,
    Value<int>? date,
    Value<String>? dataPath,
    Value<int>? isAssessment,
    Value<int>? activity,
    Value<String>? origin,
    Value<String?>? trainingId,
    Value<String?>? programSessionId,
    Value<int>? duration,
    Value<String?>? prescriptionJson,
    Value<int>? updatedAt,
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
      prescriptionJson: prescriptionJson ?? this.prescriptionJson,
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
      map['date'] = Variable<int>(date.value);
    }
    if (dataPath.present) {
      map['data_path'] = Variable<String>(dataPath.value);
    }
    if (isAssessment.present) {
      map['is_assessment'] = Variable<int>(isAssessment.value);
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
    if (prescriptionJson.present) {
      map['prescription_json'] = Variable<String>(prescriptionJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
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
          ..write('prescriptionJson: $prescriptionJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AssessmentDefinitions extends Table
    with TableInfo<AssessmentDefinitions, AssessmentDefinitionsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AssessmentDefinitions(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> perHand = GeneratedColumn<int>(
    'per_hand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (per_hand IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> trainingId = GeneratedColumn<String>(
    'training_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    unit,
    perHand,
    prompt,
    trainingId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessment_definitions';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentDefinitionsData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentDefinitionsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      perHand: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}per_hand'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      ),
      trainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  AssessmentDefinitions createAlias(String alias) {
    return AssessmentDefinitions(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class AssessmentDefinitionsData extends DataClass
    implements Insertable<AssessmentDefinitionsData> {
  final String id;
  final String label;
  final String unit;
  final int perHand;
  final String? prompt;
  final String? trainingId;
  final int updatedAt;
  const AssessmentDefinitionsData({
    required this.id,
    required this.label,
    required this.unit,
    required this.perHand,
    this.prompt,
    this.trainingId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['unit'] = Variable<String>(unit);
    map['per_hand'] = Variable<int>(perHand);
    if (!nullToAbsent || prompt != null) {
      map['prompt'] = Variable<String>(prompt);
    }
    if (!nullToAbsent || trainingId != null) {
      map['training_id'] = Variable<String>(trainingId);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AssessmentDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentDefinitionsCompanion(
      id: Value(id),
      label: Value(label),
      unit: Value(unit),
      perHand: Value(perHand),
      prompt: prompt == null && nullToAbsent
          ? const Value.absent()
          : Value(prompt),
      trainingId: trainingId == null && nullToAbsent
          ? const Value.absent()
          : Value(trainingId),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssessmentDefinitionsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentDefinitionsData(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      unit: serializer.fromJson<String>(json['unit']),
      perHand: serializer.fromJson<int>(json['perHand']),
      prompt: serializer.fromJson<String?>(json['prompt']),
      trainingId: serializer.fromJson<String?>(json['trainingId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'unit': serializer.toJson<String>(unit),
      'perHand': serializer.toJson<int>(perHand),
      'prompt': serializer.toJson<String?>(prompt),
      'trainingId': serializer.toJson<String?>(trainingId),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AssessmentDefinitionsData copyWith({
    String? id,
    String? label,
    String? unit,
    int? perHand,
    Value<String?> prompt = const Value.absent(),
    Value<String?> trainingId = const Value.absent(),
    int? updatedAt,
  }) => AssessmentDefinitionsData(
    id: id ?? this.id,
    label: label ?? this.label,
    unit: unit ?? this.unit,
    perHand: perHand ?? this.perHand,
    prompt: prompt.present ? prompt.value : this.prompt,
    trainingId: trainingId.present ? trainingId.value : this.trainingId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssessmentDefinitionsData copyWithCompanion(
    AssessmentDefinitionsCompanion data,
  ) {
    return AssessmentDefinitionsData(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      unit: data.unit.present ? data.unit.value : this.unit,
      perHand: data.perHand.present ? data.perHand.value : this.perHand,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      trainingId: data.trainingId.present
          ? data.trainingId.value
          : this.trainingId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentDefinitionsData(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('unit: $unit, ')
          ..write('perHand: $perHand, ')
          ..write('prompt: $prompt, ')
          ..write('trainingId: $trainingId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, label, unit, perHand, prompt, trainingId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentDefinitionsData &&
          other.id == this.id &&
          other.label == this.label &&
          other.unit == this.unit &&
          other.perHand == this.perHand &&
          other.prompt == this.prompt &&
          other.trainingId == this.trainingId &&
          other.updatedAt == this.updatedAt);
}

class AssessmentDefinitionsCompanion
    extends UpdateCompanion<AssessmentDefinitionsData> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> unit;
  final Value<int> perHand;
  final Value<String?> prompt;
  final Value<String?> trainingId;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AssessmentDefinitionsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.unit = const Value.absent(),
    this.perHand = const Value.absent(),
    this.prompt = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentDefinitionsCompanion.insert({
    required String id,
    required String label,
    required String unit,
    this.perHand = const Value.absent(),
    this.prompt = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       unit = Value(unit);
  static Insertable<AssessmentDefinitionsData> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? unit,
    Expression<int>? perHand,
    Expression<String>? prompt,
    Expression<String>? trainingId,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (unit != null) 'unit': unit,
      if (perHand != null) 'per_hand': perHand,
      if (prompt != null) 'prompt': prompt,
      if (trainingId != null) 'training_id': trainingId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? unit,
    Value<int>? perHand,
    Value<String?>? prompt,
    Value<String?>? trainingId,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AssessmentDefinitionsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      unit: unit ?? this.unit,
      perHand: perHand ?? this.perHand,
      prompt: prompt ?? this.prompt,
      trainingId: trainingId ?? this.trainingId,
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
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (perHand.present) {
      map['per_hand'] = Variable<int>(perHand.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (trainingId.present) {
      map['training_id'] = Variable<String>(trainingId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('unit: $unit, ')
          ..write('perHand: $perHand, ')
          ..write('prompt: $prompt, ')
          ..write('trainingId: $trainingId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Assessments extends Table with TableInfo<Assessments, AssessmentsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Assessments(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assessmentId,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
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
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Assessments createAlias(String alias) {
    return Assessments(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id)',
    'FOREIGN KEY(session_id)REFERENCES sessions(id)ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class AssessmentsData extends DataClass implements Insertable<AssessmentsData> {
  final String id;
  final String assessmentId;
  final double? rightValue;
  final double? leftValue;
  final String sessionId;
  final int? gripPosition;
  final int updatedAt;
  const AssessmentsData({
    required this.id,
    required this.assessmentId,
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
    map['assessment_id'] = Variable<String>(assessmentId);
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
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AssessmentsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentsCompanion(
      id: Value(id),
      assessmentId: Value(assessmentId),
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

  factory AssessmentsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentsData(
      id: serializer.fromJson<String>(json['id']),
      assessmentId: serializer.fromJson<String>(json['assessmentId']),
      rightValue: serializer.fromJson<double?>(json['rightValue']),
      leftValue: serializer.fromJson<double?>(json['leftValue']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      gripPosition: serializer.fromJson<int?>(json['gripPosition']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessmentId': serializer.toJson<String>(assessmentId),
      'rightValue': serializer.toJson<double?>(rightValue),
      'leftValue': serializer.toJson<double?>(leftValue),
      'sessionId': serializer.toJson<String>(sessionId),
      'gripPosition': serializer.toJson<int?>(gripPosition),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AssessmentsData copyWith({
    String? id,
    String? assessmentId,
    Value<double?> rightValue = const Value.absent(),
    Value<double?> leftValue = const Value.absent(),
    String? sessionId,
    Value<int?> gripPosition = const Value.absent(),
    int? updatedAt,
  }) => AssessmentsData(
    id: id ?? this.id,
    assessmentId: assessmentId ?? this.assessmentId,
    rightValue: rightValue.present ? rightValue.value : this.rightValue,
    leftValue: leftValue.present ? leftValue.value : this.leftValue,
    sessionId: sessionId ?? this.sessionId,
    gripPosition: gripPosition.present ? gripPosition.value : this.gripPosition,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssessmentsData copyWithCompanion(AssessmentsCompanion data) {
    return AssessmentsData(
      id: data.id.present ? data.id.value : this.id,
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
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
    return (StringBuffer('AssessmentsData(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
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
    assessmentId,
    rightValue,
    leftValue,
    sessionId,
    gripPosition,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentsData &&
          other.id == this.id &&
          other.assessmentId == this.assessmentId &&
          other.rightValue == this.rightValue &&
          other.leftValue == this.leftValue &&
          other.sessionId == this.sessionId &&
          other.gripPosition == this.gripPosition &&
          other.updatedAt == this.updatedAt);
}

class AssessmentsCompanion extends UpdateCompanion<AssessmentsData> {
  final Value<String> id;
  final Value<String> assessmentId;
  final Value<double?> rightValue;
  final Value<double?> leftValue;
  final Value<String> sessionId;
  final Value<int?> gripPosition;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.assessmentId = const Value.absent(),
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    required String id,
    required String assessmentId,
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    required String sessionId,
    this.gripPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessmentId = Value(assessmentId),
       sessionId = Value(sessionId);
  static Insertable<AssessmentsData> custom({
    Expression<String>? id,
    Expression<String>? assessmentId,
    Expression<double>? rightValue,
    Expression<double>? leftValue,
    Expression<String>? sessionId,
    Expression<int>? gripPosition,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentId != null) 'assessment_id': assessmentId,
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
    Value<String>? assessmentId,
    Value<double?>? rightValue,
    Value<double?>? leftValue,
    Value<String>? sessionId,
    Value<int?>? gripPosition,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
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
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
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
      map['updated_at'] = Variable<int>(updatedAt.value);
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
          ..write('assessmentId: $assessmentId, ')
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

class Trainings extends Table with TableInfo<Trainings, TrainingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Trainings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingsData(
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
        DriftSqlType.int,
        data['${effectivePrefix}is_favorite'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Trainings createAlias(String alias) {
    return Trainings(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class TrainingsData extends DataClass implements Insertable<TrainingsData> {
  final String id;
  final String title;
  final String? description;
  final int isFavorite;
  final int updatedAt;
  const TrainingsData({
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
    map['is_favorite'] = Variable<int>(isFavorite);
    map['updated_at'] = Variable<int>(updatedAt);
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

  factory TrainingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingsData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isFavorite: serializer.fromJson<int>(json['isFavorite']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isFavorite': serializer.toJson<int>(isFavorite),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TrainingsData copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    int? isFavorite,
    int? updatedAt,
  }) => TrainingsData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    isFavorite: isFavorite ?? this.isFavorite,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrainingsData copyWithCompanion(TrainingsCompanion data) {
    return TrainingsData(
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
    return (StringBuffer('TrainingsData(')
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
      (other is TrainingsData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.isFavorite == this.isFavorite &&
          other.updatedAt == this.updatedAt);
}

class TrainingsCompanion extends UpdateCompanion<TrainingsData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> isFavorite;
  final Value<int> updatedAt;
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
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<TrainingsData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? isFavorite,
    Expression<int>? updatedAt,
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
    Value<int>? isFavorite,
    Value<int>? updatedAt,
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
      map['is_favorite'] = Variable<int>(isFavorite.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
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

class TrainingItems extends Table
    with TableInfo<TrainingItems, TrainingItemsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TrainingItems(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> trainingId = GeneratedColumn<String>(
    'training_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> cycles = GeneratedColumn<int>(
    'cycles',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> cycleRestSeconds = GeneratedColumn<int>(
    'cycle_rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> intervalSeconds = GeneratedColumn<int>(
    'interval_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> repsIsMax = GeneratedColumn<int>(
    'reps_is_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (reps_is_max IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> worktimeSeconds = GeneratedColumn<int>(
    'worktime_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> hand = GeneratedColumn<String>(
    'hand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> granularity = GeneratedColumn<String>(
    'granularity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> loadsJson = GeneratedColumn<String>(
    'loads_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> leftLoadsJson = GeneratedColumn<String>(
    'left_loads_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> handPositionsJson =
      GeneratedColumn<String>(
        'hand_positions_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'NULL',
      );
  late final GeneratedColumn<String> edgeSizesMmJson = GeneratedColumn<String>(
    'edge_sizes_mm_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> variableTargetsJson =
      GeneratedColumn<String>(
        'variable_targets_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'NULL',
      );
  late final GeneratedColumn<int> loadIsMax = GeneratedColumn<int>(
    'load_is_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (load_is_max IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> freeText = GeneratedColumn<String>(
    'free_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> groupTitle = GeneratedColumn<String>(
    'group_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trainingId,
    parentId,
    type,
    position,
    cycles,
    cycleRestSeconds,
    intervalSeconds,
    reps,
    repsIsMax,
    duration,
    restSeconds,
    worktimeSeconds,
    hand,
    granularity,
    loadsJson,
    leftLoadsJson,
    handPositionsJson,
    edgeSizesMmJson,
    variableTargetsJson,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingItemsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingItemsData(
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
      intervalSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_seconds'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      repsIsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps_is_max'],
      )!,
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
      variableTargetsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variable_targets_json'],
      ),
      loadIsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
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
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  TrainingItems createAlias(String alias) {
    return TrainingItems(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id)',
    'FOREIGN KEY(training_id)REFERENCES trainings(id)ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class TrainingItemsData extends DataClass
    implements Insertable<TrainingItemsData> {
  final String id;
  final String trainingId;
  final String? parentId;
  final String type;
  final int position;
  final int? cycles;
  final int? cycleRestSeconds;
  final int? intervalSeconds;
  final int? reps;
  final int repsIsMax;
  final int? duration;
  final int? restSeconds;
  final int? worktimeSeconds;
  final String? hand;
  final String? granularity;
  final String? loadsJson;
  final String? leftLoadsJson;
  final String? handPositionsJson;
  final String? edgeSizesMmJson;
  final String? variableTargetsJson;
  final int loadIsMax;
  final String? freeText;
  final String? exerciseId;
  final String? groupTitle;
  final int updatedAt;
  const TrainingItemsData({
    required this.id,
    required this.trainingId,
    this.parentId,
    required this.type,
    required this.position,
    this.cycles,
    this.cycleRestSeconds,
    this.intervalSeconds,
    this.reps,
    required this.repsIsMax,
    this.duration,
    this.restSeconds,
    this.worktimeSeconds,
    this.hand,
    this.granularity,
    this.loadsJson,
    this.leftLoadsJson,
    this.handPositionsJson,
    this.edgeSizesMmJson,
    this.variableTargetsJson,
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
    if (!nullToAbsent || intervalSeconds != null) {
      map['interval_seconds'] = Variable<int>(intervalSeconds);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    map['reps_is_max'] = Variable<int>(repsIsMax);
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
    if (!nullToAbsent || variableTargetsJson != null) {
      map['variable_targets_json'] = Variable<String>(variableTargetsJson);
    }
    map['load_is_max'] = Variable<int>(loadIsMax);
    if (!nullToAbsent || freeText != null) {
      map['free_text'] = Variable<String>(freeText);
    }
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    if (!nullToAbsent || groupTitle != null) {
      map['group_title'] = Variable<String>(groupTitle);
    }
    map['updated_at'] = Variable<int>(updatedAt);
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
      intervalSeconds: intervalSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalSeconds),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      repsIsMax: Value(repsIsMax),
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
      variableTargetsJson: variableTargetsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(variableTargetsJson),
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

  factory TrainingItemsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingItemsData(
      id: serializer.fromJson<String>(json['id']),
      trainingId: serializer.fromJson<String>(json['trainingId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      type: serializer.fromJson<String>(json['type']),
      position: serializer.fromJson<int>(json['position']),
      cycles: serializer.fromJson<int?>(json['cycles']),
      cycleRestSeconds: serializer.fromJson<int?>(json['cycleRestSeconds']),
      intervalSeconds: serializer.fromJson<int?>(json['intervalSeconds']),
      reps: serializer.fromJson<int?>(json['reps']),
      repsIsMax: serializer.fromJson<int>(json['repsIsMax']),
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
      variableTargetsJson: serializer.fromJson<String?>(
        json['variableTargetsJson'],
      ),
      loadIsMax: serializer.fromJson<int>(json['loadIsMax']),
      freeText: serializer.fromJson<String?>(json['freeText']),
      exerciseId: serializer.fromJson<String?>(json['exerciseId']),
      groupTitle: serializer.fromJson<String?>(json['groupTitle']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
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
      'intervalSeconds': serializer.toJson<int?>(intervalSeconds),
      'reps': serializer.toJson<int?>(reps),
      'repsIsMax': serializer.toJson<int>(repsIsMax),
      'duration': serializer.toJson<int?>(duration),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'worktimeSeconds': serializer.toJson<int?>(worktimeSeconds),
      'hand': serializer.toJson<String?>(hand),
      'granularity': serializer.toJson<String?>(granularity),
      'loadsJson': serializer.toJson<String?>(loadsJson),
      'leftLoadsJson': serializer.toJson<String?>(leftLoadsJson),
      'handPositionsJson': serializer.toJson<String?>(handPositionsJson),
      'edgeSizesMmJson': serializer.toJson<String?>(edgeSizesMmJson),
      'variableTargetsJson': serializer.toJson<String?>(variableTargetsJson),
      'loadIsMax': serializer.toJson<int>(loadIsMax),
      'freeText': serializer.toJson<String?>(freeText),
      'exerciseId': serializer.toJson<String?>(exerciseId),
      'groupTitle': serializer.toJson<String?>(groupTitle),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TrainingItemsData copyWith({
    String? id,
    String? trainingId,
    Value<String?> parentId = const Value.absent(),
    String? type,
    int? position,
    Value<int?> cycles = const Value.absent(),
    Value<int?> cycleRestSeconds = const Value.absent(),
    Value<int?> intervalSeconds = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    int? repsIsMax,
    Value<int?> duration = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    Value<int?> worktimeSeconds = const Value.absent(),
    Value<String?> hand = const Value.absent(),
    Value<String?> granularity = const Value.absent(),
    Value<String?> loadsJson = const Value.absent(),
    Value<String?> leftLoadsJson = const Value.absent(),
    Value<String?> handPositionsJson = const Value.absent(),
    Value<String?> edgeSizesMmJson = const Value.absent(),
    Value<String?> variableTargetsJson = const Value.absent(),
    int? loadIsMax,
    Value<String?> freeText = const Value.absent(),
    Value<String?> exerciseId = const Value.absent(),
    Value<String?> groupTitle = const Value.absent(),
    int? updatedAt,
  }) => TrainingItemsData(
    id: id ?? this.id,
    trainingId: trainingId ?? this.trainingId,
    parentId: parentId.present ? parentId.value : this.parentId,
    type: type ?? this.type,
    position: position ?? this.position,
    cycles: cycles.present ? cycles.value : this.cycles,
    cycleRestSeconds: cycleRestSeconds.present
        ? cycleRestSeconds.value
        : this.cycleRestSeconds,
    intervalSeconds: intervalSeconds.present
        ? intervalSeconds.value
        : this.intervalSeconds,
    reps: reps.present ? reps.value : this.reps,
    repsIsMax: repsIsMax ?? this.repsIsMax,
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
    variableTargetsJson: variableTargetsJson.present
        ? variableTargetsJson.value
        : this.variableTargetsJson,
    loadIsMax: loadIsMax ?? this.loadIsMax,
    freeText: freeText.present ? freeText.value : this.freeText,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    groupTitle: groupTitle.present ? groupTitle.value : this.groupTitle,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrainingItemsData copyWithCompanion(TrainingItemsCompanion data) {
    return TrainingItemsData(
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
      intervalSeconds: data.intervalSeconds.present
          ? data.intervalSeconds.value
          : this.intervalSeconds,
      reps: data.reps.present ? data.reps.value : this.reps,
      repsIsMax: data.repsIsMax.present ? data.repsIsMax.value : this.repsIsMax,
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
      variableTargetsJson: data.variableTargetsJson.present
          ? data.variableTargetsJson.value
          : this.variableTargetsJson,
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
    return (StringBuffer('TrainingItemsData(')
          ..write('id: $id, ')
          ..write('trainingId: $trainingId, ')
          ..write('parentId: $parentId, ')
          ..write('type: $type, ')
          ..write('position: $position, ')
          ..write('cycles: $cycles, ')
          ..write('cycleRestSeconds: $cycleRestSeconds, ')
          ..write('intervalSeconds: $intervalSeconds, ')
          ..write('reps: $reps, ')
          ..write('repsIsMax: $repsIsMax, ')
          ..write('duration: $duration, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('worktimeSeconds: $worktimeSeconds, ')
          ..write('hand: $hand, ')
          ..write('granularity: $granularity, ')
          ..write('loadsJson: $loadsJson, ')
          ..write('leftLoadsJson: $leftLoadsJson, ')
          ..write('handPositionsJson: $handPositionsJson, ')
          ..write('edgeSizesMmJson: $edgeSizesMmJson, ')
          ..write('variableTargetsJson: $variableTargetsJson, ')
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
    intervalSeconds,
    reps,
    repsIsMax,
    duration,
    restSeconds,
    worktimeSeconds,
    hand,
    granularity,
    loadsJson,
    leftLoadsJson,
    handPositionsJson,
    edgeSizesMmJson,
    variableTargetsJson,
    loadIsMax,
    freeText,
    exerciseId,
    groupTitle,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingItemsData &&
          other.id == this.id &&
          other.trainingId == this.trainingId &&
          other.parentId == this.parentId &&
          other.type == this.type &&
          other.position == this.position &&
          other.cycles == this.cycles &&
          other.cycleRestSeconds == this.cycleRestSeconds &&
          other.intervalSeconds == this.intervalSeconds &&
          other.reps == this.reps &&
          other.repsIsMax == this.repsIsMax &&
          other.duration == this.duration &&
          other.restSeconds == this.restSeconds &&
          other.worktimeSeconds == this.worktimeSeconds &&
          other.hand == this.hand &&
          other.granularity == this.granularity &&
          other.loadsJson == this.loadsJson &&
          other.leftLoadsJson == this.leftLoadsJson &&
          other.handPositionsJson == this.handPositionsJson &&
          other.edgeSizesMmJson == this.edgeSizesMmJson &&
          other.variableTargetsJson == this.variableTargetsJson &&
          other.loadIsMax == this.loadIsMax &&
          other.freeText == this.freeText &&
          other.exerciseId == this.exerciseId &&
          other.groupTitle == this.groupTitle &&
          other.updatedAt == this.updatedAt);
}

class TrainingItemsCompanion extends UpdateCompanion<TrainingItemsData> {
  final Value<String> id;
  final Value<String> trainingId;
  final Value<String?> parentId;
  final Value<String> type;
  final Value<int> position;
  final Value<int?> cycles;
  final Value<int?> cycleRestSeconds;
  final Value<int?> intervalSeconds;
  final Value<int?> reps;
  final Value<int> repsIsMax;
  final Value<int?> duration;
  final Value<int?> restSeconds;
  final Value<int?> worktimeSeconds;
  final Value<String?> hand;
  final Value<String?> granularity;
  final Value<String?> loadsJson;
  final Value<String?> leftLoadsJson;
  final Value<String?> handPositionsJson;
  final Value<String?> edgeSizesMmJson;
  final Value<String?> variableTargetsJson;
  final Value<int> loadIsMax;
  final Value<String?> freeText;
  final Value<String?> exerciseId;
  final Value<String?> groupTitle;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TrainingItemsCompanion({
    this.id = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.type = const Value.absent(),
    this.position = const Value.absent(),
    this.cycles = const Value.absent(),
    this.cycleRestSeconds = const Value.absent(),
    this.intervalSeconds = const Value.absent(),
    this.reps = const Value.absent(),
    this.repsIsMax = const Value.absent(),
    this.duration = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.worktimeSeconds = const Value.absent(),
    this.hand = const Value.absent(),
    this.granularity = const Value.absent(),
    this.loadsJson = const Value.absent(),
    this.leftLoadsJson = const Value.absent(),
    this.handPositionsJson = const Value.absent(),
    this.edgeSizesMmJson = const Value.absent(),
    this.variableTargetsJson = const Value.absent(),
    this.loadIsMax = const Value.absent(),
    this.freeText = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.groupTitle = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrainingItemsCompanion.insert({
    required String id,
    required String trainingId,
    this.parentId = const Value.absent(),
    required String type,
    this.position = const Value.absent(),
    this.cycles = const Value.absent(),
    this.cycleRestSeconds = const Value.absent(),
    this.intervalSeconds = const Value.absent(),
    this.reps = const Value.absent(),
    this.repsIsMax = const Value.absent(),
    this.duration = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.worktimeSeconds = const Value.absent(),
    this.hand = const Value.absent(),
    this.granularity = const Value.absent(),
    this.loadsJson = const Value.absent(),
    this.leftLoadsJson = const Value.absent(),
    this.handPositionsJson = const Value.absent(),
    this.edgeSizesMmJson = const Value.absent(),
    this.variableTargetsJson = const Value.absent(),
    this.loadIsMax = const Value.absent(),
    this.freeText = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.groupTitle = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trainingId = Value(trainingId),
       type = Value(type);
  static Insertable<TrainingItemsData> custom({
    Expression<String>? id,
    Expression<String>? trainingId,
    Expression<String>? parentId,
    Expression<String>? type,
    Expression<int>? position,
    Expression<int>? cycles,
    Expression<int>? cycleRestSeconds,
    Expression<int>? intervalSeconds,
    Expression<int>? reps,
    Expression<int>? repsIsMax,
    Expression<int>? duration,
    Expression<int>? restSeconds,
    Expression<int>? worktimeSeconds,
    Expression<String>? hand,
    Expression<String>? granularity,
    Expression<String>? loadsJson,
    Expression<String>? leftLoadsJson,
    Expression<String>? handPositionsJson,
    Expression<String>? edgeSizesMmJson,
    Expression<String>? variableTargetsJson,
    Expression<int>? loadIsMax,
    Expression<String>? freeText,
    Expression<String>? exerciseId,
    Expression<String>? groupTitle,
    Expression<int>? updatedAt,
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
      if (intervalSeconds != null) 'interval_seconds': intervalSeconds,
      if (reps != null) 'reps': reps,
      if (repsIsMax != null) 'reps_is_max': repsIsMax,
      if (duration != null) 'duration': duration,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (worktimeSeconds != null) 'worktime_seconds': worktimeSeconds,
      if (hand != null) 'hand': hand,
      if (granularity != null) 'granularity': granularity,
      if (loadsJson != null) 'loads_json': loadsJson,
      if (leftLoadsJson != null) 'left_loads_json': leftLoadsJson,
      if (handPositionsJson != null) 'hand_positions_json': handPositionsJson,
      if (edgeSizesMmJson != null) 'edge_sizes_mm_json': edgeSizesMmJson,
      if (variableTargetsJson != null)
        'variable_targets_json': variableTargetsJson,
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
    Value<int?>? intervalSeconds,
    Value<int?>? reps,
    Value<int>? repsIsMax,
    Value<int?>? duration,
    Value<int?>? restSeconds,
    Value<int?>? worktimeSeconds,
    Value<String?>? hand,
    Value<String?>? granularity,
    Value<String?>? loadsJson,
    Value<String?>? leftLoadsJson,
    Value<String?>? handPositionsJson,
    Value<String?>? edgeSizesMmJson,
    Value<String?>? variableTargetsJson,
    Value<int>? loadIsMax,
    Value<String?>? freeText,
    Value<String?>? exerciseId,
    Value<String?>? groupTitle,
    Value<int>? updatedAt,
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
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      reps: reps ?? this.reps,
      repsIsMax: repsIsMax ?? this.repsIsMax,
      duration: duration ?? this.duration,
      restSeconds: restSeconds ?? this.restSeconds,
      worktimeSeconds: worktimeSeconds ?? this.worktimeSeconds,
      hand: hand ?? this.hand,
      granularity: granularity ?? this.granularity,
      loadsJson: loadsJson ?? this.loadsJson,
      leftLoadsJson: leftLoadsJson ?? this.leftLoadsJson,
      handPositionsJson: handPositionsJson ?? this.handPositionsJson,
      edgeSizesMmJson: edgeSizesMmJson ?? this.edgeSizesMmJson,
      variableTargetsJson: variableTargetsJson ?? this.variableTargetsJson,
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
    if (intervalSeconds.present) {
      map['interval_seconds'] = Variable<int>(intervalSeconds.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (repsIsMax.present) {
      map['reps_is_max'] = Variable<int>(repsIsMax.value);
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
    if (variableTargetsJson.present) {
      map['variable_targets_json'] = Variable<String>(
        variableTargetsJson.value,
      );
    }
    if (loadIsMax.present) {
      map['load_is_max'] = Variable<int>(loadIsMax.value);
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
      map['updated_at'] = Variable<int>(updatedAt.value);
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
          ..write('intervalSeconds: $intervalSeconds, ')
          ..write('reps: $reps, ')
          ..write('repsIsMax: $repsIsMax, ')
          ..write('duration: $duration, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('worktimeSeconds: $worktimeSeconds, ')
          ..write('hand: $hand, ')
          ..write('granularity: $granularity, ')
          ..write('loadsJson: $loadsJson, ')
          ..write('leftLoadsJson: $leftLoadsJson, ')
          ..write('handPositionsJson: $handPositionsJson, ')
          ..write('edgeSizesMmJson: $edgeSizesMmJson, ')
          ..write('variableTargetsJson: $variableTargetsJson, ')
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

class RepDatas extends Table with TableInfo<RepDatas, RepDatasData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RepDatas(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<double> averageWeight = GeneratedColumn<double>(
    'average_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> isRest = GeneratedColumn<int>(
    'is_rest',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (is_rest IN (0, 1))',
  );
  late final GeneratedColumn<String> hand = GeneratedColumn<String>(
    'hand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
  late final GeneratedColumn<int> edgeSizeMm = GeneratedColumn<int>(
    'edge_size_mm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> trainingItemId = GeneratedColumn<String>(
    'training_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> targetUnmeasured = GeneratedColumn<int>(
    'target_unmeasured',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT 0 CHECK (target_unmeasured IN (0, 1))',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    averageWeight,
    sessionId,
    isRest,
    hand,
    duration,
    targetWeight,
    index,
    gripPosition,
    edgeSizeMm,
    trainingItemId,
    targetUnmeasured,
    updatedAt,
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
        DriftSqlType.int,
        data['${effectivePrefix}is_rest'],
      )!,
      hand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hand'],
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
      targetUnmeasured: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_unmeasured'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  RepDatas createAlias(String alias) {
    return RepDatas(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id)',
    'FOREIGN KEY(session_id)REFERENCES sessions(id)ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class RepDatasData extends DataClass implements Insertable<RepDatasData> {
  final String id;
  final double averageWeight;
  final String sessionId;
  final int isRest;
  final String hand;
  final int duration;
  final double targetWeight;
  final int index;
  final int gripPosition;
  final int? edgeSizeMm;
  final String? trainingItemId;
  final int targetUnmeasured;
  final int updatedAt;
  const RepDatasData({
    required this.id,
    required this.averageWeight,
    required this.sessionId,
    required this.isRest,
    required this.hand,
    required this.duration,
    required this.targetWeight,
    required this.index,
    required this.gripPosition,
    this.edgeSizeMm,
    this.trainingItemId,
    required this.targetUnmeasured,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['average_weight'] = Variable<double>(averageWeight);
    map['session_id'] = Variable<String>(sessionId);
    map['is_rest'] = Variable<int>(isRest);
    map['hand'] = Variable<String>(hand);
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
    map['target_unmeasured'] = Variable<int>(targetUnmeasured);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RepDatasCompanion toCompanion(bool nullToAbsent) {
    return RepDatasCompanion(
      id: Value(id),
      averageWeight: Value(averageWeight),
      sessionId: Value(sessionId),
      isRest: Value(isRest),
      hand: Value(hand),
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
      targetUnmeasured: Value(targetUnmeasured),
      updatedAt: Value(updatedAt),
    );
  }

  factory RepDatasData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepDatasData(
      id: serializer.fromJson<String>(json['id']),
      averageWeight: serializer.fromJson<double>(json['averageWeight']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      isRest: serializer.fromJson<int>(json['isRest']),
      hand: serializer.fromJson<String>(json['hand']),
      duration: serializer.fromJson<int>(json['duration']),
      targetWeight: serializer.fromJson<double>(json['targetWeight']),
      index: serializer.fromJson<int>(json['index']),
      gripPosition: serializer.fromJson<int>(json['gripPosition']),
      edgeSizeMm: serializer.fromJson<int?>(json['edgeSizeMm']),
      trainingItemId: serializer.fromJson<String?>(json['trainingItemId']),
      targetUnmeasured: serializer.fromJson<int>(json['targetUnmeasured']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'averageWeight': serializer.toJson<double>(averageWeight),
      'sessionId': serializer.toJson<String>(sessionId),
      'isRest': serializer.toJson<int>(isRest),
      'hand': serializer.toJson<String>(hand),
      'duration': serializer.toJson<int>(duration),
      'targetWeight': serializer.toJson<double>(targetWeight),
      'index': serializer.toJson<int>(index),
      'gripPosition': serializer.toJson<int>(gripPosition),
      'edgeSizeMm': serializer.toJson<int?>(edgeSizeMm),
      'trainingItemId': serializer.toJson<String?>(trainingItemId),
      'targetUnmeasured': serializer.toJson<int>(targetUnmeasured),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RepDatasData copyWith({
    String? id,
    double? averageWeight,
    String? sessionId,
    int? isRest,
    String? hand,
    int? duration,
    double? targetWeight,
    int? index,
    int? gripPosition,
    Value<int?> edgeSizeMm = const Value.absent(),
    Value<String?> trainingItemId = const Value.absent(),
    int? targetUnmeasured,
    int? updatedAt,
  }) => RepDatasData(
    id: id ?? this.id,
    averageWeight: averageWeight ?? this.averageWeight,
    sessionId: sessionId ?? this.sessionId,
    isRest: isRest ?? this.isRest,
    hand: hand ?? this.hand,
    duration: duration ?? this.duration,
    targetWeight: targetWeight ?? this.targetWeight,
    index: index ?? this.index,
    gripPosition: gripPosition ?? this.gripPosition,
    edgeSizeMm: edgeSizeMm.present ? edgeSizeMm.value : this.edgeSizeMm,
    trainingItemId: trainingItemId.present
        ? trainingItemId.value
        : this.trainingItemId,
    targetUnmeasured: targetUnmeasured ?? this.targetUnmeasured,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RepDatasData copyWithCompanion(RepDatasCompanion data) {
    return RepDatasData(
      id: data.id.present ? data.id.value : this.id,
      averageWeight: data.averageWeight.present
          ? data.averageWeight.value
          : this.averageWeight,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      isRest: data.isRest.present ? data.isRest.value : this.isRest,
      hand: data.hand.present ? data.hand.value : this.hand,
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
      targetUnmeasured: data.targetUnmeasured.present
          ? data.targetUnmeasured.value
          : this.targetUnmeasured,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepDatasData(')
          ..write('id: $id, ')
          ..write('averageWeight: $averageWeight, ')
          ..write('sessionId: $sessionId, ')
          ..write('isRest: $isRest, ')
          ..write('hand: $hand, ')
          ..write('duration: $duration, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('index: $index, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('edgeSizeMm: $edgeSizeMm, ')
          ..write('trainingItemId: $trainingItemId, ')
          ..write('targetUnmeasured: $targetUnmeasured, ')
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
    hand,
    duration,
    targetWeight,
    index,
    gripPosition,
    edgeSizeMm,
    trainingItemId,
    targetUnmeasured,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepDatasData &&
          other.id == this.id &&
          other.averageWeight == this.averageWeight &&
          other.sessionId == this.sessionId &&
          other.isRest == this.isRest &&
          other.hand == this.hand &&
          other.duration == this.duration &&
          other.targetWeight == this.targetWeight &&
          other.index == this.index &&
          other.gripPosition == this.gripPosition &&
          other.edgeSizeMm == this.edgeSizeMm &&
          other.trainingItemId == this.trainingItemId &&
          other.targetUnmeasured == this.targetUnmeasured &&
          other.updatedAt == this.updatedAt);
}

class RepDatasCompanion extends UpdateCompanion<RepDatasData> {
  final Value<String> id;
  final Value<double> averageWeight;
  final Value<String> sessionId;
  final Value<int> isRest;
  final Value<String> hand;
  final Value<int> duration;
  final Value<double> targetWeight;
  final Value<int> index;
  final Value<int> gripPosition;
  final Value<int?> edgeSizeMm;
  final Value<String?> trainingItemId;
  final Value<int> targetUnmeasured;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RepDatasCompanion({
    this.id = const Value.absent(),
    this.averageWeight = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.isRest = const Value.absent(),
    this.hand = const Value.absent(),
    this.duration = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.index = const Value.absent(),
    this.gripPosition = const Value.absent(),
    this.edgeSizeMm = const Value.absent(),
    this.trainingItemId = const Value.absent(),
    this.targetUnmeasured = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepDatasCompanion.insert({
    required String id,
    required double averageWeight,
    required String sessionId,
    required int isRest,
    required String hand,
    required int duration,
    required double targetWeight,
    required int index,
    this.gripPosition = const Value.absent(),
    this.edgeSizeMm = const Value.absent(),
    this.trainingItemId = const Value.absent(),
    this.targetUnmeasured = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       averageWeight = Value(averageWeight),
       sessionId = Value(sessionId),
       isRest = Value(isRest),
       hand = Value(hand),
       duration = Value(duration),
       targetWeight = Value(targetWeight),
       index = Value(index);
  static Insertable<RepDatasData> custom({
    Expression<String>? id,
    Expression<double>? averageWeight,
    Expression<String>? sessionId,
    Expression<int>? isRest,
    Expression<String>? hand,
    Expression<int>? duration,
    Expression<double>? targetWeight,
    Expression<int>? index,
    Expression<int>? gripPosition,
    Expression<int>? edgeSizeMm,
    Expression<String>? trainingItemId,
    Expression<int>? targetUnmeasured,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (averageWeight != null) 'average_weight': averageWeight,
      if (sessionId != null) 'session_id': sessionId,
      if (isRest != null) 'is_rest': isRest,
      if (hand != null) 'hand': hand,
      if (duration != null) 'duration': duration,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (index != null) 'index': index,
      if (gripPosition != null) 'grip_position': gripPosition,
      if (edgeSizeMm != null) 'edge_size_mm': edgeSizeMm,
      if (trainingItemId != null) 'training_item_id': trainingItemId,
      if (targetUnmeasured != null) 'target_unmeasured': targetUnmeasured,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepDatasCompanion copyWith({
    Value<String>? id,
    Value<double>? averageWeight,
    Value<String>? sessionId,
    Value<int>? isRest,
    Value<String>? hand,
    Value<int>? duration,
    Value<double>? targetWeight,
    Value<int>? index,
    Value<int>? gripPosition,
    Value<int?>? edgeSizeMm,
    Value<String?>? trainingItemId,
    Value<int>? targetUnmeasured,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RepDatasCompanion(
      id: id ?? this.id,
      averageWeight: averageWeight ?? this.averageWeight,
      sessionId: sessionId ?? this.sessionId,
      isRest: isRest ?? this.isRest,
      hand: hand ?? this.hand,
      duration: duration ?? this.duration,
      targetWeight: targetWeight ?? this.targetWeight,
      index: index ?? this.index,
      gripPosition: gripPosition ?? this.gripPosition,
      edgeSizeMm: edgeSizeMm ?? this.edgeSizeMm,
      trainingItemId: trainingItemId ?? this.trainingItemId,
      targetUnmeasured: targetUnmeasured ?? this.targetUnmeasured,
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
      map['is_rest'] = Variable<int>(isRest.value);
    }
    if (hand.present) {
      map['hand'] = Variable<String>(hand.value);
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
    if (targetUnmeasured.present) {
      map['target_unmeasured'] = Variable<int>(targetUnmeasured.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
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
          ..write('hand: $hand, ')
          ..write('duration: $duration, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('index: $index, ')
          ..write('gripPosition: $gripPosition, ')
          ..write('edgeSizeMm: $edgeSizeMm, ')
          ..write('trainingItemId: $trainingItemId, ')
          ..write('targetUnmeasured: $targetUnmeasured, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SessionItemResults extends Table
    with TableInfo<SessionItemResults, SessionItemResultsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SessionItemResults(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> trainingItemId = GeneratedColumn<String>(
    'training_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> occurrence = GeneratedColumn<int>(
    'occurrence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    trainingItemId,
    occurrence,
    field,
    value,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_item_results';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionItemResultsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionItemResultsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      trainingItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_item_id'],
      )!,
      occurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  SessionItemResults createAlias(String alias) {
    return SessionItemResults(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id)',
    'FOREIGN KEY(session_id)REFERENCES sessions(id)ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SessionItemResultsData extends DataClass
    implements Insertable<SessionItemResultsData> {
  final String id;
  final String sessionId;
  final String trainingItemId;
  final int occurrence;
  final String field;
  final int value;
  final int updatedAt;
  const SessionItemResultsData({
    required this.id,
    required this.sessionId,
    required this.trainingItemId,
    required this.occurrence,
    required this.field,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['training_item_id'] = Variable<String>(trainingItemId);
    map['occurrence'] = Variable<int>(occurrence);
    map['field'] = Variable<String>(field);
    map['value'] = Variable<int>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SessionItemResultsCompanion toCompanion(bool nullToAbsent) {
    return SessionItemResultsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      trainingItemId: Value(trainingItemId),
      occurrence: Value(occurrence),
      field: Value(field),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionItemResultsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionItemResultsData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      trainingItemId: serializer.fromJson<String>(json['trainingItemId']),
      occurrence: serializer.fromJson<int>(json['occurrence']),
      field: serializer.fromJson<String>(json['field']),
      value: serializer.fromJson<int>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'trainingItemId': serializer.toJson<String>(trainingItemId),
      'occurrence': serializer.toJson<int>(occurrence),
      'field': serializer.toJson<String>(field),
      'value': serializer.toJson<int>(value),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SessionItemResultsData copyWith({
    String? id,
    String? sessionId,
    String? trainingItemId,
    int? occurrence,
    String? field,
    int? value,
    int? updatedAt,
  }) => SessionItemResultsData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    trainingItemId: trainingItemId ?? this.trainingItemId,
    occurrence: occurrence ?? this.occurrence,
    field: field ?? this.field,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionItemResultsData copyWithCompanion(SessionItemResultsCompanion data) {
    return SessionItemResultsData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      trainingItemId: data.trainingItemId.present
          ? data.trainingItemId.value
          : this.trainingItemId,
      occurrence: data.occurrence.present
          ? data.occurrence.value
          : this.occurrence,
      field: data.field.present ? data.field.value : this.field,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionItemResultsData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('trainingItemId: $trainingItemId, ')
          ..write('occurrence: $occurrence, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    trainingItemId,
    occurrence,
    field,
    value,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionItemResultsData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.trainingItemId == this.trainingItemId &&
          other.occurrence == this.occurrence &&
          other.field == this.field &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SessionItemResultsCompanion
    extends UpdateCompanion<SessionItemResultsData> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> trainingItemId;
  final Value<int> occurrence;
  final Value<String> field;
  final Value<int> value;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SessionItemResultsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.trainingItemId = const Value.absent(),
    this.occurrence = const Value.absent(),
    this.field = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionItemResultsCompanion.insert({
    required String id,
    required String sessionId,
    required String trainingItemId,
    this.occurrence = const Value.absent(),
    required String field,
    required int value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       trainingItemId = Value(trainingItemId),
       field = Value(field),
       value = Value(value);
  static Insertable<SessionItemResultsData> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? trainingItemId,
    Expression<int>? occurrence,
    Expression<String>? field,
    Expression<int>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (trainingItemId != null) 'training_item_id': trainingItemId,
      if (occurrence != null) 'occurrence': occurrence,
      if (field != null) 'field': field,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionItemResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? trainingItemId,
    Value<int>? occurrence,
    Value<String>? field,
    Value<int>? value,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionItemResultsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      trainingItemId: trainingItemId ?? this.trainingItemId,
      occurrence: occurrence ?? this.occurrence,
      field: field ?? this.field,
      value: value ?? this.value,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (trainingItemId.present) {
      map['training_item_id'] = Variable<String>(trainingItemId.value);
    }
    if (occurrence.present) {
      map['occurrence'] = Variable<int>(occurrence.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionItemResultsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('trainingItemId: $trainingItemId, ')
          ..write('occurrence: $occurrence, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorConfigsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorConfigsData(
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
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  SensorConfigs createAlias(String alias) {
    return SensorConfigs(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class SensorConfigsData extends DataClass
    implements Insertable<SensorConfigsData> {
  final String id;
  final String name;
  final int index;
  final double tare;
  final double coef;
  final int updatedAt;
  const SensorConfigsData({
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
    map['updated_at'] = Variable<int>(updatedAt);
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

  factory SensorConfigsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorConfigsData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      index: serializer.fromJson<int>(json['index']),
      tare: serializer.fromJson<double>(json['tare']),
      coef: serializer.fromJson<double>(json['coef']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
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
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SensorConfigsData copyWith({
    String? id,
    String? name,
    int? index,
    double? tare,
    double? coef,
    int? updatedAt,
  }) => SensorConfigsData(
    id: id ?? this.id,
    name: name ?? this.name,
    index: index ?? this.index,
    tare: tare ?? this.tare,
    coef: coef ?? this.coef,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SensorConfigsData copyWithCompanion(SensorConfigsCompanion data) {
    return SensorConfigsData(
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
    return (StringBuffer('SensorConfigsData(')
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
      (other is SensorConfigsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.index == this.index &&
          other.tare == this.tare &&
          other.coef == this.coef &&
          other.updatedAt == this.updatedAt);
}

class SensorConfigsCompanion extends UpdateCompanion<SensorConfigsData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> index;
  final Value<double> tare;
  final Value<double> coef;
  final Value<int> updatedAt;
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
    required String id,
    required String name,
    required int index,
    required double tare,
    required double coef,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       index = Value(index),
       tare = Value(tare),
       coef = Value(coef);
  static Insertable<SensorConfigsData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? index,
    Expression<double>? tare,
    Expression<double>? coef,
    Expression<int>? updatedAt,
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
    Value<int>? updatedAt,
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
      map['updated_at'] = Variable<int>(updatedAt.value);
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

class BuiltinTrainingWeights extends Table
    with TableInfo<BuiltinTrainingWeights, BuiltinTrainingWeightsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BuiltinTrainingWeights(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> builtinTrainingId =
      GeneratedColumn<String>(
        'builtin_training_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuiltinTrainingWeightsData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuiltinTrainingWeightsData(
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
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  BuiltinTrainingWeights createAlias(String alias) {
    return BuiltinTrainingWeights(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class BuiltinTrainingWeightsData extends DataClass
    implements Insertable<BuiltinTrainingWeightsData> {
  final String id;
  final String builtinTrainingId;
  final double? customWeightRight;
  final double? customWeightLeft;
  final int updatedAt;
  const BuiltinTrainingWeightsData({
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
    map['updated_at'] = Variable<int>(updatedAt);
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

  factory BuiltinTrainingWeightsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuiltinTrainingWeightsData(
      id: serializer.fromJson<String>(json['id']),
      builtinTrainingId: serializer.fromJson<String>(json['builtinTrainingId']),
      customWeightRight: serializer.fromJson<double?>(
        json['customWeightRight'],
      ),
      customWeightLeft: serializer.fromJson<double?>(json['customWeightLeft']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
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
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  BuiltinTrainingWeightsData copyWith({
    String? id,
    String? builtinTrainingId,
    Value<double?> customWeightRight = const Value.absent(),
    Value<double?> customWeightLeft = const Value.absent(),
    int? updatedAt,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuiltinTrainingWeightsData(')
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
      (other is BuiltinTrainingWeightsData &&
          other.id == this.id &&
          other.builtinTrainingId == this.builtinTrainingId &&
          other.customWeightRight == this.customWeightRight &&
          other.customWeightLeft == this.customWeightLeft &&
          other.updatedAt == this.updatedAt);
}

class BuiltinTrainingWeightsCompanion
    extends UpdateCompanion<BuiltinTrainingWeightsData> {
  final Value<String> id;
  final Value<String> builtinTrainingId;
  final Value<double?> customWeightRight;
  final Value<double?> customWeightLeft;
  final Value<int> updatedAt;
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
    required String id,
    required String builtinTrainingId,
    this.customWeightRight = const Value.absent(),
    this.customWeightLeft = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       builtinTrainingId = Value(builtinTrainingId);
  static Insertable<BuiltinTrainingWeightsData> custom({
    Expression<String>? id,
    Expression<String>? builtinTrainingId,
    Expression<double>? customWeightRight,
    Expression<double>? customWeightLeft,
    Expression<int>? updatedAt,
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
    Value<int>? updatedAt,
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
      map['updated_at'] = Variable<int>(updatedAt.value);
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

class PinnedBuiltinTrainings extends Table
    with TableInfo<PinnedBuiltinTrainings, PinnedBuiltinTrainingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PinnedBuiltinTrainings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> builtinTrainingId =
      GeneratedColumn<String>(
        'builtin_training_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [builtinTrainingId, updatedAt];
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
        DriftSqlType.string,
        data['${effectivePrefix}builtin_training_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
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
  final String builtinTrainingId;
  final int updatedAt;
  const PinnedBuiltinTrainingsData({
    required this.builtinTrainingId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['builtin_training_id'] = Variable<String>(builtinTrainingId);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PinnedBuiltinTrainingsCompanion toCompanion(bool nullToAbsent) {
    return PinnedBuiltinTrainingsCompanion(
      builtinTrainingId: Value(builtinTrainingId),
      updatedAt: Value(updatedAt),
    );
  }

  factory PinnedBuiltinTrainingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedBuiltinTrainingsData(
      builtinTrainingId: serializer.fromJson<String>(json['builtinTrainingId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'builtinTrainingId': serializer.toJson<String>(builtinTrainingId),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  PinnedBuiltinTrainingsData copyWith({
    String? builtinTrainingId,
    int? updatedAt,
  }) => PinnedBuiltinTrainingsData(
    builtinTrainingId: builtinTrainingId ?? this.builtinTrainingId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PinnedBuiltinTrainingsData copyWithCompanion(
    PinnedBuiltinTrainingsCompanion data,
  ) {
    return PinnedBuiltinTrainingsData(
      builtinTrainingId: data.builtinTrainingId.present
          ? data.builtinTrainingId.value
          : this.builtinTrainingId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedBuiltinTrainingsData(')
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
      (other is PinnedBuiltinTrainingsData &&
          other.builtinTrainingId == this.builtinTrainingId &&
          other.updatedAt == this.updatedAt);
}

class PinnedBuiltinTrainingsCompanion
    extends UpdateCompanion<PinnedBuiltinTrainingsData> {
  final Value<String> builtinTrainingId;
  final Value<int> updatedAt;
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
  static Insertable<PinnedBuiltinTrainingsData> custom({
    Expression<String>? builtinTrainingId,
    Expression<int>? updatedAt,
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
    Value<int>? updatedAt,
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
      map['updated_at'] = Variable<int>(updatedAt.value);
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

class DatabaseAtV12 extends GeneratedDatabase {
  DatabaseAtV12(QueryExecutor e) : super(e);
  late final Sessions sessions = Sessions(this);
  late final AssessmentDefinitions assessmentDefinitions =
      AssessmentDefinitions(this);
  late final Assessments assessments = Assessments(this);
  late final Trainings trainings = Trainings(this);
  late final TrainingItems trainingItems = TrainingItems(this);
  late final RepDatas repDatas = RepDatas(this);
  late final SessionItemResults sessionItemResults = SessionItemResults(this);
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
    assessmentDefinitions,
    assessments,
    trainings,
    trainingItems,
    repDatas,
    sessionItemResults,
    sensorConfigs,
    builtinTrainingWeights,
    pinnedBuiltinTrainings,
    users,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assessments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trainings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('training_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rep_datas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_item_results', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  int get schemaVersion => 12;
}
