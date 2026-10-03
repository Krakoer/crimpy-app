import 'dart:convert';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/models/max_force_offer.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen/widgets/item_review_fields.dart';
import 'package:flutter_test/flutter_test.dart';

const _coachTest = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000001',
  label: 'Pull up pyramid',
  unit: AssessmentUnit.repetitions,
  trainingId: 'coach-training',
);

Training _template({bool reviewsEachStep = true}) => Training(
  id: 'training-1',
  title: 'Repeaters 20mm',
  goal: 'Build capacity',
  items: [
    TrainingItem(
      id: 'block-1',
      type: TrainingItemType.group,
      position: 0,
      groupTitle: 'Main set',
      items: [
        TrainingItem(
          id: 'hang-1',
          type: TrainingItemType.hangboardRep,
          position: 0,
          parentId: 'block-1',
          worktimeSeconds: 7,
          restSeconds: 3,
          reps: 6,
          edgeSizesMm: const [20],
        ),
        TrainingItem(
          id: 'pull-ups',
          type: TrainingItemType.exercise,
          position: 1,
          parentId: 'block-1',
          exerciseName: 'Pull ups',
          reps: 8,
        ),
      ],
    ),
  ],
  referencedAssessments: const [_coachTest],
  reviewsEachStep: reviewsEachStep,
);

RepDataModel _rep(int index, {bool unmeasured = false}) => RepDataModel(
  averageWeight: unmeasured ? 0 : 20.5,
  duration: 7,
  index: index,
  isRest: false,
  handSide: HandSide.left,
  targetWeight: unmeasured ? 0 : 20,
  gripPosition: GripPosition.threeFinger,
  edgeSizeMm: 20,
  trainingItemId: 'hang-1',
  targetUnmeasured: unmeasured,
);

T _roundTrip<T extends FinishedRunDraft>(T draft) =>
    FinishedRunDraft.fromJson(
          jsonDecode(jsonEncode(draft.toJson())) as Map<String, dynamic>,
        )
        as T;

