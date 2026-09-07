import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/hangboard_layout.dart';

/// The link a step carries back to the item it came from. Items that were never
/// saved carry a blank id - builtin trainings and freshly duplicated items -
/// and "no item" has one representation here, the null the column documents.
String? _linkId(TrainingItem item) => item.id.isEmpty ? null : item.id;

/// What every expander needs and none of them owns: how the loads resolve, and
/// how many passes through each item have been laid down so far.
class _ExpandContext {
  final bool useSensor;
  final double? bodyweightKg;
  final AssessmentResults results;

  /// Passes already laid down per item id. Blocks nest, so a global count per
  /// item is the only one that numbers the passes of an exercise inside an emom
  /// inside a circuit the way the run actually plays them.
  final Map<String, int> _passes = {};

  _ExpandContext({
    required this.useSensor,
    required this.bodyweightKg,
    required this.results,
  });

  /// Claims the next pass through [item], from 0.
  int nextOccurrence(TrainingItem item) {
    final id = _linkId(item) ?? '';
    final next = _passes[id] ?? 0;
    _passes[id] = next + 1;
    return next;
  }
}

/// Where a step being laid down sits: the set or round label it shows, the
/// coach comment it inherits, the pass through its item, and the emom round it
/// belongs to when it is inside one.
class _StepPlacement {
  final String? context;
  final String? comment;
  final int occurrence;
  final EmomPosition? emom;

  const _StepPlacement({
    this.context,
    this.comment,
    this.occurrence = 0,
    this.emom,
  });
}

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
  final context = _ExpandContext(
    useSensor: useSensor,
    bodyweightKg: bodyweightKg,
    results: results,
  );
  final out = <TrainingExecutionItem>[];
  for (final item in training.items) {
    _expandItem(item, out, context, const _StepPlacement());
  }
  return out;
}

/// Total timed duration of a training in seconds. Self-paced (rep-based) steps
/// contribute 0, so this is an estimate for trainings that mix the two.
///
/// [results] resolves a duration the coach set as a percentage of an assessment.
/// Left out, such a step falls back to the coach's number, which is what a
/// standalone training does since it is read outside any athlete's results.
int trainingDurationSeconds(
  Training training, {
  AssessmentResults results = AssessmentResults.none,
}) => expandTrainingItems(
  training,
  useSensor: false,
  results: results,
).fold(0, (sum, item) => sum + item.durationSeconds);

void _expandItem(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  _ExpandContext ctx,
  _StepPlacement placement,
) {
  // An item without a comment of its own carries the one of the circuit or
  // group it belongs to, so a coach instruction is never lost during the run.
  final comment = _cleanComment(item.comment) ?? placement.comment;
  final at = _StepPlacement(
    context: placement.context,
    comment: comment,
    occurrence: ctx.nextOccurrence(item),
    emom: placement.emom,
  );
  switch (item.type) {
    case TrainingItemType.repeater:
      _expandRepeater(item, out, ctx, at);
    case TrainingItemType.hangboardRep:
      _expandHangboardRep(item, out, ctx, at);
    case TrainingItemType.circuit:
      _expandCircuit(item, out, ctx, at);
    case TrainingItemType.emom:
      _expandEmom(item, out, ctx, at);
    case TrainingItemType.group:
      _expandGroup(item, out, ctx, at);
    case TrainingItemType.exercise:
      _expandExercise(item, out, ctx, at);
    case TrainingItemType.free:
      _expandFree(item, out, ctx, at);
  }
}

String? _cleanComment(String? comment) {
  final trimmed = comment?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

void _expandGroup(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  _ExpandContext ctx,
  _StepPlacement at,
) {
  for (final child in item.items) {
    _expandItem(child, out, ctx, at);
  }
}

void _expandCircuit(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  _ExpandContext ctx,
  _StepPlacement at,
) {
  final cycles = item.cycles ?? 1;
  final cycleRest = item.cycleRestSeconds ?? 0;
  final childRest = item.restSeconds ?? 0;
  for (int cycle = 0; cycle < cycles; cycle++) {
    final inCycle = _StepPlacement(
      context: cycles > 1 ? 'ROUND ${cycle + 1}/$cycles' : null,
      comment: at.comment,
      emom: at.emom,
    );
    for (final (index, child) in item.items.indexed) {
      final lengthBeforeChild = out.length;
      _expandItem(child, out, ctx, inCycle);
      final isLastChild = index == item.items.length - 1;
      final rest = isLastChild
          ? (cycle < cycles - 1 ? cycleRest : 0)
          : childRest;
      // A rest the circuit sets stands for the whole gap it names, so the rest
      // the child ends on gives way to it rather than the two adding up and
      // running as two countdowns. Without one, the child keeps its own.
      if (rest > 0) {
        final childEndsOnRest =
            out.length > lengthBeforeChild && out.last is RestItem;
        if (childEndsOnRest) out.removeLast();
        out.add(
          RestItem(
            durationSeconds: rest,
            trainingItemId: _linkId(item),
            occurrence: at.occurrence,
            emom: at.emom,
          ),
        );
      }
    }
  }
}

/// Lays out an emom: every round runs its items back to back, then rests for
/// whatever is left of the interval, so the round after it starts on the clock
/// however fast the one before it went.
void _expandEmom(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  _ExpandContext ctx,
  _StepPlacement at,
) {
  final rounds = item.cycles ?? 1;
  final interval = item.intervalSeconds ?? 60;
  final itemId = _linkId(item);
  final blockKey = '${itemId ?? 'emom'}#${at.occurrence}';

  for (int round = 0; round < rounds; round++) {
    final position = EmomPosition(
      blockKey: blockKey,
      itemId: itemId,
      occurrence: at.occurrence,
      round: round,
    );
    final lengthBeforeRound = out.length;
    final inRound = _StepPlacement(
      context: 'ROUND ${round + 1}/$rounds',
      comment: at.comment,
      emom: position,
    );
    for (final child in item.items) {
      _expandItem(child, out, ctx, inRound);
    }

    // The rest is what is left of the interval once the timed work is taken
    // out. Self paced work counts for nothing here, which is why the run
    // measures the rest back to the step the round opened on instead.
    final worked = out
        .skip(lengthBeforeRound)
        .fold(0, (sum, step) => sum + step.durationSeconds);
    out.add(
      IntervalRestItem(
        durationSeconds: (interval - worked).clamp(0, interval),
        intervalSeconds: interval,
        trainingItemId: itemId,
        occurrence: at.occurrence,
        emom: position,
      ),
    );
  }
}

void _expandExercise(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  _ExpandContext ctx,
  _StepPlacement at,
) {
  final duration = item.effectiveDuration(ctx.results);
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
        subtitle: at.context,
        comment: at.comment,
        trainingItemId: _linkId(item),
        occurrence: at.occurrence,
        emom: at.emom,
      ),
    );
  } else {
    out.add(
      ConfirmItem(
        label: name,
        reps: item.effectiveReps(ctx.results),
        // An open rep count is only recordable against an item the session can
        // key it to, so an unsaved one runs as a plain self paced step.
        repsAreOpen: item.repsIsMax && _linkId(item) != null,
        load: item.loadLabel(
          bodyweightKg: ctx.bodyweightKg,
          results: ctx.results,
        ),
        subtitle: at.context,
        comment: at.comment,
        trainingItemId: _linkId(item),
        occurrence: at.occurrence,
        emom: at.emom,
      ),
    );
  }
  final rest = item.restSeconds ?? 0;
  if (rest > 0) {
    out.add(
      RestItem(
        durationSeconds: rest,
        trainingItemId: _linkId(item),
        occurrence: at.occurrence,
        emom: at.emom,
      ),
    );
  }
}

