import 'dart:convert';
import 'dart:io';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/ble_data_model.dart';

part 'database.g.dart';

// Stores the training sessions the user has done.
class Sessions extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final TextColumn name = text()();
  late final TextColumn notes = text()();
  late final DateTimeColumn date = dateTime().withDefault(currentDateAndTime)();
  late final TextColumn dataPath = text()();
  late final BoolColumn isAssessment =
      boolean().withDefault(const Constant(false))();
  late final IntColumn sessionType =
      integer().withDefault(const Constant(0))(); // 0 = crimpy (default)
  late final IntColumn duration = integer().withDefault(const Constant(0))();

  // Repeater configuration (if session was a repeater workout)
  late final IntColumn repeaterSets = integer().nullable()();
  late final IntColumn repeaterReps = integer().nullable()();
  late final IntColumn repeaterWorkTime = integer().nullable()();
  late final IntColumn repeaterRestTime = integer().nullable()();
  late final IntColumn repeaterSetRest = integer().nullable()();
  late final BoolColumn repeaterSplitHand = boolean().nullable()();
}

// Stores the assessments the user has done, with the results.
class Assessments extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final IntColumn type = integer()();
  late final RealColumn rightValue = real().nullable()();
  late final RealColumn leftValue = real().nullable()();
  late final IntColumn sessionId = integer().references(Sessions, #id)();
  late final IntColumn gripPosition =
      integer().nullable().withDefault(
        const Constant(0),
      )(); // 0 = halfCrimp (default)
}

// Stores the available trainings, including builtins and assessments.
class Trainings extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final TextColumn name = text()();
  late final IntColumn repeaterId =
      integer()
          .references(Repeaters, #id, onDelete: KeyAction.cascade)
          .nullable()();
  late final BoolColumn isBuiltin =
      boolean().withDefault(const Constant(false))();
  late final BoolColumn isFavorite =
      boolean().withDefault(const Constant(false))();
  late final BoolColumn isAssessment =
      boolean().withDefault(const Constant(false))();
}

// Stores the repeaters trainings, including builtins and assessments.
class Repeaters extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final IntColumn sets = integer()();
  late final IntColumn reps = integer()();
  late final IntColumn worktime = integer()();
  late final IntColumn resttime = integer()();
  late final IntColumn setRest = integer()();
  late final RealColumn targetWeigthRight = real().nullable()();
  late final RealColumn targetWeigthLeft = real().nullable()();
  late final BoolColumn splitHand = boolean()();
  late final IntColumn gripPosition =
      integer().withDefault(const Constant(0))(); // 0 = halfCrimp (default)
}

// Stores the repetitions for the trainings.
class RepTemplates extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final BoolColumn isRest = boolean()();
  late final BoolColumn rightHand = boolean()();
  late final IntColumn duration = integer()();
  late final IntColumn trainingId =
      integer().references(Trainings, #id, onDelete: KeyAction.cascade)();
  late final RealColumn targetWeight = real()();
  late final IntColumn index = integer()();
  late final IntColumn gripPosition =
      integer().withDefault(const Constant(0))(); // 0 = halfCrimp (default)
}

// Stores the data for the repetitions done during a session.
class RepDatas extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final RealColumn averageWeight = real()();
  late final IntColumn sessionId = integer().references(Sessions, #id)();
  late final BoolColumn isRest = boolean()();
  late final BoolColumn rightHand = boolean()();
  late final IntColumn duration = integer()();
  late final RealColumn targetWeight = real()();
  late final IntColumn index = integer()();
  late final IntColumn gripPosition =
      integer().withDefault(const Constant(0))(); // 0 = halfCrimp (default)
}

// Stores the IDs of pinned builtin trainings
class PinnedBuiltinTrainings extends Table {
  late final IntColumn builtinTrainingId = integer()();

  @override
  Set<Column> get primaryKey => {builtinTrainingId};
}

// Stores the saved sensor configs.
class SensorConfigs extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final TextColumn name = text()();
  late final IntColumn index = integer()();
  late final RealColumn tare = real()();
  late final RealColumn coef = real()();
}

// Stores custom weights for builtin trainings per user.
class BuiltinTrainingWeights extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final IntColumn builtinTrainingId =
      integer().references(Trainings, #id, onDelete: KeyAction.cascade)();
  late final RealColumn customWeightRight = real().nullable()();
  late final RealColumn customWeightLeft = real().nullable()();
  late final DateTimeColumn updatedAt =
      dateTime().withDefault(currentDateAndTime)();
}

