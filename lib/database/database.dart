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

  // Sync columns
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();

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

  // Sync columns
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE',
  ];
}

// Stores the available trainings, including builtins and assessments.
class Trainings extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final TextColumn name = text()();
  late final TextColumn repeaterId = text().nullable()();
  late final BoolColumn isBuiltin = boolean().withDefault(
    const Constant(false),
  )();
  late final BoolColumn isFavorite = boolean().withDefault(
    const Constant(false),
  )();
  late final BoolColumn isAssessment = boolean().withDefault(
    const Constant(false),
  )();

  // Sync columns
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (repeater_id) REFERENCES repeaters(id) ON DELETE CASCADE',
  ];
}

// Stores the repeaters trainings, including builtins and assessments.
class Repeaters extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final IntColumn sets = integer()();
  late final IntColumn reps = integer()();
  late final IntColumn worktime = integer()();
  late final IntColumn resttime = integer()();
  late final IntColumn setRest = integer()();
  late final RealColumn targetWeigthRight = real().nullable()();
  late final RealColumn targetWeigthLeft = real().nullable()();
  late final BoolColumn splitHand = boolean()();
  late final IntColumn gripPosition = integer().withDefault(
    const Constant(0),
  )(); // 0 = halfCrimp (default)

  // Sync columns
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Stores the repetitions for the trainings.
class RepTemplates extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final BoolColumn isRest = boolean()();
  late final BoolColumn rightHand = boolean()();
  late final IntColumn duration = integer()();
  late final TextColumn trainingId = text()();
  late final RealColumn targetWeight = real()();
  late final IntColumn index = integer()();
  late final IntColumn gripPosition = integer().withDefault(
    const Constant(0),
  )(); // 0 = halfCrimp (default)

  // Sync columns
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();

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

  // Sync columns
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();

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

  // Sync columns
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
}

// Stores the saved sensor configs.
class SensorConfigs extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final TextColumn name = text()();
  late final IntColumn index = integer()();
  late final RealColumn tare = real()();
  late final RealColumn coef = real()();

  // Sync columns
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Stores custom weights for builtin trainings per user.
class BuiltinTrainingWeights extends Table {
  late final TextColumn id = text().clientDefault(() => Uuid().v4())();

  late final TextColumn builtinTrainingId = text()();
  late final RealColumn customWeightRight = real().nullable()();
  late final RealColumn customWeightLeft = real().nullable()();

  // Sync columns
  late final DateTimeColumn updatedAt = dateTime().withDefault(
    currentDateAndTime,
  )();
  late final DateTimeColumn deletedAt = dateTime().nullable()();
  late final BoolColumn dirty = boolean().withDefault(const Constant(false))();

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

// Stores sync metadata for tracking sync state.
class SyncMetadata extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final IntColumn lastSyncVersion = integer().withDefault(
    const Constant(0),
  )();
  late final DateTimeColumn lastSyncTime = dateTime().nullable()();
  late final IntColumn pendingChanges = integer().withDefault(
    const Constant(0),
  )();
}

