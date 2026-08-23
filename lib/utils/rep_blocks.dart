import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';

/// The repeater settings that decide how a block of reps splits into sets.
class RepeaterConfig {
  final int sets;
  final int repsPerSet;
  final int setRest;

  /// Every rep of a set on one hand, then the same set on the other, so each
  /// hand reads as its own set.
  final bool splitHand;

  /// How many hands a set works before the next one starts. Two when the hands
  /// alternate inside the set, one when the block hangs a single hand, so a set
  /// is not measured out as twice the reps it actually holds.
  final int handsPerSet;

  const RepeaterConfig({
    required this.sets,
    required this.repsPerSet,
    required this.setRest,
    required this.splitHand,
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
    setRest: item.cycleRestSeconds ?? 0,
    splitHand: item.hand == HangboardHand.split,
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
/// they were performed, and a rest at least as long as the configured set rest
/// marks the boundary between two sets.
List<RepSet> groupRepsIntoSets(List<RepDataModel> reps, RepeaterConfig config) {
  final sets = <RepSet>[];
  var index = 0;

  bool isSetBoundary() =>
      index < reps.length &&
      reps[index].isRest &&
      reps[index].duration >= config.setRest;

  void takeInterHandRest(List<RepDataModel> into) {
    if (index < reps.length &&
        reps[index].isRest &&
        reps[index].duration < config.setRest) {
      into.add(reps[index]);
      index++;
    }
  }

  for (var set = 0; set < config.sets && index < reps.length; set++) {
    if (config.splitHand) {
      for (final rightHand in [true, false]) {
        final handReps = <RepDataModel>[];
        var workReps = 0;
        while (index < reps.length && workReps < config.repsPerSet) {
          final rep = reps[index];
          handReps.add(rep);
          if (!rep.isRest) workReps++;
          index++;
        }
        takeInterHandRest(handReps);
        if (handReps.isNotEmpty) {
          sets.add(
            RepSet(
              label: 'Set ${set + 1} - ${rightHand ? 'Right' : 'Left'}',
              reps: handReps,
            ),
          );
        }
      }
    } else {
      // Both hands alternate within the set, but they are shown grouped.
      final rightHand = <RepDataModel>[];
      final leftHand = <RepDataModel>[];
      var workReps = 0;
      final expectedWorkReps = config.repsPerSet * config.handsPerSet;
      while (index < reps.length &&
          workReps < expectedWorkReps &&
          !isSetBoundary()) {
        final rep = reps[index];
        (rep.handSide == HandSide.right ? rightHand : leftHand).add(rep);
        if (!rep.isRest) workReps++;
        index++;
      }
      if (rightHand.isNotEmpty) {
        sets.add(RepSet(label: 'Set ${set + 1} - Right', reps: rightHand));
      }
      if (leftHand.isNotEmpty) {
        sets.add(RepSet(label: 'Set ${set + 1} - Left', reps: leftHand));
      }
    }
    if (isSetBoundary()) index++;
  }

  // Anything the configuration did not account for, for instance a session cut
  // short and resumed, is still shown rather than silently dropped.
  if (index < reps.length) {
    sets.add(RepSet(label: 'Remaining', reps: reps.sublist(index)));
  }
  return sets;
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
        label: item == null ? 'Unnamed block' : trainingItemTitle(item),
        reps: <RepDataModel>[],
        item: item,
      ));
      currentId = id;
    }
    blocks.last.reps.add(rep);
  }

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
