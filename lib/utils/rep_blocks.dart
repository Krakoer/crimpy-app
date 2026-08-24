import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';

/// The repeater settings that decide how a block of reps splits into sets.
class RepeaterConfig {
  final int sets;
  final int repsPerSet;

  /// Every rep of a set on one hand, then the same set on the other, so each
  /// hand reads as its own set.
  final bool splitHand;

  /// A rep hung with two hands is one rep on one board, so its set is not cut
  /// into a right and a left half the way the other modes are.
  final bool bothHands;

  /// How many hands a set works before the next one starts. Two when the hands
  /// alternate inside the set, one when the block hangs a single hand, so a set
  /// is not measured out as twice the reps it actually holds.
  final int handsPerSet;

  const RepeaterConfig({
    required this.sets,
    required this.repsPerSet,
    required this.splitHand,
    required this.bothHands,
    required this.handsPerSet,
  });
}

/// The repeater settings a training item carries, or null when the item is not
/// a repeater. A played session records no configuration of its own, so the
/// item the reps name is the only place the set shape survives.
RepeaterConfig? repeaterConfigOfItem(TrainingItem item) {
  if (item.type != TrainingItemType.repeater) return null;
  final sets = item.cycles ?? 0;
  final repsPerSet = item.reps ?? 0;
  if (sets <= 0 || repsPerSet <= 0) return null;
  return RepeaterConfig(
    sets: sets,
    repsPerSet: repsPerSet,
    splitHand: item.hand == HangboardHand.split,
    bothHands: item.hand == HangboardHand.both,
    handsPerSet: item.hand == HangboardHand.alternate ? 2 : 1,
  );
}

/// One set of a repeater block, named the way the athlete saw it played.
class RepSet {
  final String label;
  final List<RepDataModel> reps;

  const RepSet({required this.label, required this.reps});
}

/// One run of reps played from a single training item.
class RepBlock {
  final String label;
  final List<RepDataModel> reps;

  /// The set breakdown when the block played a repeater, null otherwise.
  final List<RepSet>? sets;

  const RepBlock({required this.label, required this.reps, this.sets});
}

/// Rebuilds the sets of a repeater from the flat rep list, the way the portal
/// does it, so both clients show the same breakdown. Reps arrive in the order
/// they were performed and the caller has already dropped the rests, so a set
/// is measured out by its rep count alone.
List<RepSet> groupRepsIntoSets(List<RepDataModel> reps, RepeaterConfig config) {
  final sets = <RepSet>[];
  var index = 0;

  List<RepDataModel> take(int count) {
    final taken = reps.sublist(index, (index + count).clamp(0, reps.length));
    index += taken.length;
    return taken;
  }

  for (var set = 0; set < config.sets && index < reps.length; set++) {
    if (config.splitHand) {
      for (final rightHand in [true, false]) {
        final handReps = take(config.repsPerSet);
        if (handReps.isNotEmpty) {
          sets.add(
            RepSet(
              label: 'Set ${set + 1} - ${rightHand ? 'Right' : 'Left'}',
              reps: handReps,
            ),
          );
        }
      }
    } else if (config.bothHands) {
      // Two hands on the board for a single rep, so there is no hand to name
      // and nothing to split the set into.
      final setReps = take(config.repsPerSet);
      if (setReps.isNotEmpty) {
        sets.add(RepSet(label: 'Set ${set + 1}', reps: setReps));
      }
    } else {
      // Both hands alternate within the set, but they are shown grouped.
      final rightHand = <RepDataModel>[];
      final leftHand = <RepDataModel>[];
      for (final rep in take(config.repsPerSet * config.handsPerSet)) {
        (rep.handSide == HandSide.right ? rightHand : leftHand).add(rep);
      }
      if (rightHand.isNotEmpty) {
        sets.add(RepSet(label: 'Set ${set + 1} - Right', reps: rightHand));
      }
      if (leftHand.isNotEmpty) {
        sets.add(RepSet(label: 'Set ${set + 1} - Left', reps: leftHand));
      }
    }
  }

  // Anything the configuration did not account for, for instance a session cut
  // short and resumed, is still shown rather than silently dropped.
  if (index < reps.length) {
    sets.add(RepSet(label: 'Remaining', reps: reps.sublist(index)));
  }
  return sets;
}

