import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/hangboard_layout.dart';
import 'package:crimpy/utils/training_expander.dart';

/// How hard a training asks the fingers to pull, told apart at the thresholds
/// Get a Grip's routine card uses. See Krakoer/crimpy#166.
enum IntensityTier {
  /// At or under [TrainingIntensity.lightCeiling] of max.
  light,

  /// Between the two.
  moderate,

  /// From [TrainingIntensity.nearMaxFloor] of max.
  nearMax,
}

/// The heaviest load a training prescribes, as a percentage of the athlete's
/// max force on the grip and hand it is hung with.
class TrainingIntensity {
  static const double lightCeiling = 30;
  static const double nearMaxFloor = 80;

  final double percentOfMax;

  const TrainingIntensity(this.percentOfMax);

  IntensityTier get tier {
    if (percentOfMax <= lightCeiling) return IntensityTier.light;
    if (percentOfMax >= nearMaxFloor) return IntensityTier.nearMax;
    return IntensityTier.moderate;
  }

  /// The number the card spells out, so the tier never rests on colour alone.
  String get label => '${percentOfMax.round()}% max';
}

/// The athlete's latest max force per hand, on each grip and on any grip.
///
/// A builtin's loads are its fraction of the max measured on the grip it hangs,
/// so dividing them by a max from another grip would misstate them. A grip the
/// athlete never tested reads against their latest max on any grip, which is
/// the number a load set as a percentage of max force already resolves against.
class MaxForceReference {
  final Map<(GripPosition, HandSide), double> _byGrip;
  final Map<HandSide, double> _anyGrip;

  const MaxForceReference._(this._byGrip, this._anyGrip);

  static const MaxForceReference none = MaxForceReference._({}, {});

  factory MaxForceReference.fromHistory(List<AssessmentModel> history) {
    final chronological =
        history
            .where((a) => a.assessmentId == BuiltinAssessmentIds.maxForce)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    final byGrip = <(GripPosition, HandSide), double>{};
    final anyGrip = <HandSide, double>{};
    void record(GripPosition? grip, HandSide hand, double? value) {
      if (value == null || value <= 0) return;
      anyGrip[hand] = value;
      if (grip != null) byGrip[(grip, hand)] = value;
    }

    for (final assessment in chronological) {
      record(assessment.gripPosition, HandSide.right, assessment.rightValue);
      record(assessment.gripPosition, HandSide.left, assessment.leftValue);
    }
    return MaxForceReference._(byGrip, anyGrip);
  }

  double? of(HandSide hand, GripPosition? grip) =>
      (grip == null ? null : _byGrip[(grip, hand)]) ?? _anyGrip[hand];
}

/// One hang a hangboard item prescribes, for one hand, with its load resolved
/// the way the run resolves it.
class ResolvedHang {
  /// The hand hung, [HandSide.both] for a two handed hang.
  final HandSide hand;

  /// The grip as stored, null when the item names none. The run hangs such a
  /// rep as a half crimp, which is what [grip] answers.
  final GripPosition? storedGrip;

  final int? edgeSizeMm;

  /// What the coach set, null when the row carries no load.
  final Load? load;

  /// Whether the hang is at maximum effort rather than at a load.
  final bool isMax;

  /// The load in kilograms, null when it has no number to hit.
  final double? kilograms;

  /// The load as a percentage of the athlete's max on this grip and hand, null
  /// when it cannot be read against one.
  final double? percentOfMax;

  const ResolvedHang({
    required this.hand,
    required this.storedGrip,
    required this.edgeSizeMm,
    required this.load,
    required this.isMax,
    required this.kilograms,
    required this.percentOfMax,
  });

  GripPosition get grip => storedGrip ?? GripPosition.halfCrimp;
}

/// The hands a hangboard item hangs, in the order the run plays them.
List<HandSide> hangHands(TrainingItem item) => switch (item.hand) {
  HangboardHand.left => [HandSide.left],
  HangboardHand.right => [HandSide.right],
  final hand
      when HangboardHand.hangsOneHandAtATime(
        hand,
        isRepeater: item.type == TrainingItemType.repeater,
      ) =>
    [HandSide.right, HandSide.left],
  _ => [HandSide.both],
};

