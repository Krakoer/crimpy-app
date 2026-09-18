import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers after a turn of the event loop, the way a real store does. The
/// delay is the point: it is during that await that an element nobody listens
/// to would be disposed.
class _SlowAssessmentRepository extends AssessmentRepository {
  final List<AssessmentResultModel> saved = [];
  final List<String> deleted = [];
  List<AssessmentModel> stored = const [];
  int reads = 0;

  @override
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    saved.add(assessment);
    return 'a-1';
  }

  @override
  Future<void> deleteAssessment(String id) async {
    await Future<void>.delayed(Duration.zero);
    deleted.add(id);
  }

  @override
  Future<List<AssessmentModel>> getAssessments({
    String? assessmentId,
    HandSide? handSide,
    GripPosition? gripPosition,
  }) async {
    reads++;
    await Future<void>.delayed(Duration.zero);
    return stored;
  }

  @override
  Future<List<AssessmentDefinition>> getAssessmentDefinitions() async =>
      const [];
}

class _CapturingSessions extends Sessions {
  final List<SessionModel> saved = [];

  @override
  Future<List<SessionModel>> build() async => const [];

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    await Future<void>.delayed(Duration.zero);
    saved.add(session);
    return 's-1';
  }
}

SessionModel _session() => SessionModel(
  name: 'Max pull ups',
  date: DateTime(2026, 9, 18),
  isAssessment: true,
  activity: SessionActivity.hangboard,
  origin: SessionOrigin.played,
);

void main() {
  test('a result is saved through an assessment nothing is listening to', () async {
    // The screen that records a result reads the notifier for the assessment it
    // measures and nothing watches that key, so the element exists only for the
    // duration of the call. It used to be disposed at the first await, and the
    // save then failed on an unmounted ref, losing the measurement.
    final repository = _SlowAssessmentRepository();
    final sessions = _CapturingSessions();
    final container = ProviderContainer.test(
      overrides: [
        assessmentRepositoryProvider.overrideWithValue(repository),
        sessionsProvider.overrideWith(() => sessions),
      ],
    );

    await container
        .read(assessmentsProvider('a-coach').notifier)
        .saveAssessment(
          AssessmentResultModel(assessmentId: 'a-coach', rightValue: 12),
          _session(),
          const [],
        );

    expect(sessions.saved, hasLength(1));
    expect(repository.saved.single.assessmentId, 'a-coach');
  });

  test('the history the tab reads is refreshed by a save', () async {
    // The invalidations sit behind a mounted check, so they are the first thing
    // a disposed element would skip: the tab would go on showing the result
    // before the one just recorded until the athlete pulled to refresh.
    final repository = _SlowAssessmentRepository();
    final container = ProviderContainer.test(
      overrides: [
        assessmentRepositoryProvider.overrideWithValue(repository),
        sessionsProvider.overrideWith(_CapturingSessions.new),
      ],
    );
    container.listen(assessmentsProvider(null), (_, _) {});
    await container.read(assessmentsProvider(null).future);
    final readsBefore = repository.reads;

    await container
        .read(assessmentsProvider('a-coach').notifier)
        .saveAssessment(
          AssessmentResultModel(assessmentId: 'a-coach', rightValue: 12),
          _session(),
          const [],
        );
    await container.read(assessmentsProvider(null).future);

    expect(repository.reads, greaterThan(readsBefore));
  });

  test('a result recorded twice in a day replaces the earlier one', () async {
    final repository = _SlowAssessmentRepository()
      ..stored = [
        AssessmentModel(
          id: 'earlier',
          date: DateTime.now(),
          definition: const AssessmentDefinition(
            id: 'a-coach',
            label: 'Max pull ups',
            unit: AssessmentUnit.repetitions,
          ),
          rightValue: 10,
        ),
      ];
    final container = ProviderContainer.test(
      overrides: [
        assessmentRepositoryProvider.overrideWithValue(repository),
        sessionsProvider.overrideWith(_CapturingSessions.new),
      ],
    );

    await container
        .read(assessmentsProvider('a-coach').notifier)
        .saveAssessment(
          AssessmentResultModel(assessmentId: 'a-coach', rightValue: 12),
          _session(),
          const [],
        );

    expect(repository.deleted, ['earlier']);
    expect(repository.saved, hasLength(1));
  });
}
