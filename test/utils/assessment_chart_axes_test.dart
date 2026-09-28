import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/utils/assessment_chart_axes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('valueAxisRange', () {
    // The chart of Krakoer/crimpy#164: 20.8 and 20.9 kg on a 0.2 kg axis.
    test('never zooms a kilogram chart under five kilograms', () {
      expect(valueAxisRange([20.8, 20.9], AssessmentUnit.kilograms), (
        min: 20.0,
        max: 25.0,
        interval: 1.0,
      ));
    });

    test('rounds a wider series out to the step on both ends', () {
      expect(valueAxisRange([22.4, 31.2], AssessmentUnit.kilograms), (
        min: 20.0,
        max: 35.0,
        interval: 5.0,
      ));
    });

    test('keeps a series sitting on a step at least a step wide', () {
      expect(valueAxisRange([25, 25], AssessmentUnit.kilograms), (
        min: 25.0,
        max: 30.0,
        interval: 1.0,
      ));
    });

    test('spans ten seconds and five repetitions at the least', () {
      expect(valueAxisRange([41, 43], AssessmentUnit.seconds), (
        min: 40.0,
        max: 50.0,
        interval: 2.0,
      ));
      expect(valueAxisRange([12, 13], AssessmentUnit.repetitions), (
        min: 10.0,
        max: 15.0,
        interval: 1.0,
      ));
    });

    test('keeps a wide axis to six labels at the most', () {
      expect(valueAxisRange([22, 78], AssessmentUnit.kilograms), (
        min: 20.0,
        max: 80.0,
        interval: 10.0,
      ));
    });

    test('never starts under zero', () {
      expect(valueAxisRange([0, 2], AssessmentUnit.kilograms), (
        min: 0.0,
        max: 5.0,
        interval: 1.0,
      ));
    });

    test('has no range without values', () {
      expect(valueAxisRange([], AssessmentUnit.kilograms), isNull);
    });
  });

  group('testedDays', () {
    test('counts two tests on one day as one', () {
      expect(
        testedDays([DateTime(2026, 10, 4, 9), DateTime(2026, 10, 4, 18)]),
        1,
      );
    });

    test('counts tests on different days apart', () {
      expect(testedDays([DateTime(2026, 10, 4), DateTime(2026, 10, 5)]), 2);
    });
  });
}
