import 'dart:math' as math;

import 'package:crimpy/models/assessment_model.dart';

/// The narrowest value axis an assessment chart draws, per unit, and the step
/// its bounds are rounded to. Under half a kilo across a series is grip noise:
/// an axis zoomed onto it draws 20.8 and 20.9 kg a third of a chart apart and
/// calls that a trend. Five kilograms, ten seconds or five repetitions is the
/// least a chart spans, so a difference only looks big when it is.
///
/// The web portal draws its assessment charts by the same numbers, in
/// crimpy-frontend/src/lib/components/assessment/chart-axes.ts. See
/// Krakoer/crimpy#164.
double minimumAxisSpan(AssessmentUnit unit) => switch (unit) {
  AssessmentUnit.kilograms => 5,
  AssessmentUnit.seconds => 10,
  AssessmentUnit.repetitions => 5,
};

/// The value axis of a chart holding [values]: from the lowest value rounded
/// down to a multiple of the unit's [minimumAxisSpan], never under zero, to the
/// highest rounded up to one, and at least that span wide, with the gap between
/// its labels. Null for no values.
({double min, double max, double interval})? valueAxisRange(
  Iterable<double> values,
  AssessmentUnit unit,
) {
  if (values.isEmpty) return null;
  final step = minimumAxisSpan(unit);
  final low = values.reduce(math.min);
  final high = values.reduce(math.max);
  final min = math.max(0.0, (low / step).floor() * step);
  final max = math.max((high / step).ceil() * step, min + step);
  return (min: min, max: max, interval: _axisInterval(max - min, step));
}

/// A fifth of the span on the narrowest axis, then whole spans, widened so no
/// chart carries more than six labels. The bounds are multiples of it, so no
/// edge falls between two ticks.
double _axisInterval(double width, double step) {
  final steps = (width / step).round();
  if (steps <= 1) return step / 5;
  return step * (steps / 6).ceil();
}

/// The calendar days [dates] fall on. A chart is drawn from the second one: a
/// single test is a value, and a line through one day is not a trend.
int testedDays(Iterable<DateTime> dates) => dates
    .map((date) => DateTime(date.year, date.month, date.day))
    .toSet()
    .length;