void _expandFree(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  _ExpandContext ctx,
  _StepPlacement at,
) {
  final duration = item.effectiveDuration(ctx.results);
  if (duration != null) {
    out.add(
      TimedItem(
        label: item.freeText ?? 'Free',
        durationSeconds: duration,
        targetLoad: 0,
        handSide: HandSide.both,
        gripPosition: GripPosition.halfCrimp,
        collectSensorData: false,
        subtitle: at.context,
        comment: at.comment,
        trainingItemId: _linkId(item),
        occurrence: at.occurrence,
        emom: at.emom,
      ),
    );
  } else {
    out.add(
      ConfirmItem(
        label: item.freeText ?? 'Free',
        subtitle: at.context,
        comment: at.comment,
        trainingItemId: _linkId(item),
        occurrence: at.occurrence,
        emom: at.emom,
      ),
    );
  }
}

void _expandHangboardRep(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  _ExpandContext ctx,
  _StepPlacement at,
) {
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
            bodyweightKg: ctx.bodyweightKg,
            results: ctx.results,
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
      collectSensorData: ctx.useSensor && handSide != HandSide.both,
      subtitle: at.context,
      comment: at.comment,
      trainingItemId: _linkId(item),
      occurrence: at.occurrence,
      emom: at.emom,
    ),
  );
  if (resttime > 0) {
    out.add(
      RestItem(
        durationSeconds: resttime,
        trainingItemId: _linkId(item),
        occurrence: at.occurrence,
        emom: at.emom,
      ),
    );
  }
}

void _expandRepeater(
  TrainingItem item,
  List<TrainingExecutionItem> out,
  _ExpandContext ctx,
  _StepPlacement at,
) {
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
                bodyweightKg: ctx.bodyweightKg,
                results: ctx.results,
                handSide: side,
              ) ??
          0.0,
      handSide: side,
      gripPosition: _parseGrip(layout.grip(cycle, rep, leftHand: leftHand)),
      edgeSizeMm: layout.edgeSizeMm(cycle, rep),
      isHang: true,
      // Only a hang on a single hand passes through the sensor.
      collectSensorData: ctx.useSensor && side != HandSide.both,
      subtitle: setRep(cycle, rep),
      comment: at.comment,
      trainingItemId: _linkId(item),
      occurrence: at.occurrence,
      emom: at.emom,
    );
  }

  RestItem rest(int seconds) => RestItem(
    durationSeconds: seconds,
    trainingItemId: _linkId(item),
    occurrence: at.occurrence,
    emom: at.emom,
  );

  switch (hand) {
    case HangboardHand.split:
      _expandSplitRepeater(
        out,
        hang,
        rest,
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
          if (resttime > 0) out.add(rest(resttime));
          out.add(hang(cycle, rep, HandSide.left));
          if (rep < repsPerCycle - 1 && resttime > 0) {
            out.add(rest(resttime));
          }
        }
        if (cycle < cycles - 1 && cycleRest > 0) {
          out.add(rest(cycleRest));
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
            out.add(rest(resttime));
          }
        }
        if (cycle < cycles - 1 && cycleRest > 0) {
          out.add(rest(cycleRest));
        }
      }
  }
}

/// A split repeater runs every rep of a set on the right hand, rests, then
/// replays the same set on the left.
void _expandSplitRepeater(
  List<TrainingExecutionItem> out,
  TimedItem Function(int cycle, int rep, HandSide side) hang,
  RestItem Function(int seconds) rest, {
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
          out.add(rest(resttime));
        }
      }
      final lastHandOfLastCycle = side == HandSide.left && cycle == cycles - 1;
      if (!lastHandOfLastCycle && restBetweenHands > 0) {
        out.add(rest(restBetweenHands));
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
