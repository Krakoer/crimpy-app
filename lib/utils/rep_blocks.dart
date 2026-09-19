import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/format.dart';

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
/// The short name of a grip a block prescribes, or the stored value when it
/// names none this app knows: a session read back is worth heading with what it
/// says rather than with nothing.
String _gripLabel(String stored) {
  for (final grip in GripPosition.values) {
    if (grip.name == stored) return grip.shortName;
  }
  return stored;
}

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
    TrainingItemType.emom => 'EMOM',
    TrainingItemType.repeater => 'Hangboard',
    TrainingItemType.hangboardRep => 'Hang rep',
    TrainingItemType.exercise => 'Exercise',
    TrainingItemType.free => 'Note',
  };
  // One value names the block; several would name only its first hang, so the
  // block keeps only what holds for the whole of it. A ladder of hangs that
  // differ in nothing else reads as one line repeated without these: a warmup
  // works six intensities through three grips on the same edge.
  final edges = <int>{...?item.edgeSizesMm};
  final grips = <String>{...?item.handPositions?.expand((hand) => hand)};
  // Read off one hand, the way every other label that states a load does: the
  // two hands of a split block are pulled at different numbers, and naming both
  // would put the arithmetic of the whole block in its heading.
  final loads = <String>{
    for (final load in [...?item.loads])
      if (!load.isBodyweight && !load.isAssessmentRelative) load.label(),
  };

  final parts = <String>[
    if (edges.length == 1) '${edges.first}mm',
    if (grips.length == 1) _gripLabel(grips.first),
    if (loads.length == 1) 'at ${loads.first}',
  ];
  return parts.isEmpty ? label : '$label ${parts.join(', ')}';
}

/// One pass through a prescribed item and what the athlete reported about it:
/// the numbers on one line, the line they wrote on another.
typedef ReportedPass = ({int occurrence, String? achieved, String? note});

/// One prescribed item, what it asked for, and every pass of it the athlete
/// reported on, in the order they were played.
typedef ReportedItem = ({
  String label,
  String? prescribed,
  List<ReportedPass> passes,
});

/// Whether an item is a block that repeats, which is what is asked for its
/// rounds rather than for what was done inside it.
bool _isBlock(TrainingItem item) =>
    item.type == TrainingItemType.emom || item.type == TrainingItemType.circuit;

/// Whether an item is a hang, which is worked for a time on a board rather than
/// counted in repetitions.
bool _isHang(TrainingItem item) =>
    item.type == TrainingItemType.repeater ||
    item.type == TrainingItemType.hangboardRep;

/// What an item asked for, in the words the athlete was given it in, or null
/// when the prescription named no number to read an achievement against. An
/// AMRAP is the case that names one deliberately: the point of it is that the
/// coach prescribed no count.
///
/// Read against [results] rather than off the raw fields, since a coach may
/// prescribe reps or a duration as a percentage of an assessment and the raw
/// field then holds only the fallback. The run counted the athlete down from
/// the resolved number, so that is the number they are asked against.
///
/// [results] is null when the caller has no numbers to resolve against, which
/// is the history card reading a session back: the results the athlete has now
/// are not the ones the run was played against, and resolving against them
/// would state a target the session never had. A field prescribed as a
/// percentage then reads as nothing rather than as its fallback, which is a
/// number nobody was ever asked for: showing "did 10 reps" over "of 5 reps"
/// turns a miss against a target of 12 into a rout.
/// [bodyweightKg] turns a load set as a share of the athlete's weight into
/// kilograms. Null where none is known, which states the load in the unit it was
/// prescribed in ("80 %BW") rather than guessing at the kilograms behind it.
String? prescribedSummary(
  TrainingItem item, [
  AssessmentResults? results,
  double? bodyweightKg,
]) {
  if (_isBlock(item)) {
    final rounds = item.cycles;
    return rounds == null ? null : 'of $rounds rounds';
  }
  final resolved = results ?? AssessmentResults.none;
  // The load the item was given, stated for every step that carries one, since
  // the review asks the athlete to report a load against it and a card offering
  // the field without naming the target leaves them reporting against nothing.
  final load = results == null && item.loadReadsAgainstResults
      ? null
      : item.loadLabel(bodyweightKg: bodyweightKg, results: resolved);
  final at = load == null ? '' : ' at $load';

  if (_isHang(item)) {
    final work = item.worktimeSeconds;
    // A hang with no worktime still states its load: that is the number the
    // review asks the athlete to report against.
    return work == null || work <= 0
        ? (load == null ? null : 'at $load')
        : 'of ${formatSecondsAsLength(work)} hangs$at';
  }
  if (item.repsIsMax) return 'as many reps as possible$at';
  if (results == null) {
    // Nothing to resolve against, so a percentage is left unstated rather than
    // answered with the fallback standing in for it. The load is unaffected by
    // that and is still worth stating: it was never percentage dependent, and
    // it is what the review asks the athlete to report against.
    if (item.variableTargets.containsKey('duration') ||
        item.variableTargets.containsKey('reps')) {
      return load == null ? null : 'at $load';
    }
  }
  final duration = item.effectiveDuration(resolved);
  if (duration != null) {
    return 'of ${formatSecondsAsLength(duration)}$at';
  }
  final reps = item.effectiveReps(resolved);
  if (reps != null) return 'of $reps reps$at';
  // Nothing was prescribed but a load, which is still worth stating: it is what
  // the athlete is being asked to report against.
  return load == null ? null : 'at $load';
}

