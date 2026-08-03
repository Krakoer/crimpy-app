import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_model.dart';

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
}) {
  switch (item.type) {
    case TrainingItemType.repeater:
      _expandRepeater(item, out, useSensor);
    case TrainingItemType.hangboardRep:
      _expandHangboardRep(item, out, useSensor);
    case TrainingItemType.circuit:
      _expandCircuit(item, out, useSensor);
    case TrainingItemType.group:
      _expandGroup(item, out, useSensor, context: context);
    case TrainingItemType.exercise:
      _expandExercise(item, out, context: context);
    case TrainingItemType.free:
      _expandFree(item, out, context: context);
  }
}

void _expandGroup(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor, {
  String? context,
}) {
  for (final child in item.items) {
    _expandItem(child, out, useSensor, context: context);
  }
}

void _expandCircuit(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor,
) {
  final cycles = item.cycles ?? 1;
  final cycleRest = item.cycleRestSeconds ?? 0;
  for (int cycle = 0; cycle < cycles; cycle++) {
    final context = cycles > 1 ? 'ROUND ${cycle + 1}/$cycles' : null;
    for (final child in item.items) {
      _expandItem(child, out, useSensor, context: context);
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
        comment: item.comment,
      ),
    );
  } else {
    out.add(
      ConfirmItem(
        label: name,
        reps: item.effectiveReps,
        load: item.loadLabel,
        subtitle: context,
        comment: item.comment,
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
      ),
    );
  } else {
    out.add(ConfirmItem(label: item.freeText ?? 'Free', subtitle: context));
  }
}

void _expandHangboardRep(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  bool useSensor,
) {
  final worktime = item.worktimeSeconds ?? 7;
  final resttime = item.restSeconds ?? 3;
  final hand = item.hand ?? 'both';
  final grip = _parseGrip(item.handPositions?.firstOrNull);
  final w = item.loads?.firstOrNull?.value ?? 0.0;
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
      collectSensorData: useSensor,
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
) {
  final cycles = item.cycles ?? 1;
  final repsPerCycle = item.reps ?? 1;
  final worktime = item.worktimeSeconds ?? 7;
  final resttime = item.restSeconds ?? 3;
  final cycleRest = item.cycleRestSeconds ?? 0;
  final hand = item.hand ?? 'both';
  final splitHand = hand == 'split';
  final grip = _parseGrip(item.handPositions?.firstOrNull);
  final loads = item.loads ?? [];
  final leftLoads = item.leftLoads ?? [];

  String setRep(int cycle, int rep) =>
      'SET ${cycle + 1}/$cycles - REP ${rep + 1}/$repsPerCycle';

  if (splitHand) {
    for (int cycle = 0; cycle < cycles; cycle++) {
      for (int rep = 0; rep < repsPerCycle; rep++) {
        final wR = loads.isNotEmpty ? loads[rep % loads.length].value : 0.0;
        out.add(
          TimedItem(
            label: 'Right hang',
            durationSeconds: worktime,
            targetLoad: wR,
            handSide: HandSide.right,
            gripPosition: grip,
            collectSensorData: useSensor,
            subtitle: setRep(cycle, rep),
          ),
        );
        if (rep < repsPerCycle - 1) {
          out.add(RestItem(durationSeconds: resttime));
        }
      }
      final setDuration =
          repsPerCycle * worktime + (repsPerCycle - 1) * resttime;
      final restBetweenHands = ((cycleRest - setDuration) / 2).floor();
      out.add(RestItem(durationSeconds: restBetweenHands));
      for (int rep = 0; rep < repsPerCycle; rep++) {
        final wL = leftLoads.isNotEmpty
            ? leftLoads[rep % leftLoads.length].value
            : 0.0;
        out.add(
          TimedItem(
            label: 'Left hang',
            durationSeconds: worktime,
            targetLoad: wL,
            handSide: HandSide.left,
            gripPosition: grip,
            collectSensorData: useSensor,
            subtitle: setRep(cycle, rep),
          ),
        );
        if (rep < repsPerCycle - 1) {
          out.add(RestItem(durationSeconds: resttime));
        }
      }
      if (cycle < cycles - 1) {
        out.add(RestItem(durationSeconds: restBetweenHands));
      }
    }
  } else {
    for (int cycle = 0; cycle < cycles; cycle++) {
      for (int rep = 0; rep < repsPerCycle; rep++) {
        final w = loads.isNotEmpty ? loads[rep % loads.length].value : 0.0;
        out.add(
          TimedItem(
            label: 'Right hang',
            durationSeconds: worktime,
            targetLoad: w,
            handSide: HandSide.right,
            gripPosition: grip,
            collectSensorData: useSensor,
            subtitle: setRep(cycle, rep),
          ),
        );
        out.add(RestItem(durationSeconds: resttime));
        out.add(
          TimedItem(
            label: 'Left hang',
            durationSeconds: worktime,
            targetLoad: w,
            handSide: HandSide.left,
            gripPosition: grip,
            collectSensorData: useSensor,
            subtitle: setRep(cycle, rep),
          ),
        );
        if (rep < repsPerCycle - 1) {
          out.add(RestItem(durationSeconds: resttime));
        }
      }
      if (cycle < cycles - 1 && cycleRest > 0) {
        out.add(RestItem(durationSeconds: cycleRest));
      }
    }
  }
}

GripPosition _parseGrip(String? name) => switch (name) {
  'threeFinger' => GripPosition.threeFinger,
  'fullCrimp' => GripPosition.fullCrimp,
  'openHand' => GripPosition.openHand,
  _ => GripPosition.halfCrimp,
};
