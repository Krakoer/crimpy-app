import 'package:crimpy/logger.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final repository = AssessmentRepository();
  return repository;
});

/// Returns the list of available assessment trainings.
final assessmentTrainingsProvider =
    FutureProvider<List<AssessmentTrainingModel>>((ref) {
      final repository = ref.watch(assessmentRepositoryProvider);
      return repository.getAssessmentTrainings();
    });

/// Return an assessment training given its type.
final assessmentTrainingProvider =
    FutureProvider.family<AssessmentTrainingModel, AssessmentType>((
      ref,
      type,
    ) async {
      final repository = ref.watch(assessmentRepositoryProvider);
      final assessments = await repository.getAssessmentTrainings();
      return assessments.firstWhere((a) => a.type == type);
    });

/// Returns the list of assessments.
/// Allow to filter on `type`.
final assessmentsProvider = AsyncNotifierProvider.autoDispose
    .family<AssessmentNotifier, List<AssessmentModel>, AssessmentType?>(
      AssessmentNotifier.new,
    );

class AssessmentNotifier extends AsyncNotifier<List<AssessmentModel>> {
  AssessmentNotifier(this.type);
  final AssessmentType? type;

  late AssessmentRepository _assessmentRepository;

  @override
  Future<List<AssessmentModel>> build() {
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

    // Save the session
    final sessionId = await ref
        .read(sessionsProvider(null).notifier)
        .saveSession(session, reps, data: data);
    if (sessionId != -1) {
      // Save the assessment
      await _assessmentRepository.saveAssessment(assessmentModel, sessionId);
    }
    if (ref.mounted) {
      ref.invalidateSelf();
      // Invalidate the null provider as well, since it fetches all trainings.
      ref.invalidate(assessmentsProvider(null));
      // Refresh builtin trainings availability since we have new assessment data
      try {
        ref.invalidate(allTrainingsProvider);
      } catch (e) {
        // Provider might not be mounted yet, ignore
      }
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
  Future<int?> getSameDayAssessment({
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    if (type == null) {
      AppLoggerHelper.warning("Called getSameDayAssessment with a type null.");
      return 0;
    }
    final prevAssessment =
        (await _assessmentRepository.getAssessments(
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