/// The numbers one pass reported, read as a line: "8 reps", "7 rounds",
/// "12 reps at 17.5 kg". Null when the pass reported nothing but a note, which
/// is a line of its own and needs no figure in front of it.
String? achievedSummary(SessionItemResultModel result) {
  final parts = <String>[
    if (result.reps case final reps?) '$reps reps',
    if (result.cycles case final cycles?) '$cycles rounds',
    if (result.durationSeconds case final seconds?)
      formatSecondsAsLength(seconds),
  ];
  final line = parts.join(', ');
  if (result.loadKg case final load?) {
    final kg = formatKilograms(load);
    return line.isEmpty ? '$kg kg' : '$line at $kg kg';
  }
  return line.isEmpty ? null : line;
}

/// Reads what a run reported against the items it answers, so each line is
/// shown next to what was asked for rather than as a bare number. A report
/// naming an item [items] does not hold is left out: there is nothing to head
/// it with.
List<ReportedItem> reportedItems(
  List<SessionItemResultModel> results,
  List<TrainingItem> items,
) {
  if (results.isEmpty || items.isEmpty) return const [];
  final byKey = trainingItemsByReportKey(items);

  final ordered = [...results]
    ..sort((a, b) => a.occurrence.compareTo(b.occurrence));
  final passes = <String, List<ReportedPass>>{};
  for (final result in ordered) {
    if (!byKey.containsKey(result.trainingItemId)) continue;
    final note = result.note?.trim();
    final pass = (
      occurrence: result.occurrence,
      achieved: achievedSummary(result),
      note: note == null || note.isEmpty ? null : note,
    );
    if (pass.achieved == null && pass.note == null) continue;
    (passes[result.trainingItemId] ??= []).add(pass);
  }

  final out = <ReportedItem>[];
  for (final item in byKey.values) {
    final reported = passes[item.reportKey];
    if (reported == null) continue;
    out.add((
      label: sessionBlockLabel(item),
      prescribed: prescribedSummary(item),
      passes: reported,
    ));
  }
  return out;
}

/// Which numbers a prescribed item is worth asking the athlete for, so the
/// review pass shows a rep field for a set of pull ups and a rounds field for
/// an emom rather than every field on every line.
///
/// Kept in step with [prescribedSummary] deliberately: a card stating what was
/// asked and then offering no field to answer it is worse than one that asks
/// nothing.
typedef ReportableFields = ({bool reps, bool cycles, bool load, bool duration});

