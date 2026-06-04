import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crimpy/database/database.steps.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../models/ble_data_model.dart';

part 'database.g.dart';

// ignore_for_file: experimental_member_use

// Stores the training sessions the user has done.
class Sessions extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();
  late final TextColumn name = text()();
  late final TextColumn notes = text()();
  late final DateTimeColumn date = dateTime().withDefault(currentDateAndTime)();
  late final TextColumn dataPath = text()();
  late final BoolColumn isAssessment = boolean().withDefault(
    const Constant(false),
  )();
  late final IntColumn sessionType = integer().withDefault(
    const Constant(0),
  )(); // 0 = crimpy (default)
  late final IntColumn duration = integer().withDefault(const Constant(0))();

  // Repeater configuration (if session was a repeater workout)
  late final IntColumn repeaterSets = integer().nullable()();
  late final IntColumn repeaterReps = integer().nullable()();
  late final IntColumn repeaterWorkTime = integer().nullable()();
  late final IntColumn repeaterRestTime = integer().nullable()();
  late final IntColumn repeaterSetRest = integer().nullable()();
  late final BoolColumn repeaterSplitHand = boolean().nullable()();

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};
}

// Stores the assessments the user has done, with the results.
class Assessments extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final IntColumn type = integer()();
  late final RealColumn rightValue = real().nullable()();
  late final RealColumn leftValue = real().nullable()();
  late final TextColumn sessionId = text()();
  late final IntColumn gripPosition = integer().nullable().withDefault(
    const Constant(0),
  )(); // 0 = halfCrimp (default)

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE',
  ];
}

// Stores training templates (user-created and coach-assigned).
// The generated Drift row class is named TrainingRow to avoid conflict
// with the domain Training class in training_model.dart.
@DataClassName('TrainingRow')
class Trainings extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final TextColumn title = text()();
  late final TextColumn description = text().nullable()();
  late final BoolColumn isFavorite = boolean().withDefault(
    const Constant(false),
  )();

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};
}

// Stores individual items within a training.
// JSONB fields (loads, hand_positions, etc.) are stored as JSON strings.
// The generated row class is named TrainingItemRow to avoid conflict with
// the domain TrainingItem class in training_item_model.dart.
@DataClassName('TrainingItemRow')
class TrainingItems extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();
  late final TextColumn trainingId = text()();
  late final TextColumn parentId = text().nullable()();
  late final TextColumn type = text()();
  late final IntColumn position = integer().withDefault(const Constant(0))();

  // Repeater and circuit cycles
  late final IntColumn cycles = integer().nullable()();
  late final IntColumn cycleRestSeconds = integer().nullable()();

  // Reps (per cycle for repeaters, total for exercises)
  late final IntColumn reps = integer().nullable()();
  // Explicit duration in seconds (exercises, free items)
  late final IntColumn duration = integer().nullable()();
  // Rest after the item or between reps
  late final IntColumn restSeconds = integer().nullable()();
  // Worktime per rep (repeater and hangboard_rep)
  late final IntColumn worktimeSeconds = integer().nullable()();
  // Hand: 'both', 'split', 'left', 'right'
  late final TextColumn hand = text().nullable()();

  // Per-rep JSON arrays
  late final TextColumn loadsJson = text().nullable()();
  late final TextColumn leftLoadsJson = text().nullable()();
  late final TextColumn handPositionsJson = text().nullable()();
  late final TextColumn edgeSizesMmJson = text().nullable()();

  late final BoolColumn loadIsMax = boolean().withDefault(
    const Constant(false),
  )();
  late final TextColumn freeText = text().nullable()();
  late final TextColumn exerciseId = text().nullable()();
  late final TextColumn sectionTitle = text().nullable()();

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (training_id) REFERENCES trainings(id) ON DELETE CASCADE',
  ];
}

// Stores the data for the repetitions done during a session.
class RepDatas extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final RealColumn averageWeight = real()();
  late final TextColumn sessionId = text()();
  late final BoolColumn isRest = boolean()();
  late final BoolColumn rightHand = boolean()();
  late final IntColumn duration = integer()();
  late final RealColumn targetWeight = real()();
  late final IntColumn index = integer()();
  late final IntColumn gripPosition = integer().withDefault(
    const Constant(0),
  )(); // 0 = halfCrimp (default)

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE',
  ];
}

// Stores the IDs of pinned builtin trainings
class PinnedBuiltinTrainings extends Table {
  late final TextColumn builtinTrainingId = text()();

  @override
  Set<Column> get primaryKey => {builtinTrainingId};

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
}

