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

/// The heaviest hang [training] prescribes as a percentage of max, or null when
/// no hang resolves to one: nothing is hung, the loads are bodyweight, or the
/// athlete has no max to read them against.
///
/// Only hangboard items count. A max effort hang is 100%, and a load set as a
/// percentage of max force is that percentage whoever reads it. Any other load
/// is resolved to kilograms and divided by the max of the hand and grip it is
/// hung with, which only means something for a hang on one hand: a two handed
/// hang shares its load between them, and the sensor measures neither.
TrainingIntensity? peakIntensity(
  Training training, {
  required MaxForceReference maxForce,
  AssessmentResults results = AssessmentResults.none,
  double? bodyweightKg,
}) {
  double? peak;
  void consider(double? percent) {
    if (percent == null || percent <= 0) return;
    if (peak == null || percent > peak!) peak = percent;
  }

  double? percentOfMax(Load? load, HandSide hand, GripPosition? grip) {
    if (load == null) return null;
    if (load.isMax) return 100;
    if (load.isAssessmentRelative &&
        load.assessmentId == BuiltinAssessmentIds.maxForce) {
      return load.value;
    }
    if (hand == HandSide.both) return null;
    final kilograms = load.kilograms(
      bodyweightKg: bodyweightKg,
      results: results,
      handSide: hand,
    );
    final max = maxForce.of(hand, grip);
    if (kilograms == null || max == null) return null;
    return kilograms / max * 100;
  }

  void visit(TrainingItem item) {
    item.items.forEach(visit);
    final isRepeater = item.type == TrainingItemType.repeater;
    if (!isRepeater && item.type != TrainingItemType.hangboardRep) return;
    if (item.loadIsMax) {
      consider(100);
      return;
    }
    final hands = switch (item.hand) {
      HangboardHand.left => [HandSide.left],
      HangboardHand.right => [HandSide.right],
      final hand
          when HangboardHand.hangsOneHandAtATime(
            hand,
            isRepeater: isRepeater,
          ) =>
        [HandSide.right, HandSide.left],
      _ => [HandSide.both],
    };
    final layout = HangboardLayout.of(item);
    final grid = layout.grid;
    for (var row = 0; row < grid.rowCount; row++) {
      final (set, rep) = grid.coordinateOf(row);
      for (final hand in hands) {
        final leftHand = hand == HandSide.left;
        consider(
          percentOfMax(
            layout.load(set, rep, leftHand: leftHand),
            hand,
            gripFromStored(layout.grip(set, rep, leftHand: leftHand)),
          ),
        );
      }
    }
  }

  training.items.forEach(visit);
  final resolved = peak;
  return resolved == null ? null : TrainingIntensity(resolved);
}
