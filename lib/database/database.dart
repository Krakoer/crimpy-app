import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crimpy/database/database.steps.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/sensor_preset.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
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
  // What was done, as a label only. Indexes match SessionActivity.
  late final IntColumn activity = integer().withDefault(const Constant(0))();
  // How the session came to exist, as a SessionOrigin name.
  late final TextColumn origin = text().withDefault(const Constant('logged'))();
  // What the session was played from, both null when it was logged by hand.
  late final TextColumn trainingId = text().nullable()();
  late final TextColumn programSessionId = text().nullable()();
  late final IntColumn duration = integer().withDefault(const Constant(0))();

  // The items the run was played from, frozen as JSON when it was saved, the
  // way the server freezes a prescription onto the session it creates. It is
  // the only copy that still names the blocks once the training is edited or
  // deleted, and so the only thing that keeps the reps and the open counts
  // recorded against an item id readable. Null on a session that answered no
  // training, and on every session saved before the column existed, which is
  // what leaves those falling back to the live training.
  late final TextColumn prescriptionJson = text().nullable()();

  /// The id the API gave this row when the guest import put it on the server,
  /// null while it is only local. The import skips a row that carries one, so a
  /// run that failed partway can be retried without uploading, and duplicating,
  /// everything that already went up.
  late final TextColumn serverId = text().nullable()();

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};
}

// Stores the assessments the user has done, with the results.
// What each assessment is. Only the ones Crimpy ships live here, seeded on first
// open, so a result recorded offline can still be named and formatted: a coach
// assessment is read from the server, which sends its definition on every result
// and on the training it is run from. The generated row class is named
// AssessmentDefinitionRow to avoid conflict with the domain AssessmentDefinition
// in assessment_model.dart.
@DataClassName('AssessmentDefinitionRow')
class AssessmentDefinitions extends Table {
  late final TextColumn id = text()();

  late final TextColumn label = text()();

  /// 'kilograms', 'seconds' or 'repetitions', as the server stores it.
  late final TextColumn unit = text()();

  late final BoolColumn perHand = boolean().withDefault(
    const Constant(false),
  )();

  /// The question a coach assessment ends on, null on the ones Crimpy ships.
  late final TextColumn prompt = text().nullable()();

  /// The training a coach assessment is run from, null on the ones Crimpy ships.
  late final TextColumn trainingId = text().nullable()();

  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();

  @override
  Set<Column> get primaryKey => {id};
}

class Assessments extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  /// The assessment measured, naming a row in [AssessmentDefinitions]. The ones
  /// Crimpy ships are rows there like a coach's own, so there is no builtin
  /// discriminator beside this.
  late final TextColumn assessmentId = text()();
  late final RealColumn rightValue = real().nullable()();
  late final RealColumn leftValue = real().nullable()();
  late final TextColumn sessionId = text()();
  late final IntColumn gripPosition = integer().nullable().withDefault(
    const Constant(0),
  )(); // 0 = halfCrimp (default)

  /// The id the API gave this row when the guest import put it on the server,
  /// null while it is only local. The import skips a row that carries one, so a
  /// run that failed partway can be retried without uploading, and duplicating,
  /// everything that already went up.
  late final TextColumn serverId = text().nullable()();

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

  /// The id the API gave this row when the guest import put it on the server,
  /// null while it is only local. The import skips a row that carries one, so a
  /// run that failed partway can be retried without uploading, and duplicating,
  /// everything that already went up.
  late final TextColumn serverId = text().nullable()();

  /// When the import last put this training on the server, and so the moment
  /// the copy the server holds was written from. Every local edit clears it,
  /// which is what tells the next run the stored copy is behind and has to be
  /// updated rather than skipped.
  late final DateTimeColumn importedAt = dateTime().nullable()();

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
  // How often a round of an emom starts, null on every other type.
  late final IntColumn intervalSeconds = integer().nullable()();

  // Reps (per cycle for repeaters, total for exercises)
  late final IntColumn reps = integer().nullable()();
  // Whether the rep count is left open, which is an AMRAP: the athlete does as
  // many as they can and records how many that was.
  late final BoolColumn repsIsMax = boolean().withDefault(
    const Constant(false),
  )();
  // Explicit duration in seconds (exercises, free items)
  late final IntColumn duration = integer().nullable()();
  // Rest after the item or between reps
  late final IntColumn restSeconds = integer().nullable()();
  // Worktime per rep (repeater and hangboard_rep)
  late final IntColumn worktimeSeconds = integer().nullable()();
  // How the two hands are worked, see HangboardHand.
  late final TextColumn hand = text().nullable()();
  // Layout of the arrays below, see HangboardGranularity.
  late final TextColumn granularity = text().nullable()();

  // Per-rep JSON arrays
  late final TextColumn loadsJson = text().nullable()();
  late final TextColumn leftLoadsJson = text().nullable()();
  late final TextColumn handPositionsJson = text().nullable()();
  late final TextColumn edgeSizesMmJson = text().nullable()();

  /// Scalar fields set as a percentage of an assessment result, keyed by field
  /// name. Stored as JSON, the same shape the server holds.
  late final TextColumn variableTargetsJson = text().nullable()();

  late final BoolColumn loadIsMax = boolean().withDefault(
    const Constant(false),
  )();
  late final TextColumn freeText = text().nullable()();
  late final TextColumn exerciseId = text().nullable()();
  late final TextColumn groupTitle = text().nullable()();

  /// The id the API gave this row when the guest import put it on the server,
  /// null while it is only local. The import skips a row that carries one, so a
  /// run that failed partway can be retried without uploading, and duplicating,
  /// everything that already went up.
  late final TextColumn serverId = text().nullable()();

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
  // Which hand pulled the rep: 'left', 'right', or 'both' for a hang taken two
  // handed. Text rather than a boolean, which had no room for the third state
  // and stored a two handed hang as the left hand.
  late final TextColumn hand = text()();
  late final IntColumn duration = integer()();
  late final RealColumn targetWeight = real()();
  late final IntColumn index = integer()();
  late final IntColumn gripPosition = integer().withDefault(
    const Constant(0),
  )(); // 0 = halfCrimp (default)
  // Depth of the edge the rep was pulled on, null when the step prescribed
  // none: a rest, or an exercise done off the hangboard.
  late final IntColumn edgeSizeMm = integer().nullable()();
  // Item of the training the rep was played from, null for a rep recorded
  // outside a training. Not a reference: the training stays editable while the
  // played session keeps the prescription it was run from.
  late final TextColumn trainingItemId = text().nullable()();

  // Whether the step prescribed a load nothing measured, which is the sensor
  // dropping while a hang it was meant to read was running. The rep records no
  // target then, exactly as a step nothing was going to measure does, so this
  // is what tells a lost target from one never given when the run is graded.
  late final BoolColumn targetUnmeasured = boolean().withDefault(
    const Constant(false),
  )();

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

