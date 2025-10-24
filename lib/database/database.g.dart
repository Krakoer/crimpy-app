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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    notes,
    date,
    dataPath,
    isAssessment,
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
  const Session({
    required this.id,
    required this.name,
    required this.notes,
    required this.date,
    required this.dataPath,
    required this.isAssessment,
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
    };
  }

  Session copyWith({
    int? id,
    String? name,
    String? notes,
    DateTime? date,
    String? dataPath,
    bool? isAssessment,
  }) => Session(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    date: date ?? this.date,
    dataPath: dataPath ?? this.dataPath,
    isAssessment: isAssessment ?? this.isAssessment,
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
          ..write('isAssessment: $isAssessment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, notes, date, dataPath, isAssessment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.date == this.date &&
          other.dataPath == this.dataPath &&
          other.isAssessment == this.isAssessment);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> notes;
  final Value<DateTime> date;
  final Value<String> dataPath;
  final Value<bool> isAssessment;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.date = const Value.absent(),
    this.dataPath = const Value.absent(),
    this.isAssessment = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String notes,
    this.date = const Value.absent(),
    required String dataPath,
    this.isAssessment = const Value.absent(),
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date,
      if (dataPath != null) 'data_path': dataPath,
      if (isAssessment != null) 'is_assessment': isAssessment,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? notes,
    Value<DateTime>? date,
    Value<String>? dataPath,
    Value<bool>? isAssessment,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      dataPath: dataPath ?? this.dataPath,
      isAssessment: isAssessment ?? this.isAssessment,
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
          ..write('isAssessment: $isAssessment')
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    rightValue,
    leftValue,
    sessionId,
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
  const Assessment({
    required this.id,
    required this.type,
    this.rightValue,
    this.leftValue,
    required this.sessionId,
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
    };
  }

  Assessment copyWith({
    int? id,
    int? type,
    Value<double?> rightValue = const Value.absent(),
    Value<double?> leftValue = const Value.absent(),
    int? sessionId,
  }) => Assessment(
    id: id ?? this.id,
    type: type ?? this.type,
    rightValue: rightValue.present ? rightValue.value : this.rightValue,
    leftValue: leftValue.present ? leftValue.value : this.leftValue,
    sessionId: sessionId ?? this.sessionId,
  );
  Assessment copyWithCompanion(AssessmentsCompanion data) {
    return Assessment(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      rightValue:
          data.rightValue.present ? data.rightValue.value : this.rightValue,
      leftValue: data.leftValue.present ? data.leftValue.value : this.leftValue,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assessment(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rightValue: $rightValue, ')
          ..write('leftValue: $leftValue, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, rightValue, leftValue, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assessment &&
          other.id == this.id &&
          other.type == this.type &&
          other.rightValue == this.rightValue &&
          other.leftValue == this.leftValue &&
          other.sessionId == this.sessionId);
}

class AssessmentsCompanion extends UpdateCompanion<Assessment> {
  final Value<int> id;
  final Value<int> type;
  final Value<double?> rightValue;
  final Value<double?> leftValue;
  final Value<int> sessionId;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    this.sessionId = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    this.id = const Value.absent(),
    required int type,
    this.rightValue = const Value.absent(),
    this.leftValue = const Value.absent(),
    required int sessionId,
  }) : type = Value(type),
       sessionId = Value(sessionId);
  static Insertable<Assessment> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<double>? rightValue,
    Expression<double>? leftValue,
    Expression<int>? sessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (rightValue != null) 'right_value': rightValue,
      if (leftValue != null) 'left_value': leftValue,
      if (sessionId != null) 'session_id': sessionId,
    });
  }

  AssessmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? type,
    Value<double?>? rightValue,
    Value<double?>? leftValue,
    Value<int>? sessionId,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      rightValue: rightValue ?? this.rightValue,
      leftValue: leftValue ?? this.leftValue,
      sessionId: sessionId ?? this.sessionId,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rightValue: $rightValue, ')
          ..write('leftValue: $leftValue, ')
          ..write('sessionId: $sessionId')
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
          ..write('splitHand: $splitHand')
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
          other.splitHand == this.splitHand);
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
          ..write('splitHand: $splitHand')
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    repeaterId,
    isBuiltin,
    isFavorite,
    isAssessment,
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
  const Training({
    required this.id,
    required this.name,
    this.repeaterId,
    required this.isBuiltin,
    required this.isFavorite,
    required this.isAssessment,
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
    };
  }

  Training copyWith({
    int? id,
    String? name,
    Value<int?> repeaterId = const Value.absent(),
    bool? isBuiltin,
    bool? isFavorite,
    bool? isAssessment,
  }) => Training(
    id: id ?? this.id,
    name: name ?? this.name,
    repeaterId: repeaterId.present ? repeaterId.value : this.repeaterId,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    isFavorite: isFavorite ?? this.isFavorite,
    isAssessment: isAssessment ?? this.isAssessment,
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
          ..write('isAssessment: $isAssessment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, repeaterId, isBuiltin, isFavorite, isAssessment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Training &&
          other.id == this.id &&
          other.name == this.name &&
          other.repeaterId == this.repeaterId &&
          other.isBuiltin == this.isBuiltin &&
          other.isFavorite == this.isFavorite &&
          other.isAssessment == this.isAssessment);
}

