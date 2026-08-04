import 'package:collection/collection.dart';
import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/builtin_training.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/builtin_preferences_repository.dart';

class BuiltinTrainingRepository {
  final AssessmentRepository _assessmentRepository;
  final BuiltinPreferencesRepository _preferences;

  /// Both collaborators are required: defaulting them to the local backends
  /// would silently serve guest data to a signed-in user.
  BuiltinTrainingRepository({
    required AssessmentRepository assessmentRepository,
    required BuiltinPreferencesRepository preferencesRepository,
  }) : _assessmentRepository = assessmentRepository,
       _preferences = preferencesRepository;

  Future<List<BuiltinTrainingModel>> getBuiltinTrainings() async {
    return builtinTrainings;
  }

  // --- Batch helpers (call once, pass results into evaluateBuiltin) -----------

  /// Fetch all assessments in a single call for use across multiple builtins.
  Future<List<AssessmentModel>> fetchAllAssessments() =>
      _assessmentRepository.getAssessments();

  /// Fetch all custom weights in a single call.
  Future<Map<String, ({double? weightRight, double? weightLeft})>>
  fetchAllCustomWeights() => _preferences.getAllCustomWeights();

  // --- Single-builtin evaluation with pre-loaded data -----------------------

  /// Evaluate a builtin training's availability, missing assessments, and
  /// generated training in a single pass over [allAssessments].
  ///
  /// Always pass [allAssessments] from [fetchAllAssessments] to avoid one
  /// API call per builtin.
  ({bool isAvailable, List<AssessmentRequirement> missing, Training? training})
  evaluateBuiltinSync(
    BuiltinTrainingModel builtin,
    List<AssessmentModel> allAssessments, {
    double? customWeightRight,
    double? customWeightLeft,
  }) {
    final assessmentValues = builtin.requiredAssessments.map((req) {
      return AssessmentResultModel(
        type: req.type,
        rightValue: _latestValue(
          allAssessments,
          req.type,
          HandSide.right,
          req.gripPosition,
        ),
        leftValue: _latestValue(
          allAssessments,
          req.type,
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
        (a) => a.type == req.type && a.gripPosition == req.gripPosition,
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
    AssessmentType type,
    HandSide hand,
    GripPosition? gripPosition,
  ) {
    final filtered = assessments.where((a) {
      if (a.type != type) return false;
      if (gripPosition != null && a.gripPosition != gripPosition) return false;
      return hand.isRightHand ? a.rightValue != null : a.leftValue != null;
    }).toList();
    final last = filtered.lastOrNull;
    return hand.isRightHand ? last?.rightValue : last?.leftValue;
  }

  // --- Availability and assessment checking ---------------------------------

  Future<bool> isTrainingAvailable(BuiltinTrainingModel training) async {
    final assessments = await _assessmentRepository.getAssessments();
    return evaluateBuiltinSync(training, assessments).isAvailable;
  }

  Future<List<AssessmentRequirement>> getMissingAssessments(
    BuiltinTrainingModel training,
  ) async {
    final assessments = await _assessmentRepository.getAssessments();
    return evaluateBuiltinSync(training, assessments).missing;
  }

  Future<Training?> generateTraining(
    BuiltinTrainingModel training, {
    double? customLoadRight,
    double? customLoadLeft,
  }) async {
    if (customLoadRight == null || customLoadLeft == null) {
      final w = await _preferences.getCustomWeights(training.id);
      customLoadRight ??= w.weightRight;
      customLoadLeft ??= w.weightLeft;
    }
    final assessments = await _assessmentRepository.getAssessments();
    return evaluateBuiltinSync(
      training,
      assessments,
      customWeightRight: customLoadRight,
      customWeightLeft: customLoadLeft,
    ).training;
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
