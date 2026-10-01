import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/override_labels.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:flutter_test/flutter_test.dart';

AssessmentModel _maxForce(
  DateTime date, {
  double? right,
  double? left,
  GripPosition? grip,
}) => AssessmentModel(
  id: 'a-${date.millisecondsSinceEpoch}',
  date: date,
  definition: BuiltinAssessmentIds.definitionOf(AssessmentType.mvc),
  rightValue: right,
  leftValue: left,
  gripPosition: grip,
);

const _eightyPercentOfMax = Load(
  value: 80,
  unit: percentAssessmentUnit,
  assessmentId: BuiltinAssessmentIds.maxForce,
  fallback: 10,
);

TrainingItem _hang(String grip, {String hand = HangboardHand.right}) =>
    TrainingItem(
      id: 'h',
      type: TrainingItemType.hangboardRep,
      position: 0,
      hand: hand,
      worktimeSeconds: 7,
      restSeconds: 3,
      loads: const [_eightyPercentOfMax],
      handPositions: [
        [grip],
      ],
    );

void main() {
  // Half crimp tested in January, open hand in February: the open hand is the
  // latest result, and before Krakoer/crimpy#182 every percentage load read
  // against it.
  final history = [
    _maxForce(
      DateTime(2026, 1, 5),
      right: 45,
      left: 44,
      grip: GripPosition.halfCrimp,
    ),
    _maxForce(DateTime(2026, 2, 5), right: 30, grip: GripPosition.openHand),
  ];
  final results = AssessmentResults.fromHistory(history);
  const maxForce = BuiltinAssessmentIds.maxForce;

  group('AssessmentResults.value', () {
    test('reads the max of the grip asked for', () {
      expect(
        results.value(
          maxForce,
          handSide: HandSide.right,
          grip: GripPosition.halfCrimp,
        ),
        45,
      );
      expect(
        results.value(
          maxForce,
          handSide: HandSide.right,
          grip: GripPosition.openHand,
        ),
        30,
      );
    });

    test('falls back to the latest on any grip for a grip never tested', () {
      expect(
        results.value(
          maxForce,
          handSide: HandSide.right,
          grip: GripPosition.threeFinger,
        ),
        30,
      );
      expect(results.value(maxForce, handSide: HandSide.right), 30);
    });

    test('falls back hand by hand', () {
      // The open hand was only ever pulled on the right.
      expect(
        results.value(
          maxForce,
          handSide: HandSide.left,
          grip: GripPosition.openHand,
        ),
        44,
      );
    });

    test('a two handed hang reads the mean of the grip', () {
      expect(
        results.value(
          maxForce,
          handSide: HandSide.both,
          grip: GripPosition.halfCrimp,
        ),
        44.5,
      );
    });

    test('agrees with the intensity rater on every grip and hand', () {
      final reference = MaxForceReference.fromHistory(history);
      for (final grip in GripPosition.values) {
        for (final hand in [HandSide.right, HandSide.left]) {
          expect(
            results.value(maxForce, handSide: hand, grip: grip),
            reference.of(hand, grip),
            reason: '$grip $hand',
          );
        }
      }
    });
  });

  test('a load resolves against the grip it is hung with', () {
    expect(
      _eightyPercentOfMax.kilograms(
        results: results,
        handSide: HandSide.right,
        grip: GripPosition.halfCrimp,
      ),
      36,
    );
  });

  test('the run hangs a half crimp at a percentage of the half crimp max', () {
    final steps = expandTrainingItems(
      Training(id: 't', title: 'Hang', items: [_hang('halfCrimp')]),
      results: results,
    );

    final hang = steps.whereType<TimedItem>().single;
    expect(hang.targetLoad, 36);
  });

  test('the rater and the run read the same kilograms', () {
    final hang = resolveHangs(
      _hang('openHand'),
      maxForce: MaxForceReference.fromHistory(history),
      results: results,
    ).single;

    expect(hang.kilograms, 24);
  });

  test('the review states the load the run hung', () {
    expect(prescribedSummary(_hang('halfCrimp'), results), contains('36'));
  });

  test('a repeater reads each rep against the grip of that rep', () {
    final steps = expandTrainingItems(
      Training(
        id: 't',
        title: 'Two grips',
        items: [
          TrainingItem(
            id: 'r',
            type: TrainingItemType.repeater,
            position: 0,
            hand: HangboardHand.right,
            cycles: 1,
            reps: 2,
            worktimeSeconds: 7,
            restSeconds: 3,
            granularity: HangboardGranularity.perRep,
            loads: const [_eightyPercentOfMax, _eightyPercentOfMax],
            handPositions: const [
              ['HC', 'OH'],
            ],
          ),
        ],
      ),
      results: results,
    );

    final hangs = steps.whereType<TimedItem>().toList();
    expect(hangs.map((h) => h.targetLoad), [36, 24]);
  });

  test('a week override chip reads the load on the hang it overrides', () {
    final labels = overrideChipLabels(
      {
        'loads': [_eightyPercentOfMax.toJson()],
      },
      results: results,
      bodyweightKg: null,
      item: _hang('halfCrimp'),
    );

    expect(labels.single, contains('(36 kg)'));
  });
}
