import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assessments_view_model.g.dart';

/// The assessment protocols the app ships with.
///
/// These are compiled-in definitions, not stored data, so they do not depend on
/// whether the user is signed in.
@Riverpod(keepAlive: true)
List<AssessmentTrainingModel> assessmentTrainings(Ref ref) =>
    builtinAssessments.map((a) => a.generateAssessment()).toList();

/// Return an assessment training given its type.
@Riverpod(keepAlive: true)
AssessmentTrainingModel assessmentTraining(Ref ref, AssessmentType type) =>
    ref.watch(assessmentTrainingsProvider).firstWhere((a) => a.type == type);

/// Returns the list of assessments.
/// Allow to filter on `type`.
@riverpod
class Assessments extends _$Assessments {
  late AssessmentRepository _assessmentRepository;

  @override
  Future<List<AssessmentModel>> build(AssessmentType? type) {
    _assessmentRepository = ref.watch(assessmentRepositoryProvider);
    return _assessmentRepository.getAssessments(type: type);
  }

  /// Save the assessment into the database. If the assessment has already been done today, the previous results will be deleted.
  Future<void> saveAssessment(
    AssessmentResultModel assessmentModel,
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  }) async {
    // First, delete same-day assessment if any.
    final prevAssessmentId = await getSameDayAssessment(
      handSide: assessmentModel.hand,
      gripPosition: assessmentModel.gripPosition,
    );
    if (prevAssessmentId != null) {
      await _assessmentRepository.deleteAssessment(prevAssessmentId);
    }

    // Save the session. A failure here must reach the caller: without a session
    // to attach it to, the assessment cannot be stored either.
    final sessionId = await ref
        .read(sessionsProvider.notifier)
        .saveSession(session, reps, data: data);
    await _assessmentRepository.saveAssessment(assessmentModel, sessionId);

    if (ref.mounted) {
      ref.invalidateSelf();
      // Invalidate the null provider as well, since it fetches all trainings.
      ref.invalidate(assessmentsProvider(null));
      // Refresh builtin trainings availability since we have new assessment data
      ref.invalidate(allTrainingsProvider);
    }
  }

  /// Returns the last assessment result for a given hand.
  /// If `gripPosition` is provided, only assessments with that grip position will be considered.
  /// Only call this method with a non null type family.
  Future<double?> getLastValueForHand(
    HandSide handSide, {
    GripPosition? gripPosition,
  }) async {
    if (type == null) {
      AppLoggerHelper.warning("Called getLastValueForHand with a type null.");
      return 0;
    }
    return _assessmentRepository.getLastValueForHand(
      type!,
      handSide,
      gripPosition: gripPosition,
    );
  }

  /// Retuns the id of the assessment that has been done the same day with the same hand and grip position, if any.
  /// Only call this method with a non null type family.
  Future<String?> getSameDayAssessment({
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    if (type == null) {
      AppLoggerHelper.warning("Called getSameDayAssessment with a type null.");
      return "";
    }
    final prevAssessment = (await _assessmentRepository.getAssessments(
      type: type,
      handSide: handSide,
      gripPosition: gripPosition,
    )).lastOrNull;
    if (prevAssessment == null) {
      return null;
    }

    // If session is the same day, delete the last assessment
    if (DateUtils.isSameDay(prevAssessment.date, DateTime.now())) {
      return prevAssessment.id;
    }

    return null;
  }
}
