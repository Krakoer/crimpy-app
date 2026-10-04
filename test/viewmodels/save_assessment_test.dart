import 'package:clock/clock.dart';
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

  /// A hand whose result the store refuses to write.
  HandSide? refusing;
  List<AssessmentModel> stored = const [];
  int reads = 0;

  @override
  Future<String> saveAssessment(
    AssessmentResultModel assessment,
    String sessionId,
  ) async {
    await Future<void>.delayed(Duration.zero);
    if (refusing != null && assessment.hand == refusing) {
      throw Exception('refused');
    }
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

SessionModel _session({DateTime? date}) => SessionModel(
  name: 'Max pull ups',
  date: date ?? DateTime(2026, 9, 18, 10),
  isAssessment: true,
  activity: SessionActivity.hangboard,
  origin: SessionOrigin.played,
);

AssessmentModel _maxForce(
  String id,
  DateTime date, {
  AssessmentOrigin origin = AssessmentOrigin.test,
}) => AssessmentModel(
  id: id,
  date: date,
  definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
  rightValue: 40,
  origin: origin,
);

/// Records a Max Force whose session started at [at], with the clock there
/// too, as a run finished at that moment would.
Future<void> _recordMaxForceAt(ProviderContainer container, DateTime at) =>
    withClock(
      Clock.fixed(at),
      () => container
          .read(assessmentsProvider(BuiltinAssessmentIds.maxForce).notifier)
          .saveAssessment(
            AssessmentResultModel(
              assessmentId: BuiltinAssessmentIds.maxForce,
              rightValue: 41,
            ),
            _session(date: at),
            const [],
          ),
    );

ProviderContainer _containerOver(_SlowAssessmentRepository repository) =>
    ProviderContainer.test(
      overrides: [
        assessmentRepositoryProvider.overrideWithValue(repository),
        sessionsProvider.overrideWith(_CapturingSessions.new),
      ],
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
          date: DateTime(2026, 9, 18, 9),
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

  test(
    'a test taken the day a max was kept from a training replaces nothing',
    () async {
      // The result kept from a training is not a run of the test, so the test
      // sits beside it rather than erasing it.
      final repository = _SlowAssessmentRepository()
        ..stored = [
          AssessmentModel(
            id: 'kept',
            date: DateTime(2026, 9, 18, 9),
            definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
            rightValue: 42,
            origin: AssessmentOrigin.training,
          ),
        ];
      final container = ProviderContainer.test(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(repository),
          sessionsProvider.overrideWith(_CapturingSessions.new),
        ],
      );

      await container
          .read(assessmentsProvider(BuiltinAssessmentIds.maxForce).notifier)
          .saveAssessment(
            AssessmentResultModel(
              assessmentId: BuiltinAssessmentIds.maxForce,
              rightValue: 41,
            ),
            _session(),
            const [],
          );

      expect(repository.deleted, isEmpty);
    },
  );

  test(
    'results added to a stored session write no session and replace nothing',
    () async {
      final repository = _SlowAssessmentRepository()
        ..stored = [
          AssessmentModel(
            id: 'morning-test',
            date: DateTime(2026, 9, 18, 9),
            definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
            rightValue: 40,
          ),
        ];
      final sessions = _CapturingSessions();
      final container = ProviderContainer.test(
        overrides: [
          assessmentRepositoryProvider.overrideWithValue(repository),
          sessionsProvider.overrideWith(() => sessions),
        ],
      );
      container.listen(assessmentsProvider(null), (_, _) {});
      await container.read(assessmentsProvider(null).future);
      final readsBefore = repository.reads;

      await container
          .read(assessmentsProvider(BuiltinAssessmentIds.maxForce).notifier)
          .addResultsToSession([
            AssessmentResultModel(
              assessmentId: BuiltinAssessmentIds.maxForce,
              rightValue: 42,
              origin: AssessmentOrigin.training,
            ),
          ], 'training-session');
      await container.read(assessmentsProvider(null).future);

      expect(sessions.saved, isEmpty);
      expect(repository.deleted, isEmpty);
      expect(repository.saved.single.origin, AssessmentOrigin.training);
      expect(repository.reads, greaterThan(readsBefore));
    },
  );

  test('a result that fails to land does not stop the others', () async {
    final repository = _SlowAssessmentRepository()..refusing = HandSide.left;
    final container = ProviderContainer.test(
      overrides: [
        assessmentRepositoryProvider.overrideWithValue(repository),
        sessionsProvider.overrideWith(_CapturingSessions.new),
      ],
    );

    final failed = await container
        .read(assessmentsProvider(BuiltinAssessmentIds.maxForce).notifier)
        .addResultsToSession([
          AssessmentResultModel(
            assessmentId: BuiltinAssessmentIds.maxForce,
            leftValue: 42,
            origin: AssessmentOrigin.training,
          ),
          AssessmentResultModel(
            assessmentId: BuiltinAssessmentIds.maxForce,
            rightValue: 43,
            origin: AssessmentOrigin.training,
          ),
        ], 'training-session');

    expect(failed.single.leftValue, 42);
    expect(repository.saved.single.rightValue, 43);
  });

  group('the day a test replaces is the training day', () {
    test('a retest at 01:00 replaces the test taken at 23:00', () async {
      // The training day turns at 04:00, so both runs are the same evening's.
      final repository = _SlowAssessmentRepository()
        ..stored = [_maxForce('evening', DateTime(2026, 9, 28, 23))];

      await _recordMaxForceAt(
        _containerOver(repository),
        DateTime(2026, 9, 29, 1),
      );

      expect(repository.deleted, ['evening']);
      expect(repository.saved, hasLength(1));
    });

    test('a test at 04:00 keeps the one taken at 03:59', () async {
      final repository = _SlowAssessmentRepository()
        ..stored = [_maxForce('night', DateTime(2026, 9, 29, 3, 59))];

      await _recordMaxForceAt(
        _containerOver(repository),
        DateTime(2026, 9, 29, 4),
      );

      expect(repository.deleted, isEmpty);
      expect(repository.saved, hasLength(1));
    });

    test(
      'a retest at 01:00 leaves a max kept from a training untouched',
      () async {
        // Kept after the evening's test, so it is the last result: only the
        // test it sits beside is replaced.
        final repository = _SlowAssessmentRepository()
          ..stored = [
            _maxForce('evening', DateTime(2026, 9, 28, 23)),
            _maxForce(
              'kept',
              DateTime(2026, 9, 28, 23, 30),
              origin: AssessmentOrigin.training,
            ),
          ];

        await _recordMaxForceAt(
          _containerOver(repository),
          DateTime(2026, 9, 29, 1),
        );

        expect(repository.deleted, ['evening']);
      },
    );

    test('the redo prompt asks by the training day too', () async {
      // The list screen asks before a run whether one is to be replaced, with
      // no session yet, so it measures against now.
      final repository = _SlowAssessmentRepository()
        ..stored = [_maxForce('evening', DateTime(2026, 9, 28, 23))];
      final notifier = _containerOver(
        repository,
      ).read(assessmentsProvider(BuiltinAssessmentIds.maxForce).notifier);

      expect(
        await withClock(
          Clock.fixed(DateTime(2026, 9, 29, 1)),
          notifier.getSameDayAssessment,
        ),
        'evening',
      );
      expect(
        await withClock(
          Clock.fixed(DateTime(2026, 9, 29, 4)),
          notifier.getSameDayAssessment,
        ),
        isNull,
      );
    });

    test('a run resumed the next day replaces its own day\'s test', () async {
      // A draft keeps the session it was run in, so its result is filed on
      // that day and must not erase the test taken since.
      final repository = _SlowAssessmentRepository()
        ..stored = [
          _maxForce('yesterday', DateTime(2026, 9, 28, 18)),
          _maxForce('today', DateTime(2026, 9, 29, 10)),
        ];
      final container = _containerOver(repository);

      await withClock(
        Clock.fixed(DateTime(2026, 9, 29, 12)),
        () => container
            .read(assessmentsProvider(BuiltinAssessmentIds.maxForce).notifier)
            .saveAssessment(
              AssessmentResultModel(
                assessmentId: BuiltinAssessmentIds.maxForce,
                rightValue: 41,
              ),
              _session(date: DateTime(2026, 9, 28, 20)),
              const [],
            ),
      );

      expect(repository.deleted, ['yesterday']);
    });
  });
}
