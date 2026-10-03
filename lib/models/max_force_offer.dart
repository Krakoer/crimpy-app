import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';

/// The peak the sensor measured over one hang, with where it was pulled. It is
/// what a run hands its review so a pull above the Max Force on file can be
/// offered as a new one.
class MeasuredPull {
  final HandSide hand;
  final GripPosition gripPosition;
  final int? edgeSizeMm;
  final double peakKg;

  const MeasuredPull({
    required this.hand,
    required this.gripPosition,
    required this.edgeSizeMm,
    required this.peakKg,
  });

  factory MeasuredPull.fromJson(Map<String, dynamic> json) => MeasuredPull(
    hand: handSideFromApi(json['hand'] as String),
    gripPosition: enumFromIndex(
      GripPosition.values,
      json['grip_position'] as num?,
      GripPosition.halfCrimp,
    ),
    edgeSizeMm: (json['edge_size_mm'] as num?)?.toInt(),
    peakKg: (json['peak_kg'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'hand': hand.apiValue,
    'grip_position': gripPosition.index,
    if (edgeSizeMm != null) 'edge_size_mm': edgeSizeMm,
    'peak_kg': peakKg,
  };
}

/// A pull that beat the athlete's Max Force on file for its hand and grip,
/// offered on a review screen as a new one. Never saved without the athlete
/// saying so.
class MaxForceOffer {
  final HandSide hand;
  final GripPosition gripPosition;
  final double peakKg;
  final double onFileKg;

  const MaxForceOffer({
    required this.hand,
    required this.gripPosition,
    required this.peakKg,
    required this.onFileKg,
  });

  /// The result the offer saves, on the one hand it was pulled with.
  AssessmentResultModel toResult(AssessmentOrigin origin) =>
      AssessmentResultModel(
        assessmentId: BuiltinAssessmentIds.maxForce,
        rightValue: hand == HandSide.right ? peakKg : null,
        leftValue: hand == HandSide.left ? peakKg : null,
        gripPosition: gripPosition,
        origin: origin,
      );

  @override
  bool operator ==(Object other) =>
      other is MaxForceOffer &&
      other.hand == hand &&
      other.gripPosition == gripPosition &&
      other.peakKg == peakKg &&
      other.onFileKg == onFileKg;

  @override
  int get hashCode => Object.hash(hand, gripPosition, peakKg, onFileKg);

  /// The offers a run's pulls make against the Max Force history, oldest
  /// result first as the repositories return it.
  ///
  /// A pull stands for a Max Force only when it was measured the way the test
  /// measures one: a single hand, on the test's edge. A two handed hang is not
  /// a one hand max whatever it reads.
  ///
  /// It has to beat the latest result for the same hand and grip, by what the
  /// screen can show ("40.0 kg, up from 40.0 kg" would be no news). That is
  /// what it is a new max of, what the card says it is up from, and, since
  /// percentage loads resolve against the max of their own grip (see
  /// [AssessmentResults.value]), what every percent of max hang on that grip
  /// reads against: saving it can only make those harder. A grip the athlete
  /// never tested reads the latest result on any grip instead, so saving a pull
  /// can still move those loads, either way. That is the trade-off
  /// Krakoer/crimpy#182 settled on: comparing against the same grip alone.
  ///
  /// With nothing on file for the hand and grip there is nothing to beat, and
  /// no offer.
  ///
  /// One offer per hand and grip, the hardest pull of the run.
  static List<MaxForceOffer> fromPulls(
    Iterable<MeasuredPull> pulls,
    List<AssessmentModel> maxForceHistory,
  ) {
    final hardest = <(HandSide, GripPosition), double>{};
    for (final pull in pulls) {
      if (pull.hand == HandSide.both) continue;
      if (pull.edgeSizeMm != BuiltinAssessmentIds.maxForceEdgeSizeMm) continue;
      final key = (pull.hand, pull.gripPosition);
      final best = hardest[key];
      if (best == null || pull.peakKg > best) hardest[key] = pull.peakKg;
    }

    final offers = <MaxForceOffer>[];
    for (final MapEntry(key: (hand, grip), value: peak) in hardest.entries) {
      final onFile = latestOnFile(maxForceHistory, hand, grip);
      if (onFile == null || _tenths(peak) <= _tenths(onFile)) continue;
      offers.add(
        MaxForceOffer(
          hand: hand,
          gripPosition: grip,
          peakKg: peak,
          onFileKg: onFile,
        ),
      );
    }
    offers.sort((a, b) {
      final byGrip = a.gripPosition.index.compareTo(b.gripPosition.index);
      if (byGrip != 0) return byGrip;
      // Left before right, as the per hand columns of the history read.
      return b.hand.index.compareTo(a.hand.index);
    });
    return offers;
  }

  /// The latest Max Force on file for [hand] and [grip], or null when there is
  /// none.
  static double? latestOnFile(
    List<AssessmentModel> history,
    HandSide hand,
    GripPosition grip,
  ) {
    for (final result in history.reversed) {
      if (result.assessmentId != BuiltinAssessmentIds.maxForce) continue;
      if (result.gripPosition != grip) continue;
      final value = hand == HandSide.right
          ? result.rightValue
          : result.leftValue;
      if (value != null) return value;
    }
    return null;
  }

  static int _tenths(double kg) => (kg * 10).round();
}