// Stores what the athlete achieved on a step the prescription left open: the
// reps an AMRAP turned out to be, and the rounds an emom was carried through.
// Neither can be read back off the reps, since a set of pull ups passes through
// no sensor and so records none.
class SessionItemResults extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final TextColumn sessionId = text()();
  // Which item of the prescription the count answers. Not a reference, for the
  // reason the rep link is not one either: the training stays editable while
  // the played session keeps the prescription it was run from.
  late final TextColumn trainingItemId = text()();
  // Which pass through that item the count belongs to, from 0, so a block that
  // repeats can be answered once per round.
  late final IntColumn occurrence = integer().withDefault(const Constant(0))();
  // 'reps' for an AMRAP, 'cycles' for the rounds an emom was carried through.
  late final TextColumn field = text()();
  late final IntColumn value = integer()();

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

// Which account the guest import marks belong to. A server id recorded on a row
// only means anything against the account it was uploaded to: without this, an
// athlete who is dropped back to guest mode by an expired token and then signs
// in as somebody else would have those rows skipped as already imported, and
// then wiped once the run reported no failures, losing them from the device
// while they sit on the first account.
class GuestImportTargets extends Table {
  // Always zero: the table holds one row, or none before the first import.
  late final IntColumn id = integer().withDefault(const Constant(0))();
  late final TextColumn userId = text()();

  @override
  Set<Column> get primaryKey => {id};
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
    AssessmentDefinitions,
    Assessments,
    Trainings,
    TrainingItems,
    RepDatas,
    SessionItemResults,
    SensorConfigs,
    BuiltinTrainingWeights,
    PinnedBuiltinTrainings,
    GuestImportTargets,
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

