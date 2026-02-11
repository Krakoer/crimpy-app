import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';

class TrainingRepository {
  /// Get all the available trainings along with their reps, except for the assessment ones.
  Future<List<TrainingWithReps>> getAllTrainings({
    bool onlyFavs = false,
  }) async {
    final trainings =
        onlyFavs
            ? await gDatabase.getFavTrainings()
            : await gDatabase.getAllTrainingsWithoutAssessments();

    List<TrainingWithReps> resp = [];

    for (final t in trainings) {
      bool isRepeater = t.repeaterId != null;
      // Get repeater model if available
      Repeater? repeaterData =
          !isRepeater ? null : await gDatabase.getRepeater(t.repeaterId!);

      RepeaterModel? model =
          !isRepeater
              ? null
              : RepeaterModel(
                sets: repeaterData!.sets,
                restBteweenSets: repeaterData.setRest,
                repsBySet: repeaterData.reps,
                workTime: repeaterData.worktime,
                restTime: repeaterData.resttime,
                splitHand: repeaterData.splitHand,
                weightRight: repeaterData.targetWeigthRight,
                weightLeft: repeaterData.targetWeigthLeft,
                gripPosition: GripPosition.values[repeaterData.gripPosition],
              );
      // If the training is a repeater, generate the reps instead of getting them from DB.
      final List<RepModel> repModels;
      if (isRepeater) {
        final repTemplates = model!.generateReps();
        repModels =
            repTemplates
                .map(
                  (r) => RepModel(
                    durationInSeconds: r.duration,
                    isRest: r.isRest,
                    handSide: r.handSide,
                    targetWeight: r.targetWeight,
                    id: r.id,
                    index: r.index,
                    gripPosition: r.gripPosition,
                  ),
                )
                .toList();
      } else {
        final dbReps = await gDatabase.getRepsForTraining(t.id);
        repModels =
            dbReps
                .map(
                  (r) => RepModel(
                    durationInSeconds: r.duration,
                    isRest: r.isRest,
                    handSide: r.rightHand ? HandSide.right : HandSide.left,
                    targetWeight: r.targetWeight,
                    id: r.id,
                    index: r.index,
                    gripPosition: GripPosition.values[r.gripPosition],
                  ),
                )
                .toList();
      }

      resp.add(
        TrainingWithReps(
          id: t.id,
          name: t.name,
          isFav: t.isFavorite,
          reps: repModels,
          repeater: model,
        ),
      );
    }

    return resp;
  }

  /// Save a training into a DB given a name and a list of rep models.
  Future<void> saveTraining(String name, List<RepModel> reps) async {
    await gDatabase.saveTrainingWithReps(name, reps);
  }

  /// Save a repeater training given a name and a repeater model.
  Future<void> saveRepeaterTraining(String name, RepeaterModel model) async {
    await gDatabase.saveRepeaterTraining(name, model);
  }

  /// Edit a training name and/or reps.
  Future<void> editTraining(
    int trainingId, {
    String? name,
    List<RepModel>? reps,
  }) async {
    await gDatabase.editTrainingWithReps(trainingId, name: name, reps: reps);
  }

  /// Toggle the favorite bool for a given training.
  Future<void> toggleFav(int trainingId) async {
    return gDatabase.toggleFav(trainingId);
  }

  /// Edit a repeater training name and/or model.
  Future<void> editRepeaterTraining(
    int trainingId, {
    String? name,
    RepeaterModel? model,
  }) async {
    await gDatabase.editRepeaterTraining(trainingId, name: name, model: model);
  }

  /// Delete a training by its ID.
  Future<void> deleteTraining(int trainingId) async {
    gDatabase.deleteTraining(trainingId);
  }

  /// Get sessions with the reps data, with optional filters (see `SessionFilter` doc).
  Future<List<SessionModel>> getAllSessionsWithReps({
    SessionFilter? filters,
  }) async {
    final trainings = await gDatabase.getAllSessions(filters: filters);

    List<SessionModel> res = [];

    for (final t in trainings) {
      final reps = await gDatabase.getRepsForSession(t.id);

      // Build repeater config if available
      RepeaterConfig? repeaterConfig;
      if (t.repeaterSets != null &&
          t.repeaterReps != null &&
          t.repeaterWorkTime != null &&
          t.repeaterRestTime != null &&
          t.repeaterSetRest != null &&
          t.repeaterSplitHand != null) {
        repeaterConfig = RepeaterConfig(
          sets: t.repeaterSets!,
          repsPerSet: t.repeaterReps!,
          workTime: t.repeaterWorkTime!,
          restTime: t.repeaterRestTime!,
          setRest: t.repeaterSetRest!,
          splitHand: t.repeaterSplitHand!,
        );
      }

      res.add(
        SessionModel(
          id: t.id,
          name: t.name,
          notes: t.notes,
          date: t.date,
          reps: reps,
          isAssessment: t.isAssessment,
          sessionType: SessionType.values[t.sessionType],
          durationInSeconds: t.duration,
          repeaterConfig: repeaterConfig,
        ),
      );
    }

    return res;
  }

  /// Get a session with its reps data given an ID.
  Future<SessionModel?> getSessionWithData(int sessionId) async {
    return await gDatabase.getSessionWithData(sessionId);
  }

  /// Save a session into the DB.
  Future<int> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  }) async {
    return await gDatabase.saveSession(session, reps, points: data);
  }

  /// Update an existing session in the DB.
  Future<void> updateSession(SessionModel session) async {
    return await gDatabase.updateSession(session);
  }

  /// Delete a session by its ID.
  Future<void> deleteSession(int sessionId) async {
    gDatabase.deleteSession(sessionId);
  }
}
