import 'package:collection/collection.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/builtin_preferences_repository.dart';

class BuiltinTrainingRepository {
  final AssessmentRepository _assessmentRepository;
  final BuiltinPreferencesRepository _preferences;

  BuiltinTrainingRepository({
    AssessmentRepository? assessmentRepository,
    BuiltinPreferencesRepository? preferencesRepository,
  }) : _assessmentRepository =
           assessmentRepository ?? LocalAssessmentRepository(),
       _preferences =
           preferencesRepository ?? LocalBuiltinPreferencesRepository();

  Future<List<BuiltinTrainingModel>> getBuiltinTrainings() async {
    return builtinTrainings;
  }

  Future<bool> isTrainingAvailable(BuiltinTrainingModel training) async {
    final assessmentValues = await _getAssessmentValues(
      training.requiredAssessments,
    );
    return training.isAvailable(assessmentValues);
  }

  Future<Training?> generateTraining(
    BuiltinTrainingModel training, {
    double? customLoadRight,
    double? customLoadLeft,
  }) async {
    final assessmentValues = await _getAssessmentValues(
      training.requiredAssessments,
    );

    if (customLoadRight == null || customLoadLeft == null) {
      final savedWeights = await _preferences.getCustomWeights(training.id);
      customLoadRight ??= savedWeights.weightRight;
      customLoadLeft ??= savedWeights.weightLeft;
    }

    return training.generateNewFormatTraining(
      assessmentValues,
      customLoadRight: customLoadRight,
      customLoadLeft: customLoadLeft,
    );
  }

  Future<List<AssessmentRequirement>> getMissingAssessments(
    BuiltinTrainingModel training,
  ) async {
    final assessmentValues = await _getAssessmentValues(
      training.requiredAssessments,
    );
    final missing = <AssessmentRequirement>[];

    for (final requirement in training.requiredAssessments) {
      final value = assessmentValues.lastWhereOrNull(
        (ass) =>
            ass.type == requirement.type &&
            ass.gripPosition == requirement.gripPosition,
      );
      if (value == null ||
          value.leftValue == null ||
          value.rightValue == null) {
        missing.add(requirement);
      }
    }

    return missing;
  }

  Future<List<AssessmentResultModel>> _getAssessmentValues(
    List<AssessmentRequirement> requirements,
  ) async {
    final List<AssessmentResultModel> values = [];

    for (final requirement in requirements) {
      final rightValue = await _assessmentRepository.getLastValueForHand(
        requirement.type,
        HandSide.right,
        gripPosition: requirement.gripPosition,
      );
      final leftValue = await _assessmentRepository.getLastValueForHand(
        requirement.type,
        HandSide.left,
        gripPosition: requirement.gripPosition,
      );
      values.add(
        AssessmentResultModel(
          type: requirement.type,
          rightValue: rightValue,
          leftValue: leftValue,
          gripPosition: requirement.gripPosition,
        ),
      );
    }

    return values;
  }

  Future<void> updateTargetWeights({
    required BuiltinTrainingModel training,
    required double newWeightRight,
    required double newWeightLeft,
  }) => _preferences.saveCustomWeights(
    builtinTrainingId: training.id,
    weightRight: newWeightRight,
    weightLeft: newWeightLeft,
  );

  Future<({double? weightRight, double? weightLeft})> getCustomWeights(
    String builtinTrainingId,
  ) => _preferences.getCustomWeights(builtinTrainingId);

  Future<List<String>> getPinnedBuiltinTrainingIds() =>
      _preferences.getPinnedBuiltinTrainingIds();

  Future<void> pinBuiltinTraining(String builtinTrainingId) =>
      _preferences.pinBuiltinTraining(builtinTrainingId);

  Future<void> unpinBuiltinTraining(String builtinTrainingId) =>
      _preferences.unpinBuiltinTraining(builtinTrainingId);

  Future<bool> isBuiltinTrainingPinned(String builtinTrainingId) =>
      _preferences.isBuiltinTrainingPinned(builtinTrainingId);
}
