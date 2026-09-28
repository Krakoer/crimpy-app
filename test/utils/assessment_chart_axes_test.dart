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

    // Wider than six steps, the gap widens to a nice multiple of the span and
    // both ends round out to it, so the top is always labelled. The same cases
    // as crimpy-frontend's chart-axes.test.ts.
    for (final (values, expected) in [
      ([22.0, 53.0], (min: 20.0, max: 60.0, interval: 10.0)),
      ([27.0, 58.0], (min: 20.0, max: 60.0, interval: 10.0)),
      ([3.0, 64.0], (min: 0.0, max: 80.0, interval: 20.0)),
      ([22.0, 78.0], (min: 20.0, max: 80.0, interval: 20.0)),
      ([25.0, 75.0], (min: 20.0, max: 80.0, interval: 20.0)),
    ]) {
      test('labels both ends of $values kg, six labels at the most', () {
        expect(valueAxisRange(values, AssessmentUnit.kilograms), expected);
        expect(
          (expected.max - expected.min) / expected.interval + 1,
          lessThanOrEqualTo(6),
        );
      });
    }

    test('widens the axis for a value just past a step', () {
      expect(valueAxisRange([20.2, 25.0004], AssessmentUnit.kilograms), (
        min: 20.0,
        max: 30.0,
        interval: 5.0,
      ));
    });

    test('takes floating point noise on a step as the step', () {
      expect(valueAxisRange([20, 25.000000000001], AssessmentUnit.kilograms), (
        min: 20.0,
        max: 25.0,
        interval: 1.0,
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

  group('dateLabelInterval', () {
    test('divides a span evenly so its last day is labelled', () {
      expect(dateLabelInterval(8), 2);
      expect(dateLabelInterval(9), 3);
      expect(dateLabelInterval(2), 1);
    });

    test('labels only the two ends of a span nothing divides', () {
      expect(dateLabelInterval(7), 7);
      expect(dateLabelInterval(1), 1);
    });
  });

  group('dayOffset and dayAt', () {
    test('count calendar days across the autumn clock change', () {
      final first = DateTime(2026, 10, 12, 9);
      expect(dayOffset(first, DateTime(2026, 11, 1, 20)), 20);
      expect(dayAt(first, 15), DateTime(2026, 10, 27));
    });

    test('count calendar days across the spring clock change', () {
      final first = DateTime(2026, 3, 16, 1);
      expect(dayOffset(first, DateTime(2026, 4, 5, 23)), 20);
      expect(dayAt(first, 20), DateTime(2026, 4, 5));
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
