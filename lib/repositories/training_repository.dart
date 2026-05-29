import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';

abstract class TrainingRepository {
  Future<List<TrainingWithReps>> getAllTrainings({bool onlyFavs = false});
  Future<void> saveTraining(String name, List<RepModel> reps);
  Future<void> saveRepeaterTraining(String name, RepeaterModel model);
  Future<void> editTraining(
    String trainingId, {
    String? name,
    List<RepModel>? reps,
  });
  Future<void> editRepeaterTraining(
    String trainingId, {
    String? name,
    RepeaterModel? model,
  });
  Future<void> toggleFav(String trainingId);
  Future<void> deleteTraining(String trainingId);
  Future<List<SessionModel>> getAllSessionsWithReps({SessionFilter? filters});
  Future<SessionModel?> getSessionWithData(String sessionId);
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  });
  Future<void> updateSession(SessionModel session);
  Future<void> deleteSession(String sessionId);
}

class LocalTrainingRepository implements TrainingRepository {
  @override
  Future<List<TrainingWithReps>> getAllTrainings({
    bool onlyFavs = false,
  }) async {
    final trainings = onlyFavs
        ? await gDatabase.getFavTrainings()
        : await gDatabase.getAllTrainingsWithoutAssessments();

    List<TrainingWithReps> resp = [];

    for (final t in trainings) {
      bool isRepeater = t.repeaterId != null;
      Repeater? repeaterData = !isRepeater
          ? null
          : await gDatabase.getRepeater(t.repeaterId!);

      RepeaterModel? model = !isRepeater
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

      final List<RepModel> repModels;
      if (isRepeater) {
        final repTemplates = model!.generateReps();
        repModels = repTemplates
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
        repModels = dbReps
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

  @override
  Future<void> saveTraining(String name, List<RepModel> reps) async {
    await gDatabase.saveTrainingWithReps(name, reps);
  }

  @override
  Future<void> saveRepeaterTraining(String name, RepeaterModel model) async {
    await gDatabase.saveRepeaterTraining(name, model);
  }

  @override
  Future<void> editTraining(
    String trainingId, {
    String? name,
    List<RepModel>? reps,
  }) async {
    await gDatabase.editTrainingWithReps(trainingId, name: name, reps: reps);
  }

  @override
  Future<void> toggleFav(String trainingId) async {
    return gDatabase.toggleFav(trainingId);
  }

  @override
  Future<void> editRepeaterTraining(
    String trainingId, {
    String? name,
    RepeaterModel? model,
  }) async {
    await gDatabase.editRepeaterTraining(trainingId, name: name, model: model);
  }

  @override
  Future<void> deleteTraining(String trainingId) async {
    gDatabase.deleteTraining(trainingId);
  }

  @override
  Future<List<SessionModel>> getAllSessionsWithReps({
    SessionFilter? filters,
  }) async {
    final trainings = await gDatabase.getAllSessions(filters: filters);

    List<SessionModel> res = [];

    for (final t in trainings) {
      final reps = await gDatabase.getRepsForSession(t.id);

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

  @override
  Future<SessionModel?> getSessionWithData(String sessionId) async {
    return await gDatabase.getSessionWithData(sessionId);
  }

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  }) async {
    return await gDatabase.saveSession(session, reps, points: data);
  }

  @override
  Future<void> updateSession(SessionModel session) async {
    return await gDatabase.updateSession(session);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    gDatabase.deleteSession(sessionId);
  }
}