ReportableFields reportableFields(
  TrainingItem item, [
  AssessmentResults results = AssessmentResults.none,
]) {
  // A block that repeats is asked how many rounds it went, and nothing about
  // the work inside it: that belongs to the items it holds, which get their own
  // lines.
  if (_isBlock(item)) {
    return (reps: false, cycles: true, load: false, duration: false);
  }
  // A hang is held for a time at a load, and counts no repetitions of its own:
  // the repeater is the block that repeats a hang.
  if (_isHang(item)) {
    return (reps: false, cycles: false, load: true, duration: true);
  }
  final isTimed = item.effectiveDuration(results) != null;
  return (reps: !isTimed, cycles: false, load: true, duration: isTimed);
}

/// Whether the athlete has anything to report about an item. A group and a free
/// note are the two that carry no work of their own: one is a heading, the
/// other is a line of the coach's own text.
///
/// An item with no report key is left out: a report is keyed to the item it
/// answers, so a line written against a nameless one could never be read back
/// and would collide with every other nameless line of the same session. A
/// builtin's items are generated rather than stored and so carry no id, but
/// they do carry a key, and are reported on like anything else.
bool isReportable(TrainingItem item) =>
    item.reportKey.isNotEmpty && _carriesWork(item);

/// Whether an item is work the athlete performs, rather than a heading or a
/// line of the coach's own text. Spelled once, since [isReportable] and
/// [holdsReportableWork] both turn on it and two copies would drift the first
/// time a type that carries no work is added.
bool _carriesWork(TrainingItem item) =>
    item.type != TrainingItemType.group && item.type != TrainingItemType.free;

/// Whether a run has somewhere to put what the athlete reports about its steps,
/// for as long as the session lives.
///
/// A report is keyed to an item of the prescription the session was run from,
/// so what this asks is whether the session carries one at all. There are two
/// ways it can: the store resolves it from the training or the program slot the
/// session names, or the run hands over the prescription it played, which is
/// what a training generated on the device does.
///
/// Both stores hold a report either way. The local one keys its rows on the
/// session alone, and the API takes a prescription with the session and keys
/// membership against it, so a run that carries one also survives the athlete
/// signing in with it.
bool sessionKeepsItemReports({
  String? trainingId,
  String? programSessionId,
  List<TrainingItem>? prescriptionItems,
}) =>
    trainingId != null ||
    programSessionId != null ||
    (prescriptionItems != null && prescriptionItems.isNotEmpty);

/// Whether every item of a prescription carries a name, nested ones included.
///
/// A snapshot is only worth handing over when it does: the reps and the reports
/// name their steps by it, and the API refuses one outright rather than storing
/// a step nothing can point at. Sessions frozen before a generated step had a
/// name of its own hold a blank id for every one of them, and they are already
/// on devices waiting to be imported.
bool everyItemIsNamed(List<TrainingItem> items) {
  for (final item in items) {
    if (item.reportKey.isEmpty) return false;
    if (!everyItemIsNamed(item.items)) return false;
  }
  return true;
}

/// Whether a training holds work the athlete could be asked about at all,
/// whether or not a line is actually offered for it.
///
/// What the screen owes an explanation for: prescribed work and no review pass
/// over it is a hole where every other training shows one, and silence there
/// reads as the feature being broken rather than as it not applying.
bool holdsReportableWork(List<TrainingItem> items) {
  for (final item in items) {
    if (_carriesWork(item)) return true;
    if (holdsReportableWork(item.items)) return true;
  }
  return false;
}

/// One line of the post workout review: a prescribed item and which pass of it
/// the line answers, and the rule in force on it.
///
/// [protocol] is the item's own protocol, or the one of the nearest block above
/// it that gets no line of its own. It is carried on the line rather than read
/// off the item because a group carries no line: a rule written on the block
/// would otherwise be on screen during the run and nowhere on the card where
/// the athlete writes down what it resolved to.
///
/// This is where it parts company with the run, which inherits a rule down to
/// every step (see the expander's _StepPlacement). A run shows one step at a
/// time, so repeating the rule on each is what keeps it in front of the
/// athlete; the review is a single scroll, so a circuit restating its rule on
/// its own card and on each of its children would be four copies of the same
/// prose in one screen.
typedef ReviewLine = ({TrainingItem item, int occurrence, String? protocol});