// Stores sync metadata for tracking backend synchronization.
class SyncMetadata extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final TextColumn entityTable = text()();
  late final IntColumn localId = integer()();
  late final IntColumn remoteId = integer().nullable()();
  late final DateTimeColumn lastSyncedAt = dateTime().nullable()();
  late final BoolColumn needsUpload =
      boolean().withDefault(const Constant(false))();
  late final BoolColumn needsDownload =
      boolean().withDefault(const Constant(false))();
  late final TextColumn pendingOperation = text().nullable()();
}

// Stores offline operations queue for sync retry logic.
class OfflineQueue extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final TextColumn operation = text()();
  late final TextColumn payload = text()();
  late final DateTimeColumn createdAt =
      dateTime().withDefault(currentDateAndTime)();
  late final IntColumn retryCount = integer().withDefault(const Constant(0))();
}

// Stores authenticated user profile information.
class UserProfile extends Table {
  late final TextColumn id = text()();
  late final TextColumn email = text()();
  late final TextColumn firstname = text().nullable()();
  late final TextColumn lastname = text().nullable()();
  late final DateTimeColumn createdAt = dateTime()();

  @override
  Set<Column> get primaryKey => {id};
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
    SyncMetadata,
    OfflineQueue,
    UserProfile,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  // ------------------------------------- SESSIONS -------------------------------------
  /// Get a session with its data points.
  Future<SessionModel?> getSessionWithData(int sessionId) async {
    final session =
        await (select(sessions)
          ..where((s) => s.id.equals(sessionId))).getSingleOrNull();
    if (session == null) return null;

    final List<BleDataPoint> dataPoints =
        session.dataPath.isEmpty ? [] : await getSessionData(session.dataPath);

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
    // Handle date filters
    if (filters != null) {
      if (filters.startDate != null) {
        query =
            query..where(
              (session) => session.date.isBiggerThanValue(filters.startDate!),
            );
      }
      if (filters.endDate != null) {
        query =
            query..where(
              (session) => session.date.isSmallerThanValue(filters.endDate!),
            );
      }
      if (filters.isAssessment != null) {
        query =
            query..where(
              (session) => session.isAssessment.equals(filters.isAssessment!),
            );
      }
    }
    return query.get();
  }

  /// Get the repetitions data for a given session.
  Future<List<RepData>> getRepsForSession(int sessionId) =>
      (select(repDatas)
            ..where((r) => r.sessionId.equals(sessionId))
            ..orderBy([(r) => OrderingTerm(expression: r.index)]))
          .get();

