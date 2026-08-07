import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/hangboard_layout.dart';

/// Expands a training tree into a flat, runnable sequence of execution items.
/// [useSensor] controls whether hangboard/repeater hangs collect live force
/// data (and thus show the gauge); when false the whole training runs without
/// a sensor.
List<TrainingExecutionItem> expandTrainingItems(
  Training training, {
  bool useSensor = true,
}) {
  final out = <TrainingExecutionItem>[];
  for (final item in training.items) {
    _expandItem(item, out, useSensor);
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
  bool useSensor, {
  String? context,
  String? inheritedComment,
}) {
  // An item without a comment of its own carries the one of the circuit or
  // group it belongs to, so a coach instruction is never lost during the run.
  final comment = _cleanComment(item.comment) ?? inheritedComment;
  switch (item.type) {
    case TrainingItemType.repeater:
      _expandRepeater(item, out, useSensor, comment: comment);
    case TrainingItemType.hangboardRep:
      _expandHangboardRep(item, out, useSensor, comment: comment);
    case TrainingItemType.circuit:
      _expandCircuit(item, out, useSensor, comment: comment);
    case TrainingItemType.group:
      _expandGroup(item, out, useSensor, context: context, comment: comment);
    case TrainingItemType.exercise:
      _expandExercise(item, out, context: context, comment: comment);
    case TrainingItemType.free:
      _expandFree(item, out, context: context, comment: comment);
  }
}

String? _cleanComment(String? comment) {
  final trimmed = comment?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

void _expandGroup(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor, {
  String? context,
  String? comment,
}) {
  for (final child in item.items) {
    _expandItem(
      child,
      out,
      useSensor,
      context: context,
      inheritedComment: comment,
    );
  }
}

void _expandCircuit(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor, {
  String? comment,
}) {
  final cycles = item.cycles ?? 1;
  final cycleRest = item.cycleRestSeconds ?? 0;
  for (int cycle = 0; cycle < cycles; cycle++) {
    final context = cycles > 1 ? 'ROUND ${cycle + 1}/$cycles' : null;
    for (final child in item.items) {
      _expandItem(
        child,
        out,
        useSensor,
        context: context,
        inheritedComment: comment,
      );
    }
    if (cycle < cycles - 1 && cycleRest > 0) {
      out.add(RestItem(durationSeconds: cycleRest));
    }
  }
}

void _expandExercise(
  TrainingItem item,
  List<TrainingExecutionItem> out, {
  String? context,
  String? comment,
}) {
  final duration = item.effectiveDuration;
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
        reps: item.effectiveReps,
        load: item.loadLabel,
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
  List<TrainingExecutionItem> out, {
  String? context,
  String? comment,
}) {
  final duration = item.effectiveDuration;
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
  bool useSensor, {
  String? comment,
}) {
  final worktime = item.worktimeSeconds ?? 7;
  final resttime = item.restSeconds ?? 3;
  final hand = item.hand ?? 'both';
  final layout = HangboardLayout.of(item);
  final leftHand = hand == 'left';
  final grip = _parseGrip(layout.grip(0, 0, leftHand: leftHand));
  final w = layout.load(0, 0, leftHand: leftHand)?.value ?? 0.0;
  final handSide = switch (hand) {
    'left' => HandSide.left,
    'right' => HandSide.right,
    _ => HandSide.both,
  };

  out.add(
    TimedItem(
      label: 'Hang',
      durationSeconds: worktime,
      targetLoad: w,
      handSide: handSide,
      gripPosition: grip,
      edgeSizeMm: layout.edgeSizeMm(0, 0),
      collectSensorData: useSensor,
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
  bool useSensor, {
  String? comment,
}) {
  final cycles = item.cycles ?? 1;
  final repsPerCycle = item.reps ?? 1;
  final worktime = item.worktimeSeconds ?? 7;
  final resttime = item.restSeconds ?? 3;
  final cycleRest = item.cycleRestSeconds ?? 0;
  final hand = item.hand ?? 'both';
  final splitHand = hand == 'split';
  final layout = HangboardLayout.of(item);

  String setRep(int cycle, int rep) =>
      'SET ${cycle + 1}/$cycles - REP ${rep + 1}/$repsPerCycle';

  if (splitHand) {
    for (int cycle = 0; cycle < cycles; cycle++) {
      for (int rep = 0; rep < repsPerCycle; rep++) {
        out.add(
          TimedItem(
            label: 'Right hang',
            durationSeconds: worktime,
            targetLoad: layout.load(cycle, rep, leftHand: false)?.value ?? 0.0,
            handSide: HandSide.right,
            gripPosition: _parseGrip(layout.grip(cycle, rep, leftHand: false)),
            edgeSizeMm: layout.edgeSizeMm(cycle, rep),
            collectSensorData: useSensor,
            subtitle: setRep(cycle, rep),
            comment: comment,
          ),
        );
        if (rep < repsPerCycle - 1 && resttime > 0) {
          out.add(RestItem(durationSeconds: resttime));
        }
      }
      // The configured cycle rest covers both hands plus the gap between them,
      // so a short cycle rest can leave nothing to split.
      final setDuration =
          repsPerCycle * worktime + (repsPerCycle - 1) * resttime;
      final restBetweenHands = ((cycleRest - setDuration) / 2).floor();
      if (restBetweenHands > 0) {
        out.add(RestItem(durationSeconds: restBetweenHands));
      }
      for (int rep = 0; rep < repsPerCycle; rep++) {
        out.add(
          TimedItem(
            label: 'Left hang',
            durationSeconds: worktime,
            targetLoad: layout.load(cycle, rep, leftHand: true)?.value ?? 0.0,
            handSide: HandSide.left,
            gripPosition: _parseGrip(layout.grip(cycle, rep, leftHand: true)),
            edgeSizeMm: layout.edgeSizeMm(cycle, rep),
            collectSensorData: useSensor,
            subtitle: setRep(cycle, rep),
            comment: comment,
          ),
        );
        if (rep < repsPerCycle - 1 && resttime > 0) {
          out.add(RestItem(durationSeconds: resttime));
        }
      }
      if (cycle < cycles - 1 && restBetweenHands > 0) {
        out.add(RestItem(durationSeconds: restBetweenHands));
      }
    }
  } else {
    for (int cycle = 0; cycle < cycles; cycle++) {
      for (int rep = 0; rep < repsPerCycle; rep++) {
        final w = layout.load(cycle, rep, leftHand: false)?.value ?? 0.0;
        final edge = layout.edgeSizeMm(cycle, rep);
        out.add(
          TimedItem(
            label: 'Right hang',
            durationSeconds: worktime,
            targetLoad: w,
            handSide: HandSide.right,
            gripPosition: _parseGrip(layout.grip(cycle, rep, leftHand: false)),
            edgeSizeMm: edge,
            collectSensorData: useSensor,
            subtitle: setRep(cycle, rep),
            comment: comment,
          ),
        );
        if (resttime > 0) {
          out.add(RestItem(durationSeconds: resttime));
        }
        out.add(
          TimedItem(
            label: 'Left hang',
            durationSeconds: worktime,
            targetLoad: w,
            handSide: HandSide.left,
            gripPosition: _parseGrip(layout.grip(cycle, rep, leftHand: true)),
            edgeSizeMm: edge,
            collectSensorData: useSensor,
            subtitle: setRep(cycle, rep),
            comment: comment,
          ),
        );
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

/// Grips arrive either as the app's enum names or as the short codes the coach
/// portal stores, so both vocabularies resolve here.
GripPosition _parseGrip(String? name) => switch (name) {
  'threeFinger' || '3FD' => GripPosition.threeFinger,
  'fullCrimp' || 'FC' => GripPosition.fullCrimp,
  'openHand' || 'OC' || 'OH' => GripPosition.openHand,
  _ => GripPosition.halfCrimp,
};
