import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/hangboard_layout.dart';

/// Expands a training tree into a flat, runnable sequence of execution items.
/// [useSensor] controls whether hangboard/repeater hangs collect live force
/// data (and thus show the gauge); when false the whole training runs without
/// a sensor.
/// [bodyweightKg] resolves loads the coach expressed as a percentage of the
/// bodyweight; those loads fall back to no target when it is unknown.
/// [results] resolves the loads, durations and reps the coach expressed as a
/// percentage of an assessment; without it they all take their fallback.
List<TrainingExecutionItem> expandTrainingItems(
  Training training, {
  bool useSensor = true,
  double? bodyweightKg,
  AssessmentResults results = AssessmentResults.none,
}) {
  final out = <TrainingExecutionItem>[];
  for (final item in training.items) {
    _expandItem(item, out, useSensor, bodyweightKg, results);
  }
  return out;
}

/// Total timed duration of a training in seconds. Self-paced (rep-based) steps
/// contribute 0, so this is an estimate for trainings that mix the two.
int trainingDurationSeconds(Training training) => expandTrainingItems(
  training,
  useSensor: false,
).fold(0, (sum, item) => sum + item.durationSeconds);

void _expandItem(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor,
  double? bodyweightKg,
  AssessmentResults results, {
  String? context,
  String? inheritedComment,
}) {
  // An item without a comment of its own carries the one of the circuit or
  // group it belongs to, so a coach instruction is never lost during the run.
  final comment = _cleanComment(item.comment) ?? inheritedComment;
  switch (item.type) {
    case TrainingItemType.repeater:
      _expandRepeater(
        item,
        out,
        useSensor,
        bodyweightKg,
        results,
        comment: comment,
      );
    case TrainingItemType.hangboardRep:
      _expandHangboardRep(
        item,
        out,
        useSensor,
        bodyweightKg,
        results,
        comment: comment,
      );
    case TrainingItemType.circuit:
      _expandCircuit(
        item,
        out,
        useSensor,
        bodyweightKg,
        results,
        comment: comment,
      );
    case TrainingItemType.group:
      _expandGroup(
        item,
        out,
        useSensor,
        bodyweightKg,
        results,
        context: context,
        comment: comment,
      );
    case TrainingItemType.exercise:
      _expandExercise(
        item,
        out,
        bodyweightKg,
        results,
        context: context,
        comment: comment,
      );
    case TrainingItemType.free:
      _expandFree(item, out, results, context: context, comment: comment);
  }
}

