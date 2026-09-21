import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
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

/// Every assessment that can be measured, so a result can be named and a
/// percentage of one unit checked. Cached locally, so it answers offline.
@riverpod
Future<List<AssessmentDefinition>> assessmentDefinitions(Ref ref) =>
    ref.watch(assessmentRepositoryProvider).getAssessmentDefinitions();

/// The assessment trainings a coach has prescribed to the athlete, as the
/// server lists them.
///
/// Held apart from the athlete's own library so it is not re-read every time
/// that library changes: favouriting a training says nothing about what a coach
/// has scheduled.
@riverpod
Future<List<Training>> prescribedAssessmentTrainings(Ref ref) async {
  final programs = ref.watch(programRepositoryProvider);
  if (programs == null) return const [];
  return programs.getPrescribedAssessmentTrainings();
}

/// The assessments the athlete may record a result against beyond the ones
/// Crimpy ships: their own, and a coach's whose training a program has
/// prescribed to them. Each is measured by running the training that backs it,
/// so the training itself is what this holds.
///
/// This mirrors the rule the server enforces when a result is posted. The
/// prescribed half can fail offline: when it does the athlete keeps the
/// assessments they own rather than an empty tab.
///
/// Ordered by name, which is how the history lists them once they have results.
@riverpod
Future<List<Training>> recordableAssessmentTrainings(Ref ref) async {
  final own = (await ref.watch(
    trainingsProvider.future,
  )).where((training) => training.assessment != null).toList();

  List<Training> prescribed = const [];
  try {
    prescribed = await ref.watch(prescribedAssessmentTrainingsProvider.future);
  } catch (e) {
    AppLoggerHelper.warning("Could not load the prescribed assessments: $e");
  }

  // Keyed on the assessment rather than on the training: the athlete's own copy
  // and a prescription of it are the same thing to measure, and listing it
  // twice would offer two cards writing to one history.
  final byAssessment = <String, Training>{};
  for (final training in [...own, ...prescribed]) {
    byAssessment.putIfAbsent(training.assessment!.id, () => training);
  }
  return byAssessment.values.toList()
    ..sort((a, b) => a.assessment!.label.compareTo(b.assessment!.label));
}

/// The athlete latest result per assessment, used to turn the loads, durations
/// and reps a coach set as a percentage of an assessment into numbers.
///
/// The definitions only add names for assessments that were never measured,
/// since a result carries its own, so failing to fetch them must not cost the
/// athlete the numbers they did measure.
@riverpod
Future<AssessmentResults> assessmentResults(Ref ref) async {
  final measured = await ref.watch(assessmentsProvider(null).future);
  List<AssessmentDefinition> definitions = const [];
  try {
    definitions = await ref.watch(assessmentDefinitionsProvider.future);
  } catch (e) {
    AppLoggerHelper.warning("Could not load the assessment definitions: $e");
  }
  return AssessmentResults.fromHistory(measured, definitions: definitions);
}

/// Returns the list of assessments.
/// Allow to filter on the assessment measured.
@riverpod
class Assessments extends _$Assessments {
  late AssessmentRepository _assessmentRepository;

  @override
  Future<List<AssessmentModel>> build(String? assessmentId) {
    _assessmentRepository = ref.watch(assessmentRepositoryProvider);
    return _assessmentRepository.getAssessments(assessmentId: assessmentId);
  }

  /// Save the assessment into the database. If the assessment has already been done today, the previous results will be deleted.
  Future<void> saveAssessment(
    AssessmentResultModel assessmentModel,
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    // Held open for the whole write. The screen that records a result reads
    // this notifier for the assessment it measures, and nothing watches that
    // key: without this the element is disposed at the first await, and every
    // ref below it fails on a disposed ref, losing the measurement.
    final keepAlive = ref.keepAlive();
    try {
      await _writeAssessment(
        assessmentModel,
        session,
        reps,
        data: data,
        itemResults: itemResults,
      );
    } finally {
      keepAlive.close();
    }
  }

  Future<void> _writeAssessment(
    AssessmentResultModel assessmentModel,
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
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
        .saveSession(session, reps, data: data, itemResults: itemResults);
    await _assessmentRepository.saveAssessment(assessmentModel, sessionId);

    if (ref.mounted) {
      ref.invalidateSelf();
      // Invalidate the null provider as well, since it fetches all trainings.
      ref.invalidate(assessmentsProvider(null));
      // What the next percentage driven run reads, so a training prescribed
      // against this assessment resolves against the number just measured.
      ref.invalidate(assessmentResultsProvider);
      // Refresh builtin trainings availability since we have new assessment
      // data. Both lists show builtins, and neither reads the library to
      // rebuild, so the home screen card is refreshed here too rather than
      // waiting for a pull.
      ref.invalidate(allTrainingsProvider);
      ref.invalidate(pinnedTrainingsProvider);
    }
  }

  /// Returns the last assessment result for a given hand.
  /// If `gripPosition` is provided, only assessments with that grip position will be considered.
  /// Only call this method on a family keyed to an assessment.
  Future<double?> getLastValueForHand(
    HandSide handSide, {
    GripPosition? gripPosition,
  }) async {
    if (assessmentId == null) {
      AppLoggerHelper.warning("Called getLastValueForHand with no assessment.");
      return 0;
    }
    return _assessmentRepository.getLastValueForHand(
      assessmentId!,
      handSide,
      gripPosition: gripPosition,
    );
  }

  /// Retuns the id of the assessment that has been done the same day with the same hand and grip position, if any.
  /// Only call this method on a family keyed to an assessment.
  Future<String?> getSameDayAssessment({
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    if (assessmentId == null) {
      AppLoggerHelper.warning(
        "Called getSameDayAssessment with no assessment.",
      );
      return "";
    }
    final prevAssessment = (await _assessmentRepository.getAssessments(
      assessmentId: assessmentId,
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
