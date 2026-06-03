import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_model.dart';

/// Expands a Training's items into a flat list of RepModels for execution.
/// Handles repeater and hangboard_rep item types; free/exercise/circuit/section
/// items are logged and skipped until they are fully supported in A6.
List<RepModel> expandTrainingItemsToReps(Training training) {
  final reps = <RepModel>[];
  int globalIndex = 0;

  for (final item in training.items) {
    globalIndex = _expandItem(item, reps, globalIndex);
  }
  return reps;
}

int _expandItem(TrainingItem item, List<RepModel> reps, int startIndex) {
  int idx = startIndex;
  switch (item.type) {
    case TrainingItemType.repeater:
      idx = _expandRepeater(item, reps, idx);
    case TrainingItemType.hangboardRep:
      idx = _expandHangboardRep(item, reps, idx);
    case TrainingItemType.free:
      if ((item.duration ?? 0) > 0) {
        reps.add(
          RepModel(
            durationInSeconds: item.duration!,
            isRest: true,
            handSide: HandSide.both,
            targetWeight: 0,
            index: idx++,
          ),
        );
      }
    default:
      // exercise, circuit, section not yet supported
      break;
  }
  return idx;
}

int _expandRepeater(TrainingItem item, List<RepModel> reps, int startIndex) {
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

  int idx = startIndex;

  if (splitHand) {
    for (int cycle = 0; cycle < cycles; cycle++) {
      for (int rep = 0; rep < repsPerCycle; rep++) {
        final wR = loads.isNotEmpty ? loads[rep % loads.length].value : 0.0;
        reps.add(
          RepModel(
            durationInSeconds: worktime,
            isRest: false,
            handSide: HandSide.right,
            targetWeight: wR,
            index: idx++,
            gripPosition: grip,
          ),
        );
        if (rep < repsPerCycle - 1) {
          reps.add(
            RepModel(
              durationInSeconds: resttime,
              isRest: true,
              handSide: HandSide.right,
              targetWeight: 0,
              index: idx++,
            ),
          );
        }
      }
      final setDuration =
          repsPerCycle * worktime + (repsPerCycle - 1) * resttime;
      final restBetweenHands = ((cycleRest - setDuration) / 2).floor();
      reps.add(
        RepModel(
          durationInSeconds: restBetweenHands,
          isRest: true,
          handSide: HandSide.right,
          targetWeight: 0,
          index: idx++,
        ),
      );
      for (int rep = 0; rep < repsPerCycle; rep++) {
        final wL = leftLoads.isNotEmpty
            ? leftLoads[rep % leftLoads.length].value
            : 0.0;
        reps.add(
          RepModel(
            durationInSeconds: worktime,
            isRest: false,
            handSide: HandSide.left,
            targetWeight: wL,
            index: idx++,
            gripPosition: grip,
          ),
        );
        if (rep < repsPerCycle - 1) {
          reps.add(
            RepModel(
              durationInSeconds: resttime,
              isRest: true,
              handSide: HandSide.left,
              targetWeight: 0,
              index: idx++,
            ),
          );
        }
      }
      if (cycle < cycles - 1) {
        reps.add(
          RepModel(
            durationInSeconds: restBetweenHands,
            isRest: true,
            handSide: HandSide.left,
            targetWeight: 0,
            index: idx++,
          ),
        );
      }
    }
  } else {
    for (int cycle = 0; cycle < cycles; cycle++) {
      for (int rep = 0; rep < repsPerCycle; rep++) {
        final w = loads.isNotEmpty ? loads[rep % loads.length].value : 0.0;
        reps.add(
          RepModel(
            durationInSeconds: worktime,
            isRest: false,
            handSide: HandSide.right,
            targetWeight: w,
            index: idx++,
            gripPosition: grip,
          ),
        );
        reps.add(
          RepModel(
            durationInSeconds: resttime,
            isRest: true,
            handSide: HandSide.right,
            targetWeight: 0,
            index: idx++,
          ),
        );
        reps.add(
          RepModel(
            durationInSeconds: worktime,
            isRest: false,
            handSide: HandSide.left,
            targetWeight: w,
            index: idx++,
            gripPosition: grip,
          ),
        );
        if (rep < repsPerCycle - 1) {
          reps.add(
            RepModel(
              durationInSeconds: resttime,
              isRest: true,
              handSide: HandSide.left,
              targetWeight: 0,
              index: idx++,
            ),
          );
        }
      }
      if (cycle < cycles - 1 && cycleRest > 0) {
        reps.add(
          RepModel(
            durationInSeconds: cycleRest,
            isRest: true,
            handSide: HandSide.right,
            targetWeight: 0,
            index: idx++,
          ),
        );
      }
    }
  }
  return idx;
}

int _expandHangboardRep(
  TrainingItem item,
  List<RepModel> reps,
  int startIndex,
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

  int idx = startIndex;
  reps.add(
    RepModel(
      durationInSeconds: worktime,
      isRest: false,
      handSide: handSide,
      targetWeight: w,
      index: idx++,
      gripPosition: grip,
    ),
  );
  if (resttime > 0) {
    reps.add(
      RepModel(
        durationInSeconds: resttime,
        isRest: true,
        handSide: handSide,
        targetWeight: 0,
        index: idx++,
      ),
    );
  }
  return idx;
}

GripPosition _parseGrip(String? name) => switch (name) {
  'threeFinger' => GripPosition.threeFinger,
  'fullCrimp' => GripPosition.fullCrimp,
  'openHand' => GripPosition.openHand,
  _ => GripPosition.halfCrimp,
};