class TrainingsCompanion extends UpdateCompanion<Training> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> repeaterId;
  final Value<bool> isBuiltin;
  final Value<bool> isFavorite;
  final Value<bool> isAssessment;
  const TrainingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.repeaterId = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isAssessment = const Value.absent(),
  });
  TrainingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.repeaterId = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isAssessment = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Training> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? repeaterId,
    Expression<bool>? isBuiltin,
    Expression<bool>? isFavorite,
    Expression<bool>? isAssessment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (repeaterId != null) 'repeater_id': repeaterId,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isAssessment != null) 'is_assessment': isAssessment,
    });
  }

  TrainingsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? repeaterId,
    Value<bool>? isBuiltin,
    Value<bool>? isFavorite,
    Value<bool>? isAssessment,
  }) {
    return TrainingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      repeaterId: repeaterId ?? this.repeaterId,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      isFavorite: isFavorite ?? this.isFavorite,
      isAssessment: isAssessment ?? this.isAssessment,
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
          ..write('isAssessment: $isAssessment')
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    isRest,
    rightHand,
    duration,
    trainingId,
    targetWeight,
    index,
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
  const RepTemplate({
    required this.id,
    required this.isRest,
    required this.rightHand,
    required this.duration,
    required this.trainingId,
    required this.targetWeight,
    required this.index,
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
  }) => RepTemplate(
    id: id ?? this.id,
    isRest: isRest ?? this.isRest,
    rightHand: rightHand ?? this.rightHand,
    duration: duration ?? this.duration,
    trainingId: trainingId ?? this.trainingId,
    targetWeight: targetWeight ?? this.targetWeight,
    index: index ?? this.index,
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
          ..write('index: $index')
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
          other.index == this.index);
}

