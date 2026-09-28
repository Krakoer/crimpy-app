import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/builtin_training_repository.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:flutter_test/flutter_test.dart';

final _maxForce = BuiltinAssessmentIds.definitionOf(AssessmentType.mvc);

AssessmentModel _mvc(
  GripPosition grip,
  double right,
  double left, {
  required DateTime date,
}) => AssessmentModel(
  id: '${grip.name}-$right-$left',
  date: date,
  definition: _maxForce,
  rightValue: right,
  leftValue: left,
  gripPosition: grip,
);

/// Three grips with three different maxes, so a load divided by the wrong
/// grip's max comes out visibly wrong.
final _history = [
  _mvc(GripPosition.halfCrimp, 40, 38, date: DateTime(2026, 1, 1)),
  _mvc(GripPosition.openHand, 50, 48, date: DateTime(2026, 1, 2)),
  _mvc(GripPosition.threeFinger, 30, 29, date: DateTime(2026, 1, 3)),
];

TrainingIntensity? _builtinIntensity(
  String name, {
  double? customRight,
  double? customLeft,
}) {
  final builtin = builtinTrainings.firstWhere((b) => b.name == name);
  final training = BuiltinTrainingRepository.evaluateBuiltinSync(
    builtin,
    _history,
    customWeightRight: customRight,
    customWeightLeft: customLeft,
  ).training!;
  return peakIntensity(
    training,
    maxForce: MaxForceReference.fromHistory(_history),
  );
}

Training _hang(
  Load load, {
  String hand = HangboardHand.right,
  String grip = 'HC',
  TrainingItemType type = TrainingItemType.hangboardRep,
  bool loadIsMax = false,
}) => Training(
  id: 't',
  title: 'Board',
  items: [
    TrainingItem(
      id: 'i',
      type: type,
      position: 0,
      hand: hand,
      loads: [load],
      handPositions: [
        [grip],
      ],
      loadIsMax: loadIsMax,
    ),
  ],
);

void main() {
  group('builtins read against the max of the grip they hang', () {
    test('Power Endurance is 65%', () {
      expect(
        _builtinIntensity('Power Endurance')!.percentOfMax,
        closeTo(65, 1e-9),
      );
    });

    test('Max Force is 85%', () {
      expect(_builtinIntensity('Max Force')!.percentOfMax, closeTo(85, 1e-9));
    });

    test('Warmup peaks at its 95% block', () {
      expect(_builtinIntensity('Warmup')!.percentOfMax, closeTo(95, 1e-9));
    });

    test('a custom weight moves the figure off the description', () {
      final intensity = _builtinIntensity(
        'Power Endurance',
        customRight: 30,
        customLeft: 30,
      )!;
      // 30 kg on a left half crimp max of 38 kg.
      expect(intensity.percentOfMax, closeTo(30 / 38 * 100, 1e-9));
    });
  });

  group('peakIntensity', () {
    final reference = MaxForceReference.fromHistory(_history);

    test('a max effort hang is 100%', () {
      expect(
        peakIntensity(
          _hang(const Load(value: 0, unit: 'max')),
          maxForce: MaxForceReference.none,
        )!.percentOfMax,
        100,
      );
    });

    test('a percentage of max force is that percentage', () {
      final load = Load(
        value: 72,
        unit: percentAssessmentUnit,
        assessmentId: BuiltinAssessmentIds.maxForce,
        fallback: 10,
      );
      expect(
        peakIntensity(
          _hang(load, hand: HangboardHand.both),
          maxForce: MaxForceReference.none,
        )!.percentOfMax,
        72,
      );
    });

    test('kilograms divide by the max of their own grip and hand', () {
      final intensity = peakIntensity(
        _hang(const Load(value: 25, unit: 'kg'), grip: 'OH'),
        maxForce: reference,
      )!;
      expect(intensity.percentOfMax, closeTo(50, 1e-9));
    });

    test('a grip never tested reads against the latest max on any grip', () {
      final intensity = peakIntensity(
        _hang(const Load(value: 15, unit: 'kg'), grip: 'FC'),
        maxForce: reference,
      )!;
      // The three finger drag was entered last, at 30 kg on the right.
      expect(intensity.percentOfMax, closeTo(50, 1e-9));
    });

    test('a two handed hang in kilograms resolves to nothing', () {
      expect(
        peakIntensity(
          _hang(const Load(value: 25, unit: 'kg'), hand: HangboardHand.both),
          maxForce: reference,
        ),
        isNull,
      );
    });

    test('a bodyweight hang or an athlete without a max has no intensity', () {
      expect(
        peakIntensity(_hang(Load.bodyweight), maxForce: reference),
        isNull,
      );
      expect(
        peakIntensity(
          _hang(const Load(value: 25, unit: 'kg')),
          maxForce: MaxForceReference.none,
        ),
        isNull,
      );
    });

    test('an exercise does not count, however heavy', () {
      expect(
        peakIntensity(
          _hang(
            const Load(value: 0, unit: 'max'),
            type: TrainingItemType.exercise,
          ),
          maxForce: reference,
        ),
        isNull,
      );
    });

    test('the heaviest hang wins, nested ones included', () {
      final training = Training(
        id: 't',
        title: 'Board',
        items: [
          _hang(const Load(value: 10, unit: 'kg')).items.single,
          TrainingItem(
            id: 'g',
            type: TrainingItemType.group,
            position: 1,
            items: [_hang(const Load(value: 34, unit: 'kg')).items.single],
          ),
        ],
      );
      expect(
        peakIntensity(training, maxForce: reference)!.percentOfMax,
        closeTo(85, 1e-9),
      );
    });
  });

  group('tiers', () {
    test('split at 30% and 80%, as Get a Grip splits them', () {
      expect(const TrainingIntensity(30).tier, IntensityTier.light);
      expect(const TrainingIntensity(30.5).tier, IntensityTier.moderate);
      expect(const TrainingIntensity(79.9).tier, IntensityTier.moderate);
      expect(const TrainingIntensity(80).tier, IntensityTier.nearMax);
    });

    test('the label spells the percentage out', () {
      expect(const TrainingIntensity(64.6).label, '65% max');
    });
  });
}
