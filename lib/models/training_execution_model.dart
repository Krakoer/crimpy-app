import 'package:crimpy/models/common.dart';

/// Where a step sits inside an emom: which block it is a round of, and which
/// round. Every step of the block carries it, so the run can close each round
/// back on the clock and can end the block at the round the athlete dropped out
/// of. Where a round starts is read off a change in these two rather than
/// stamped on a step, so nothing has to be copied onto the opening step.
class EmomPosition {
  /// Identifies this run of the block, unique within the run. The steps of one
  /// emom are told from those of another by it, which an item id cannot do:
  /// a block inside a circuit is laid down once per cycle, and an item that was
  /// never saved has no id at all.
  final String blockKey;

  /// The emom item the round belongs to, which is what a recorded round count
  /// is keyed to. Null for a block expanded from an item that was never saved,
  /// which nothing can record against.
  final String? itemId;

  /// Which pass through the emom item this block is, from 0.
  final int occurrence;

  /// Round index from 0.
  final int round;

  const EmomPosition({
    required this.blockKey,
    required this.itemId,
    required this.occurrence,
    required this.round,
  });

  /// Whether [other] belongs to a different round than this one, which is what
  /// a run watches for to know a round has just started.
  bool isSameRoundAs(EmomPosition? other) =>
      other != null && other.blockKey == blockKey && other.round == round;
}

sealed class TrainingExecutionItem {
  /// Id of the training item this step was expanded from, carried onto the rep
  /// it records so a played session can be read block by block instead of as
  /// one pooled list. Null for a step built outside a training.
  final String? trainingItemId;

  /// Which pass through [trainingItemId] this step belongs to, from 0. A block
  /// that repeats plays the same item several times, and a count recorded
  /// against it has to say which of those passes it answers.
  final int occurrence;

  /// Set when the step is part of an emom round, null otherwise.
  final EmomPosition? emom;

  const TrainingExecutionItem({
    this.trainingItemId,
    this.occurrence = 0,
    this.emom,
  });

  int get durationSeconds;
}

final class TimedItem extends TrainingExecutionItem {
  final String label;
  @override
  final int durationSeconds;
  final double targetLoad;
  final HandSide handSide;
  final GripPosition gripPosition;
  final bool collectSensorData;

  /// Edge depth prescribed for this hang, when the coach set one.
  final int? edgeSizeMm;

  /// Whether the step is a hangboard hang, so its grip and edge are a real
  /// prescription rather than the filler a duration exercise carries.
  final bool isHang;

  /// Position context shown during the step, e.g. "SET 2/3 - REP 4/6" or
  /// "ROUND 1/3".
  final String? subtitle;

  /// Optional coach comment shown to the athlete during the step.
  final String? comment;

  /// Whether the step measured the athlete. Collecting sensor data is decided
  /// when the training is expanded, from the sensor the run started with, so a
  /// step still measures nothing when the sensor drops before it runs and
  /// [sensorDelivered] stays false for the rest of the session.
  bool measured({required bool sensorDelivered}) =>
      collectSensorData && sensorDelivered;

  /// Target to store on the rep this step records. A step that measured nothing
  /// carries no target: stored with one, it would read as a missed target to
  /// every screen that grades a run.
  double recordedTargetLoad({required bool sensorDelivered}) =>
      measured(sensorDelivered: sensorDelivered) ? targetLoad : 0;

  /// Whether the step prescribed a load the run failed to measure. It records
  /// the same empty target as a step nothing was meant to measure, so the rep
  /// carries this to say the target was lost rather than never given: a run is
  /// graded on the reps it could measure, and this one was performed blind.
  bool targetUnmeasured({required bool sensorDelivered}) =>
      collectSensorData && targetLoad > 0 && !sensorDelivered;

  const TimedItem({
    required this.label,
    required this.durationSeconds,
    required this.targetLoad,
    required this.handSide,
    required this.gripPosition,
    required this.collectSensorData,
    this.edgeSizeMm,
    this.isHang = false,
    this.subtitle,
    this.comment,
    super.trainingItemId,
    super.occurrence,
    super.emom,
  });
}

base class RestItem extends TrainingExecutionItem {
  @override
  final int durationSeconds;

  const RestItem({
    required this.durationSeconds,
    super.trainingItemId,
    super.occurrence,
    super.emom,
  });
}

/// The rest that closes an emom round. It runs to the mark on the clock the
/// next round starts on rather than for a fixed length, so a round the athlete
/// worked through quickly rests for longer and the block never drifts.
///
/// [durationSeconds] is what is left of the interval once the timed work of the
/// round is taken out, which is the honest length for a preview and for a total.
/// The run shortens it by however long the self paced work actually took, which
/// is only known once it has been done.
final class IntervalRestItem extends RestItem {
  /// The whole interval the round started on.
  final int intervalSeconds;

  const IntervalRestItem({
    required super.durationSeconds,
    required this.intervalSeconds,
    super.trainingItemId,
    super.occurrence,
    super.emom,
  });
}

/// A self-paced step the user completes manually (e.g. a rep-based exercise or
/// a free item without a duration). The user taps "Done" to advance.
final class ConfirmItem extends TrainingExecutionItem {
  final String label;
  final String? instructions;
  final int? reps;
  final String? load;

  /// Whether the rep count was left open, which is an AMRAP. The step
  /// prescribes no number, so finishing it asks the athlete how many they
  /// managed and records the answer against the item.
  final bool repsAreOpen;

  /// Position context shown during the step, e.g. "ROUND 1/3".
  final String? subtitle;

  /// Optional coach comment shown to the athlete during the step.
  final String? comment;

  const ConfirmItem({
    required this.label,
    this.instructions,
    this.reps,
    this.load,
    this.repsAreOpen = false,
    this.subtitle,
    this.comment,
    super.trainingItemId,
    super.occurrence,
    super.emom,
  });

  @override
  int get durationSeconds => 0;
}
