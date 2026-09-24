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

/// The athlete's whole assessment history, read once and shared by everything
/// that reads it.
///
/// `GET /api/assessments` takes no parameters and always answers the whole
/// history, so every caller that wanted a narrower view was paying for the
/// whole one anyway. Two of them asked for it at the same time: the dashboard
/// through [assessmentsProvider] and the builtin catalog through the builtin
/// repository, so a cold load and every pull to refresh of the home screen put
/// the byte identical request on the wire twice. They derive from this now, and
/// the fetch happens once.
///
/// This is the provider to invalidate to read the history again. Invalidating
/// anything below it rebuilds from what is already held and never reaches the
/// server, which is what makes a filtered view free.
///
/// It is the root rather than [assessmentsProvider] with a null key because
/// that one is an autoDispose family: a keepAlive provider watching an entry of
/// it would pin that entry for the session, and every existing invalidation of
/// it would start refetching the builtin availability as a side effect. A root
/// of its own leaves those call sites meaning what they already meant.
@Riverpod(keepAlive: true)
Future<List<AssessmentModel>> assessmentHistory(Ref ref) =>
    ref.watch(assessmentRepositoryProvider).getAssessments();

/// Returns the list of assessments.
/// Allow to filter on the assessment measured.
@riverpod
class Assessments extends _$Assessments {
  late AssessmentRepository _assessmentRepository;

  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async {
    _assessmentRepository = ref.watch(assessmentRepositoryProvider);
    final history = await ref.watch(assessmentHistoryProvider.future);
    if (assessmentId == null) return history;
    // Filtered here rather than asked for narrower. Both stores answer the
    // whole history sorted oldest first and filter it themselves, so narrowing
    // in memory gives the same list in the same order and costs no request.
    // Callers take the last entry as the most recent one, and a filter over a
    // sorted list keeps that true.
    return history
        .where((assessment) => assessment.assessmentId == assessmentId)
        .toList();
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
      // One drop, where four used to stand. The history is the only thing this
      // write made stale, and everything that showed the old one derives from
      // it: this notifier and its siblings in the family, the results the next
      // percentage driven run resolves against, and the builtin catalog, whose
      // availability is read off the assessments. Dropping the root rebuilds
      // all of them from one read, and leaves the training library alone.
      ref.invalidate(assessmentHistoryProvider);
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