/// The lines the athlete goes back over once the run is done, in the order the
/// prescription lays them out, nested items included.
///
/// An item the run already recorded a pass against gets one line per recorded
/// pass, so an emom dropped out of twice is annotated round by round. Anything
/// else gets the single line of its first pass: reporting per round on a block
/// nothing was recorded against would ask the athlete to fill in a grid, when
/// what the spreadsheet asked for was a line per exercise.
List<ReviewLine> reviewLines(
  List<TrainingItem> items,
  List<SessionItemResultModel> recorded,
) {
  final occurrencesByItem = <String, Set<int>>{};
  for (final result in recorded) {
    (occurrencesByItem[result.trainingItemId] ??= {}).add(result.occurrence);
  }

  final lines = <ReviewLine>[];
  void walk(List<TrainingItem> items, String? inheritedProtocol) {
    for (final item in items) {
      final own = item.protocol?.trim() ?? '';
      final protocol = own.isEmpty ? inheritedProtocol : own;
      if (isReportable(item)) {
        final occurrences = (occurrencesByItem[item.reportKey]?.toList() ?? [0])
          ..sort();
        for (final occurrence in occurrences) {
          lines.add((item: item, occurrence: occurrence, protocol: protocol));
        }
      }
      // A block that gets a card of its own has already stated its rule there,
      // so its children do not restate it: a circuit and its three exercises
      // would otherwise stack four copies of the same prose down one screen.
      // A group gets no card, which is the case the inheritance exists for, so
      // it passes its rule down.
      walk(item.items, isReportable(item) ? null : protocol);
    }
  }

  walk(items, null);
  return lines;
}

