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

/// The most gaps between labels an axis carries, so at most six labels.
const int _maximumLabelGaps = 5;

/// The multiples of the span the gap between labels may take: 1, 2 and 4 of
/// each power of ten, so the labels stay round numbers.
int _niceMultiple(double atLeast) {
  for (var power = 1; ; power *= 10) {
    for (final multiple in const [1, 2, 4]) {
      if (multiple * power >= atLeast) return multiple * power;
    }
  }
}

/// The value axis of a chart holding [values], and the gap between its labels.
/// The narrowest axis is one [minimumAxisSpan] wide, from the lowest value
/// rounded down to a multiple of the span, never under zero, labelled every
/// fifth of it. A wider one is labelled every span, or a nice multiple of it
/// when that would take more than six labels, and both its ends are rounded out
/// to that gap, so the bottom and the top are always labelled. Null for no
/// values.
({double min, double max, double interval})? valueAxisRange(
  Iterable<double> values,
  AssessmentUnit unit,
) {
  if (values.isEmpty) return null;
  final step = minimumAxisSpan(unit);
  final low = math.max(0.0, (values.reduce(math.min) / step).floor() * step);
  final high = math.max(
    (values.reduce(math.max) / step).ceil() * step,
    low + step,
  );
  final steps = ((high - low) / step).round();
  if (steps <= 1) return (min: low, max: high, interval: step / 5);
  for (
    var multiple = _niceMultiple(steps / _maximumLabelGaps);
    ;
    multiple = _niceMultiple(multiple + 1.0)
  ) {
    final interval = step * multiple;
    final min = (low / interval).floor() * interval;
    final max = (high / interval).ceil() * interval;
    if (((max - min) / interval).round() <= _maximumLabelGaps) {
      return (min: min, max: max, interval: interval);
    }
  }
}

/// The gap in days between the date axis's labels, so the first and the last
/// tested day are both labelled: the widest of a quarter, a third or a half of
/// the span that divides it evenly, or the whole span, which labels only the
/// two ends.
int dateLabelInterval(int spanDays) {
  for (final parts in const [4, 3, 2]) {
    if (spanDays >= parts && spanDays % parts == 0) return spanDays ~/ parts;
  }
  return math.max(1, spanDays);
}

/// The calendar days [dates] fall on. A chart is drawn from the second one: a
/// single test is a value, and a line through one day is not a trend.
int testedDays(Iterable<DateTime> dates) => dates
    .map((date) => DateTime(date.year, date.month, date.day))
    .toSet()
    .length;
