import 'package:collection/collection.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/builtin_training.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/repositories/builtin_preferences_repository.dart';

class BuiltinTrainingRepository {
  final BuiltinPreferencesRepository _preferences;

  /// The collaborator is required: defaulting it to the local backend would
  /// silently serve guest data to a signed-in user.
  BuiltinTrainingRepository({
    required BuiltinPreferencesRepository preferencesRepository,
  }) : _preferences = preferencesRepository;

  Future<List<BuiltinTrainingModel>> getBuiltinTrainings() async {
    return builtinTrainings;
  }

  // --- Batch helpers (call once, pass results into evaluateBuiltin) -----------

  /// Fetch all custom weights in a single call.
  Future<Map<String, ({double? weightRight, double? weightLeft})>>
  fetchAllCustomWeights() => _preferences.getAllCustomWeights();

  // --- Single-builtin evaluation with pre-loaded data -----------------------

  /// Evaluate a builtin training's availability, missing assessments, and
  /// generated training in a single pass over [allAssessments].
  ///
  /// [allAssessments] is the whole history, read once by the caller and passed
  /// in. Evaluating a builtin never fetches: reading per builtin is what sends
  /// the same request once per card. Its one caller watches
  /// assessmentHistoryProvider, the single read everything derives from.
  static ({
    bool isAvailable,
    List<AssessmentRequirement> missing,
    Training? training,
  })
  evaluateBuiltinSync(
    BuiltinTrainingModel builtin,
    List<AssessmentModel> allAssessments, {
    double? customWeightRight,
    double? customWeightLeft,
  }) {
    final assessmentValues = builtin.requiredAssessments.map((req) {
      return AssessmentResultModel(
        assessmentId: req.assessmentId,
        rightValue: _latestValue(
          allAssessments,
          req.assessmentId,
          HandSide.right,
          req.gripPosition,
        ),
        leftValue: _latestValue(
          allAssessments,
          req.assessmentId,
          HandSide.left,
          req.gripPosition,
        ),
        gripPosition: req.gripPosition,
      );
    }).toList();

    final isAvailable = builtin.isAvailable(assessmentValues);

    final missing = <AssessmentRequirement>[];
    for (final req in builtin.requiredAssessments) {
      final val = assessmentValues.lastWhereOrNull(
        (a) =>
            a.assessmentId == req.assessmentId &&
            a.gripPosition == req.gripPosition,
      );
      if (val == null || val.leftValue == null || val.rightValue == null) {
        missing.add(req);
      }
    }

    final generated = isAvailable
        ? builtin.generateNewFormatTraining(
            assessmentValues,
            customLoadRight: customWeightRight,
            customLoadLeft: customWeightLeft,
          )
        : null;

    return (isAvailable: isAvailable, missing: missing, training: generated);
  }

  static double? _latestValue(
    List<AssessmentModel> assessments,
    String assessmentId,
    HandSide hand,
    GripPosition? gripPosition,
  ) {
    final filtered = assessments.where((a) {
      if (a.assessmentId != assessmentId) return false;
      if (gripPosition != null && a.gripPosition != gripPosition) return false;
      return hand.isRightHand ? a.rightValue != null : a.leftValue != null;
    }).toList();
    final last = filtered.lastOrNull;
    return hand.isRightHand ? last?.rightValue : last?.leftValue;
  }

  // --- Preferences delegation -----------------------------------------------

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