    return session.toModel(
      dataPoints: dataPoints,
      itemResults: await getItemResultsForSession(sessionId),
    );
  }

  /// Get all saved sessions. Filtering is deliberately not done here:
  /// [SessionFilter.matchesSession] is the single implementation of the
  /// predicate, so the local and the remote repositories select the same
  /// sessions for the same filter.
  Future<List<Session>> getAllSessions() => select(sessions).get();

  /// Get the repetitions data for a given session.
  Future<List<RepDataModel>> getRepsForSession(String sessionId) async =>
      (await _repRowsForSession(sessionId)).map((r) => r.toModel()).toList();

  /// The counts the run recorded for the items the prescription left open.
  Future<List<SessionItemResultModel>> getItemResultsForSession(
    String sessionId,
  ) async =>
      (await (select(sessionItemResults)
                ..where((r) => r.sessionId.equals(sessionId))
                ..orderBy([
                  (r) => OrderingTerm(expression: r.trainingItemId),
                  (r) => OrderingTerm(expression: r.occurrence),
                ]))
              .get())
          .map(
            (r) => SessionItemResultModel(
              trainingItemId: r.trainingItemId,
              occurrence: r.occurrence,
              field: SessionItemField.fromApi(r.field),
              value: r.value,
            ),
          )
          .toList();

  Future<List<RepData>> _repRowsForSession(String sessionId) =>
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
    List<SessionItemResultModel> itemResults = const [],
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
        activity: Value(session.activity.index),
        origin: Value(session.origin.apiValue),
        trainingId: Value(session.trainingId),
        programSessionId: Value(session.programSessionId),
        duration: Value(sessionDuration),
        prescriptionJson: _encodePrescription(session.prescriptionItems),
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
            hand: Value(index.$2.handSide.apiValue),
            sessionId: Value(sessionId),
            targetWeight: Value(index.$2.targetWeight),
            averageWeight: Value(index.$2.averageWeight),
            gripPosition: Value(index.$2.gripPosition.index),
            edgeSizeMm: Value(index.$2.edgeSizeMm),
            trainingItemId: Value(index.$2.trainingItemId),
            targetUnmeasured: Value(index.$2.targetUnmeasured),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .toList();

    final resultCompanions = itemResults
        .map(
          (result) => SessionItemResultsCompanion(
            sessionId: Value(sessionId),
            trainingItemId: Value(result.trainingItemId),
            occurrence: Value(result.occurrence),
            field: Value(result.field.apiValue),
            value: Value(result.value),
            updatedAt: Value(DateTime.now()),
          ),
        )
        .toList();

    batch((batch) {
      batch.insertAll(repDatas, companions);
      batch.insertAll(sessionItemResults, resultCompanions);
    });

    return sessionId;
  }

  /// Update an existing session.
  /// Only updates basic fields (date, name, notes, duration). Activity and
  /// origin describe how the session came about and never change afterwards,
  /// and reps and data points are left untouched.
  ///
  /// A played session owns its date and its duration, since the run measured
  /// them, so an edit leaves both columns as they are and touches the fields a
  /// user can actually type. The remote repository holds the same line.
  Future<void> updateSession(SessionModel session) async {
    if (session.id == null) {
      throw ArgumentError('Session ID is required for update');
    }

    final bool keepsRunTimings = session.origin.isPlayed;

    await (update(sessions)..where((s) => s.id.equals(session.id!))).write(
      SessionsCompanion(
        date: keepsRunTimings ? const Value.absent() : Value(session.date),
        notes: Value(session.notes ?? ""),
        name: Value(session.name),
        duration: keepsRunTimings
            ? const Value.absent()
            : Value(session.duration),
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
  Training _buildTraining(
    TrainingRow row,
    List<TrainingItemRow> allItems, {
    AssessmentDefinition? assessment,
  }) {
    final topLevel = allItems.where((i) => i.parentId == null).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return Training(
      id: row.id,
      title: row.title,
      description: row.description,
      isFavorite: row.isFavorite,
      items: topLevel.map((i) => _buildItem(i, allItems)).toList(),
      assessment: assessment,
    );
  }

  /// The assessment a training is run from, when it is one. Read from the cached
  /// definitions rather than stored twice, so the two cannot disagree.
  Future<AssessmentDefinition?> _assessmentForTraining(
    String trainingId,
  ) async {
    final row = await (select(
      assessmentDefinitions,
    )..where((d) => d.trainingId.equals(trainingId))).getSingleOrNull();
    return row?.toDomain();
  }

  TrainingItem _buildItem(TrainingItemRow row, List<TrainingItemRow> allItems) {
    List<Load>? parseLoads(String? json) {
      if (json == null || json.isEmpty) return null;
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => Load.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<List<String>>? parseGrips(String? json) {
      if (json == null || json.isEmpty) return null;
      return parseHandPositions(jsonDecode(json));
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
      intervalSeconds: row.intervalSeconds,
      reps: row.reps,
      repsIsMax: row.repsIsMax,
      duration: row.duration,
      restSeconds: row.restSeconds,
      worktimeSeconds: row.worktimeSeconds,
      hand: row.hand,
      granularity: row.granularity,
      loads: parseLoads(row.loadsJson),
      leftLoads: parseLoads(row.leftLoadsJson),
      edgeSizesMm: parseInts(row.edgeSizesMmJson),
      handPositions: parseGrips(row.handPositionsJson),
      variableTargets: parseVariableTargets(
        row.variableTargetsJson == null
            ? null
            : jsonDecode(row.variableTargetsJson!),
      ),
      loadIsMax: row.loadIsMax,
      freeText: row.freeText,
      exerciseId: row.exerciseId,
      groupTitle: row.groupTitle,
      items: children.map((c) => _buildItem(c, allItems)).toList(),
    );
  }

  String? _loadsToJson(List<Load>? loads) =>
      loads == null ? null : jsonEncode(loads.map((l) => l.toJson()).toList());

  String? _variableTargetsToJson(Map<String, VariableTarget> targets) =>
      targets.isEmpty
      ? null
      : jsonEncode({
          for (final entry in targets.entries) entry.key: entry.value.toJson(),
        });

  String? _handPositionsToJson(TrainingItem item) =>
      item.handPositions == null ? null : jsonEncode(item.handPositions);

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
      result.add(
        _buildTraining(
          row,
          itemRows,
          assessment: await _assessmentForTraining(row.id),
        ),
      );
    }
    return result;
  }

  /// One training by id, or null when it no longer exists.
  Future<Training?> getTraining(String trainingId) async {
    final row = await (select(
      trainings,
    )..where((t) => t.id.equals(trainingId))).getSingleOrNull();
    if (row == null) return null;
    final itemRows =
        await (select(trainingItems)
              ..where((i) => i.trainingId.equals(trainingId))
              ..orderBy([(i) => OrderingTerm(expression: i.position)]))
            .get();
    return _buildTraining(
      row,
      itemRows,
      assessment: await _assessmentForTraining(trainingId),
    );
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

  /// The columns of one item row. The insert and the reconcile paths share it,
  /// so a field added to one of them cannot be forgotten by the other.
  TrainingItemsCompanion _itemCompanion(
    TrainingItem item,
    String trainingId,
    String? parentId,
  ) {
    return TrainingItemsCompanion(
      trainingId: Value(trainingId),
      parentId: Value(parentId),
      type: Value(item.type.apiValue),
      position: Value(item.position),
      cycles: Value(item.cycles),
      cycleRestSeconds: Value(item.cycleRestSeconds),
      intervalSeconds: Value(item.intervalSeconds),
      reps: Value(item.reps),
      repsIsMax: Value(item.repsIsMax),
      duration: Value(item.duration),
      restSeconds: Value(item.restSeconds),
      worktimeSeconds: Value(item.worktimeSeconds),
      hand: Value(item.hand),
      granularity: Value(item.granularity),
      loadsJson: Value(_loadsToJson(item.loads)),
      leftLoadsJson: Value(_loadsToJson(item.leftLoads)),
      handPositionsJson: Value(_handPositionsToJson(item)),
      edgeSizesMmJson: Value(_intsToJson(item.edgeSizesMm)),
      variableTargetsJson: Value(_variableTargetsToJson(item.variableTargets)),
      loadIsMax: Value(item.loadIsMax),
      freeText: Value(item.freeText),
      exerciseId: Value(item.exerciseId),
      groupTitle: Value(item.groupTitle),
      updatedAt: Value(DateTime.now()),
    );
  }

  Future<void> _insertItems(
    List<TrainingItem> items,
    String trainingId,
    String? parentId,
  ) async {
    for (final item in items) {
      final itemId = await _insertItem(item, trainingId, parentId);
      if (item.items.isNotEmpty) {
        await _insertItems(item.items, trainingId, itemId);
      }
    }
  }

  /// Inserts one item and returns the id storage minted for it.
  Future<String> _insertItem(
    TrainingItem item,
    String trainingId,
    String? parentId,
  ) async {
    final itemRowId = await into(
      trainingItems,
    ).insert(_itemCompanion(item, trainingId, parentId));
    return (await (select(
      trainingItems,
    )..where((i) => i.rowId.equals(itemRowId))).getSingle()).id;
  }

  /// Writes [items] onto the rows already stored for [trainingId] rather than
  /// recreating them: an item carrying the id it was read under keeps that row,
  /// one the editor added or duplicated carries an empty id and gets a new row.
  /// The ids the tree still holds are collected into [keptIds], so the caller
  /// can delete the rows that disappeared and only those.
  Future<void> _syncItems(
    List<TrainingItem> items,
    String trainingId,
    String? parentId,
    Set<String> keptIds,
  ) async {
    for (final item in items) {
      final String itemId;
      if (item.id.isEmpty) {
        itemId = await _insertItem(item, trainingId, parentId);
        keptIds.add(itemId);
      } else {
        itemId = item.id;
        // Two items claiming one row would collapse onto it, and the tree
        // would come back a node short with nothing to say so.
        if (!keptIds.add(itemId)) {
          throw StateError('training item $itemId appears twice in the tree');
        }
        final written =
            await (update(trainingItems)..where(
                  (i) => i.id.equals(itemId) & i.trainingId.equals(trainingId),
                ))
                .write(_itemCompanion(item, trainingId, parentId));
        if (written == 0) {
          throw StateError(
            'training item $itemId does not belong to training $trainingId',
          );
        }
      }
      if (item.items.isNotEmpty) {
        await _syncItems(item.items, trainingId, itemId, keptIds);
      }
    }
  }

  /// Update an existing training, reconciling its items against the stored rows
  /// instead of replacing them. The reps and the open rep counts a session
  /// recorded are written against the item ids in force when it ran, so minting
  /// a fresh id per row on every save strands all of them, on an edit that
  /// never touched the item they point at.
  Future<void> updateTraining(Training training) async {
    await transaction(() async {
      // The mark the guest import left says the server holds this training as
      // it was written then, and it no longer does. Clearing it is what has the
      // next run update the stored copy instead of skipping a training it
      // believes is already up.
      await (update(trainings)..where((t) => t.id.equals(training.id))).write(
        TrainingsCompanion(
          title: Value(training.title),
          description: Value(training.description),
          isFavorite: Value(training.isFavorite),
          importedAt: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final keptIds = <String>{};
      await _syncItems(training.items, training.id, null, keptIds);

      // An empty set of kept ids deletes the whole tree: drift reads `isNotIn`
      // on no value as true rather than emitting `id NOT IN ()`.
      await (delete(trainingItems)..where(
            (i) => i.trainingId.equals(training.id) & i.id.isNotIn(keptIds),
          ))
          .go();
    });
  }

  /// Toggle the favorite status of a training.
  Future<void> toggleFav(String trainingId) async {
    final row = await (select(
      trainings,
    )..where((t) => t.id.equals(trainingId))).getSingle();
    await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
      TrainingsCompanion(
        isFavorite: Value(!row.isFavorite),
        importedAt: const Value(null),
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
      assessmentId: Value(assessment.assessmentId),
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

  /// Every assessment known locally, the ones Crimpy ships seeded on first
  /// open, so a result can be named offline.
  Future<List<AssessmentDefinition>> getAssessmentDefinitions() async {
    final rows = await select(assessmentDefinitions).get();
    return rows.map((row) => row.toDomain()).toList();
  }

  /// Get the assessments done.
  /// Allow to filter on `type`.
  /// If the `rightHand` parameter is set, it will only return the results for the given hand.
  /// If the `gripPosition` parameter is set, only assessments with that grip position will be retrieved.
  Future<List<AssessmentModel>> getAssessments({
    String? assessmentId,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    var query = select(assessments);

    if (assessmentId != null) {
      query = query..where((r) => r.assessmentId.equals(assessmentId));
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

    final joined = query.join([
      innerJoin(sessions, sessions.id.equalsExp(assessments.sessionId)),
      // Left, so a result whose definition has not synced yet still reads back
      // rather than vanishing from the history.
      leftOuterJoin(
        assessmentDefinitions,
        assessmentDefinitions.id.equalsExp(assessments.assessmentId),
      ),
    ]);

    // Callers take the last entry as the most recent one, so the order is part
    // of the contract and cannot be left to whatever SQLite returns. The row id
    // breaks ties so two results recorded on the same session date still read
    // back in the order they were written.
    joined.orderBy([
      OrderingTerm.asc(sessions.date),
      OrderingTerm.asc(assessments.rowId),
    ]);

    final res = await joined.get();

    return res.map((row) {
      final assessment = row.readTable(assessments);
      final session = row.readTable(sessions);
      final definition = row.readTableOrNull(assessmentDefinitions);

      return AssessmentModel(
        date: session.date,
        definition:
            definition?.toDomain() ??
            AssessmentDefinition(
              id: assessment.assessmentId,
              label: 'Assessment',
              unit: AssessmentUnit.kilograms,
            ),
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
  Future<List<SensorPreset>> getSensorPresets() async =>
      (await (select(
            sensorConfigs,
          )..orderBy([(r) => OrderingTerm.desc(r.index)])).get())
          .map((row) => row.toModel())
          .toList();

  /// Save a new sensor config.
  Future<int> addSensorPreset(NewSensorPreset preset) async {
    // Only the highest position is needed. Without the limit this reads every
    // row and getSingleOrNull throws as soon as a second preset exists.
    final maxConfIndex =
        await (select(sensorConfigs)
              ..orderBy([(u) => OrderingTerm.desc(u.index)])
              ..limit(1))
            .getSingleOrNull();
    final newIndex = maxConfIndex == null ? 1 : maxConfIndex.index + 1;
    final newConf = SensorConfigsCompanion(
      coef: Value(preset.coef),
      tare: Value(preset.tare),
      index: Value(newIndex),
      name: Value(preset.name),
      updatedAt: Value(DateTime.now()),
    );
    final rowId = await into(sensorConfigs).insert(newConf);
    return rowId;
  }

  /// Delete a sensor config.
  Future<void> deleteSensorPreset(String id) async {
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
  // -------------------------- GUEST DATA IMPORT --------------------------
  // What the API called the rows the import has already put up. Only the
  // trainings, their items, the sessions and the assessments are tracked: the
  // pinned builtins and the builtin weight overrides upsert on a natural key
  // server side, so sending one twice updates the same row rather than adding
  // a second, and there is nothing to remember for them.

  /// The local to server id map the import has established so far, for the
  /// trainings it has already put on the server and for their items. A session
  /// imported on a later attempt still has to name the training it was played
  /// from and the blocks its reps came from, and neither id survives in memory
  /// between two runs.
  Future<({Map<String, String> trainings, Map<String, String> items})>
  importedTrainingIds() async {
    final trainingRows = await (select(
      trainings,
    )..where((t) => t.serverId.isNotNull())).get();
    final itemRows = await (select(
      trainingItems,
    )..where((i) => i.serverId.isNotNull())).get();
    return (
      trainings: {for (final row in trainingRows) row.id: row.serverId!},
      items: {for (final row in itemRows) row.id: row.serverId!},
    );
  }

  /// Records what the API called a training and each of its items, so a retry
  /// skips the upload and still resolves the links its sessions carry. The mark
  /// is stamped with the moment it was made, which the next local edit clears:
  /// that is what has the run after it update the stored copy rather than skip
  /// a training the server holds an older version of.
  Future<void> markTrainingImported(
    String localId,
    String serverId,
    Map<String, String> itemIds,
  ) => transaction(() async {
    await (update(trainings)..where((t) => t.id.equals(localId))).write(
      TrainingsCompanion(
        serverId: Value(serverId),
        importedAt: Value(DateTime.now()),
      ),
    );
    for (final entry in itemIds.entries) {
      await (update(trainingItems)..where((i) => i.id.equals(entry.key))).write(
        TrainingItemsCompanion(serverId: Value(entry.value)),
      );
    }
  });

  Future<void> markSessionImported(String localId, String serverId) =>
      (update(sessions)..where((s) => s.id.equals(localId))).write(
        SessionsCompanion(serverId: Value(serverId)),
      );

  Future<void> markAssessmentImported(String localId, String serverId) =>
      (update(assessments)..where((a) => a.id.equals(localId))).write(
        AssessmentsCompanion(serverId: Value(serverId)),
      );

  /// The sessions still to import: the ones never uploaded, and the ones whose
  /// own upload succeeded while one of their assessments did not. Leaving that
  /// second kind out would let the run report nothing left to do while a result
  /// is still stranded on the device.
  Future<List<Session>> pendingSessions() {
    final withPendingResult = selectOnly(assessments)
      ..addColumns([assessments.sessionId])
      ..where(assessments.serverId.isNull());
    return (select(sessions)..where(
          (s) => s.serverId.isNull() | s.id.isInQuery(withPendingResult),
        ))
        .get();
  }

  /// Makes [userId] the account the import marks belong to, dropping the marks
  /// first when they were made against a different one. A server id says where
  /// a row went, and it says nothing at all about an account that has never
  /// seen it.
  Future<void> retargetImport(String userId) => transaction(() async {
    final current = await select(guestImportTargets).getSingleOrNull();
    if (current != null && current.userId == userId) return;
    await _clearImportMarks();
    await delete(guestImportTargets).go();
    await into(
      guestImportTargets,
    ).insert(GuestImportTargetsCompanion.insert(userId: userId));
  });

  Future<void> _clearImportMarks() async {
    await update(
      sessions,
    ).write(const SessionsCompanion(serverId: Value(null)));
    await update(trainings).write(
      const TrainingsCompanion(serverId: Value(null), importedAt: Value(null)),
    );
    await update(
      trainingItems,
    ).write(const TrainingItemsCompanion(serverId: Value(null)));
    await update(
      assessments,
    ).write(const AssessmentsCompanion(serverId: Value(null)));
  }

  /// Drops the mark a training and its items carry, for a training the server
  /// turns out not to hold any more. The ids it names answer nothing, so the
  /// import creates the training again rather than aiming update after update
  /// at a row that is gone.
  Future<void> clearTrainingImport(String trainingId) => transaction(() async {
    await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
      const TrainingsCompanion(serverId: Value(null), importedAt: Value(null)),
    );
    await (update(trainingItems)..where((i) => i.trainingId.equals(trainingId)))
        .write(const TrainingItemsCompanion(serverId: Value(null)));
  });

  /// The trainings the import already put on the server and the athlete has
  /// edited since. The server holds a copy of what the training was, so the
  /// next run has to update it: skipping it leaves the edit on the device for
  /// good, and the items the edit added with no server id to name them, which
  /// strands the reps and the open counts of every session played from them.
  ///
  /// A local edit clears the time the mark was made, so a training carrying a
  /// server id and no time is one the server holds an older copy of. The marks
  /// written before the time was recorded read as behind for the same reason:
  /// nothing says whether an edit came after them, and an update the server did
  /// not need costs one request.
  Future<Set<String>> staleImportedTrainingIds() async {
    final rows = await (select(
      trainings,
    )..where((t) => t.serverId.isNotNull() & t.importedAt.isNull())).get();
    return {for (final row in rows) row.id};
  }

  /// The trainings still to import: the ones never uploaded, and the ones
  /// uploaded before an edit the server has not been told about.
  Future<List<Training>> pendingTrainings() async {
    final imported = (await importedTrainingIds()).trainings;
    final stale = await staleImportedTrainingIds();
    return (await getAllTrainings())
        .where((t) => !imported.containsKey(t.id) || stale.contains(t.id))
        .toList();
  }

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
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await seedBuiltinAssessmentDefinitions(m.database);
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Rebuild trainings from the legacy repeaters / rep_templates
        // tables into the unified training_items schema. Raw SQL is used
        // because the legacy tables no longer exist in the Dart schema.
        const gripNames = ['halfCrimp', 'threeFinger', 'fullCrimp', 'openHand'];
        String gripName(int idx) =>
            idx < gripNames.length ? gripNames[idx] : 'halfCrimp';

        // Read old data before any schema changes
        final oldRepeaters = await m.database
            .customSelect('SELECT * FROM repeaters')
            .get();
        // Soft-deleted and assessment trainings have no place in the new
        // schema, so they are left behind rather than copied over.
        const liveTrainings =
            'deleted_at IS NULL AND is_assessment = 0 AND is_builtin = 0';
        final oldRepeaterTrainings = await m.database
            .customSelect(
              'SELECT id, repeater_id, is_favorite, name FROM trainings '
              'WHERE repeater_id IS NOT NULL AND $liveTrainings',
            )
            .get();
        final oldCustomTrainings = await m.database
            .customSelect(
              'SELECT id, is_favorite, name FROM trainings '
              'WHERE repeater_id IS NULL AND $liveTrainings',
            )
            .get();
        final keptIds = [
          ...oldRepeaterTrainings.map((t) => t.data['id'] as String),
          ...oldCustomTrainings.map((t) => t.data['id'] as String),
        ];
        final oldRepTemplates = await m.database
            .customSelect(
              'SELECT training_id, is_rest, right_hand, duration, '
              'target_weight, "index", grip_position '
              'FROM rep_templates ORDER BY training_id, "index"',
            )
            .get();

        // Rebuild trainings on the v2 shape. alterTable emits drift's own
        // DDL, so the result matches the generated schema exactly.
        await m.alterTable(
          TableMigration(
            schema.trainings,
            columnTransformer: {
              schema.trainings.title: const CustomExpression<String>('name'),
            },
            newColumns: [schema.trainings.description],
          ),
        );
        await m.database.customStatement(
          'DELETE FROM trainings WHERE id NOT IN (${keptIds.isEmpty ? "''" : keptIds.map((_) => '?').join(',')})',
          keptIds.isEmpty ? const [] : keptIds,
        );

        await m.createTable(schema.trainingItems);

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
              (r['target_weigth_right'] as num?)?.toDouble() ?? 0.0;
          final weightLeft =
              (r['target_weigth_left'] as num?)?.toDouble() ?? 0.0;
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
            '(id, training_id, type, position, cycles, reps, worktime_seconds, '
            'rest_seconds, cycle_rest_seconds, hand, loads_json, '
            'left_loads_json, hand_positions_json, updated_at) '
            'VALUES (?,?,?,0,?,?,?,?,?,?,?,?,?,?)',
            [
              const Uuid().v4(),
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
              '(id, training_id, type, position, worktime_seconds, '
              'rest_seconds, hand, loads_json, hand_positions_json, '
              'updated_at) '
              'VALUES (?,?,?,?,?,?,?,?,?,?)',
              [
                const Uuid().v4(),
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
        await m.database.customStatement('DROP TABLE IF EXISTS sync_metadata');

        // Shed the sync bookkeeping columns (dirty, deleted_at) that the
        // remote-first repositories replaced.
        await m.alterTable(TableMigration(schema.sessions));
        await m.alterTable(TableMigration(schema.assessments));
        await m.alterTable(TableMigration(schema.repDatas));
        await m.alterTable(TableMigration(schema.sensorConfigs));
        await m.alterTable(TableMigration(schema.builtinTrainingWeights));
        await m.alterTable(TableMigration(schema.pinnedBuiltinTrainings));
      },
      from2To3: (m, schema) async {
        await m.addColumn(
          schema.trainingItems,
          schema.trainingItems.granularity,
        );

        // A step that throws after the column exists would leave the schema
        // ahead of the recorded version, and the retry on the next launch would
        // fail on the duplicate column with no way back. json_array_length
        // raises on malformed JSON rather than returning null, so every
        // statement reading a JSON column guards with json_valid first.
        await m.database.transaction(() async {
          // Items used to leave their layout implicit, so declare the one they
          // were written with. The edge sizes decide it when they are there,
          // and the load count otherwise, which is all an app-written item
          // carries.
          await m.database.customStatement(
            "UPDATE training_items SET granularity = CASE "
            "WHEN json_array_length(COALESCE(NULLIF(edge_sizes_mm_json, ''), '[]')) > 1 THEN "
            "  CASE WHEN COALESCE(cycles, 1) > 1 "
            "        AND json_array_length(edge_sizes_mm_json) "
            "            = COALESCE(cycles, 1) * COALESCE(reps, 1) "
            "       THEN 'set' ELSE 'rep' END "
            "WHEN json_array_length(COALESCE(NULLIF(edge_sizes_mm_json, ''), '[]')) = 1 THEN 'uniform' "
            "WHEN json_array_length(COALESCE(NULLIF(loads_json, ''), '[]')) > 1 THEN 'rep' "
            "ELSE 'uniform' END "
            "WHERE type IN ('repeater', 'hangboard_rep') "
            "AND (edge_sizes_mm_json IS NULL OR json_valid(edge_sizes_mm_json)) "
            "AND (loads_json IS NULL OR json_valid(loads_json))",
          );

          // Anything left holding malformed JSON carries no readable layout, so
          // it declares the single-row one rather than blocking the migration.
          await m.database.customStatement(
            "UPDATE training_items SET granularity = 'uniform' "
            "WHERE type IN ('repeater', 'hangboard_rep') AND granularity IS NULL",
          );

          // A repeater the app stored as 'both' ran one hand at a time, right
          // then left within every rep. That is the alternating mode now. Only
          // the app omits the edge sizes, and a hangboard_rep already meant a
          // genuine two-handed hang, so neither is reclassified.
          await m.database.customStatement(
            "UPDATE training_items SET hand = 'alternate' "
            "WHERE type = 'repeater' AND hand = 'both' "
            "AND edge_sizes_mm_json IS NULL",
          );

          // Grips are stored as one array per hand everywhere, so wrap the flat
          // array earlier versions wrote.
          await m.database.customStatement(
            "UPDATE training_items "
            "SET hand_positions_json = json_array(json(hand_positions_json)) "
            "WHERE hand_positions_json IS NOT NULL "
            "AND json_valid(hand_positions_json) "
            "AND json_type(hand_positions_json, '\$[0]') != 'array'",
          );
        });
      },
      from3To4: (m, schema) async {
        await m.addColumn(schema.repDatas, schema.repDatas.edgeSizeMm);
      },
      from4To5: (m, schema) async {
        // session_type carried three meanings at once. Its values become the
        // activity label unchanged, and the two facts it was standing in for
        // get their own columns.
        await m.renameColumn(
          schema.sessions,
          'session_type',
          schema.sessions.activity,
        );
        await m.addColumn(schema.sessions, schema.sessions.origin);
        await m.addColumn(schema.sessions, schema.sessions.trainingId);
        await m.addColumn(schema.sessions, schema.sessions.programSessionId);

        // Reps only ever came from a run played in the app, so their presence
        // is what separates the two origins in the existing rows. Assessments
        // are played too, even when the protocol recorded no usable rep.
        await m.database.customStatement(
          "UPDATE sessions SET origin = 'played' WHERE is_assessment = 1 "
          'OR id IN (SELECT DISTINCT session_id FROM rep_datas)',
        );
      },
      from5To6: (m, schema) async {
        await m.addColumn(schema.repDatas, schema.repDatas.trainingItemId);
      },
      // The repeater configuration described the set shape of a session, but
      // only the dummy data generator ever wrote it: a finished run saved none.
      // The reps name the training item they were played from instead, which
      // describes the same shape and holds for a training of several blocks.
      from6To7: (m, schema) async {
        for (final column in [
          'repeater_sets',
          'repeater_reps',
          'repeater_work_time',
          'repeater_rest_time',
          'repeater_set_rest',
          'repeater_split_hand',
        ]) {
          await m.database.customStatement(
            'ALTER TABLE sessions DROP COLUMN $column',
          );
        }
      },
      from7To8: (m, schema) async {
        await m.addColumn(schema.repDatas, schema.repDatas.targetUnmeasured);
      },
      from8To9: (m, schema) async {
        // The boolean had no room for a two handed hang, which it stored as the
        // left hand. The reps already recorded carry no trace of the state that
        // was lost, so they keep the hand the boolean claimed.
        await m.alterTable(
          TableMigration(
            schema.repDatas,
            columnTransformer: {
              schema.repDatas.hand: const CustomExpression<String>(
                "CASE WHEN right_hand THEN 'right' ELSE 'left' END",
              ),
            },
            newColumns: [schema.repDatas.hand],
          ),
        );
      },
      from9To10: (m, schema) async {
        // Assessments stopped being a closed set of three: every one is a row
        // now, the ones Crimpy ships included, and a result names it by id.
        await m.createTable(schema.assessmentDefinitions);
        await seedBuiltinAssessmentDefinitions(m.database);

        // A result whose discriminator named no assessment described nothing a
        // client could read back. It goes first, since the column it would be
        // copied into does not accept a null.
        await m.database.customStatement(
          'DELETE FROM assessments WHERE type NOT IN (0, 1, 2)',
        );

        // The results already recorded were keyed by the old discriminator,
        // so they are re-pointed at the rows just seeded.
        await m.alterTable(
          TableMigration(
            schema.assessments,
            columnTransformer: {
              schema.assessments.assessmentId: CustomExpression<String>(
                "CASE type "
                "WHEN 0 THEN '${BuiltinAssessmentIds.criticalForce}' "
                "WHEN 1 THEN '${BuiltinAssessmentIds.maxForce}' "
                "WHEN 2 THEN '${BuiltinAssessmentIds.endurance60}' "
                "END",
              ),
            },
            newColumns: [schema.assessments.assessmentId],
          ),
        );

        // Variable targets were never stored locally, so a training cached here
        // lost every percentage reference on a round trip.
        await m.addColumn(
          schema.trainingItems,
          schema.trainingItems.variableTargetsJson,
        );
      },
      from10To11: (m, schema) async {
        // An emom is a block, and a rep count may be left open, so a run now
        // has counts to record that no rep carries.
        await m.addColumn(
          schema.trainingItems,
          schema.trainingItems.intervalSeconds,
        );
        await m.addColumn(schema.trainingItems, schema.trainingItems.repsIsMax);
        await m.createTable(schema.sessionItemResults);
      },
      from11To12: (m, schema) async {
        // A session now freezes what it was played from, so its reps and its
        // open counts stay readable once the training is edited or deleted.
        // The sessions already stored are left without one: they were saved
        // from a training that may have drifted since, and a snapshot taken
        // now would freeze that drift as though the run had played it.
        await m.addColumn(schema.sessions, schema.sessions.prescriptionJson);
      },
      from12To13: (m, schema) async {
        // The guest import now records what it managed to upload, so a retry
        // after a partial failure skips what is already on the server instead
        // of sending it a second time. Everything stored before this is left
        // null, which is what an unimported row looks like anyway.
        await m.addColumn(schema.sessions, schema.sessions.serverId);
        await m.addColumn(schema.trainings, schema.trainings.serverId);
        await m.addColumn(schema.assessments, schema.assessments.serverId);
        await m.addColumn(schema.trainingItems, schema.trainingItems.serverId);
        await m.createTable(schema.guestImportTargets);
      },
      from13To14: (m, schema) async {
        // The import now stamps the mark it leaves on a training, and a local
        // edit clears the stamp, so a training the server holds an older copy
        // of is sent up as an update instead of skipped. The marks already
        // stored are left without a stamp, which reads as edited: an update
        // the server did not need costs one request, and a guest edit made
        // before this shipped reaches the account it was skipped for.
        await m.addColumn(schema.trainings, schema.trainings.importedAt);
      },
    ),
  );
}

/// The assessments Crimpy ships, written with the ids the server seeds so a
/// result recorded offline names the same row once it syncs.
Future<void> seedBuiltinAssessmentDefinitions(DatabaseConnectionUser db) async {
  const builtins = [
    (BuiltinAssessmentIds.criticalForce, 'Critical Force', 'kilograms'),
    (BuiltinAssessmentIds.maxForce, 'Max Force', 'kilograms'),
    (BuiltinAssessmentIds.endurance60, '60% Endurance', 'seconds'),
  ];
  for (final (id, label, unit) in builtins) {
    await db.customStatement(
      'INSERT OR IGNORE INTO assessment_definitions '
      '(id, label, unit, per_hand, updated_at) VALUES (?, ?, ?, 1, ?)',
      [id, label, unit, DateTime.now().millisecondsSinceEpoch ~/ 1000],
    );
  }
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

/// Maps a stored repetition row onto the domain model the rest of the app
/// works with, so drift's row classes stop at the database layer.
extension RepDataRowToModel on RepData {
  RepDataModel toModel() => RepDataModel(
    averageWeight: averageWeight,
    duration: duration,
    index: index,
    isRest: isRest,
    handSide: handSideFromApi(hand),
    targetWeight: targetWeight,
    gripPosition: enumFromIndex(
      GripPosition.values,
      gripPosition,
      GripPosition.halfCrimp,
    ),
    edgeSizeMm: edgeSizeMm,
    trainingItemId: trainingItemId,
    targetUnmeasured: targetUnmeasured,
  );
}

/// The items a run was played from, as the column holds them: the envelope the
/// server sends a prescription in, so both stores hold one shape and are read
/// back by one parser. A tree with no items is stored as none rather than as an
/// empty snapshot: a run that named no block has nothing to freeze, and an
/// empty list would claim the training was read and found bare.
Value<String?> _encodePrescription(List<TrainingItem>? items) =>
    items == null || items.isEmpty
    ? const Value(null)
    : Value(
        jsonEncode({
          'items': items.map((i) => i.toPrescriptionJson()).toList(),
        }),
      );

/// The frozen prescription of a session row, or null when it holds none. A
/// snapshot that no longer parses is read as none rather than thrown: the reps
/// are still worth showing, headed by the live training as they were before
/// the column existed.
List<TrainingItem>? _decodePrescription(String? stored) {
  if (stored == null || stored.isEmpty) return null;
  try {
    return SessionModel.prescriptionItemsOf(jsonDecode(stored));
  } catch (error) {
    AppLoggerHelper.error('Unreadable session prescription', error);
    return null;
  }
}

/// Maps a stored session row onto the domain model, optionally with the
/// repetitions and sensor samples that were loaded alongside it.
extension SessionRowToModel on Session {
  SessionModel toModel({
    List<RepDataModel>? reps,
    List<BleDataPoint>? dataPoints,
    List<SessionItemResultModel> itemResults = const [],
  }) => SessionModel(
    id: id,
    name: name,
    notes: notes,
    date: date,
    reps: reps,
    dataPoints: dataPoints,
    isAssessment: isAssessment,
    activity: enumFromIndex(
      SessionActivity.values,
      activity,
      SessionActivity.hangboard,
    ),
    origin: sessionOriginFromApi(origin),
    trainingId: trainingId,
    programSessionId: programSessionId,
    durationInSeconds: duration,
    prescriptionItems: _decodePrescription(prescriptionJson),
    itemResults: itemResults,
  );
}

/// Maps a stored definition row onto the domain model.
extension AssessmentDefinitionRowToModel on AssessmentDefinitionRow {
  AssessmentDefinition toDomain() => AssessmentDefinition(
    id: id,
    label: label,
    unit: assessmentUnitFromApi(unit),
    perHand: perHand,
    prompt: prompt,
    trainingId: trainingId,
  );
}

/// Maps a stored assessment row onto the domain result model.
extension AssessmentRowToModel on Assessment {
  AssessmentResultModel toResult() => AssessmentResultModel(
    assessmentId: assessmentId,
    rightValue: rightValue,
    leftValue: leftValue,
    gripPosition: gripPosition == null
        ? null
        : enumFromIndex<GripPosition?>(GripPosition.values, gripPosition, null),
  );
}

/// Maps a stored sensor calibration row onto the domain model.
extension SensorConfigRowToModel on SensorConfig {
  SensorPreset toModel() =>
      SensorPreset(id: id, name: name, index: index, tare: tare, coef: coef);
}