class RepTemplatesCompanion extends UpdateCompanion<RepTemplate> {
  final Value<int> id;
  final Value<bool> isRest;
  final Value<bool> rightHand;
  final Value<int> duration;
  final Value<int> trainingId;
  final Value<double> targetWeight;
  final Value<int> index;
  const RepTemplatesCompanion({
    this.id = const Value.absent(),
    this.isRest = const Value.absent(),
    this.rightHand = const Value.absent(),
    this.duration = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.index = const Value.absent(),
  });
  RepTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required bool isRest,
    required bool rightHand,
    required int duration,
    required int trainingId,
    required double targetWeight,
    required int index,
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isRest != null) 'is_rest': isRest,
      if (rightHand != null) 'right_hand': rightHand,
      if (duration != null) 'duration': duration,
      if (trainingId != null) 'training_id': trainingId,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (index != null) 'index': index,
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
  }) {
    return RepTemplatesCompanion(
      id: id ?? this.id,
      isRest: isRest ?? this.isRest,
      rightHand: rightHand ?? this.rightHand,
      duration: duration ?? this.duration,
      trainingId: trainingId ?? this.trainingId,
      targetWeight: targetWeight ?? this.targetWeight,
      index: index ?? this.index,
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
          ..write('index: $index')
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
  const RepData({
    required this.id,
    required this.averageWeight,
    required this.sessionId,
    required this.isRest,
    required this.rightHand,
    required this.duration,
    required this.targetWeight,
    required this.index,
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
  }) => RepData(
    id: id ?? this.id,
    averageWeight: averageWeight ?? this.averageWeight,
    sessionId: sessionId ?? this.sessionId,
    isRest: isRest ?? this.isRest,
    rightHand: rightHand ?? this.rightHand,
    duration: duration ?? this.duration,
    targetWeight: targetWeight ?? this.targetWeight,
    index: index ?? this.index,
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
          ..write('index: $index')
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
          other.index == this.index);
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
  const RepDatasCompanion({
    this.id = const Value.absent(),
    this.averageWeight = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.isRest = const Value.absent(),
    this.rightHand = const Value.absent(),
    this.duration = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.index = const Value.absent(),
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
          ..write('index: $index')
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
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> notes,
      Value<DateTime> date,
      Value<String> dataPath,
      Value<bool> isAssessment,
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
              }) => SessionsCompanion(
                id: id,
                name: name,
                notes: notes,
                date: date,
                dataPath: dataPath,
                isAssessment: isAssessment,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String notes,
                Value<DateTime> date = const Value.absent(),
                required String dataPath,
                Value<bool> isAssessment = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                name: name,
                notes: notes,
                date: date,
                dataPath: dataPath,
                isAssessment: isAssessment,
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
    });
typedef $$AssessmentsTableUpdateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      Value<int> type,
      Value<double?> rightValue,
      Value<double?> leftValue,
      Value<int> sessionId,
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
              }) => AssessmentsCompanion(
                id: id,
                type: type,
                rightValue: rightValue,
                leftValue: leftValue,
                sessionId: sessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int type,
                Value<double?> rightValue = const Value.absent(),
                Value<double?> leftValue = const Value.absent(),
                required int sessionId,
              }) => AssessmentsCompanion.insert(
                id: id,
                type: type,
                rightValue: rightValue,
                leftValue: leftValue,
                sessionId: sessionId,
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
    });
typedef $$TrainingsTableUpdateCompanionBuilder =
    TrainingsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> repeaterId,
      Value<bool> isBuiltin,
      Value<bool> isFavorite,
      Value<bool> isAssessment,
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
              }) => TrainingsCompanion(
                id: id,
                name: name,
                repeaterId: repeaterId,
                isBuiltin: isBuiltin,
                isFavorite: isFavorite,
                isAssessment: isAssessment,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> repeaterId = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isAssessment = const Value.absent(),
              }) => TrainingsCompanion.insert(
                id: id,
                name: name,
                repeaterId: repeaterId,
                isBuiltin: isBuiltin,
                isFavorite: isFavorite,
                isAssessment: isAssessment,
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
              }) => RepTemplatesCompanion(
                id: id,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                trainingId: trainingId,
                targetWeight: targetWeight,
                index: index,
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
              }) => RepTemplatesCompanion.insert(
                id: id,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                trainingId: trainingId,
                targetWeight: targetWeight,
                index: index,
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
              }) => RepDatasCompanion(
                id: id,
                averageWeight: averageWeight,
                sessionId: sessionId,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                targetWeight: targetWeight,
                index: index,
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
              }) => RepDatasCompanion.insert(
                id: id,
                averageWeight: averageWeight,
                sessionId: sessionId,
                isRest: isRest,
                rightHand: rightHand,
                duration: duration,
                targetWeight: targetWeight,
                index: index,
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
}