@DriftDatabase(
  tables: [
    Sessions,
    Assessments,
    Trainings,
    RepTemplates,
    RepDatas,
    Repeaters,
    SensorConfigs,
    BuiltinTrainingWeights,
    PinnedBuiltinTrainings,
    Users,
    SyncMetadata,
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
    var query = select(sessions)..where((s) => s.deletedAt.isNull());
    // Handle date filters
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
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final sessionId = (await (select(
      sessions,
    )..where((s) => s.rowId.equals(sessionRowId))).getSingle()).id;

    await incrementPendingChanges();
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
            dirty: Value(true),
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
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await incrementPendingChanges();
  }

  /// Delete a session.
  Future<void> deleteSession(String sessionId) async {
    await (update(sessions)..where((s) => s.id.equals(sessionId))).write(
      SessionsCompanion(
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
        deletedAt: Value(DateTime.now()),
      ),
    );
    await incrementPendingChanges();
  }

  // ------------------------------------- TRAININGS -------------------------------------
  /// Save a training with its repetitions.
  Future<String> saveTrainingWithReps(String name, List<RepModel> reps) async {
    final trainingRowId = await into(trainings).insert(
      TrainingsCompanion(
        name: Value(name),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final trainingId = (await (select(
      trainings,
    )..where((t) => t.rowId.equals(trainingRowId))).getSingle()).id;
    await incrementPendingChanges();

    final companions = reps
        .asMap()
        .map(
          (index, rep) => MapEntry(
            index,
            RepTemplatesCompanion(
              duration: Value(rep.durationInSeconds),
              index: Value(index),
              isRest: Value(rep.isRest),
              rightHand: Value(rep.handSide.isRightHand),
              trainingId: Value(trainingId),
              targetWeight: Value(rep.targetWeight),
              gripPosition: Value(rep.gripPosition.index),
              dirty: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          ),
        )
        .values
        .toList();

    batch((batch) {
      batch.insertAll(repTemplates, companions);
    });
    await incrementPendingChanges();

    return trainingId;
  }

  /// Toggle the favorite status of a training.
  Future<void> toggleFav(String trainingId) async {
    final oldFav = (await (select(
      trainings,
    )..where((t) => t.id.equals(trainingId))).getSingle()).isFavorite;
    await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
      TrainingsCompanion(
        isFavorite: Value(!oldFav),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await incrementPendingChanges();
  }

  /// Edit a repetitions along with its reps.
  /// Updates existing reps in place to preserve IDs for sync.
  /// For a repeater training, use `editRepeaterTraining`
  Future<void> editTrainingWithReps(
    String trainingId, {
    String? name,
    List<RepModel>? reps,
  }) async {
    // First update the name if given.
    if (name != null) {
      await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
        TrainingsCompanion(
          name: Value(name),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await incrementPendingChanges();
    }

    if (reps != null) {
      final existingReps =
          await (select(repTemplates)
                ..where((r) => r.trainingId.equals(trainingId))
                ..orderBy([(r) => OrderingTerm(expression: r.index)]))
              .get();

      final now = DateTime.now();

      // Update existing reps or insert new ones, preserving IDs where possible
      for (var i = 0; i < reps.length; i++) {
        final rep = reps[i];
        final companion = RepTemplatesCompanion(
          duration: Value(rep.durationInSeconds),
          index: Value(i),
          isRest: Value(rep.isRest),
          rightHand: Value(rep.handSide.isRightHand),
          trainingId: Value(trainingId),
          targetWeight: Value(rep.targetWeight),
          gripPosition: Value(rep.gripPosition.index),
          dirty: const Value(true),
          updatedAt: Value(now),
        );

        if (i < existingReps.length) {
          await (update(
            repTemplates,
          )..where((r) => r.id.equals(existingReps[i].id))).write(companion);
        } else {
          await into(repTemplates).insert(companion);
        }
      }

      // Soft delete any excess reps that were removed
      for (var i = reps.length; i < existingReps.length; i++) {
        await (update(
          repTemplates,
        )..where((r) => r.id.equals(existingReps[i].id))).write(
          RepTemplatesCompanion(
            dirty: const Value(true),
            updatedAt: Value(now),
            deletedAt: Value(now),
          ),
        );
      }

      await incrementPendingChanges();

      if (name == null) {
        await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
          TrainingsCompanion(dirty: const Value(true), updatedAt: Value(now)),
        );
        await incrementPendingChanges();
      }
    }
  }

  /// Edit a repeater training.
  Future<void> editRepeaterTraining(
    String trainingId, {
    String? name,
    RepeaterModel? model,
  }) async {
    // First update the name if any.
    if (name != null) {
      await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
        TrainingsCompanion(
          name: Value(name),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await incrementPendingChanges();
    }

    if (model != null) {
      // Get repeater ID
      var r = await (select(
        trainings,
      )..where((t) => t.id.equals(trainingId))).getSingle();

      // Make sure the template has a repeater Id
      if (r.repeaterId == null) {
        AppLoggerHelper.error("Template missing repeater ID while updating");
        return;
      }

      // Then update the repeater template
      await (update(
        repeaters,
      )..where((tbl) => tbl.id.equals(r.repeaterId!))).write(
        RepeatersCompanion(
          reps: Value(model.repsBySet),
          sets: Value(model.sets),
          resttime: Value(model.restTime),
          setRest: Value(model.restBteweenSets),
          splitHand: Value(model.splitHand),
          targetWeigthLeft: Value(model.weightLeft),
          targetWeigthRight: Value(model.weightRight),
          worktime: Value(model.workTime),
          gripPosition: Value(model.gripPosition.index),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (name == null) {
        await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
          TrainingsCompanion(
            dirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
        await incrementPendingChanges();
      }
    }
  }

  /// Save a repeater training given a model.
  Future<String> saveRepeaterTraining(String name, RepeaterModel model) async {
    final repeaterRowId = await into(repeaters).insert(
      RepeatersCompanion(
        reps: Value(model.repsBySet),
        sets: Value(model.sets),
        resttime: Value(model.restTime),
        setRest: Value(model.restBteweenSets),
        splitHand: Value(model.splitHand),
        targetWeigthLeft: Value(model.weightLeft),
        targetWeigthRight: Value(model.weightRight),
        worktime: Value(model.workTime),
        gripPosition: Value(model.gripPosition.index),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final repeaterId = (await (select(
      repeaters,
    )..where((r) => r.rowId.equals(repeaterRowId))).getSingle()).id;

    final trainingRowId = await into(trainings).insert(
      TrainingsCompanion(
        name: Value(name),
        repeaterId: Value(repeaterId),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final trainingId = (await (select(
      trainings,
    )..where((t) => t.rowId.equals(trainingRowId))).getSingle()).id;
    await incrementPendingChanges();
    return trainingId;
  }

  /// Get a repeater training.
  Future<Repeater?> getRepeater(String rId) =>
      (select(repeaters)..where((s) => s.id.equals(rId))).getSingleOrNull();

  /// Get all the trainings without the assessments.
  Future<List<Training>> getAllTrainingsWithoutAssessments() =>
      (select(trainings)..where(
            (training) =>
                training.isAssessment.not() & training.deletedAt.isNull(),
          ))
          .get();

  /// Get all the assessment trainings.
  Future<List<Training>> getAllAssessmentTrainings() =>
      (select(trainings)..where(
            (training) => training.isAssessment & training.deletedAt.isNull(),
          ))
          .get();

  /// Get all favorite trainings.
  Future<List<Training>> getFavTrainings() => (select(
    trainings,
  )..where((t) => t.isFavorite & t.deletedAt.isNull())).get();

  /// Get the rep templates associated with a training.
  Future<List<RepTemplate>> getRepsForTraining(String trainingId) =>
      (select(repTemplates)
            ..where(
              (r) => r.trainingId.equals(trainingId) & r.deletedAt.isNull(),
            )
            ..orderBy([(r) => OrderingTerm(expression: r.index)]))
          .get();

  /// Delete a training.
  Future<void> deleteTraining(String trainingId) async {
    await (update(trainings)..where((t) => t.id.equals(trainingId))).write(
      TrainingsCompanion(
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
        deletedAt: Value(DateTime.now()),
      ),
    );
    await incrementPendingChanges();
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
      dirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    );

    final assessmentRowId = await into(assessments).insert(companion);
    final assessmentId = (await (select(
      assessments,
    )..where((a) => a.rowId.equals(assessmentRowId))).getSingle()).id;
    await incrementPendingChanges();
    return assessmentId;
  }

  /// Delete an assessment.
  Future<void> deleteAssessment(String id) async {
    await (update(assessments)..where((a) => a.id.equals(id))).write(
      AssessmentsCompanion(
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
        deletedAt: Value(DateTime.now()),
      ),
    );
    await incrementPendingChanges();
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
    var query = select(assessments)..where((a) => a.deletedAt.isNull());

    if (type != null) {
      query = query..where((r) => r.type.equals(type.index));
    }
    // Add filter if hand was provided.
    if (handSide != null) {
      query = query
        ..where(
          (assessment) => handSide.isRightHand
              ? assessment.rightValue.isNotNull()
              : assessment.leftValue.isNotNull(),
        );
    }
    // Add filter if grip position was provided.
    if (gripPosition != null) {
      query = query
        ..where(
          (assessment) => assessment.gripPosition.equals(gripPosition.index),
        );
    }

    // Join on sessions to get the date of the assessment.
    final res = await query.join([
      innerJoin(
        sessions,
        sessions.id.equalsExp(assessments.sessionId) &
            sessions.deletedAt.isNull(),
      ),
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
  Future<List<SensorConfig>> getSensorConfigs() async =>
      (select(sensorConfigs)
            ..orderBy([(r) => OrderingTerm.desc(r.index)])
            ..where((conf) => conf.deletedAt.isNull()))
          .get();

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
      dirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    );
    final rowId = await into(sensorConfigs).insert(newConf);
    await incrementPendingChanges();
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
          dirty: const Value(true),
          updatedAt: Value(now),
        ),
      );
    }
    await incrementPendingChanges();
  }

  /// Delete a sensor config.
  Future<void> deleteSensorConfig(String id) async {
    await (update(sensorConfigs)..where((t) => t.id.equals(id))).write(
      SensorConfigsCompanion(
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
        deletedAt: Value(DateTime.now()),
      ),
    );
    await incrementPendingChanges();
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

  /// Save or update custom weights for a builtin training.
  Future<void> saveBuiltinTrainingWeights({
    required String builtinTrainingId,
    double? customWeightRight,
    double? customWeightLeft,
  }) async {
    // Check if weights already exist
    final existing = await getBuiltinTrainingWeights(builtinTrainingId);

    if (existing != null) {
      await (update(
        builtinTrainingWeights,
      )..where((w) => w.id.equals(existing.id))).write(
        BuiltinTrainingWeightsCompanion(
          customWeightRight: Value(customWeightRight),
          customWeightLeft: Value(customWeightLeft),
          updatedAt: Value(DateTime.now()),
          dirty: const Value(true),
        ),
      );
    } else {
      await into(builtinTrainingWeights).insert(
        BuiltinTrainingWeightsCompanion.insert(
          builtinTrainingId: builtinTrainingId,
          customWeightRight: Value(customWeightRight),
          customWeightLeft: Value(customWeightLeft),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    await incrementPendingChanges();
  }

  // ------------------------------------- PINNED BUILTIN TRAININGS -------------------------------------
  /// Get all pinned builtin training IDs.
  Future<List<String>> getPinnedBuiltinTrainingIds() async {
    return (await (select(
          pinnedBuiltinTrainings,
        )..where((p) => p.deletedAt.isNull())).get())
        .map((row) => row.builtinTrainingId)
        .toList();
  }

  /// Pin a builtin training to the home screen.
  Future<void> pinBuiltinTraining(String builtinTrainingId) async {
    await into(pinnedBuiltinTrainings).insert(
      PinnedBuiltinTrainingsCompanion(
        builtinTrainingId: Value(builtinTrainingId),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await incrementPendingChanges();
  }

  /// Unpin a builtin training from the home screen.
  Future<void> unpinBuiltinTraining(String builtinTrainingId) async {
    await (update(
      pinnedBuiltinTrainings,
    )..where((t) => t.builtinTrainingId.equals(builtinTrainingId))).write(
      PinnedBuiltinTrainingsCompanion(
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
        deletedAt: Value(DateTime.now()),
      ),
    );
    await incrementPendingChanges();
  }

  /// Check if a builtin training is pinned.
  Future<bool> isBuiltinTrainingPinned(String builtinTrainingId) async {
    final result =
        await (select(pinnedBuiltinTrainings)..where(
              (t) =>
                  t.builtinTrainingId.equals(builtinTrainingId) &
                  t.deletedAt.isNull(),
            ))
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

  // ------------------------------------- SYNC METADATA -------------------------------------
  /// Get the sync metadata.
  Future<SyncMetadataData?> getSyncMetadata() async {
    return await (select(syncMetadata)).getSingleOrNull();
  }

  /// Save or update sync metadata.
  Future<void> saveSyncMetadata({
    required int lastSyncVersion,
    DateTime? lastSyncTime,
    int? pendingChanges,
  }) async {
    final existing = await getSyncMetadata();
    if (existing != null) {
      await (update(
        syncMetadata,
      )..where((s) => s.id.equals(existing.id))).write(
        SyncMetadataCompanion(
          lastSyncVersion: Value(lastSyncVersion),
          lastSyncTime: Value(lastSyncTime),
          pendingChanges: Value(pendingChanges ?? existing.pendingChanges),
        ),
      );
    } else {
      await into(syncMetadata).insert(
        SyncMetadataCompanion.insert(
          lastSyncVersion: Value(lastSyncVersion),
          lastSyncTime: Value(lastSyncTime),
          pendingChanges: Value(pendingChanges ?? 0),
        ),
      );
    }
  }

  /// Increment pending changes count.
  Future<void> incrementPendingChanges() async {
    final existing = await getSyncMetadata();
    final currentCount = existing?.pendingChanges ?? 0;
    await saveSyncMetadata(
      lastSyncVersion: existing?.lastSyncVersion ?? 0,
      lastSyncTime: existing?.lastSyncTime,
      pendingChanges: currentCount + 1,
    );
  }

  /// Reset pending changes count.
  Future<void> resetPendingChanges() async {
    final existing = await getSyncMetadata();
    if (existing != null) {
      await saveSyncMetadata(
        lastSyncVersion: existing.lastSyncVersion,
        lastSyncTime: existing.lastSyncTime,
        pendingChanges: 0,
      );
    }
  }

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.users);
        await m.createTable(schema.syncMetadata);
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
              repeaters.id: Schema3(database: m.database).repeaters.remoteId,
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
              repTemplates.id: Schema3(
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