// Stores the saved sensor configs.
class SensorConfigs extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final TextColumn name = text()();
  late final IntColumn index = integer()();
  late final RealColumn tare = real()();
  late final RealColumn coef = real()();

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};
}

// Stores custom weights for builtin trainings per user.
class BuiltinTrainingWeights extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final TextColumn builtinTrainingId = text()();
  late final RealColumn customWeightRight = real().nullable()();
  late final RealColumn customWeightLeft = real().nullable()();

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};
}

// Stores the currently authenticated user information.
class Users extends Table {
  late final TextColumn id = text()();
  late final TextColumn email = text()();
  late final TextColumn firstname = text()();
  late final TextColumn lastname = text()();
  late final BoolColumn emailVerified = boolean().withDefault(
    const Constant(false),
  )();
  late final BoolColumn isAdmin = boolean().withDefault(
    const Constant(false),
  )();
  late final BoolColumn isCoach = boolean().withDefault(
    const Constant(false),
  )();
  late final BoolColumn coachValidated = boolean().withDefault(
    const Constant(false),
  )();
  late final DateTimeColumn createdAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Sessions,
    Assessments,
    Trainings,
    TrainingItems,
    RepDatas,
    SensorConfigs,
    BuiltinTrainingWeights,
    PinnedBuiltinTrainings,
    Users,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  // ------------------------------------- SESSIONS -------------------------------------
  /// Get a session with its data points.
  Future<SessionModel?> getSessionWithData(String sessionId) async {
    final session = await (select(
      sessions,
    )..where((s) => s.id.equals(sessionId))).getSingleOrNull();
    if (session == null) return null;

    final List<BleDataPoint> dataPoints = session.dataPath.isEmpty
        ? []
        : await getSessionData(session.dataPath);

    // Build repeater config if available
    RepeaterConfig? repeaterConfig;
    if (session.repeaterSets != null &&
        session.repeaterReps != null &&
        session.repeaterWorkTime != null &&
        session.repeaterRestTime != null &&
        session.repeaterSetRest != null &&
        session.repeaterSplitHand != null) {
      repeaterConfig = RepeaterConfig(
        sets: session.repeaterSets!,
        repsPerSet: session.repeaterReps!,
        workTime: session.repeaterWorkTime!,
        restTime: session.repeaterRestTime!,
        setRest: session.repeaterSetRest!,
        splitHand: session.repeaterSplitHand!,
      );
    }

    return SessionModel(
      name: session.name,
      date: session.date,
      id: session.id,
      notes: session.notes,
      dataPoints: dataPoints,
      isAssessment: session.isAssessment,
      sessionType: SessionType.values[session.sessionType],
      durationInSeconds: session.duration,
      repeaterConfig: repeaterConfig,
    );
  }

  /// Get all saved sessions, with optional filters.
  Future<List<Session>> getAllSessions({SessionFilter? filters}) async {
    var query = select(sessions);
    if (filters != null) {
      if (filters.startDate != null) {
        query = query
          ..where(
            (session) => session.date.isBiggerThanValue(filters.startDate!),
          );
      }
      if (filters.endDate != null) {
        query = query
          ..where(
            (session) => session.date.isSmallerThanValue(filters.endDate!),
          );
      }
      if (filters.isAssessment != null) {
        query = query
          ..where(
            (session) => session.isAssessment.equals(filters.isAssessment!),
          );
      }
    }
    return query.get();
  }

  /// Get the repetitions data for a given session.
  Future<List<RepData>> getRepsForSession(String sessionId) =>
      (select(repDatas)
            ..where((r) => r.sessionId.equals(sessionId))
            ..orderBy([(r) => OrderingTerm(expression: r.index)]))
          .get();

