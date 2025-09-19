import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';

class AssessmentRepository {
  /// Get all assessments trainings.
  /// Here we could get the trainings and reps from the builtins list direclty,
  /// but we inserted it and keep the DB as the only source of truth.
  Future<List<AssessmentTrainingModel>> getAssessmentTrainings() async {
    final trainings = await gDatabase.getAllAssessmentTrainings();
    // The builtins assessments stores the training ID, so create a map for easy search
    final Map<int, Training> trainingsDict = {for (var v in trainings) v.id: v};

    List<AssessmentTrainingModel> resp = [];

    for (final assessment in builtinsAssessments) {
      // First get the trainings.
      final training = trainingsDict[assessment.trainingId];
      if (training == null) {
        AppLoggerHelper.warning(
          "No training for builtin assessment $assessment",
        );
        continue;
      }

      bool isRepeater = training.repeaterId != null;
      // Get repeater training if available
      Repeater? repeaterData =
          !isRepeater
              ? null
              : await gDatabase.getRepeater(training.repeaterId!);

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
              );
      // If the training is a repeater, generate the reps instead
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
                  ),
                )
                .toList();
      } else {
        final dbReps = await gDatabase.getRepsForTraining(training.id);
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
                  ),
                )
                .toList();
      }

      resp.add(
        AssessmentTrainingModel(
          description: assessment.description,
          icon: assessment.icon,
          trainingId: assessment.trainingId,
          type: assessment.type,
          training: TrainingWithReps(
            id: training.id,
            name: training.name,
            isFav: training.isFavorite,
            reps: repModels,
            repeater: model,
          ),
        ),
      );
    }

    return resp;
  }

  /// Save an assessment given its model and a session ID.
  Future<void> saveAssessment(
    FinishedAssessmentModel assessment,
    int sessionId,
  ) async {
    await gDatabase.saveAssessment(assessment, sessionId);
  }

  /// Delete an assessment.
  Future<void> deleteAssessment(int id) async {
    await gDatabase.deleteAssessment(id);
  }

  /// Get all the assessments.
  /// Allow to filter on `type`.
  /// If the `rightHand` parameter is set, only corresponding assessment will be retrieved.
  Future<List<AssessmentModel>> getAssessments({
    AssessmentType? type,
    bool? rightHand,
  }) async {
    return await gDatabase.getAssessments(type: type, rightHand: rightHand);
  }

  /// Get the last value of an assessment given its type for a given hand.
  Future<double?> getLastValueForHand(
    AssessmentType type,
    bool rightHand,
  ) async {
    final assessment =
        (await gDatabase.getAssessments(
          type: type,
          rightHand: rightHand,
        )).lastOrNull;
    return rightHand ? assessment?.rightValue : assessment?.leftValue;
  }
}
