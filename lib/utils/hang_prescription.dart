import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/utils/training_intensity.dart';

/// What a hangboard item asks the athlete to set up before pulling, in words:
/// the hand, the grip and the edge, then the load. Read off [resolveHangs], so
/// the numbers are the ones the run and the intensity badge use. See
/// Krakoer/crimpy#163.
class HangPrescription {
  /// "Right hand - Half Crimp - 20mm".
  final String setup;

  /// "13 kg (65% max)", or one load per hand when they differ:
  /// "Right 13 kg (65% max) - Left 12 kg (60% max)".
  final String load;

  const HangPrescription({required this.setup, required this.load});

  /// Null for an item that hangs nothing.
  static HangPrescription? of(
    TrainingItem item, {
    required MaxForceReference maxForce,
    AssessmentResults results = AssessmentResults.none,
    double? bodyweightKg,
  }) {
    final hangs = resolveHangs(
      item,
      maxForce: maxForce,
      results: results,
      bodyweightKg: bodyweightKg,
    );
    if (hangs.isEmpty) return null;
    final grips = {for (final hang in hangs) hang.grip.displayName};
    return HangPrescription(
      setup: [
        _handsLabel(item),
        grips.join(' / '),
        ?_edgeLabel(hangs),
      ].join(' - '),
      load: _loadLabel(hangs, results),
    );
  }

  static String _handsLabel(TrainingItem item) {
    final hands = hangHands(item);
    if (hands.length > 1) {
      return item.hand == HangboardHand.alternate
          ? 'Alternating hands'
          : 'Right, then left';
    }
    return switch (hands.single) {
      HandSide.right => 'Right hand',
      HandSide.left => 'Left hand',
      HandSide.both => 'Both hands',
    };
  }

  static String? _edgeLabel(List<ResolvedHang> hangs) {
    final edges = [
      for (final hang in hangs)
        if (hang.edgeSizeMm != null) hang.edgeSizeMm!,
    ]..sort();
    if (edges.isEmpty) return null;
    if (edges.first == edges.last) return '${edges.first}mm';
    return '${edges.first}-${edges.last}mm';
  }

  static String _loadLabel(
    List<ResolvedHang> hangs,
    AssessmentResults results,
  ) {
    final perHand = {
      for (final hand in {for (final hang in hangs) hang.hand})
        hand: _describe(
          hangs.where((hang) => hang.hand == hand).toList(),
          results,
        ),
    };
    final distinct = perHand.values.toSet();
    if (distinct.length == 1) return distinct.single;
    return [
      for (final MapEntry(key: hand, value: text) in perHand.entries)
        '${hand == HandSide.left ? 'Left' : 'Right'} $text',
    ].join(' - ');
  }

  /// One hand's load across its rows: a single value when every row agrees, a
  /// range in kilograms when they differ.
  static String _describe(List<ResolvedHang> hangs, AssessmentResults results) {
    final single = {for (final hang in hangs) _single(hang, results)};
    if (single.length == 1) return single.single;
    final kilograms = [for (final hang in hangs) hang.kilograms];
    if (kilograms.contains(null)) return 'Varies by rep';
    final weights = kilograms.cast<double>();
    final range = _range(weights, formatKilograms);
    // One weight read off several percentages is the coach fallback standing
    // in for an assessment not yet done, and a range of percentages beside it
    // would claim a spread the weight does not have.
    if (weights.map(formatKilograms).toSet().length == 1) return '$range kg';
    final source = _sourceRange(hangs, results);
    return source == null ? '$range kg' : '$range kg ($source)';
  }

  /// The percentages a varying load comes from, when every row reads against
  /// the same thing: "20-30% max", "70-80% BW", "70-80% Weighted hang". Null
  /// when the rows mix sources, which a single range cannot say.
  static String? _sourceRange(
    List<ResolvedHang> hangs,
    AssessmentResults results,
  ) {
    final loads = [for (final hang in hangs) hang.load!];
    if (loads.every(_readsAgainstMax)) {
      final percents = [for (final hang in hangs) hang.percentOfMax];
      if (percents.contains(null)) return null;
      return '${_range(percents.cast<double>(), formatPercent)}% max';
    }
    final first = loads.first;
    final shared = loads.every(
      (load) =>
          load.unit == first.unit && load.assessmentId == first.assessmentId,
    );
    if (!shared) return null;
    final name = first.unit == 'percent_bw'
        ? 'BW'
        : results.labelOf(first.assessmentId!);
    final values = [for (final load in loads) load.value];
    return '${_range(values, formatPercent)}% $name';
  }

  static String _single(ResolvedHang hang, AssessmentResults results) {
    final load = hang.load;
    if (hang.isMax) return 'Max effort';
    if (load == null || load.isBodyweight) return 'Bodyweight';
    return loadInKilogramsFirst(
      load,
      kilograms: hang.kilograms,
      percentOfMax: hang.percentOfMax,
      results: results,
    );
  }

  /// Whether the percentage a load is shown with is one of the athlete's max:
  /// a load set in kilograms or in percent of max force, rather than in
  /// percent of the bodyweight or of another assessment.
  static bool _readsAgainstMax(Load load) =>
      load.unit != 'percent_bw' &&
      (!load.isAssessmentRelative ||
          load.assessmentId == BuiltinAssessmentIds.maxForce);

  static String _range(List<double> values, String Function(double) format) {
    final sorted = [...values]..sort();
    final low = format(sorted.first);
    final high = format(sorted.last);
    return low == high ? low : '$low-$high';
  }
}

/// A load, kilograms first and then the percentage they come from:
/// "13 kg (65% max)", "56 kg (80% BW)", "20 kg (80% Weighted hang)". The
/// percentage the coach set wins, since it is where the kilograms come from; a
/// load set in kilograms reads against [percentOfMax] when there is one. A load
/// with no kilograms to hit yet says the percentage alone.
String loadInKilogramsFirst(
  Load load, {
  required double? kilograms,
  double? percentOfMax,
  AssessmentResults results = AssessmentResults.none,
}) {
  final source = load.unit == 'percent_bw'
      ? '${formatPercent(load.value)}% BW'
      : load.isAssessmentRelative
      ? load.assessmentId == BuiltinAssessmentIds.maxForce
            ? '${formatPercent(load.value)}% max'
            : '${formatPercent(load.value)}% ${results.labelOf(load.assessmentId!)}'
      : percentOfMax != null
      ? '${formatPercent(percentOfMax)}% max'
      : null;
  if (kilograms == null) return source ?? load.label(results: results);
  final weight = '${formatKilograms(kilograms)} kg';
  return source == null ? weight : '$weight ($source)';
}

/// A percentage as the prescription writes it, to the whole percent.
String formatPercent(double value) => value.round().toString();
