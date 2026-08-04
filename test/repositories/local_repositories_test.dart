import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/assessment_repository.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Exercises the local backends against a real in-memory database, which the
/// injected AppDatabase makes possible.
void main() {
  late AppDatabase db;
  late LocalTrainingRepository trainings;
  late LocalAssessmentRepository assessments;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    trainings = LocalTrainingRepository(database: db);
    assessments = LocalAssessmentRepository(database: db);
  });

  tearDown(() => db.close());

  RepDataModel rep({
    required int index,
    required bool isRest,
    HandSide hand = HandSide.right,
    double average = 10,
  }) => RepDataModel(
    averageWeight: average,
    duration: 7,
    index: index,
    isRest: isRest,
    handSide: hand,
    targetWeight: 12,
  );

  group('sessions round-trip', () {
    test('a saved session comes back with its repetitions', () async {
      final id = await trainings.saveSession(
        SessionModel(
          name: 'Repeaters',
          isAssessment: false,
          date: DateTime(2026, 3, 1),
          notes: 'felt strong',
        ),
        [
          rep(index: 0, isRest: false),
          rep(index: 1, isRest: true),
          rep(index: 2, isRest: false, hand: HandSide.left, average: 8),
        ],
      );

      final loaded = await trainings.getAllSessionsWithReps();

      expect(loaded, hasLength(1));
      expect(loaded.single.id, id);
      expect(loaded.single.name, 'Repeaters');
      expect(loaded.single.notes, 'felt strong');
      expect(loaded.single.reps, hasLength(3));
    });

    test('repetitions keep their hand and rest flags across a save', () async {
      await trainings.saveSession(
        SessionModel(
          name: 'S',
          isAssessment: false,
          date: DateTime(2026, 3, 1),
        ),
        [
          rep(index: 0, isRest: false, hand: HandSide.right),
          rep(index: 1, isRest: true, hand: HandSide.left),
        ],
      );

      final reps = (await trainings.getAllSessionsWithReps()).single.reps!;

      expect(reps[0].handSide, HandSide.right);
      expect(reps[0].isRest, isFalse);
      expect(reps[1].handSide, HandSide.left);
      expect(reps[1].isRest, isTrue);
    });

    test('the filter narrows to assessments', () async {
      await trainings.saveSession(
        SessionModel(name: 'A', isAssessment: true, date: DateTime(2026, 3, 1)),
        [],
      );
      await trainings.saveSession(
        SessionModel(
          name: 'T',
          isAssessment: false,
          date: DateTime(2026, 3, 2),
        ),
        [],
      );

      final onlyAssessments = await trainings.getAllSessionsWithReps(
        filters: const SessionFilter(isAssessment: true),
      );

      expect(onlyAssessments.map((s) => s.name), ['A']);
    });

    test('a deleted session is gone', () async {
      final id = await trainings.saveSession(
        SessionModel(
          name: 'S',
          isAssessment: false,
          date: DateTime(2026, 3, 1),
        ),
        [],
      );

      await trainings.deleteSession(id);

      expect(await trainings.getAllSessionsWithReps(), isEmpty);
    });
  });

  group('assessments', () {
    Future<void> saveOn(DateTime date, {required double right}) async {
      final sessionId = await trainings.saveSession(
        SessionModel(name: 'MVC', isAssessment: true, date: date),
        [],
      );
      await assessments.saveAssessment(
        AssessmentResultModel(
          type: AssessmentType.mvc,
          rightValue: right,
          leftValue: right - 2,
          gripPosition: GripPosition.halfCrimp,
        ),
        sessionId,
      );
    }

    test('getLastValueForHand returns the most recent result', () async {
      await saveOn(DateTime(2026, 1, 1), right: 30);
      await saveOn(DateTime(2026, 2, 1), right: 42);

      final right = await assessments.getLastValueForHand(
        AssessmentType.mvc,
        HandSide.right,
      );
      final left = await assessments.getLastValueForHand(
        AssessmentType.mvc,
        HandSide.left,
      );

      expect(right, 42);
      expect(left, 40);
    });

    test('getLastValueForHand is null when nothing was recorded', () async {
      final value = await assessments.getLastValueForHand(
        AssessmentType.criticalForce,
        HandSide.right,
      );

      expect(value, isNull);
    });

    test('filtering by type ignores other assessments', () async {
      await saveOn(DateTime(2026, 1, 1), right: 30);

      final criticalForce = await assessments.getAssessments(
        type: AssessmentType.criticalForce,
      );
      final mvc = await assessments.getAssessments(type: AssessmentType.mvc);

      expect(criticalForce, isEmpty);
      expect(mvc, hasLength(1));
    });
  });
}
