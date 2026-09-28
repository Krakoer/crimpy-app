import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/hang_prescription.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:flutter_test/flutter_test.dart';

final _mvc = BuiltinAssessmentIds.definitionOf(AssessmentType.mvc);

final _history = [
  AssessmentModel(
    id: 'mvc',
    date: DateTime(2026, 1, 1),
    definition: _mvc,
    rightValue: 40,
    leftValue: 20,
    gripPosition: GripPosition.halfCrimp,
  ),
];

final _maxForce = MaxForceReference.fromHistory(_history);

const _percentOfMaxForce = Load(
  value: 65,
  unit: percentAssessmentUnit,
  assessmentId: BuiltinAssessmentIds.maxForce,
  fallback: 10,
);

TrainingItem _hang({
  TrainingItemType type = TrainingItemType.hangboardRep,
  String hand = HangboardHand.right,
  List<Load> loads = const [Load(value: 10, unit: 'kg')],
  List<Load>? leftLoads,
  String granularity = HangboardGranularity.uniform,
  int reps = 1,
  List<int>? edges,
  List<List<String>>? grips,
  bool loadIsMax = false,
}) => TrainingItem(
  id: 'i',
  type: type,
  position: 0,
  hand: hand,
  reps: reps,
  cycles: 1,
  granularity: granularity,
  loads: loads,
  leftLoads: leftLoads,
  edgeSizesMm: edges,
  handPositions: grips,
  loadIsMax: loadIsMax,
);

HangPrescription? _of(
  TrainingItem item, {
  double? bodyweightKg,
  AssessmentResults results = AssessmentResults.none,
}) => HangPrescription.of(
  item,
  maxForce: _maxForce,
  results: results,
  bodyweightKg: bodyweightKg,
);

void main() {
  group('the setup', () {
    test('names the hand, the grip and the edge', () {
      final prescription = _of(
        _hang(
          edges: const [20],
          grips: const [
            ['OH'],
          ],
        ),
      )!;
      expect(prescription.setup, 'Right hand - Open Hand - 20mm');
    });

    test('a hang with no grip is the half crimp the run hangs it as', () {
      expect(_of(_hang())!.setup, 'Right hand - Half Crimp');
    });

    test('an alternating repeater names both hands in turn', () {
      final prescription = _of(
        _hang(
          type: TrainingItemType.repeater,
          hand: HangboardHand.alternate,
          reps: 10,
        ),
      )!;
      expect(prescription.setup, startsWith('Alternating hands'));
    });

    test('edges that change across reps read as a range', () {
      final prescription = _of(
        _hang(
          type: TrainingItemType.repeater,
          granularity: HangboardGranularity.perRep,
          reps: 3,
          loads: const [
            Load(value: 10, unit: 'kg'),
            Load(value: 10, unit: 'kg'),
            Load(value: 10, unit: 'kg'),
          ],
          edges: const [20, 15, 10],
        ),
      )!;
      expect(prescription.setup, endsWith('10-20mm'));
    });
  });

  group('the load, in kilograms and the percentage it came from', () {
    // The repeater is the block the detail screen stated no load for at all.
    test('a repeater at a percentage of max force', () {
      final prescription = _of(
        _hang(
          type: TrainingItemType.repeater,
          hand: HangboardHand.right,
          reps: 10,
          loads: const [_percentOfMaxForce],
        ),
      )!;
      expect(prescription.load, '10 kg (65% max)');
    });

    test('a load in kilograms reads against the max of its hand', () {
      expect(_of(_hang())!.load, '10 kg (25% max)');
    });

    test('a load in percent of the bodyweight keeps that percentage', () {
      final item = _hang(
        hand: HangboardHand.both,
        loads: const [Load(value: 80, unit: 'percent_bw')],
      );
      expect(_of(item, bodyweightKg: 70)!.load, '56 kg (80% BW)');
      expect(_of(item)!.load, '80% BW');
    });

    test('a two handed load in kilograms has no percentage of max', () {
      expect(_of(_hang(hand: HangboardHand.both))!.load, '10 kg');
    });

    test('hands with different loads are each named', () {
      final prescription = _of(
        _hang(
          type: TrainingItemType.repeater,
          hand: HangboardHand.alternate,
          leftLoads: const [Load(value: 6, unit: 'kg')],
        ),
      )!;
      expect(prescription.load, 'Right 10 kg (25% max) - Left 6 kg (30% max)');
    });

    test('a percentage of max force resolves against each hand', () {
      final item = _hang(
        type: TrainingItemType.repeater,
        hand: HangboardHand.alternate,
        loads: const [_percentOfMaxForce],
      );
      final measured = AssessmentResults.fromHistory(
        _history,
        definitions: [_mvc],
      );
      expect(
        _of(item, results: measured)!.load,
        'Right 26 kg (65% max) - Left 13 kg (65% max)',
      );
      // Until max force is tested both hands take the coach fallback, and
      // the same load reads once.
      expect(_of(item)!.load, '10 kg (65% max)');
    });

    test('loads that change across reps read as a range', () {
      final prescription = _of(
        _hang(
          type: TrainingItemType.repeater,
          granularity: HangboardGranularity.perRep,
          reps: 3,
          loads: const [
            Load(value: 8, unit: 'kg'),
            Load(value: 10, unit: 'kg'),
            Load(value: 12, unit: 'kg'),
          ],
        ),
      )!;
      expect(prescription.load, '8-12 kg (20-30% max)');
    });

    test('a max effort and a bodyweight hang say what they are', () {
      expect(_of(_hang(loadIsMax: true))!.load, 'Max effort');
      expect(_of(_hang(loads: const [Load.bodyweight]))!.load, 'Bodyweight');
    });
  });

  test('an item that hangs nothing has no prescription', () {
    expect(
      _of(
        const TrainingItem(
          id: 'e',
          type: TrainingItemType.exercise,
          position: 0,
          reps: 5,
        ),
      ),
      isNull,
    );
  });
}
