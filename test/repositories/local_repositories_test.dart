import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session_filter.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
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
          origin: SessionOrigin.logged,
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
          origin: SessionOrigin.logged,
          date: DateTime(2026, 3, 1),
        ),
        [
          rep(index: 0, isRest: false, hand: HandSide.right),
          rep(index: 1, isRest: true, hand: HandSide.left),
          rep(index: 2, isRest: false, hand: HandSide.both),
        ],
      );

      final reps = (await trainings.getAllSessionsWithReps()).single.reps!;

      expect(reps[0].handSide, HandSide.right);
      expect(reps[0].isRest, isFalse);
      expect(reps[1].handSide, HandSide.left);
      expect(reps[1].isRest, isTrue);
      // A two handed hang is a state of its own, and the boolean this column
      // replaced stored it as the left hand.
      expect(reps[2].handSide, HandSide.both);
    });

    test('the filter narrows to assessments', () async {
      await trainings.saveSession(
        SessionModel(
          name: 'A',
          isAssessment: true,
          origin: SessionOrigin.played,
          date: DateTime(2026, 3, 1),
        ),
        [],
      );
      await trainings.saveSession(
        SessionModel(
          name: 'T',
          isAssessment: false,
          origin: SessionOrigin.logged,
          date: DateTime(2026, 3, 2),
        ),
        [],
      );

      final onlyAssessments = await trainings.getAllSessionsWithReps(
        filters: const SessionFilter(isAssessment: true),
      );

      expect(onlyAssessments.map((s) => s.name), ['A']);
    });

    test('the filter narrows to an activity', () async {
      await trainings.saveSession(
        SessionModel(
          name: 'Board',
          isAssessment: false,
          origin: SessionOrigin.played,
          activity: SessionActivity.hangboard,
          date: DateTime(2026, 3, 1),
        ),
        [],
      );
      await trainings.saveSession(
        SessionModel(
          name: 'Run',
          isAssessment: false,
          origin: SessionOrigin.logged,
          activity: SessionActivity.other,
          date: DateTime(2026, 3, 2),
        ),
        [],
      );

      final onlyOther = await trainings.getAllSessionsWithReps(
        filters: const SessionFilter(activities: {SessionActivity.other}),
      );

      expect(onlyOther.map((s) => s.name), ['Run']);
    });

    test(
      'editing the notes of a played session keeps its run timings',
      () async {
        final recordedAt = DateTime(2026, 3, 1, 18, 42, 37);
        await trainings.saveSession(
          SessionModel(
            name: 'Board',
            isAssessment: false,
            origin: SessionOrigin.played,
            durationInSeconds: 187,
            date: recordedAt,
          ),
          [],
        );

        final played = (await trainings.getAllSessionsWithReps()).single;
        await trainings.updateSession(played.copyWith(notes: 'felt strong'));

        final edited = (await trainings.getAllSessionsWithReps()).single;
        expect(edited.notes, 'felt strong');
        expect(edited.duration, 187);
        expect(edited.date, recordedAt);
      },
    );

    // The guest-mode store, which is also what local_data_migration uploads
    // when a guest signs up, so an answer lost here is lost silently.
    test('a session keeps the RPE it was saved with', () async {
      await trainings.saveSession(
        SessionModel(
          name: 'Board',
          isAssessment: false,
          origin: SessionOrigin.logged,
          durationInSeconds: 3600,
          date: DateTime(2026, 3, 1),
          rpe: 8,
        ),
        [],
      );

      final saved = (await trainings.getAllSessionsWithReps()).single;
      expect(saved.rpe, 8);
      expect(saved.rpeFailed, isFalse);
    });

    test('a failed session is stored as ECHEC and not as a number', () async {
      await trainings.saveSession(
        SessionModel(
          name: 'Board',
          isAssessment: false,
          origin: SessionOrigin.logged,
          durationInSeconds: 3600,
          date: DateTime(2026, 3, 1),
          rpeFailed: true,
        ),
        [],
      );

      final saved = (await trainings.getAllSessionsWithReps()).single;
      expect(saved.rpe, isNull);
      expect(saved.rpeFailed, isTrue);
    });

    test('an RPE given after the fact reaches the local store', () async {
      await trainings.saveSession(
        SessionModel(
          name: 'Board',
          isAssessment: false,
          origin: SessionOrigin.played,
          durationInSeconds: 187,
          date: DateTime(2026, 3, 1),
        ),
        [],
      );

      final played = (await trainings.getAllSessionsWithReps()).single;
      await trainings.updateSession(played.withSessionRpe(rpe: 9));

      expect((await trainings.getAllSessionsWithReps()).single.rpe, 9);
    });

    test('an answer taken back leaves the session unrated', () async {
      await trainings.saveSession(
        SessionModel(
          name: 'Board',
          isAssessment: false,
          origin: SessionOrigin.logged,
          durationInSeconds: 3600,
          date: DateTime(2026, 3, 1),
          rpe: 7,
        ),
        [],
      );

      final rated = (await trainings.getAllSessionsWithReps()).single;
      await trainings.updateSession(rated.withSessionRpe());

      final cleared = (await trainings.getAllSessionsWithReps()).single;
      expect(cleared.rpe, isNull);
      expect(cleared.rpeFailed, isFalse);
    });

    test('a row holding both reads back as a failure alone', () async {
      await trainings.saveSession(
        SessionModel(
          name: 'Board',
          isAssessment: false,
          origin: SessionOrigin.logged,
          durationInSeconds: 3600,
          date: DateTime(2026, 3, 1),
          rpe: 8,
        ),
        [],
      );

      // Written past the model, since the model refuses the pair: the column
      // pair carries no cross-column constraint, so the reader is what has to
      // hold the invariant.
      await db.customStatement('UPDATE sessions SET rpe_failed = 1');

      final read = (await trainings.getAllSessionsWithReps()).single;
      expect(read.rpe, isNull);
      expect(read.rpeFailed, isTrue);
    });

    test('a deleted session is gone', () async {
      final id = await trainings.saveSession(
        SessionModel(
          name: 'S',
          isAssessment: false,
          origin: SessionOrigin.logged,
          date: DateTime(2026, 3, 1),
        ),
        [],
      );

      await trainings.deleteSession(id);

      expect(await trainings.getAllSessionsWithReps(), isEmpty);
    });
  });

  group('trainings round-trip', () {
    test(
      'a split item keeps a grip array per hand and its granularity',
      () async {
        await trainings.saveTraining(
          Training(
            id: '',
            title: 'Split repeaters',
            items: [
              TrainingItem(
                id: '',
                type: TrainingItemType.repeater,
                position: 0,
                hand: HangboardHand.split,
                granularity: HangboardGranularity.perSet,
                cycles: 2,
                reps: 2,
                handPositions: const [
                  ['HC', 'FC', 'OC', '3FD'],
                  ['OC', '3FD', 'HC', 'FC'],
                ],
                edgeSizesMm: const [20, 20, 14, 14],
              ),
            ],
          ),
        );

        final item =
            (await trainings.getAllTrainings()).trainings.single.items.single;

        expect(item.hand, HangboardHand.split);
        expect(item.granularity, HangboardGranularity.perSet);
        expect(item.handPositions, [
          ['HC', 'FC', 'OC', '3FD'],
          ['OC', '3FD', 'HC', 'FC'],
        ]);
        expect(item.edgeSizesMm, [20, 20, 14, 14]);
      },
    );

    // The local table stored no variable targets at all, so a training cached
    // here lost every percentage reference on a round trip.
    test('an item keeps the assessment its numbers are read against', () async {
      await trainings.saveTraining(
        Training(
          id: '',
          title: 'Volume day',
          items: [
            TrainingItem(
              id: '',
              type: TrainingItemType.exercise,
              position: 0,
              reps: 8,
              variableTargets: const {
                'reps': VariableTarget(
                  assessmentId: 'a9b8c7d6-0000-0000-0000-000000000001',
                  percent: 60,
                  fallback: 8,
                ),
              },
              loads: const [
                Load(
                  value: 80,
                  unit: percentAssessmentUnit,
                  assessmentId: 'f7954158-63ba-4f0b-a125-6ef195fa6442',
                  fallback: 25,
                ),
              ],
            ),
          ],
        ),
      );

      final item =
          (await trainings.getAllTrainings()).trainings.single.items.single;

      expect(
        item.variableTargets['reps']!.assessmentId,
        'a9b8c7d6-0000-0000-0000-000000000001',
      );
      expect(item.variableTargets['reps']!.percent, 60);
      expect(
        item.loads!.single.assessmentId,
        'f7954158-63ba-4f0b-a125-6ef195fa6442',
      );
      expect(item.loads!.single.fallback, 25);
    });

    test('a single-hand item keeps its one grip array', () async {
      await trainings.saveTraining(
        Training(
          id: '',
          title: 'App repeaters',
          items: [
            TrainingItem(
              id: '',
              type: TrainingItemType.repeater,
              position: 0,
              hand: HangboardHand.right,
              granularity: HangboardGranularity.perRep,
              reps: 2,
              handPositions: const [
                ['HC', 'FC'],
              ],
            ),
          ],
        ),
      );

      final item =
          (await trainings.getAllTrainings()).trainings.single.items.single;

      expect(item.handPositions, [
        ['HC', 'FC'],
      ]);
    });
  });

  group('assessments', () {
    Future<void> saveOn(DateTime date, {required double right}) async {
      final sessionId = await trainings.saveSession(
        SessionModel(
          name: 'MVC',
          isAssessment: true,
          origin: SessionOrigin.played,
          date: date,
        ),
        [],
      );
      await assessments.saveAssessment(
        AssessmentResultModel(
          assessmentId: BuiltinAssessmentIds.maxForce,
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
        BuiltinAssessmentIds.maxForce,
        HandSide.right,
      );
      final left = await assessments.getLastValueForHand(
        BuiltinAssessmentIds.maxForce,
        HandSide.left,
      );

      expect(right, 42);
      expect(left, 40);
    });

    // The rows used to come back in whatever order SQLite gave them, so the
    // last one was the last written rather than the most recent measured.
    test('the most recent result wins over the order it was written', () async {
      await saveOn(DateTime(2026, 2, 1), right: 42);
      await saveOn(DateTime(2026, 1, 1), right: 30);

      final right = await assessments.getLastValueForHand(
        BuiltinAssessmentIds.maxForce,
        HandSide.right,
      );

      expect(right, 42);
    });

    test('reads the assessments back chronologically', () async {
      await saveOn(DateTime(2026, 3, 1), right: 45);
      await saveOn(DateTime(2026, 1, 1), right: 30);
      await saveOn(DateTime(2026, 2, 1), right: 42);

      final history = await assessments.getAssessments(
        assessmentId: BuiltinAssessmentIds.maxForce,
      );

      expect(history.map((a) => a.rightValue), [30, 42, 45]);
    });

    test('getLastValueForHand is null when nothing was recorded', () async {
      final value = await assessments.getLastValueForHand(
        BuiltinAssessmentIds.criticalForce,
        HandSide.right,
      );

      expect(value, isNull);
    });

    test('filtering by type ignores other assessments', () async {
      await saveOn(DateTime(2026, 1, 1), right: 30);

      final criticalForce = await assessments.getAssessments(
        assessmentId: BuiltinAssessmentIds.criticalForce,
      );
      final mvc = await assessments.getAssessments(
        assessmentId: BuiltinAssessmentIds.maxForce,
      );

      expect(criticalForce, isEmpty);
      expect(mvc, hasLength(1));
    });
  });

  // A guest run stores the counts it resolved for the open items, and the list
  // is the only read a local session gets: it already fills the reps, so the
  // detail fetch that carries them on the remote side is never reached here.
  test('a listed local session carries the counts its run recorded', () async {
    final saved = await trainings.saveSession(
      SessionModel(
        name: 'Pull up EMOM',
        isAssessment: false,
        origin: SessionOrigin.played,
      ),
      [rep(index: 0, isRest: false)],
      itemResults: const [
        SessionItemResultModel(
          trainingItemId: 'pullup-1',
          occurrence: 0,
          reps: 23,
          note: 'hard on the shoulders',
        ),
        SessionItemResultModel(
          trainingItemId: 'emom-1',
          occurrence: 0,
          cycles: 7,
        ),
      ],
    );

    final listed = (await trainings.getAllSessionsWithReps()).single;
    expect(listed.id, saved);
    expect(
      listed.itemResults.map(
        (r) => '${r.trainingItemId}/${r.reps}/${r.cycles}/${r.note}',
      ),
      containsAll([
        'pullup-1/23/null/hard on the shoulders',
        'emom-1/null/7/null',
      ]),
    );
  });
}