/// Every configuration row of a hangboard item, per hand, with its load in
/// kilograms and as a percentage of max. Empty for any other item.
///
/// A max effort hang is 100%, and a load set as a percentage of max force is
/// that percentage whoever reads it. Any other load is resolved to kilograms
/// and divided by the max of the hand and grip it is hung with, which only
/// means something for a hang on one hand: a two handed hang shares its load
/// between them, and the sensor measures neither.
List<ResolvedHang> resolveHangs(
  TrainingItem item, {
  required MaxForceReference maxForce,
  AssessmentResults results = AssessmentResults.none,
  double? bodyweightKg,
}) {
  if (item.type != TrainingItemType.repeater &&
      item.type != TrainingItemType.hangboardRep) {
    return const [];
  }
  final layout = HangboardLayout.of(item);
  final grid = layout.grid;
  final hangs = <ResolvedHang>[];
  for (var row = 0; row < grid.rowCount; row++) {
    final (set, rep) = grid.coordinateOf(row);
    for (final hand in hangHands(item)) {
      final leftHand = hand == HandSide.left;
      final load = layout.load(set, rep, leftHand: leftHand);
      final grip = gripFromStored(layout.grip(set, rep, leftHand: leftHand));
      final isMax = item.loadIsMax || (load?.isMax ?? false);
      final kilograms = isMax
          ? null
          : load?.kilograms(
              bodyweightKg: bodyweightKg,
              results: results,
              handSide: hand,
            );
      hangs.add(
        ResolvedHang(
          hand: hand,
          storedGrip: grip,
          edgeSizeMm: layout.edgeSizeMm(set, rep),
          load: load,
          isMax: isMax,
          kilograms: kilograms,
          percentOfMax: _percentOfMax(
            load,
            isMax: isMax,
            kilograms: kilograms,
            max: hand == HandSide.both ? null : maxForce.of(hand, grip),
            hand: hand,
          ),
        ),
      );
    }
  }
  return hangs;
}

double? _percentOfMax(
  Load? load, {
  required bool isMax,
  required double? kilograms,
  required double? max,
  required HandSide hand,
}) {
  if (isMax) return 100;
  if (load == null) return null;
  if (load.isAssessmentRelative &&
      load.assessmentId == BuiltinAssessmentIds.maxForce) {
    return load.value;
  }
  if (hand == HandSide.both || kilograms == null || max == null) return null;
  return kilograms / max * 100;
}

/// The heaviest hang [training] prescribes as a percentage of max, or null when
/// no hang resolves to one: nothing is hung, the loads are bodyweight, or the
/// athlete has no max to read them against. Only hangboard items count, read
/// as [resolveHangs] reads them.
TrainingIntensity? peakIntensity(
  Training training, {
  required MaxForceReference maxForce,
  AssessmentResults results = AssessmentResults.none,
  double? bodyweightKg,
}) {
  double? peak;
  void visit(TrainingItem item) {
    item.items.forEach(visit);
    final hangs = resolveHangs(
      item,
      maxForce: maxForce,
      results: results,
      bodyweightKg: bodyweightKg,
    );
    for (final hang in hangs) {
      final percent = hang.percentOfMax;
      if (percent == null || percent <= 0) continue;
      if (peak == null || percent > peak!) peak = percent;
    }
  }

  training.items.forEach(visit);
  final resolved = peak;
  return resolved == null ? null : TrainingIntensity(resolved);
}

/// Everything [peakIntensity] reads a training against, gathered once so every
/// card that rates a training rates it the same way.
class TrainingIntensityRater {
  final MaxForceReference maxForce;
  final AssessmentResults results;
  final double? bodyweightKg;

  const TrainingIntensityRater({
    required this.maxForce,
    required this.results,
    this.bodyweightKg,
  });

  factory TrainingIntensityRater.fromHistory(
    List<AssessmentModel> history, {
    double? bodyweightKg,
  }) => TrainingIntensityRater(
    maxForce: MaxForceReference.fromHistory(history),
    results: AssessmentResults.fromHistory(history),
    bodyweightKg: bodyweightKg,
  );

  /// The training's intensity, reading its loads against the assessments it
  /// names as well, since a coach's assessment is known only through them.
  TrainingIntensity? rate(Training training) => peakIntensity(
    training,
    maxForce: maxForce,
    results: resultsFor(training),
    bodyweightKg: bodyweightKg,
  );

  /// The athlete's results, read against the assessments [training] names as
  /// well, which is what resolves its loads, durations and reps.
  AssessmentResults resultsFor(Training training) =>
      results.withDefinitions(training.referencedAssessments);
}