  /// Save a session with its reps.
  /// If the `points` argument is not null, it will save
  /// the data onto the disk.
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? points,
  }) async {
    String dataPath = "";

    // Write points to filesystem if provided.
    if (points != null && points.isNotEmpty) {
      final dirPath = await getApplicationDocumentsDirectory();
      dataPath = "${dirPath.path}/${DateTime.now().millisecondsSinceEpoch}";
      await File(dataPath).writeAsString(jsonEncode(points));
    }

    // Calculate duration from reps or use provided duration
    final int sessionDuration =
        session.durationInSeconds ??
        reps.fold(0, (prev, r) => prev + r.duration);

    final sessionRowId = await into(sessions).insert(
      SessionsCompanion(
        dataPath: Value(dataPath),
        date: Value(session.date),
        notes: Value(session.notes ?? ""),
        name: Value(session.name),
        isAssessment: Value(session.isAssessment),
        sessionType: Value(session.sessionType.index),
        duration: Value(sessionDuration),
        repeaterSets: Value(session.repeaterConfig?.sets),
        repeaterReps: Value(session.repeaterConfig?.repsPerSet),
        repeaterWorkTime: Value(session.repeaterConfig?.workTime),
        repeaterRestTime: Value(session.repeaterConfig?.restTime),
        repeaterSetRest: Value(session.repeaterConfig?.setRest),
        repeaterSplitHand: Value(session.repeaterConfig?.splitHand),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final sessionId = (await (select(
      sessions,
    )..where((s) => s.rowId.equals(sessionRowId))).getSingle()).id;

    final companions = reps.indexed
        .map(
          (index) => RepDatasCompanion(
            duration: Value(index.$2.duration),
            index: Value(index.$1),
            isRest: Value(index.$2.isRest),
            rightHand: Value(index.$2.handSide.isRightHand),
            sessionId: Value(sessionId),
            targetWeight: Value(index.$2.targetWeight),
            averageWeight: Value(index.$2.averageWeight),
            gripPosition: Value(index.$2.gripPosition.index),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .toList();

    batch((batch) {
      batch.insertAll(repDatas, companions);
    });

    return sessionId;
  }

  /// Update an existing session.
  /// Only updates basic fields (date, notes, duration, sessionType).
  /// Does not modify reps or data points.
  Future<void> updateSession(SessionModel session) async {
    if (session.id == null) {
      throw ArgumentError('Session ID is required for update');
    }

    final int sessionDuration =
        session.durationInSeconds ??
        (session.reps != null
            ? session.reps!.fold(0, (prev, r) => prev + r.duration)
            : 0);

    await (update(sessions)..where((s) => s.id.equals(session.id!))).write(
      SessionsCompanion(
        date: Value(session.date),
        notes: Value(session.notes ?? ""),
        name: Value(session.name),
        sessionType: Value(session.sessionType.index),
        duration: Value(sessionDuration),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a session.
  Future<void> deleteSession(String sessionId) async {
    await (delete(sessions)..where((s) => s.id.equals(sessionId))).go();
  }

  // ------------------------------------- TRAININGS -------------------------------------

  /// Convert a flat list of TrainingItemRow rows into a nested Training object.
  Training _buildTraining(TrainingRow row, List<TrainingItemRow> allItems) {
    final topLevel = allItems.where((i) => i.parentId == null).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return Training(
      id: row.id,
      title: row.title,
      description: row.description,
      isFavorite: row.isFavorite,
      items: topLevel.map((i) => _buildItem(i, allItems)).toList(),
    );
  }

  TrainingItem _buildItem(TrainingItemRow row, List<TrainingItemRow> allItems) {
    List<Load>? parseLoads(String? json) {
      if (json == null || json.isEmpty) return null;
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => Load.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<String>? parseStrings(String? json) {
      if (json == null || json.isEmpty) return null;
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e as String).toList();
    }

    List<int>? parseInts(String? json) {
      if (json == null || json.isEmpty) return null;
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => (e as num).toInt()).toList();
    }

    final children = allItems.where((i) => i.parentId == row.id).toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return TrainingItem(
      id: row.id,
      type: TrainingItemType.fromString(row.type),
      position: row.position,
      parentId: row.parentId,
      cycles: row.cycles,
      cycleRestSeconds: row.cycleRestSeconds,
      reps: row.reps,
      duration: row.duration,
      restSeconds: row.restSeconds,
      worktimeSeconds: row.worktimeSeconds,
      hand: row.hand,
      loads: parseLoads(row.loadsJson),
      leftLoads: parseLoads(row.leftLoadsJson),
      handPositions: parseStrings(row.handPositionsJson),
      edgeSizesMm: parseInts(row.edgeSizesMmJson),
      loadIsMax: row.loadIsMax,
      freeText: row.freeText,
      exerciseId: row.exerciseId,
      sectionTitle: row.sectionTitle,
      items: children.map((c) => _buildItem(c, allItems)).toList(),
    );
  }

  String? _loadsToJson(List<Load>? loads) =>
      loads == null ? null : jsonEncode(loads.map((l) => l.toJson()).toList());

  String? _stringsToJson(List<String>? list) =>
      list == null ? null : jsonEncode(list);

  String? _intsToJson(List<int>? list) =>
      list == null ? null : jsonEncode(list);

  /// Get all trainings for the current user.
  Future<List<Training>> getAllTrainings({bool onlyFavs = false}) async {
    final rows = await (select(
      trainings,
    )..where((t) => onlyFavs ? t.isFavorite : const Constant(true))).get();

    final result = <Training>[];
    for (final row in rows) {
      final itemRows =
          await (select(trainingItems)
                ..where((i) => i.trainingId.equals(row.id))
                ..orderBy([(i) => OrderingTerm(expression: i.position)]))
              .get();
      result.add(_buildTraining(row, itemRows));
    }
    return result;
  }

  /// Save a new training (inserts training row and all items recursively).
  Future<String> saveTraining(Training training) async {
    final trainingRowId = await into(trainings).insert(
      TrainingsCompanion(
        title: Value(training.title),
        description: Value(training.description),
        isFavorite: Value(training.isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final trainingId = (await (select(
      trainings,
    )..where((t) => t.rowId.equals(trainingRowId))).getSingle()).id;

    await _insertItems(training.items, trainingId, null);
    return trainingId;
  }

  Future<void> _insertItems(
    List<TrainingItem> items,
    String trainingId,
    String? parentId,
  ) async {
    for (final item in items) {
      final itemRowId = await into(trainingItems).insert(
        TrainingItemsCompanion(
          trainingId: Value(trainingId),
          parentId: Value(parentId),
          type: Value(item.type.apiValue),
          position: Value(item.position),
          cycles: Value(item.cycles),
          cycleRestSeconds: Value(item.cycleRestSeconds),
          reps: Value(item.reps),
          duration: Value(item.duration),
          restSeconds: Value(item.restSeconds),
          worktimeSeconds: Value(item.worktimeSeconds),
          hand: Value(item.hand),
          loadsJson: Value(_loadsToJson(item.loads)),
          leftLoadsJson: Value(_loadsToJson(item.leftLoads)),
          handPositionsJson: Value(_stringsToJson(item.handPositions)),
          edgeSizesMmJson: Value(_intsToJson(item.edgeSizesMm)),
          loadIsMax: Value(item.loadIsMax),
          freeText: Value(item.freeText),
          exerciseId: Value(item.exerciseId),
          sectionTitle: Value(item.sectionTitle),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final itemId = (await (select(
        trainingItems,
      )..where((i) => i.rowId.equals(itemRowId))).getSingle()).id;
      if (item.items.isNotEmpty) {
        await _insertItems(item.items, trainingId, itemId);
      }
    }
  }

  /// Update an existing training (replaces all items).
  Future<void> updateTraining(Training training) async {
    await (update(trainings)..where((t) => t.id.equals(training.id))).write(
      TrainingsCompanion(
        title: Value(training.title),
        description: Value(training.description),
        isFavorite: Value(training.isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await (delete(
      trainingItems,
    )..where((i) => i.trainingId.equals(training.id))).go();
    await _insertItems(training.items, training.id, null);
  }

  /// Toggle the favorite status of a training.
  Future<void> toggleFav(String trainingId) async {
    final row = await (select(
      trainings,
    )..where((t) => t.id.equals(trainingId))).getSingle();
    await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
      TrainingsCompanion(
        isFavorite: Value(!row.isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a training and all its items.
  Future<void> deleteTraining(String trainingId) async {
    await (delete(trainings)..where((t) => t.id.equals(trainingId))).go();
  }

  // ------------------------------------- ASSESSMENTS -------------------------------------
  /// Given an assessment with the results and a sessionId, store the assessment into DB.
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async {
    final companion = AssessmentsCompanion(
      rightValue: Value(assessment.rightValue),
      leftValue: Value(assessment.leftValue),
      type: Value(assessment.type.index),
      sessionId: Value(sessionId),
      gripPosition: Value(assessment.gripPosition?.index),
      updatedAt: Value(DateTime.now()),
    );

    final assessmentRowId = await into(assessments).insert(companion);
    final assessmentId = (await (select(
      assessments,
    )..where((a) => a.rowId.equals(assessmentRowId))).getSingle()).id;
    return assessmentId;
  }

  /// Delete an assessment.
  Future<void> deleteAssessment(String id) async {
    await (delete(assessments)..where((a) => a.id.equals(id))).go();
  }

  Future<List<Assessment>> getAssessmentsForSession(String sessionId) {
    return (select(
      assessments,
    )..where((a) => a.sessionId.equals(sessionId))).get();
  }

  /// Get the assessments done.
  /// Allow to filter on `type`.
  /// If the `rightHand` parameter is set, it will only return the results for the given hand.
  /// If the `gripPosition` parameter is set, only assessments with that grip position will be retrieved.
  Future<List<AssessmentModel>> getAssessments({
    AssessmentType? type,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    var query = select(assessments);

    if (type != null) {
      query = query..where((r) => r.type.equals(type.index));
    }
    if (handSide != null) {
      query = query
        ..where(
          (assessment) => handSide.isRightHand
              ? assessment.rightValue.isNotNull()
              : assessment.leftValue.isNotNull(),
        );
    }
    if (gripPosition != null) {
      query = query
        ..where(
          (assessment) => assessment.gripPosition.equals(gripPosition.index),
        );
    }

    final res = await query.join([
      innerJoin(sessions, sessions.id.equalsExp(assessments.sessionId)),
    ]).get();

    return res.map((row) {
      final assessment = row.readTable(assessments);
      final session = row.readTable(sessions);

      return AssessmentModel(
        date: session.date,
        type: AssessmentType.values[assessment.type],
        leftValue: assessment.leftValue,
        rightValue: assessment.rightValue,
        id: assessment.id,
        gripPosition: assessment.gripPosition != null
            ? GripPosition.values[assessment.gripPosition!]
            : null,
      );
    }).toList();
  }

  // ------------------------------------- SENSOR CONFIGS -------------------------------------
  /// Get the saved sensor configs.
  Future<List<SensorConfig>> getSensorConfigs() async => (select(
    sensorConfigs,
  )..orderBy([(r) => OrderingTerm.desc(r.index)])).get();

  /// Save a new sensor config.
  Future<int> addSensorConfig(SensorConfigsCompanion config) async {
    final maxConfIndex = await (select(
      sensorConfigs,
    )..orderBy([(u) => OrderingTerm.desc(u.index)])).getSingleOrNull();
    final newIndex = maxConfIndex == null ? 1 : maxConfIndex.index + 1;
    final newConf = SensorConfigsCompanion(
      coef: config.coef,
      tare: config.tare,
      index: Value(newIndex),
      name: config.name,
      updatedAt: Value(DateTime.now()),
    );
    final rowId = await into(sensorConfigs).insert(newConf);
    return rowId;
  }

  /// Update a list of sensor configs.
  Future<void> updateSensorConfigs(List<SensorConfig> configs) async {
    final now = DateTime.now();
    for (final entry in configs) {
      await (update(sensorConfigs)..where((s) => s.id.equals(entry.id))).write(
        SensorConfigsCompanion(
          name: Value(entry.name),
          index: Value(entry.index),
          tare: Value(entry.tare),
          coef: Value(entry.coef),
          updatedAt: Value(now),
        ),
      );
    }
  }

  /// Delete a sensor config.
  Future<void> deleteSensorConfig(String id) async {
    await (delete(sensorConfigs)..where((s) => s.id.equals(id))).go();
  }

  // ------------------------------------- BUILTIN TRAINING WEIGHTS -------------------------------------
  /// Get custom weights for a builtin training.
  Future<BuiltinTrainingWeight?> getBuiltinTrainingWeights(
    String builtinTrainingId,
  ) async =>
      (select(builtinTrainingWeights)
            ..where((w) => w.builtinTrainingId.equals(builtinTrainingId))
            ..orderBy([(w) => OrderingTerm.desc(w.updatedAt)]))
          .getSingleOrNull();

  /// Get all custom weights (used when importing local data to the remote API).
  Future<List<BuiltinTrainingWeight>> getAllBuiltinTrainingWeights() =>
      select(builtinTrainingWeights).get();

  /// Save or update custom weights for a builtin training.
  Future<void> saveBuiltinTrainingWeights({
    required String builtinTrainingId,
    double? customWeightRight,
    double? customWeightLeft,
  }) async {
    final existing = await getBuiltinTrainingWeights(builtinTrainingId);

    if (existing != null) {
      await (update(
        builtinTrainingWeights,
      )..where((w) => w.id.equals(existing.id))).write(
        BuiltinTrainingWeightsCompanion(
          customWeightRight: Value(customWeightRight),
          customWeightLeft: Value(customWeightLeft),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await into(builtinTrainingWeights).insert(
        BuiltinTrainingWeightsCompanion.insert(
          builtinTrainingId: builtinTrainingId,
          customWeightRight: Value(customWeightRight),
          customWeightLeft: Value(customWeightLeft),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ------------------------------------- PINNED BUILTIN TRAININGS -------------------------------------
  /// Get all pinned builtin training IDs.
  Future<List<String>> getPinnedBuiltinTrainingIds() async {
    return (await select(
      pinnedBuiltinTrainings,
    ).get()).map((row) => row.builtinTrainingId).toList();
  }

  /// Pin a builtin training to the home screen.
  Future<void> pinBuiltinTraining(String builtinTrainingId) async {
    await into(pinnedBuiltinTrainings).insertOnConflictUpdate(
      PinnedBuiltinTrainingsCompanion(
        builtinTrainingId: Value(builtinTrainingId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Unpin a builtin training from the home screen.
  Future<void> unpinBuiltinTraining(String builtinTrainingId) async {
    await (delete(
      pinnedBuiltinTrainings,
    )..where((t) => t.builtinTrainingId.equals(builtinTrainingId))).go();
  }

  /// Check if a builtin training is pinned.
  Future<bool> isBuiltinTrainingPinned(String builtinTrainingId) async {
    final result =
        await (select(pinnedBuiltinTrainings)
              ..where((t) => t.builtinTrainingId.equals(builtinTrainingId)))
            .getSingleOrNull();
    return result != null;
  }

  // ------------------------------------- USERS -------------------------------------
  /// Get the currently logged-in user.
  Future<User?> getCurrentUser() async {
    return await (select(users)).getSingleOrNull();
  }

  /// Save or update the current user.
  Future<void> saveCurrentUser(UsersCompanion user) async {
    await into(users).insertOnConflictUpdate(user);
  }

  /// Delete the current user (on logout).
  Future<void> deleteCurrentUser() async {
    await delete(users).go();
  }

  /// Clear all user-generated local data (called on logout after remote import).
  Future<void> wipeLocalData() async {
    await delete(assessments).go();
    await delete(repDatas).go();
    await delete(sessions).go();
    await delete(trainings).go();
    await delete(sensorConfigs).go();
    await delete(builtinTrainingWeights).go();
    await delete(pinnedBuiltinTrainings).go();
  }

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.users);
      },
      from2To3: (m, schema) async {
        await m.addColumn(schema.sessions, schema.sessions.createdAt);
        await m.addColumn(schema.assessments, schema.assessments.createdAt);
        await m.addColumn(schema.repDatas, schema.repDatas.createdAt);
        await m.addColumn(
          schema.builtinTrainingWeights,
          schema.builtinTrainingWeights.createdAt,
        );
        await m.addColumn(schema.sensorConfigs, schema.sensorConfigs.createdAt);
        await m.addColumn(schema.repTemplates, schema.repTemplates.createdAt);
        await m.addColumn(schema.trainings, schema.trainings.createdAt);
        await m.addColumn(schema.repeaters, schema.repeaters.createdAt);
        await m.addColumn(
          schema.pinnedBuiltinTrainings,
          schema.pinnedBuiltinTrainings.createdAt,
        );
      },
      from3To4: (m, schema) async {
        await m.alterTable(
          TableMigration(
            schema.sessions,
            columnTransformer: {
              sessions.id: Schema3(database: m.database).sessions.remoteId,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.assessments,
            columnTransformer: {
              sessions.id: Schema3(database: m.database).sessions.remoteId,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.trainings,
            columnTransformer: {
              trainings.id: Schema3(database: m.database).trainings.remoteId,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.repDatas,
            columnTransformer: {
              repDatas.id: Schema3(database: m.database).repDatas.remoteId,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.repeaters,
            columnTransformer: {
              schema.repeaters.id: Schema3(
                database: m.database,
              ).repeaters.remoteId,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.sensorConfigs,
            columnTransformer: {
              sensorConfigs.id: Schema3(
                database: m.database,
              ).sensorConfigs.remoteId,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.repTemplates,
            columnTransformer: {
              schema.repTemplates.id: Schema3(
                database: m.database,
              ).repTemplates.remoteId,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.builtinTrainingWeights,
            columnTransformer: {
              builtinTrainingWeights.id: Schema3(
                database: m.database,
              ).builtinTrainingWeights.remoteId,
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schema.pinnedBuiltinTrainings,
            columnTransformer: {
              pinnedBuiltinTrainings.builtinTrainingId: Schema3(
                database: m.database,
              ).pinnedBuiltinTrainings.remoteId,
            },
          ),
        );
      },
      from4To5: (m, schema) async {
        await m.alterTable(TableMigration(schema.pinnedBuiltinTrainings));
      },
      from5To6: (m, schema) async {
        await m.alterTable(TableMigration(schema.sessions));
        await m.alterTable(TableMigration(schema.assessments));
        await m.alterTable(TableMigration(schema.repeaters));
        await m.alterTable(TableMigration(schema.trainings));
        await m.alterTable(TableMigration(schema.repTemplates));
        await m.alterTable(TableMigration(schema.repDatas));
        await m.alterTable(TableMigration(schema.sensorConfigs));
        await m.alterTable(TableMigration(schema.builtinTrainingWeights));
        await m.addColumn(
          schema.pinnedBuiltinTrainings,
          schema.pinnedBuiltinTrainings.updatedAt,
        );
        await m.addColumn(
          schema.pinnedBuiltinTrainings,
          schema.pinnedBuiltinTrainings.deletedAt,
        );
      },
      from6To7: (m, schema) async {
        // Drop dirty and deleted_at columns from all synced tables
        await m.alterTable(TableMigration(schema.sessions));
        await m.alterTable(TableMigration(schema.assessments));
        await m.alterTable(TableMigration(schema.repDatas));
        await m.alterTable(TableMigration(schema.sensorConfigs));
        await m.alterTable(TableMigration(schema.builtinTrainingWeights));
        await m.alterTable(TableMigration(schema.pinnedBuiltinTrainings));
        // Drop SyncMetadata table
        await m.database.customStatement('DROP TABLE IF EXISTS sync_metadata');
      },
      from7To8: (m, _) async {
        // Migrate trainings/repeaters/rep_templates to the unified schema.
        // Uses raw SQL to avoid depending on typed Schema8 table accessors.
        const gripNames = ['halfCrimp', 'threeFinger', 'fullCrimp', 'openHand'];
        String gripName(int idx) =>
            idx < gripNames.length ? gripNames[idx] : 'halfCrimp';

        // Read old data before any schema changes
        final oldRepeaters = await m.database
            .customSelect('SELECT * FROM repeaters')
            .get();
        final oldRepeaterTrainings = await m.database
            .customSelect(
              'SELECT id, repeater_id, is_favorite, name FROM trainings '
              'WHERE repeater_id IS NOT NULL',
            )
            .get();
        final oldCustomTrainings = await m.database
            .customSelect(
              'SELECT id, is_favorite, name FROM trainings '
              'WHERE repeater_id IS NULL',
            )
            .get();
        final oldRepTemplates = await m.database
            .customSelect(
              'SELECT training_id, is_rest, right_hand, duration, '
              'target_weight, "index", grip_position '
              'FROM rep_templates ORDER BY training_id, "index"',
            )
            .get();

        // Replace trainings table with new schema (raw SQLite table rename)
        await m.database.customStatement('''
          CREATE TABLE new_trainings (
            id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            is_favorite INTEGER NOT NULL DEFAULT 0
              CHECK (is_favorite IN (0, 1)),
            updated_at INTEGER NOT NULL DEFAULT
              (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
            PRIMARY KEY (id)
          )
        ''');
        await m.database.customStatement('''
          INSERT INTO new_trainings (id, title, is_favorite, updated_at)
          SELECT id, name, is_favorite, updated_at FROM trainings
        ''');
        await m.database.customStatement('DROP TABLE trainings');
        await m.database.customStatement(
          'ALTER TABLE new_trainings RENAME TO trainings',
        );

        // Create training_items table
        await m.database.customStatement('''
          CREATE TABLE training_items (
            id TEXT NOT NULL DEFAULT (lower(hex(randomblob(4))) || '-' ||
              lower(hex(randomblob(2))) || '-' || lower(hex(randomblob(2))) ||
              '-' || lower(hex(randomblob(2))) || '-' ||
              lower(hex(randomblob(6)))),
            training_id TEXT NOT NULL,
            parent_id TEXT,
            type TEXT NOT NULL,
            position INTEGER NOT NULL DEFAULT 0,
            cycles INTEGER,
            cycle_rest_seconds INTEGER,
            reps INTEGER,
            duration INTEGER,
            rest_seconds INTEGER,
            worktime_seconds INTEGER,
            hand TEXT,
            loads_json TEXT,
            left_loads_json TEXT,
            hand_positions_json TEXT,
            edge_sizes_mm_json TEXT,
            load_is_max INTEGER NOT NULL DEFAULT 0
              CHECK (load_is_max IN (0, 1)),
            free_text TEXT,
            exercise_id TEXT,
            section_title TEXT,
            updated_at INTEGER NOT NULL DEFAULT
              (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
            PRIMARY KEY (id),
            FOREIGN KEY (training_id) REFERENCES trainings(id)
              ON DELETE CASCADE
          )
        ''');

        final repeaterMap = {
          for (final r in oldRepeaters) r.data['id'] as String: r.data,
        };
        final now = (DateTime.now().millisecondsSinceEpoch / 1000)
            .floor()
            .toString();

        // Insert repeater items
        for (final t in oldRepeaterTrainings) {
          final trainingId = t.data['id'] as String;
          final r = repeaterMap[t.data['repeater_id'] as String];
          if (r == null) continue;

          final repsCount = (r['reps'] as num).toInt();
          final splitHand = r['split_hand'] == 1 || r['split_hand'] == true;
          final weightRight =
              (r['target_weight_right'] as num?)?.toDouble() ?? 0.0;
          final weightLeft =
              (r['target_weight_left'] as num?)?.toDouble() ?? 0.0;
          final grip = gripName((r['grip_position'] as num? ?? 0).toInt());
          final loads = jsonEncode(
            List.filled(repsCount, {'value': weightRight, 'unit': 'kg'}),
          );
          final leftLoads = splitHand
              ? jsonEncode(
                  List.filled(repsCount, {'value': weightLeft, 'unit': 'kg'}),
                )
              : null;
          final positions = jsonEncode(List.filled(repsCount, grip));

          await m.database.customStatement(
            'INSERT INTO training_items '
            '(training_id, type, position, cycles, reps, worktime_seconds, '
            'rest_seconds, cycle_rest_seconds, hand, loads_json, '
            'left_loads_json, hand_positions_json, updated_at) '
            'VALUES (?,?,0,?,?,?,?,?,?,?,?,?,?)',
            [
              trainingId,
              'repeater',
              (r['sets'] as num).toInt(),
              repsCount,
              (r['worktime'] as num).toInt(),
              (r['resttime'] as num).toInt(),
              (r['set_rest'] as num).toInt(),
              splitHand ? 'split' : 'both',
              loads,
              leftLoads,
              positions,
              now,
            ],
          );
        }

        // Insert hangboard_rep items for custom trainings
        final repsByTraining = <String, List<Map<String, dynamic>>>{};
        for (final rt in oldRepTemplates) {
          final tid = rt.data['training_id'] as String;
          repsByTraining.putIfAbsent(tid, () => []).add(rt.data);
        }

        for (final t in oldCustomTrainings) {
          final trainingId = t.data['id'] as String;
          final reps = repsByTraining[trainingId] ?? [];
          int pos = 0;
          for (int i = 0; i < reps.length; i++) {
            final rep = reps[i];
            if (rep['is_rest'] == 1 || rep['is_rest'] == true) continue;

            int restSecs = 0;
            if (i + 1 < reps.length) {
              final next = reps[i + 1];
              if (next['is_rest'] == 1 || next['is_rest'] == true) {
                restSecs = (next['duration'] as num).toInt();
              }
            }

            final rightHand =
                rep['right_hand'] == 1 || rep['right_hand'] == true;
            final weight = (rep['target_weight'] as num).toDouble();
            final grip = gripName((rep['grip_position'] as num? ?? 0).toInt());
            final loads = jsonEncode([
              {'value': weight, 'unit': 'kg'},
            ]);
            final positions = jsonEncode([grip]);

            await m.database.customStatement(
              'INSERT INTO training_items '
              '(training_id, type, position, worktime_seconds, rest_seconds, '
              'hand, loads_json, hand_positions_json, updated_at) '
              'VALUES (?,?,?,?,?,?,?,?,?)',
              [
                trainingId,
                'hangboard_rep',
                pos++,
                (rep['duration'] as num).toInt(),
                restSecs,
                rightHand ? 'right' : 'left',
                loads,
                positions,
                now,
              ],
            );
          }
        }

        // Drop legacy tables
        await m.database.customStatement('DROP TABLE IF EXISTS rep_templates');
        await m.database.customStatement('DROP TABLE IF EXISTS repeaters');
      },
    ),
  );
}

/// Helper function that given a file path, will read its content as JSON
/// and return the BleDataPoints if the file was formatted correclty.
Future<List<BleDataPoint>> getSessionData(String dataPath) async {
  try {
    final file = File(dataPath);
    final content = await file.readAsString();
    return (jsonDecode(content) as List)
        .map((u) => BleDataPoint.fromJson(u))
        .toList();
  } catch (e) {
    AppLoggerHelper.error("Failed to read data points in file $dataPath: $e");
    return [];
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ble_sessions.sqlite'));
    return NativeDatabase(file);
  });
}

final AppDatabase gDatabase = AppDatabase();