/// Every item of a training by what names it, nested ones included, so a rep or
/// a report naming one can be headed with it. Both name a step the same way,
/// through the report key, which is the stored id wherever there is one.
///
/// Items with no name at all are left out rather than collapsed onto one entry:
/// nothing can name them, and keeping them would have the first of them answer
/// for the rest.
Map<String, TrainingItem> trainingItemsByReportKey(List<TrainingItem> items) {
  final byKey = <String, TrainingItem>{};
  void walk(List<TrainingItem> items) {
    for (final item in items) {
      if (item.reportKey.isNotEmpty) byKey[item.reportKey] = item;
      walk(item.items);
    }
  }

  walk(items);
  return byKey;
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

/// The share of its target a rep has to reach to count as on target. Stated
/// once here so every screen grades a run the same way, and kept equal to
/// ON_TARGET_RATIO in crimpy-frontend/src/lib/sessions.ts so an athlete and
/// their coach read the same session the same way.
const double onTargetRatio = 0.9;

/// Whether a rep reached the load it was given. A rep the training gave no
/// target is graded by nothing, so it is not on target either.
bool isOnTarget(RepDataModel rep) =>
    rep.targetWeight > 0 &&
    rep.averageWeight / rep.targetWeight >= onTargetRatio;

/// How many of a run's reps reached the load they were given, out of how many
/// the run could grade, plus the ones it prescribed a load for and never
/// measured.
typedef OnTargetCount = ({int onTarget, int total, int unmeasured});

/// How many of a run's reps reached the load they were given, rests left out.
///
/// Null when no rep carries a target: a ratio over reps the training never gave
/// one grades every single one as missed, which is an athlete's own logged run
/// rather than a failed one. Reps without a target still count in the total once
/// any of its neighbours has one, so a block reads as the whole run it was.
///
/// A rep whose target was lost to a sensor that dropped mid run is the one
/// exception: it was prescribed a load and performed, but nothing measured it,
/// so grading it either way states something the run does not know. It leaves
/// the ratio entirely and is counted apart, for the screens to say how much of
/// the run went unmeasured.
OnTargetCount? onTargetCount(List<RepDataModel> reps) {
  final workReps = reps.where((rep) => !rep.isRest).toList();
  final graded = measuredReps(reps);
  // Asked of the reps the run could grade, not of every rep: a group whose only
  // targets went unmeasured has nothing to state a ratio over, and 0/0 reads as
  // a run that met nothing.
  if (!graded.any((rep) => rep.targetWeight > 0)) return null;
  return (
    onTarget: graded.where(isOnTarget).length,
    total: graded.length,
    unmeasured: workReps.length - graded.length,
  );
}

/// The work reps a run actually weighed: the set every load stated over a run is
/// counted on, and the same one [onTargetCount] grades. A rep whose target was
/// lost to a sensor that dropped mid run was performed and weighed nothing, so
/// it is not one of them. Kept equal to measuredReps in
/// crimpy-frontend/src/lib/sessions.ts.
List<RepDataModel> measuredReps(List<RepDataModel> reps) =>
    reps.where((rep) => !rep.isRest && !rep.targetUnmeasured).toList();

/// Mean load over the reps a run weighed, or null when it weighed none.
///
/// A rep the sensor missed carries an average of 0 it never pulled. Averaged
/// in, it states a load lighter than anything the athlete held, on the same
/// line as a ratio that already leaves that rep out, and beside a row that
/// names it unmeasured. Every load of the card counts the same reps instead.
/// Kept equal to measuredAvgWeight in crimpy-frontend/src/lib/sessions.ts.
double? measuredAvgWeight(List<RepDataModel> reps) {
  final weighed = weighedReps(reps);
  if (weighed.isEmpty) return null;
  return weighed.map((rep) => rep.averageWeight).reduce((a, b) => a + b) /
      weighed.length;
}

/// Heaviest load over the reps a run weighed, or null when it weighed none.
///
/// A max is not pooled by the blocks a session played, since the heaviest rep of
/// a run is one rep whichever block it was hung in, so the only run that states
/// none is the one nothing ever weighed. There a zero does not lose the max the
/// way it loses an average: it is the only value left, and reads as a load the
/// athlete never pulled beside a mean that is correctly absent. The two stats
/// count the same reps and appear together. Kept equal to measuredMaxWeight in
/// crimpy-frontend/src/lib/sessions.ts.
double? measuredMaxWeight(List<RepDataModel> reps) {
  final weighed = weighedReps(reps);
  if (weighed.isEmpty) return null;
  return weighed
      .map((rep) => rep.averageWeight)
      .reduce((a, b) => a > b ? a : b);
}

/// Whether the run got a reading for one rep. False for a rep it weighed
/// nothing for: one whose target a dropped sensor lost, and one played from a
/// block that measures nothing at all, a two handed hang included. Both are
/// stored at exactly zero against no target, which is the absence of a reading
/// rather than a load the athlete pulled, so no surface states a load for them.
///
/// A reading is anything the sensor answered with, the zero it read against a
/// target and the below zero run of a sensor tared under load included: both are
/// what the athlete pulled, and the peak already reads the second one as it was
/// read. Kept equal to repWeighed in crimpy-frontend/src/lib/sessions.ts.
bool repWeighed(RepDataModel rep) =>
    rep.averageWeight != 0 || rep.targetWeight > 0;

/// The reps a run put a load on: the set every load stated over it is counted
/// on, so the session stats and the rows cannot state loads over different reps.
/// Empty for a run whose sensor never answered, and for a block that was never
/// meant to be weighed. Kept equal to weighedReps in
/// crimpy-frontend/src/lib/sessions.ts.
List<RepDataModel> weighedReps(List<RepDataModel> reps) =>
    measuredReps(reps).where(repWeighed).toList();

/// Names how much of a run went unmeasured, or null when the run measured all
/// of it. Stated next to a ratio so a denominator shrunk by a dropped sensor is
/// not read as a shorter run than the athlete performed, and kept equal to
/// unmeasuredNote in crimpy-frontend/src/lib/sessions.ts.
String? unmeasuredNote(OnTargetCount count) =>
    count.unmeasured == 0 ? null : '${count.unmeasured} unmeasured';

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

  final byId = trainingItemsByReportKey(items);
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