/// Names one training item the way a played session heads the block it ran,
/// matching the portal so a coach and an athlete reading the same run see the
/// same name. The training editor keeps its own vocabulary through
/// [trainingItemTitle]: a block listed among the blocks of a training is named
/// for what it is, one listed under a run is named for what was hung.
String sessionBlockLabel(TrainingItem item) {
  final named =
      (item.type == TrainingItemType.exercise
              ? item.exerciseName
              : item.freeText)
          ?.trim();
  if (named != null && named.isNotEmpty) return named;
  final title = item.groupTitle?.trim();
  if (title != null && title.isNotEmpty) return title;
  final label = switch (item.type) {
    TrainingItemType.group => 'Group',
    TrainingItemType.circuit => 'Circuit',
    TrainingItemType.repeater => 'Hangboard',
    TrainingItemType.hangboardRep => 'Hang rep',
    TrainingItemType.exercise => 'Exercise',
    TrainingItemType.free => 'Note',
  };
  // One edge names the block; several would name only its first hang, so the
  // block is left on its type alone.
  final edges = <int>{...?item.edgeSizesMm};
  return edges.length == 1 ? '$label ${edges.first}mm' : label;
}

/// Every item of a training by id, nested ones included, so a rep naming one
/// can be headed with it.
Map<String, TrainingItem> trainingItemsById(List<TrainingItem> items) {
  final byId = <String, TrainingItem>{};
  void walk(List<TrainingItem> items) {
    for (final item in items) {
      byId[item.id] = item;
      walk(item.items);
    }
  }

  walk(items);
  return byId;
}

/// Whether a session played more than one block, which is when a number stated
/// for the whole session starts pooling them. Averaging a block hung at 34 kg
/// with one hung at 24 kg names a load neither block asked for and no rep
/// pulled, and one on-target ratio over blocks graded against different targets
/// hides which of them was missed. Such a session states both per block instead.
///
/// The count is the test, not the loads: two blocks worked at the same target
/// pool nothing, but they still read honestly one block at a time.
bool spansMultipleBlocks(List<RepBlock>? blocks) => (blocks?.length ?? 0) > 1;

/// Cuts the reps into the blocks they were played from, in the order they were
/// performed: a new block starts wherever the item changes. Grouping by item id
/// instead would merge a block the athlete came back to with its first pass and
/// lose the order the two halves of a circuit ran in.
///
/// Returns null when no rep names an item, which is every session played before
/// the link existed and every one played outside a training. The card falls
/// back to its flat list there rather than showing one nameless block.
List<RepBlock>? groupRepsByTrainingItem(
  List<RepDataModel> reps,
  List<TrainingItem> items,
) {
  if (!reps.any((rep) => rep.trainingItemId != null)) return null;

  final byId = trainingItemsById(items);
  final blocks =
      <({String label, List<RepDataModel> reps, TrainingItem? item})>[];
  String? currentId;

  for (final rep in reps) {
    final id = rep.trainingItemId;
    if (blocks.isEmpty || id != currentId) {
      final item = id == null ? null : byId[id];
      blocks.add((
        // A link the training can no longer name is a block the athlete
        // deleted from it after the run, so the reps are still shown as their
        // own block rather than folded into the one before them.
        label: item == null ? 'Unnamed block' : sessionBlockLabel(item),
        reps: <RepDataModel>[],
        item: item,
      ));
      currentId = id;
    }
    blocks.last.reps.add(rep);
  }

  // Reps can name items that no longer exist - a training edited after the run,
  // or a guest-mode session whose training was never resolved at all. Heading
  // every one of them 'Unnamed block' would read as a breakdown while saying
  // less than the flat list does, so the card is left to fall back.
  if (blocks.every((block) => block.item == null)) return null;

  // An item played more than once, a circuit child on its second cycle, would
  // otherwise show the same heading twice with nothing to tell the passes
  // apart.
  final totals = <TrainingItem, int>{};
  for (final block in blocks) {
    if (block.item != null) {
      totals[block.item as TrainingItem] =
          (totals[block.item as TrainingItem] ?? 0) + 1;
    }
  }
  final passes = <TrainingItem, int>{};

  return blocks.map((block) {
    var label = block.label;
    final item = block.item;
    if (item != null && (totals[item] ?? 0) > 1) {
      final pass = (passes[item] ?? 0) + 1;
      passes[item] = pass;
      label = '$label (pass $pass)';
    }
    final config = item == null ? null : repeaterConfigOfItem(item);
    return RepBlock(
      label: label,
      reps: block.reps,
      sets: config == null ? null : groupRepsIntoSets(block.reps, config),
    );
  }).toList();
}