String? _cleanComment(String? comment) {
  final trimmed = comment?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

void _expandGroup(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor,
  double? bodyweightKg,
  AssessmentResults results, {
  String? context,
  String? comment,
}) {
  for (final child in item.items) {
    _expandItem(
      child,
      out,
      useSensor,
      bodyweightKg,
      results,
      context: context,
      inheritedComment: comment,
    );
  }
}

void _expandCircuit(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor,
  double? bodyweightKg,
  AssessmentResults results, {
  String? comment,
}) {
  final cycles = item.cycles ?? 1;
  final cycleRest = item.cycleRestSeconds ?? 0;
  // Rest the circuit puts between its children, on top of whatever rest a child
  // carries of its own. The last child is followed by the cycle rest instead.
  final childRest = item.restSeconds ?? 0;
  for (int cycle = 0; cycle < cycles; cycle++) {
    final context = cycles > 1 ? 'ROUND ${cycle + 1}/$cycles' : null;
    for (final (index, child) in item.items.indexed) {
      _expandItem(
        child,
        out,
        useSensor,
        bodyweightKg,
        results,
        context: context,
        inheritedComment: comment,
      );
      if (index < item.items.length - 1 && childRest > 0) {
        out.add(RestItem(durationSeconds: childRest));
      }
    }
    if (cycle < cycles - 1 && cycleRest > 0) {
      out.add(RestItem(durationSeconds: cycleRest));
    }
  }
}

void _expandExercise(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  double? bodyweightKg,
  AssessmentResults results, {
  String? context,
  String? comment,
}) {
  final duration = item.effectiveDuration(results);
  final name = item.exerciseName ?? 'Exercise';
  if (duration != null) {
    out.add(
      TimedItem(
        label: name,
        durationSeconds: duration,
        targetLoad: 0,
        handSide: HandSide.both,
        gripPosition: GripPosition.halfCrimp,
        collectSensorData: false,
        subtitle: context,
        comment: comment,
      ),
    );
  } else {
    out.add(
      ConfirmItem(
        label: name,
        reps: item.effectiveReps(results),
        load: item.loadLabel(bodyweightKg: bodyweightKg, results: results),
        subtitle: context,
        comment: comment,
      ),
    );
  }
  final rest = item.restSeconds ?? 0;
  if (rest > 0) out.add(RestItem(durationSeconds: rest));
}

void _expandFree(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  AssessmentResults results, {
  String? context,
  String? comment,
}) {
  final duration = item.effectiveDuration(results);
  if (duration != null) {
    out.add(
      TimedItem(
        label: item.freeText ?? 'Free',
        durationSeconds: duration,
        targetLoad: 0,
        handSide: HandSide.both,
        gripPosition: GripPosition.halfCrimp,
        collectSensorData: false,
        subtitle: context,
        comment: comment,
      ),
    );
  } else {
    out.add(
      ConfirmItem(
        label: item.freeText ?? 'Free',
        subtitle: context,
        comment: comment,
      ),
    );
  }
}

void _expandHangboardRep(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor,
  double? bodyweightKg,
  AssessmentResults results, {
  String? comment,
}) {
  final worktime = item.worktimeSeconds ?? 7;
  final resttime = item.restSeconds ?? 3;
  final hand = item.hand ?? HangboardHand.both;
  final layout = HangboardLayout.of(item);
  final leftHand = hand == HangboardHand.left;
  final grip = _parseGrip(layout.grip(0, 0, leftHand: leftHand));
  final handSide = switch (hand) {
    HangboardHand.left => HandSide.left,
    HangboardHand.right => HandSide.right,
    _ => HandSide.both,
  };
  final w =
      layout
          .load(0, 0, leftHand: leftHand)
          ?.kilograms(
            bodyweightKg: bodyweightKg,
            results: results,
            handSide: handSide,
          ) ??
      0.0;

  out.add(
    TimedItem(
      label: 'Hang',
      durationSeconds: worktime,
      targetLoad: w,
      handSide: handSide,
      gripPosition: grip,
      edgeSizeMm: layout.edgeSizeMm(0, 0),
      isHang: true,
      // Only a hang on a single hand passes through the sensor.
      collectSensorData: useSensor && handSide != HandSide.both,
      comment: comment,
    ),
  );
  if (resttime > 0) {
    out.add(RestItem(durationSeconds: resttime));
  }
}

void _expandRepeater(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor,
  double? bodyweightKg,
  AssessmentResults results, {
  String? comment,
}) {
  final cycles = item.cycles ?? 1;
  final repsPerCycle = item.reps ?? 1;
  final worktime = item.worktimeSeconds ?? 7;
  final resttime = item.restSeconds ?? 3;
  final cycleRest = item.cycleRestSeconds ?? 0;
  final hand = item.hand ?? HangboardHand.both;
  final layout = HangboardLayout.of(item);

  String setRep(int cycle, int rep) =>
      'SET ${cycle + 1}/$cycles - REP ${rep + 1}/$repsPerCycle';

  TimedItem hang(int cycle, int rep, HandSide side) {
    final leftHand = side == HandSide.left;
    return TimedItem(
      label: switch (side) {
        HandSide.left => 'Left hang',
        HandSide.right => 'Right hang',
        HandSide.both => 'Hang',
      },
      durationSeconds: worktime,
      targetLoad:
          layout
              .load(cycle, rep, leftHand: leftHand)
              ?.kilograms(
                bodyweightKg: bodyweightKg,
                results: results,
                handSide: side,
              ) ??
          0.0,
      handSide: side,
      gripPosition: _parseGrip(layout.grip(cycle, rep, leftHand: leftHand)),
      edgeSizeMm: layout.edgeSizeMm(cycle, rep),
      isHang: true,
      // Only a hang on a single hand passes through the sensor.
      collectSensorData: useSensor && side != HandSide.both,
      subtitle: setRep(cycle, rep),
      comment: comment,
    );
  }

  switch (hand) {
    case HangboardHand.split:
      _expandSplitRepeater(
        out,
        hang,
        cycles: cycles,
        repsPerCycle: repsPerCycle,
        worktime: worktime,
        resttime: resttime,
        cycleRest: cycleRest,
      );
    case HangboardHand.alternate:
      for (int cycle = 0; cycle < cycles; cycle++) {
        for (int rep = 0; rep < repsPerCycle; rep++) {
          out.add(hang(cycle, rep, HandSide.right));
          if (resttime > 0) out.add(RestItem(durationSeconds: resttime));
          out.add(hang(cycle, rep, HandSide.left));
          if (rep < repsPerCycle - 1 && resttime > 0) {
            out.add(RestItem(durationSeconds: resttime));
          }
        }
        if (cycle < cycles - 1 && cycleRest > 0) {
          out.add(RestItem(durationSeconds: cycleRest));
        }
      }
    default:
      // Both hands together, or a single named hand: one hang per rep.
      final side = switch (hand) {
        HangboardHand.left => HandSide.left,
        HangboardHand.right => HandSide.right,
        _ => HandSide.both,
      };
      for (int cycle = 0; cycle < cycles; cycle++) {
        for (int rep = 0; rep < repsPerCycle; rep++) {
          out.add(hang(cycle, rep, side));
          if (rep < repsPerCycle - 1 && resttime > 0) {
            out.add(RestItem(durationSeconds: resttime));
          }
        }
        if (cycle < cycles - 1 && cycleRest > 0) {
          out.add(RestItem(durationSeconds: cycleRest));
        }
      }
  }
}

/// A split repeater runs every rep of a set on the right hand, rests, then
/// replays the same set on the left.
void _expandSplitRepeater(
  List<TrainingExecutionItem> out,
  TimedItem Function(int cycle, int rep, HandSide side) hang, {
  required int cycles,
  required int repsPerCycle,
  required int worktime,
  required int resttime,
  required int cycleRest,
}) {
  // The configured cycle rest covers both hands plus the gap between them,
  // so a short cycle rest can leave nothing to split.
  final setDuration = repsPerCycle * worktime + (repsPerCycle - 1) * resttime;
  final restBetweenHands = ((cycleRest - setDuration) / 2).floor();

  for (int cycle = 0; cycle < cycles; cycle++) {
    for (final side in [HandSide.right, HandSide.left]) {
      for (int rep = 0; rep < repsPerCycle; rep++) {
        out.add(hang(cycle, rep, side));
        if (rep < repsPerCycle - 1 && resttime > 0) {
          out.add(RestItem(durationSeconds: resttime));
        }
      }
      final lastHandOfLastCycle = side == HandSide.left && cycle == cycles - 1;
      if (!lastHandOfLastCycle && restBetweenHands > 0) {
        out.add(RestItem(durationSeconds: restBetweenHands));
      }
    }
  }
}

/// Grips arrive either as the app's enum names or as the short codes the coach
/// portal stores, so both vocabularies resolve here.
/// Every known code is listed, so an unrecognised one falls to the default
/// rather than hiding among the mapped ones.
GripPosition _parseGrip(String? name) => switch (name) {
  'threeFinger' || '3FD' => GripPosition.threeFinger,
  'fullCrimp' || 'FC' => GripPosition.fullCrimp,
  'openHand' || 'OC' || 'OH' => GripPosition.openHand,
  'halfCrimp' || 'HC' => GripPosition.halfCrimp,
  _ => GripPosition.halfCrimp,
};
