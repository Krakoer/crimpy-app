import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:flutter/foundation.dart';

List<TrainingExecutionItem> expandTrainingItems(Training training) {
  final out = <TrainingExecutionItem>[];
  for (final item in training.items) {
    _expandItem(item, out);
  }
  return out;
}

void _expandItem(TrainingItem item, List<TrainingExecutionItem> out) {
  switch (item.type) {
    case TrainingItemType.repeater:
      _expandRepeater(item, out);
    case TrainingItemType.hangboardRep:
      _expandHangboardRep(item, out);
    case TrainingItemType.free:
      _expandFree(item, out);
    default:
      debugPrint('TrainingExpander: unsupported item type ${item.type}');
      out.add(ConfirmItem(label: item.sectionTitle ?? item.type.apiValue));
  }
}

void _expandFree(TrainingItem item, List<TrainingExecutionItem> out) {
  final duration = item.duration ?? 0;
  if (duration > 0) {
    out.add(
      TimedItem(
        label: item.freeText ?? 'Free',
        durationSeconds: duration,
        targetLoad: 0,
        handSide: HandSide.both,
        gripPosition: GripPosition.halfCrimp,
        collectSensorData: false,
      ),
    );
  } else {
    out.add(ConfirmItem(label: item.freeText ?? 'Free'));
  }
}

void _expandHangboardRep(TrainingItem item, List<TrainingExecutionItem> out) {
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
      collectSensorData: true,
    ),
  );
  if (resttime > 0) {
    out.add(RestItem(durationSeconds: resttime));
  }
}

void _expandRepeater(TrainingItem item, List<TrainingExecutionItem> out) {
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
            collectSensorData: true,
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
            collectSensorData: true,
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
            collectSensorData: true,
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
            collectSensorData: true,
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