  /// Save a session with its reps.
  /// If the `points` argument is not null, it will save
  /// the data onto the disk.
  Future<int> saveSession(
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

    final sessionId = await into(sessions).insert(
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
      ),
    );
    final companions =
        reps.indexed
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
      ),
    );
  }

  /// Delete a session.
  Future<void> deleteSession(int sessionId) =>
      (delete(sessions)..where((t) => t.id.equals(sessionId))).go();

  // ------------------------------------- TRAININGS -------------------------------------
  /// Save a training with its repetitions.
  Future<int> saveTrainingWithReps(String name, List<RepModel> reps) async {
    final trainingId = await into(
      trainings,
    ).insert(TrainingsCompanion(name: Value(name)));

    final companions =
        reps
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
                ),
              ),
            )
            .values
            .toList();

    batch((batch) {
      batch.insertAll(repTemplates, companions);
    });

    return trainingId;
  }

  /// Toggle the favorite status of a training.
  Future<void> toggleFav(int trainingId) async {
    final oldFav =
        (await (select(trainings)
              ..where((t) => t.id.equals(trainingId))).getSingle())
            .isFavorite;
    await (update(trainings)..where(
      (t) => t.id.equals(trainingId),
    )).write(TrainingsCompanion(isFavorite: Value(!oldFav)));
  }

  /// Edit a repetitions along with its reps.
  /// While being inneficient, instead of recomputing rep index etc., all reps are deleted and recreated.
  /// For a repeater training, use `editRepeaterTraining`
  Future<void> editTrainingWithReps(
    int trainingId, {
    String? name,
    List<RepModel>? reps,
  }) async {
    // First update the name if given.
    if (name != null) {
      await (update(trainings)..where(
        (t) => t.id.equals(trainingId),
      )).write(TrainingsCompanion(name: Value(name)));
    }

    // Then delete and recreate the reps, if any.
    if (reps != null) {
      await (delete(repTemplates)
        ..where((r) => r.trainingId.equals(trainingId))).go();
      final companions =
          reps
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
                  ),
                ),
              )
              .values
              .toList();

      await batch((batch) {
        batch.insertAll(repTemplates, companions);
      });
    }
  }

  /// Edit a repeater training.
  Future<void> editRepeaterTraining(
    int trainingId, {
    String? name,
    RepeaterModel? model,
  }) async {
    // First update the name if any.
    if (name != null) {
      await (update(trainings)..where(
        (t) => t.id.equals(trainingId),
      )).write(TrainingsCompanion(name: Value(name)));
    }

    if (model != null) {
      // Get repeater ID
      var r =
          await (select(trainings)
            ..where((t) => t.id.equals(trainingId))).getSingle();

      // Make sure the template has a repeater Id
      if (r.repeaterId == null) {
        AppLoggerHelper.error("Template missing repeater ID while updating");
        return;
      }

      // Then update the repeater template
      await (update(repeaters)
        ..where((tbl) => tbl.id.equals(r.repeaterId!))).write(
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
        ),
      );
    }
  }

  /// Save a repeater training given a model.
  Future<int> saveRepeaterTraining(String name, RepeaterModel model) async {
    final repeaterId = await into(repeaters).insert(
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
      ),
    );

    return await into(trainings).insert(
      TrainingsCompanion(name: Value(name), repeaterId: Value(repeaterId)),
    );
  }

  /// Get a repeater training.
  Future<Repeater?> getRepeater(int rId) =>
      (select(repeaters)..where((s) => s.id.equals(rId))).getSingleOrNull();

  /// Get all the trainings without the assessments.
  Future<List<Training>> getAllTrainingsWithoutAssessments() =>
      (select(trainings)
        ..where((training) => training.isAssessment.not())).get();

  /// Get all the assessment trainings.
  Future<List<Training>> getAllAssessmentTrainings() =>
      (select(trainings)..where((training) => training.isAssessment)).get();

  /// Get all favorite trainings.
  Future<List<Training>> getFavTrainings() =>
      (select(trainings)..where((t) => t.isFavorite)).get();

  /// Get the rep templates associated with a training.
  Future<List<RepTemplate>> getRepsForTraining(int trainingId) =>
      (select(repTemplates)
            ..where((r) => r.trainingId.equals(trainingId))
            ..orderBy([(r) => OrderingTerm(expression: r.index)]))
          .get();

  /// Delete a training.
  Future<void> deleteTraining(int trainingId) =>
      (delete(trainings)..where((t) => t.id.equals(trainingId))).go();

  // ------------------------------------- ASSESSMENTS -------------------------------------
  /// Given an assessment with the results and a sessionId, store the assessment into DB.
  Future<int> saveAssessment(
    AssessmentResultModel assessment,
    int sessionId,
  ) async {
    final companion = AssessmentsCompanion(
      rightValue: Value(assessment.rightValue),
      leftValue: Value(assessment.leftValue),
      type: Value(assessment.type.index),
      sessionId: Value(sessionId),
      gripPosition: Value(assessment.gripPosition?.index),
    );

    return await into(assessments).insert(companion);
  }

  /// Delete an assessment.
  Future<void> deleteAssessment(int id) =>
      (delete(assessments)..where((t) => t.id.equals(id))).go();

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
    // Add filter if hand was provided.
    if (handSide != null) {
      query =
          query..where(
            (assessment) =>
                handSide.isRightHand
                    ? assessment.rightValue.isNotNull()
                    : assessment.leftValue.isNotNull(),
          );
    }
    // Add filter if grip position was provided.
    if (gripPosition != null) {
      query =
          query..where(
            (assessment) => assessment.gripPosition.equals(gripPosition.index),
          );
    }

    // Join on sessions to get the date of the assessment.
    final res =
        await query.join([
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
        gripPosition:
            assessment.gripPosition != null
                ? GripPosition.values[assessment.gripPosition!]
                : null,
      );
    }).toList();
  }

  // ------------------------------------- SENSOR CONFIGS -------------------------------------
  /// Get the saved sensor configs.
  Future<List<SensorConfig>> getSensorConfigs() async =>
      (select(sensorConfigs)
        ..orderBy([(r) => OrderingTerm.desc(r.index)])).get();

  /// Save a new sensor config.
  Future<int> addSensorConfig(SensorConfigsCompanion config) async {
    final maxConfIndex =
        await (select(sensorConfigs)
          ..orderBy([(u) => OrderingTerm.desc(u.index)])).getSingleOrNull();
    final newIndex = maxConfIndex == null ? 1 : maxConfIndex.index + 1;
    final newConf = SensorConfigsCompanion(
      coef: config.coef,
      tare: config.tare,
      index: Value(newIndex),
      name: config.name,
    );
    return await into(sensorConfigs).insert(newConf);
  }

  /// Update a list of sensor configs.
  Future<void> updateSensorConfigs(List<SensorConfigs> configs) async {
    for (final entry in configs) {
      await update(sensorConfigs).replace(entry as Insertable<SensorConfig>);
    }
  }

  /// Delete a new sensor config.
  Future<void> deleteSensorConfig(int id) async =>
      (delete(sensorConfigs)..where((t) => t.id.equals(id))).go();

  // ------------------------------------- BUILTIN TRAINING WEIGHTS -------------------------------------
  /// Get custom weights for a builtin training.
  Future<BuiltinTrainingWeight?> getBuiltinTrainingWeights(
    int builtinTrainingId,
  ) async =>
      (select(builtinTrainingWeights)
            ..where((w) => w.builtinTrainingId.equals(builtinTrainingId))
            ..orderBy([(w) => OrderingTerm.desc(w.updatedAt)]))
          .getSingleOrNull();

  /// Save or update custom weights for a builtin training.
  Future<void> saveBuiltinTrainingWeights({
    required int builtinTrainingId,
    double? customWeightRight,
    double? customWeightLeft,
  }) async {
    // Check if weights already exist
    final existing = await getBuiltinTrainingWeights(builtinTrainingId);

    if (existing != null) {
      // Update existing weights
      await (update(builtinTrainingWeights)
        ..where((w) => w.id.equals(existing.id))).write(
        BuiltinTrainingWeightsCompanion(
          customWeightRight: Value(customWeightRight),
          customWeightLeft: Value(customWeightLeft),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // Insert new weights
      await into(builtinTrainingWeights).insert(
        BuiltinTrainingWeightsCompanion.insert(
          builtinTrainingId: builtinTrainingId,
          customWeightRight: Value(customWeightRight),
          customWeightLeft: Value(customWeightLeft),
        ),
      );
    }
  }

  // ------------------------------------- PINNED BUILTIN TRAININGS -------------------------------------
  /// Get all pinned builtin training IDs.
  Future<List<int>> getPinnedBuiltinTrainingIds() async {
    return (await select(pinnedBuiltinTrainings).get())
        .map((row) => row.builtinTrainingId)
        .toList();
  }

  /// Pin a builtin training to the home screen.
  Future<void> pinBuiltinTraining(int builtinTrainingId) async {
    await into(pinnedBuiltinTrainings).insert(
      PinnedBuiltinTrainingsCompanion(
        builtinTrainingId: Value(builtinTrainingId),
      ),
    );
  }

  /// Unpin a builtin training from the home screen.
  Future<void> unpinBuiltinTraining(int builtinTrainingId) async {
    await (delete(pinnedBuiltinTrainings)
      ..where((t) => t.builtinTrainingId.equals(builtinTrainingId))).go();
  }

  /// Check if a builtin training is pinned.
  Future<bool> isBuiltinTrainingPinned(int builtinTrainingId) async {
    final result =
        await (select(pinnedBuiltinTrainings)..where(
          (t) => t.builtinTrainingId.equals(builtinTrainingId),
        )).getSingleOrNull();
    return result != null;
  }

  // ------------------------------------- SYNC METADATA -------------------------------------
  /// Get sync metadata for a specific entity
  Future<SyncMetadataData?> getSyncMetadata(
    String tableName,
    int localId,
  ) async {
    return await (select(syncMetadata)
          ..where(
            (s) => s.entityTable.equals(tableName) & s.localId.equals(localId),
          ))
        .getSingleOrNull();
  }

  /// Save or update sync metadata
  Future<void> upsertSyncMetadata({
    required String tableName,
    required int localId,
    int? remoteId,
    DateTime? lastSyncedAt,
    bool? needsUpload,
    bool? needsDownload,
    String? pendingOperation,
  }) async {
    final existing = await getSyncMetadata(tableName, localId);

    if (existing != null) {
      await (update(syncMetadata)
            ..where(
              (s) =>
                  s.entityTable.equals(tableName) & s.localId.equals(localId),
            ))
          .write(
        SyncMetadataCompanion(
          remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
          lastSyncedAt: lastSyncedAt != null
              ? Value(lastSyncedAt)
              : const Value.absent(),
          needsUpload:
              needsUpload != null ? Value(needsUpload) : const Value.absent(),
          needsDownload: needsDownload != null
              ? Value(needsDownload)
              : const Value.absent(),
          pendingOperation: pendingOperation != null
              ? Value(pendingOperation)
              : const Value.absent(),
        ),
      );
    } else {
      await into(syncMetadata).insert(
        SyncMetadataCompanion.insert(
          entityTable: tableName,
          localId: localId,
          remoteId: Value(remoteId),
          lastSyncedAt: Value(lastSyncedAt),
          needsUpload: Value(needsUpload ?? false),
          needsDownload: Value(needsDownload ?? false),
          pendingOperation: Value(pendingOperation),
        ),
      );
    }
  }

  /// Get all entities that need upload
  Future<List<SyncMetadataData>> getEntitiesNeedingUpload() async {
    return await (select(syncMetadata)
          ..where((s) => s.needsUpload.equals(true)))
        .get();
  }

  /// Mark entity for upload
  Future<void> markForUpload(
    String tableName,
    int localId,
    String operation,
  ) async {
    await upsertSyncMetadata(
      tableName: tableName,
      localId: localId,
      needsUpload: true,
      pendingOperation: operation,
    );
  }

  // ------------------------------------- OFFLINE QUEUE -------------------------------------
  /// Add operation to offline queue
  Future<int> enqueueOfflineOperation({
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    return await into(offlineQueue).insert(
      OfflineQueueCompanion.insert(
        operation: operation,
        payload: jsonEncode(payload),
      ),
    );
  }

  /// Get all queued operations
  Future<List<OfflineQueueData>> getQueuedOperations() async {
    return await (select(offlineQueue)
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
        .get();
  }

  /// Remove operation from queue
  Future<void> dequeueOperation(int id) async {
    await (delete(offlineQueue)..where((o) => o.id.equals(id))).go();
  }

  /// Increment retry count
  Future<void> incrementRetryCount(int id) async {
    final entry = await (select(offlineQueue)..where((o) => o.id.equals(id)))
        .getSingle();
    await (update(offlineQueue)..where((o) => o.id.equals(id))).write(
      OfflineQueueCompanion(retryCount: Value(entry.retryCount + 1)),
    );
  }

  // ------------------------------------- USER PROFILE -------------------------------------
  /// Save user profile
  Future<void> saveUserProfile({
    required String id,
    required String email,
    String? firstname,
    String? lastname,
  }) async {
    await into(userProfile).insert(
      UserProfileCompanion.insert(
        id: id,
        email: email,
        firstname: Value(firstname),
        lastname: Value(lastname),
        createdAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Get user profile
  Future<UserProfileData?> getUserProfile() async {
    return await select(userProfile).getSingleOrNull();
  }

  /// Delete user profile (on logout)
  Future<void> deleteUserProfile() async {
    await delete(userProfile).go();
  }

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1 && to == 2) {
        // Migration from schema version 1 to 2: Add BuiltinTrainingWeights table
        await m.createTable(builtinTrainingWeights);
      }
      if (from <= 2 && to >= 3) {
        // Migration to schema version 3: Add gripPosition columns
        await m.addColumn(repTemplates, repTemplates.gripPosition);
        await m.addColumn(repDatas, repDatas.gripPosition);
        await m.addColumn(assessments, assessments.gripPosition);
      }
      if (from <= 3 && to >= 4) {
        // Migration to schema version 4: Add gripPosition to repeaters
        await m.addColumn(repeaters, repeaters.gripPosition);
      }
      if (from <= 4 && to >= 5) {
        // Migration to schema version 5: Add sessionType and duration to sessions
        await m.addColumn(sessions, sessions.sessionType);
        await m.addColumn(sessions, sessions.duration);
      }
      if (from <= 5 && to >= 6) {
        // Migration to schema version 6: Add PinnedBuiltinTrainings table
        await m.createTable(pinnedBuiltinTrainings);
      }
      if (from <= 6 && to >= 7) {
        // Migration to schema version 7: Add repeater configuration fields to sessions
        await m.addColumn(sessions, sessions.repeaterSets);
        await m.addColumn(sessions, sessions.repeaterReps);
        await m.addColumn(sessions, sessions.repeaterWorkTime);
        await m.addColumn(sessions, sessions.repeaterRestTime);
        await m.addColumn(sessions, sessions.repeaterSetRest);
        await m.addColumn(sessions, sessions.repeaterSplitHand);
      }
      if (from <= 7 && to >= 8) {
        // Migration to schema version 8: Add cloud sync tables
        await m.createTable(syncMetadata);
        await m.createTable(offlineQueue);
        await m.createTable(userProfile);
      }
    },
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