void main() {
  group('a training review', () {
    final startedAt = DateTime(2026, 9, 28, 23, 55);
    final draft = TrainingReviewDraft(
      owner: 'user-1',
      template: _template(),
      results: [_rep(0), _rep(1, unmeasured: true)],
      startedAt: startedAt,
      itemResults: const [
        SessionItemResultModel(
          trainingItemId: 'pull-ups',
          occurrence: 0,
          reps: 7,
          note: 'Last one slow',
        ),
      ],
      measuredPulls: const [
        MeasuredPull(
          hand: HandSide.left,
          gripPosition: GripPosition.threeFinger,
          edgeSizeMm: 20,
          peakKg: 31.4,
        ),
      ],
      assessmentResults: AssessmentResults(
        {_coachTest.id: const AssessmentHandValues(right: 14)},
        definitions: {_coachTest.id: _coachTest},
      ),
      bodyweightKg: 64.5,
      activity: SessionActivity.workout,
      trainingId: 'training-1',
      programSessionId: 'slot-1',
    );

    test('keeps the owner and the frozen start of the run', () {
      final back = _roundTrip(draft);

      expect(back.owner, 'user-1');
      // #152: the session is dated by the run's start, which the draft has to
      // carry through the app dying, not read off the clock on resume.
      expect(back.startedAt, startedAt);
      expect(back.title, 'Repeaters 20mm');
    });

    // The reps, the item reports and the review lines all key on the item ids,
    // so a draft that lost them would review a run nothing can be filed under.
    test('keeps the prescription, its item ids and its assessments', () {
      final back = _roundTrip(draft);
      final block = back.template.items.single;

      expect(back.template.id, 'training-1');
      expect(back.template.goal, 'Build capacity');
      expect(block.id, 'block-1');
      expect(block.items.map((item) => item.id), ['hang-1', 'pull-ups']);
      expect(block.items.last.exerciseName, 'Pull ups');
      expect(back.template.referencedAssessments.single.id, _coachTest.id);
      expect(back.template.reviewsEachStep, isTrue);
      expect(
        buildItemReviewDrafts(
          back.template.items,
          back.itemResults,
          back.assessmentResults,
          back.bodyweightKg,
        ).length,
        buildItemReviewDrafts(
          draft.template.items,
          draft.itemResults,
          draft.assessmentResults,
          draft.bodyweightKg,
        ).length,
      );
    });

    test('keeps a generated training from asking for a line per step', () {
      final back = _roundTrip(
        TrainingReviewDraft(
          owner: 'user-1',
          template: _template(reviewsEachStep: false),
          results: const [],
          startedAt: startedAt,
        ),
      );

      expect(back.template.reviewsEachStep, isFalse);
    });

    test('keeps the reps as they were recorded', () {
      final back = _roundTrip(draft);

      expect(back.results, hasLength(2));
      final (measured, dropped) = (back.results[0], back.results[1]);
      expect(measured.averageWeight, 20.5);
      expect(measured.handSide, HandSide.left);
      expect(measured.gripPosition, GripPosition.threeFinger);
      expect(measured.edgeSizeMm, 20);
      expect(measured.trainingItemId, 'hang-1');
      expect(dropped.targetUnmeasured, isTrue);
      expect(dropped.targetWeight, 0);
    });

    // A result recorded since the run would otherwise change the loads the
    // review states from the ones the athlete hung.
    test('keeps the numbers the run was played against', () {
      final back = _roundTrip(draft);

      expect(back.assessmentResults.lastById[_coachTest.id]?.right, 14);
      expect(
        back.assessmentResults.unitOf(_coachTest.id),
        AssessmentUnit.repetitions,
      );
      expect(back.bodyweightKg, 64.5);
    });

    test('keeps the reports, the pulls and the links of the run', () {
      final back = _roundTrip(draft);

      expect(back.itemResults.single.reps, 7);
      expect(back.itemResults.single.note, 'Last one slow');
      expect(back.measuredPulls.single.peakKg, 31.4);
      expect(back.measuredPulls.single.hand, HandSide.left);
      expect(back.activity, SessionActivity.workout);
      expect(back.trainingId, 'training-1');
      expect(back.programSessionId, 'slot-1');
    });
  });

  test('a Critical Force result keeps what its save writes', () {
    final t0 = DateTime(2026, 9, 28, 18);
    final draft = CriticalForceResultDraft(
      owner: FinishedRunDraft.guestOwner,
      previousCriticalForce: 18.2,
      saveAssessment: AssessmentResultModel(
        assessmentId: BuiltinAssessmentIds.criticalForce,
        leftValue: 19.4,
      ),
      saveSession: SessionModel(
        name: 'Critical force assessment - 28/09/2026',
        date: t0,
        isAssessment: true,
        origin: SessionOrigin.played,
      ),
      saveReps: [_rep(0)],
      data: [
        BleDataPoint(1.5, t0),
        BleDataPoint(22.25, t0.add(const Duration(milliseconds: 100))),
      ],
      samples: const [(t: 0.0, kg: 1.5), (t: 0.1, kg: 22.25)],
      pullWindows: const [(start: 0.0, end: 7.0), (start: 10.0, end: 17.0)],
      pausedSeconds: 12,
    );

    final back = _roundTrip(draft);

    expect(back.owner, FinishedRunDraft.guestOwner);
    expect(back.previousCriticalForce, 18.2);
    expect(back.saveAssessment.leftValue, 19.4);
    expect(back.saveAssessment.rightValue, isNull);
    expect(back.saveSession.name, draft.saveSession.name);
    expect(back.saveSession.date, t0);
    expect(back.saveSession.isAssessment, isTrue);
    expect(back.saveReps.single.trainingItemId, 'hang-1');
    expect(back.data.map((point) => point.value), [1.5, 22.25]);
    expect(back.data.last.timestamp, draft.data.last.timestamp);
    expect(back.samples, draft.samples);
    expect(back.pullWindows, draft.pullWindows);
    expect(back.pausedSeconds, 12);
  });

  test('refuses a draft written by another version of the app', () {
    expect(
      () => FinishedRunDraft.fromJson({'version': 0, 'owner': 'user-1'}),
      throwsFormatException,
    );
    expect(
      () => FinishedRunDraft.fromJson({
        'version': 1,
        'owner': 'user-1',
        'kind': 'unknown',
      }),
      throwsFormatException,
    );
  });
}
