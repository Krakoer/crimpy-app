import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

AssessmentModel _assessment(
  AssessmentType type, {
  double? right,
  double? left,
  DateTime? date,
}) => AssessmentModel(
  type: type,
  id: '${type.name}-${date ?? ''}',
  date: date ?? DateTime(2026, 1, 1),
  rightValue: right,
  leftValue: left,
);

void main() {
  group('AssessmentResults', () {
    test('keeps the most recent result per assessment', () {
      final results = AssessmentResults.fromHistory([
        _assessment(AssessmentType.mvc, right: 40, date: DateTime(2026, 1, 1)),
        _assessment(AssessmentType.mvc, right: 50, date: DateTime(2026, 3, 1)),
        _assessment(
          AssessmentType.endurance60,
          right: 90,
          date: DateTime(2026, 2, 1),
        ),
      ]);

      expect(results.value(AssessmentType.mvc), 50);
      expect(results.value(AssessmentType.endurance60), 90);
    });

    test('reads the value of the hand that was asked for', () {
      final results = AssessmentResults.fromHistory([
        _assessment(AssessmentType.mvc, right: 50, left: 40),
      ]);

      expect(results.value(AssessmentType.mvc, handSide: HandSide.right), 50);
      expect(results.value(AssessmentType.mvc, handSide: HandSide.left), 40);
    });

    test('averages both hands when no hand is asked for', () {
      final results = AssessmentResults.fromHistory([
        _assessment(AssessmentType.mvc, right: 50, left: 40),
      ]);

      expect(results.value(AssessmentType.mvc), 45);
    });

    test('is null for an assessment that was never done', () {
      expect(AssessmentResults.none.value(AssessmentType.mvc), isNull);
    });

    test('keeps each hand last measurement when they were run apart', () {
      final results = AssessmentResults.fromHistory([
        _assessment(
          AssessmentType.criticalForce,
          left: 22,
          date: DateTime(2026, 1, 1),
        ),
        _assessment(
          AssessmentType.criticalForce,
          right: 25,
          date: DateTime(2026, 2, 1),
        ),
      ]);

      expect(
        results.value(AssessmentType.criticalForce, handSide: HandSide.left),
        22,
      );
      expect(
        results.value(AssessmentType.criticalForce, handSide: HandSide.right),
        25,
      );
    });

    test('is null for a hand that was never measured', () {
      final results = AssessmentResults.fromHistory([
        _assessment(AssessmentType.mvc, right: 50),
      ]);

      expect(
        results.value(AssessmentType.mvc, handSide: HandSide.left),
        isNull,
      );
    });
  });

  group('assessment-relative load', () {
    final results = AssessmentResults.fromHistory([
      _assessment(AssessmentType.mvc, right: 50, left: 40),
    ]);

    const load = Load(
      value: 80,
      unit: percentAssessmentUnit,
      assessmentType: AssessmentType.mvc,
      fallback: 25,
    );

    test('resolves to the percentage of the measured hand', () {
      expect(load.kilograms(results: results, handSide: HandSide.right), 40);
      expect(load.kilograms(results: results, handSide: HandSide.left), 32);
    });

    test('falls back when the assessment was never done', () {
      expect(load.kilograms(results: AssessmentResults.none), 25);
    });

    test('falls back when the assessment is not measured in kilograms', () {
      const secondsBacked = Load(
        value: 80,
        unit: percentAssessmentUnit,
        assessmentType: AssessmentType.endurance60,
        fallback: 25,
      );
      final measured = AssessmentResults.fromHistory([
        _assessment(AssessmentType.endurance60, right: 120),
      ]);

      expect(secondsBacked.kilograms(results: measured), 25);
    });

    test(
      'is neither bodyweight nor max, and labels the resolved kilograms',
      () {
        expect(load.isBodyweight, isFalse);
        expect(load.isMax, isFalse);
        expect(
          load.label(results: results, handSide: HandSide.right),
          '80% Max Force (40 kg)',
        );
      },
    );

    test('a fixed load keeps its own number', () {
      const fixed = Load(value: 35, unit: 'kg');
      expect(fixed.kilograms(results: results), 35);
      expect(fixed.label(results: results), '35 kg');
    });

    test('round-trips through JSON', () {
      final parsed = Load.fromJson(load.toJson());
      expect(parsed.unit, percentAssessmentUnit);
      expect(parsed.value, 80);
      expect(parsed.assessmentType, AssessmentType.mvc);
      expect(parsed.fallback, 25);
    });

    test('an unknown assessment index is not treated as relative', () {
      final parsed = Load.fromJson({
        'value': 80,
        'unit': percentAssessmentUnit,
        'assessment_type': 99,
      });
      expect(parsed.isAssessmentRelative, isFalse);
    });
  });

  group('variable reps and duration', () {
    final results = AssessmentResults.fromHistory([
      _assessment(AssessmentType.endurance60, right: 120, left: 120),
    ]);

    TrainingItem itemWith(Map<String, dynamic> targets) =>
        TrainingItem.fromJson({
          'id': 'i1',
          'type': 'exercise',
          'position': 0,
          'duration': 60,
          'variable_targets': targets,
        });

    test('resolves the duration against the last assessment', () {
      final item = itemWith({
        'duration': {
          'assessment_type': AssessmentType.endurance60.index,
          'percent': 75,
          'fallback': 60,
        },
      });

      expect(item.effectiveDuration(results), 90);
    });

    test('falls back when the assessment was never done', () {
      final item = itemWith({
        'duration': {
          'assessment_type': AssessmentType.endurance60.index,
          'percent': 75,
          'fallback': 60,
        },
      });

      expect(item.effectiveDuration(), 60);
    });

    test('falls back when the assessment is measured in another unit', () {
      final item = itemWith({
        'duration': {
          'assessment_type': AssessmentType.mvc.index,
          'percent': 75,
          'fallback': 60,
        },
      });

      expect(item.effectiveDuration(results), 60);
    });

    test('falls back on a reps target, nothing being measured in reps', () {
      final item = itemWith({
        'reps': {
          'assessment_type': AssessmentType.endurance60.index,
          'percent': 50,
          'fallback': 8,
        },
      });

      expect(item.effectiveReps(results), 8);
    });

    test('drops a target naming an assessment the app does not know', () {
      final item = itemWith({
        'duration': {'assessment_type': 99, 'percent': 75, 'fallback': 60},
      });

      expect(item.variableTargets, isEmpty);
      expect(item.effectiveDuration(results), 60);
    });

    test('round-trips through JSON', () {
      final item = itemWith({
        'reps': {
          'assessment_type': AssessmentType.endurance60.index,
          'percent': 50,
          'fallback': 8,
        },
      });

      final parsed = TrainingItem.fromJson({
        'id': 'i2',
        'type': 'exercise',
        'position': 0,
        ...item.toJson(),
      });
      expect(parsed.variableTargets['reps']?.percent, 50);
      expect(parsed.variableTargets['reps']?.fallback, 8);
    });

    test('lists the assessments a training tree resolves against', () {
      final group = TrainingItem.fromJson({
        'id': 'g1',
        'type': 'group',
        'position': 0,
        'items': [
          {
            'id': 'i1',
            'type': 'exercise',
            'position': 0,
            'variable_targets': {
              'duration': {
                'assessment_type': AssessmentType.endurance60.index,
                'percent': 75,
                'fallback': 60,
              },
            },
          },
          {
            'id': 'i2',
            'type': 'hangboard_rep',
            'position': 1,
            'loads': [
              {
                'value': 80,
                'unit': percentAssessmentUnit,
                'assessment_type': AssessmentType.mvc.index,
                'fallback': 25,
              },
            ],
          },
        ],
      });

      expect(group.referencedAssessments, {
        AssessmentType.endurance60,
        AssessmentType.mvc,
      });
    });
  });
}
