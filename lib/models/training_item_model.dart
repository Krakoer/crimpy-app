import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';

enum TrainingItemType {
  repeater,
  hangboardRep,
  free,
  exercise,
  circuit,
  group,
  emom;

  static TrainingItemType fromString(String value) => switch (value) {
    'repeater' => TrainingItemType.repeater,
    'hangboard_rep' => TrainingItemType.hangboardRep,
    'free' => TrainingItemType.free,
    'exercise' => TrainingItemType.exercise,
    'circuit' => TrainingItemType.circuit,
    'group' => TrainingItemType.group,
    'emom' => TrainingItemType.emom,
    _ => TrainingItemType.free,
  };

  String get apiValue => switch (this) {
    TrainingItemType.repeater => 'repeater',
    TrainingItemType.hangboardRep => 'hangboard_rep',
    TrainingItemType.free => 'free',
    TrainingItemType.exercise => 'exercise',
    TrainingItemType.circuit => 'circuit',
    TrainingItemType.group => 'group',
    TrainingItemType.emom => 'emom',
  };
}

/// The unit marking a load set as a percentage of an assessment result. The
/// load value carries the percentage, as it does for percent_bw.
const String percentAssessmentUnit = 'percent_assessment';

/// The assessment a percentage names, or null when the payload names none, in
/// which case the coach fixed value applies instead.
String? assessmentIdFromJson(Object? value) {
  final id = value as String?;
  return (id == null || id.isEmpty) ? null : id;
}

/// A number the coach set as a percentage of the athlete latest result for an
/// assessment, with the value to use until that assessment is done.
class VariableTarget {
  final String assessmentId;
  final double percent;
  final double fallback;

  const VariableTarget({
    required this.assessmentId,
    required this.percent,
    required this.fallback,
  });

  static VariableTarget? fromJson(Map<String, dynamic> json) {
    final assessmentId = assessmentIdFromJson(json['assessment_id']);
    final percent = (json['percent'] as num?)?.toDouble();
    if (assessmentId == null || percent == null) return null;
    return VariableTarget(
      assessmentId: assessmentId,
      percent: percent,
      fallback: (json['fallback'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'assessment_id': assessmentId,
    'percent': percent,
    'fallback': fallback,
  };

  /// The prescribed number, or the fallback when the assessment is missing or
  /// is not measured in [expects]. A percentage of a force result cannot stand
  /// in for a duration, so a mismatched reference takes the fallback rather
  /// than putting a number in the wrong unit on the gauge.
  double resolve(
    AssessmentResults results, {
    required AssessmentUnit expects,
    HandSide? handSide,
  }) {
    if (results.unitOf(assessmentId) != expects) return fallback;
    final measured = results.value(assessmentId, handSide: handSide);
    return measured == null ? fallback : measured * percent / 100;
  }
}

class Load {
  final double value;
  final String unit;

  /// Set only on a percent_assessment load: the assessment the percentage
  /// applies to, and the kilograms to use until it has been done.
  final String? assessmentId;
  final double? fallback;

  const Load({
    required this.value,
    required this.unit,
    this.assessmentId,
    this.fallback,
  });

  static const Load bodyweight = Load(value: 0.0, unit: 'bw');

  factory Load.fromJson(Map<String, dynamic> json) => Load(
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
    unit: json['unit'] as String? ?? 'kg',
    assessmentId: assessmentIdFromJson(json['assessment_id']),
    fallback: (json['fallback'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'value': value,
    'unit': unit,
    if (assessmentId != null) 'assessment_id': assessmentId,
    if (fallback != null) 'fallback': fallback,
  };

  /// Whether the load is a percentage of an assessment result, and so only
  /// becomes kilograms once that assessment has been done.
  bool get isAssessmentRelative =>
      unit == percentAssessmentUnit && assessmentId != null;

  bool get isBodyweight =>
      !isAssessmentRelative &&
      (unit == 'bw' || (unit != 'max' && value == 0.0));

  /// Whether this rep is performed at maximum effort rather than a fixed load.
  bool get isMax => unit == 'max';

  /// Whether the load is expressed relative to the athlete bodyweight, and so
  /// needs one to be turned into kilograms. Kept in step with [kilograms] by
  /// test, so a load that resolves against the bodyweight always asks for one.
  bool get needsBodyweight => !isBodyweight && unit == 'percent_bw';

  /// The load in kilograms, the unit the sensor measures. An assessment-relative
  /// load resolves against [results] and falls back to the coach value when the
  /// athlete has never done that assessment. Null when there is no number to
  /// hit: a max effort rep, a plain bodyweight hang, a load set as a percentage
  /// of a bodyweight that is not known yet, or a unit the app does not read.
  /// Guessing at an unknown unit would put its bare number on the gauge as if it
  /// were kilograms.
  double? kilograms({
    double? bodyweightKg,
    AssessmentResults results = AssessmentResults.none,
    HandSide? handSide,
  }) {
    if (isMax || isBodyweight) return null;
    if (isAssessmentRelative) {
      return VariableTarget(
        assessmentId: assessmentId!,
        percent: value,
        fallback: fallback ?? 0.0,
      ).resolve(results, expects: AssessmentUnit.kilograms, handSide: handSide);
    }
    return switch (unit) {
      'percent_bw' => bodyweightKg == null ? null : bodyweightKg * value / 100,
      'kg' => value,
      _ => null,
    };
  }

  /// Human-readable load, e.g. "+35 kg", "100 %BW", "MAX", or "BW". A load set
  /// in another unit also shows what the sensor will ask for, e.g.
  /// "80 %BW (56 kg)" or "80% Max force (30 kg)", since the gauge reads in
  /// kilograms.
  String label({
    double? bodyweightKg,
    AssessmentResults results = AssessmentResults.none,
    HandSide? handSide,
  }) {
    if (isMax) return 'MAX';
    if (isBodyweight) return 'BW';
    if (isAssessmentRelative) {
      final name = results.labelOf(assessmentId!);
      final kg = kilograms(results: results, handSide: handSide);
      final base = '${_format(value)}% $name';
      return kg == null ? base : '$base (${_format(kg)} kg)';
    }
    final u = switch (unit) {
      'percent_bw' => '%BW',
      'bw' => 'BW',
      _ => unit,
    };
    final base = '${_format(value)} $u';
    if (unit == 'kg') return base;
    final kg = kilograms(bodyweightKg: bodyweightKg);
    return kg == null ? base : '$base (${_format(kg)} kg)';
  }

  static String _format(double value) => value.truncateToDouble() == value
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

/// A title the user left blank reads as no title at all, so the item falls back
/// to the label of its type rather than showing an empty line.
String? cleanTitle(String? title) {
  final trimmed = title?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

/// Reads the variable targets of an item, dropping any entry that does not name
/// an assessment this version of the app knows.
Map<String, VariableTarget> parseVariableTargets(dynamic raw) {
  if (raw is! Map) return const {};
  final out = <String, VariableTarget>{};
  raw.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      final target = VariableTarget.fromJson(value);
      if (target != null) out[key.toString()] = target;
    }
  });
  return out;
}

/// How the two hands are worked. Only [both] puts two hands on the board at the
/// same time; every other mode hangs a single hand and can be measured by the
/// force sensor.
abstract final class HangboardHand {
  /// Both hands on the board together, one hang per rep.
  static const both = 'both';

  /// One hand at a time, right then left within each rep.
  static const alternate = 'alternate';

  /// Every rep of a set on one hand, then the same set on the other.
  static const split = 'split';

  static const left = 'left';
  static const right = 'right';

  /// Modes that hang the hands separately, each with its own configuration.
  static bool worksHandsSeparately(String? hand) =>
      hand == alternate || hand == split;

  /// Whether the hangs put one hand on the board at a time, which is the only
  /// case the force sensor can measure. A hangboard_rep runs a single hang, so
  /// only the explicitly named hands qualify; a repeater also alternates or
  /// splits its hands across reps. The expanders derive their hand sides the
  /// same way, so what the sensor is offered for is what actually records.
  static bool hangsOneHandAtATime(String? hand, {required bool isRepeater}) =>
      hand == left ||
      hand == right ||
      (isRepeater && worksHandsSeparately(hand));
}

/// Layout of the configuration arrays, declared by the item rather than
/// inferred from any array length.
abstract final class HangboardGranularity {
  /// One row for the whole item.
  static const uniform = 'uniform';

  /// One row per rep, replayed in every set.
  static const perRep = 'rep';

  /// One row per set and rep, indexed set * reps + rep.
  static const perSet = 'set';
}

/// Reads hand_positions, which carries one array of rows per hand with the left
/// hand first. A flat array written before the format was unified is read as
/// the rows of a single hand.
List<List<String>>? parseHandPositions(dynamic raw) {
  if (raw is! List || raw.isEmpty) return null;
  if (raw.every((e) => e is List)) {
    return raw
        .map((hand) => (hand as List).map((e) => e.toString()).toList())
        .toList();
  }
  return [raw.map((e) => e.toString()).toList()];
}

/// How an item is headed wherever it is listed: the training editor, and the
/// blocks a played session is read in.
String trainingItemTitle(TrainingItem item) => switch (item.type) {
  TrainingItemType.group => item.groupTitle ?? 'Group',
  TrainingItemType.circuit => item.groupTitle ?? 'Circuit',
  TrainingItemType.repeater => 'Repeater',
  TrainingItemType.hangboardRep => 'Hang rep',
  TrainingItemType.exercise => item.exerciseName ?? 'Exercise',
  TrainingItemType.free => item.freeText ?? 'Note',
  TrainingItemType.emom => 'EMOM',
};

class TrainingItem {
  final String id;
  final TrainingItemType type;
  final int position;
  final String? parentId;

  // Repeater and hangboard_rep: worktime and rest
  final int? worktimeSeconds;
  final int? restSeconds;

  // Repeater: cycles and structured timing
  final int? cycles;
  final int? cycleRestSeconds;

  /// How often a round of an emom starts, in seconds. Null on every other type.
  /// It is what makes the block every minute on the minute: the work of a round
  /// is self paced and whatever is left of the interval is the rest, so the
  /// round after it starts on the clock however fast the one before it went.
  final int? intervalSeconds;

  // Repeater/exercise: reps per cycle or total reps
  final int? reps;

  /// Whether the rep count is left open, which is an AMRAP: the coach set no
  /// number, so the athlete does as many as they can and records how many that
  /// was. Exercises only, and [reps] is read by nothing when it is set.
  final bool repsIsMax;

  // Exercise: explicit duration (for timed exercises like planks)
  final int? duration;

  // How the two hands are worked, see [HangboardHand].
  final String? hand;

  // Layout of the arrays below, see [HangboardGranularity].
  final String? granularity;

  // Configuration arrays, one entry per row. [loads] is the right hand of a
  // mode that works the hands separately, and the only load otherwise.
  final List<Load>? loads;
  final List<Load>? leftLoads;
  final List<int>? edgeSizesMm;

  // Grips indexed [hand][row], left hand first. A single array applies to
  // both hands.
  final List<List<String>>? handPositions;

  // Whether this item is done at maximum effort rather than a fixed load
  final bool loadIsMax;

  // Scalar fields the coach set as a percentage of an assessment result,
  // keyed by field name ('duration', 'reps').
  final Map<String, VariableTarget> variableTargets;

  // Free item text
  final String? freeText;

  // Optional coach comment shown to the athlete (e.g. "first rep in pronation")
  final String? comment;

  // Exercise reference
  final String? exerciseId;

  // Exercise display name (denormalized from the referenced exercise)
  final String? exerciseName;

  // Group label
  final String? groupTitle;

  // Nested items (circuits and sections)
  final List<TrainingItem> items;

  const TrainingItem({
    required this.id,
    required this.type,
    required this.position,
    this.parentId,
    this.worktimeSeconds,
    this.restSeconds,
    this.cycles,
    this.cycleRestSeconds,
    this.intervalSeconds,
    this.reps,
    this.repsIsMax = false,
    this.duration,
    this.hand,
    this.granularity,
    this.loads,
    this.leftLoads,
    this.edgeSizesMm,
    this.handPositions,
    this.loadIsMax = false,
    this.variableTargets = const {},
    this.freeText,
    this.comment,
    this.exerciseId,
    this.exerciseName,
    this.groupTitle,
    this.items = const [],
  });

  /// Grips as one array per hand, empty when the item prescribes none.
  List<List<String>> get handPositionsPerHand => handPositions ?? const [];

  /// Reps to perform when this is a rep-based item, null otherwise.
  /// An item is never both rep-based and time-based.
  /// An open rep count prescribes no number at all, which is what tells an
  /// AMRAP from an exercise the coach simply gave one rep. Nothing resolves it:
  /// the number only exists once the athlete has done the set and said so.
  int? effectiveReps([AssessmentResults results = AssessmentResults.none]) {
    if (repsIsMax) return null;
    final target = variableTargets['reps'];
    if (target != null) {
      final resolved = target
          .resolve(results, expects: AssessmentUnit.repetitions)
          .round();
      return resolved > 0 ? resolved : null;
    }
    return (reps ?? 0) > 0 ? reps : null;
  }

  /// Duration in seconds when this is a time-based item, null otherwise.
  int? effectiveDuration([AssessmentResults results = AssessmentResults.none]) {
    final target = variableTargets['duration'];
    if (target != null) {
      final resolved = target
          .resolve(results, expects: AssessmentUnit.seconds)
          .round();
      return resolved > 0 ? resolved : null;
    }
    return (duration ?? 0) > 0 ? duration : null;
  }

  /// Whether [load] is an exercise carrying the whole bodyweight and nothing
  /// more, which is just the athlete doing the movement. That is how the coach
  /// portal writes it and why it hides it there: showing the kilograms would
  /// read as weight added to a set of pull ups. Nothing resolves such a load,
  /// so it must not ask for a bodyweight either.
  bool _isPlainBodyweightExercise(Load load) =>
      type == TrainingItemType.exercise &&
      load.unit == 'percent_bw' &&
      load.value == 100;

  /// First-rep load shown to the user, or null when bodyweight / unset.
  String? loadLabel({
    double? bodyweightKg,
    AssessmentResults results = AssessmentResults.none,
  }) {
    final first = loads?.firstOrNull;
    if (loadIsMax || (first?.isMax ?? false)) return 'MAX';
    if (first == null || first.isBodyweight) return null;
    if (_isPlainBodyweightExercise(first)) return null;
    return first.label(bodyweightKg: bodyweightKg, results: results);
  }

  /// Whether any rep of this item is loaded relative to the bodyweight, and so
  /// would show or hit a different number once one is known. Kept in step with
  /// [loadLabel]: a load this item never resolves must not make the app ask for
  /// a bodyweight it will not use.
  bool get needsBodyweight {
    bool needs(List<Load>? l) => (l ?? []).any(
      (e) => e.needsBodyweight && !_isPlainBodyweightExercise(e),
    );
    return needs(loads) || needs(leftLoads);
  }

  /// Every assessment this item resolves a load, duration or rep count
  /// against, so a screen can tell the athlete which ones it is missing.
  Set<String> get referencedAssessments => {
    for (final target in variableTargets.values) target.assessmentId,
    for (final load in [...?loads, ...?leftLoads])
      if (load.isAssessmentRelative) load.assessmentId!,
    for (final child in items) ...child.referencedAssessments,
  };

  /// Whether this item can be performed with the crimpy force sensor: a
  /// single-hand hangboard/repeater item with a non-bodyweight target load.
  bool get usesSensor {
    if (type != TrainingItemType.hangboardRep &&
        type != TrainingItemType.repeater) {
      return false;
    }
    if (!HangboardHand.hangsOneHandAtATime(
      hand,
      isRepeater: type == TrainingItemType.repeater,
    )) {
      return false;
    }
    bool hasLoad(List<Load>? l) => (l ?? []).any((e) => !e.isBodyweight);
    return hasLoad(loads) || hasLoad(leftLoads);
  }

  factory TrainingItem.fromJson(Map<String, dynamic> json) {
    List<Load>? parseLoads(dynamic raw) {
      if (raw is! List || raw.isEmpty) return null;
      return raw.whereType<Map<String, dynamic>>().map(Load.fromJson).toList();
    }

    List<int>? parseIntList(dynamic raw) {
      if (raw is! List || raw.isEmpty) return null;
      return raw.whereType<num>().map((e) => e.toInt()).toList();
    }

    final nestedRaw = json['items'] as List<dynamic>?;
    final targets = parseVariableTargets(json['variable_targets']);
    final nestedItems =
        nestedRaw
            ?.map((e) => TrainingItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return TrainingItem(
      id: json['id'] as String,
      type: TrainingItemType.fromString(json['type'] as String),
      position: (json['position'] as num).toInt(),
      parentId: json['parent_id'] as String?,
      worktimeSeconds: (json['worktime_seconds'] as num?)?.toInt(),
      restSeconds: (json['rest_seconds'] as num?)?.toInt(),
      cycles: (json['cycles'] as num?)?.toInt(),
      cycleRestSeconds: (json['cycle_rest_seconds'] as num?)?.toInt(),
      intervalSeconds: (json['interval_seconds'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      repsIsMax: json['reps_is_max'] as bool? ?? false,
      duration: (json['duration'] as num?)?.toInt(),
      hand: json['hand'] as String?,
      granularity: json['granularity'] as String?,
      loads: parseLoads(json['loads']),
      leftLoads: parseLoads(json['left_loads']),
      edgeSizesMm: parseIntList(json['edge_sizes_mm']),
      handPositions: parseHandPositions(json['hand_positions']),
      loadIsMax: json['load_is_max'] as bool? ?? false,
      variableTargets: targets,
      freeText: json['free_text'] as String?,
      comment: json['comment'] as String?,
      exerciseId: json['exercise_id'] as String?,
      exerciseName: json['exercise_name'] as String?,
      groupTitle: json['group_title'] as String?,
      items: nestedItems,
    );
  }

  /// [includeItems] is dropped by the prescription snapshot, which rebuilds the
  /// nested tree itself: serializing it here first would be work thrown away,
  /// and would leave a subtree in the snapshot that the snapshot never wrote.
  Map<String, dynamic> toJson({bool includeItems = true}) {
    final map = <String, dynamic>{'type': type.apiValue};
    // Sent back on an update so the stored row keeps its id: the reps, the open
    // counts and the program overrides recorded against this item all key on
    // it, and an item that comes back under a new id strands every one of them.
    // Empty on an item the editor just added or duplicated, which is what tells
    // the backend to give it one.
    if (id.isNotEmpty) map['id'] = id;
    if (worktimeSeconds != null) map['worktime_seconds'] = worktimeSeconds;
    if (restSeconds != null) map['rest_seconds'] = restSeconds;
    if (cycles != null) map['cycles'] = cycles;
    if (cycleRestSeconds != null) map['cycle_rest_seconds'] = cycleRestSeconds;
    if (intervalSeconds != null) map['interval_seconds'] = intervalSeconds;
    if (reps != null) map['reps'] = reps;
    map['reps_is_max'] = repsIsMax;
    if (duration != null) map['duration'] = duration;
    if (hand != null) map['hand'] = hand;
    if (granularity != null) map['granularity'] = granularity;
    if (loads != null) map['loads'] = loads!.map((l) => l.toJson()).toList();
    if (leftLoads != null) {
      map['left_loads'] = leftLoads!.map((l) => l.toJson()).toList();
    }
    if (handPositions != null) map['hand_positions'] = handPositions;
    if (edgeSizesMm != null) map['edge_sizes_mm'] = edgeSizesMm;
    map['load_is_max'] = loadIsMax;
    if (variableTargets.isNotEmpty) {
      map['variable_targets'] = variableTargets.map(
        (field, target) => MapEntry(field, target.toJson()),
      );
    }
    if (freeText != null) map['free_text'] = freeText;
    if (comment != null) map['comment'] = comment;
    if (exerciseId != null) map['exercise_id'] = exerciseId;
    if (groupTitle != null) map['group_title'] = groupTitle;
    if (includeItems && items.isNotEmpty) {
      map['items'] = items.map((i) => i.toJson()).toList();
    }
    return map;
  }

  /// The item as a frozen prescription holds it, which is [toJson] plus what
  /// the API derives on its side rather than accepts from the client: where the
  /// item sits, which item it hangs from, and the name the exercise catalog
  /// resolved. A snapshot is read back with [fromJson] long after the run, with
  /// no tree and no catalog left to ask, so it carries all three itself.
  Map<String, dynamic> toPrescriptionJson() => {
    ...toJson(includeItems: false),
    'id': id,
    'position': position,
    if (parentId != null) 'parent_id': parentId,
    if (exerciseName != null) 'exercise_name': exerciseName,
    if (items.isNotEmpty)
      'items': items.map((i) => i.toPrescriptionJson()).toList(),
  };

  /// A null argument leaves the field alone, except for [groupTitle]: a blank
  /// one clears the title, since an editor always has some text to hand over
  /// and a group is allowed to have no name.
  TrainingItem copyWith({
    int? position,
    int? worktimeSeconds,
    int? restSeconds,
    int? cycles,
    int? cycleRestSeconds,
    int? intervalSeconds,
    int? reps,
    bool? repsIsMax,
    int? duration,
    String? hand,
    String? granularity,
    List<Load>? loads,
    List<Load>? leftLoads,
    List<int>? edgeSizesMm,
    List<List<String>>? handPositions,
    bool? loadIsMax,
    Map<String, VariableTarget>? variableTargets,
    String? groupTitle,
    List<TrainingItem>? items,
  }) {
    return TrainingItem(
      id: id,
      type: type,
      position: position ?? this.position,
      parentId: parentId,
      worktimeSeconds: worktimeSeconds ?? this.worktimeSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      cycles: cycles ?? this.cycles,
      cycleRestSeconds: cycleRestSeconds ?? this.cycleRestSeconds,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      reps: reps ?? this.reps,
      repsIsMax: repsIsMax ?? this.repsIsMax,
      duration: duration ?? this.duration,
      hand: hand ?? this.hand,
      granularity: granularity ?? this.granularity,
      loads: loads ?? this.loads,
      leftLoads: leftLoads ?? this.leftLoads,
      edgeSizesMm: edgeSizesMm ?? this.edgeSizesMm,
      handPositions: handPositions ?? this.handPositions,
      loadIsMax: loadIsMax ?? this.loadIsMax,
      variableTargets: variableTargets ?? this.variableTargets,
      freeText: freeText,
      comment: comment,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      groupTitle: groupTitle == null ? this.groupTitle : cleanTitle(groupTitle),
      items: items ?? this.items,
    );
  }

  /// A copy that saves as a new item. Ids are assigned by the store on save, so
  /// a duplicate must not carry the one of the item it was copied from, or the
  /// two would be the same item to everything that keys on it.
  TrainingItem duplicate() => TrainingItem(
    id: '',
    type: type,
    position: position,
    worktimeSeconds: worktimeSeconds,
    restSeconds: restSeconds,
    cycles: cycles,
    cycleRestSeconds: cycleRestSeconds,
    intervalSeconds: intervalSeconds,
    reps: reps,
    repsIsMax: repsIsMax,
    duration: duration,
    hand: hand,
    granularity: granularity,
    loads: loads,
    leftLoads: leftLoads,
    edgeSizesMm: edgeSizesMm,
    handPositions: handPositions,
    loadIsMax: loadIsMax,
    variableTargets: variableTargets,
    freeText: freeText,
    comment: comment,
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    groupTitle: groupTitle,
    items: items.map((child) => child.duplicate()).toList(),
  );

  /// Returns a copy with the sparse program override applied. Only keys present
  /// in [override] replace base values; missing keys are kept.
  TrainingItem applyOverride(Map<String, dynamic> override) {
    if (override.isEmpty) return this;

    // An empty array carries no prescription, so it leaves the base value
    // alone rather than wiping it.
    List<T>? orBase<T>(List<T>? parsed) =>
        parsed == null || parsed.isEmpty ? null : parsed;

    List<Load>? parseLoads(dynamic raw) {
      if (raw is! List) return null;
      return orBase(
        raw.whereType<Map<String, dynamic>>().map(Load.fromJson).toList(),
      );
    }

    return copyWith(
      loads: parseLoads(override['loads']),
      leftLoads: parseLoads(override['left_loads']),
      handPositions: orBase(parseHandPositions(override['hand_positions'])),
      edgeSizesMm: override['edge_sizes_mm'] is! List
          ? null
          : orBase(
              (override['edge_sizes_mm'] as List)
                  .whereType<num>()
                  .map((e) => e.toInt())
                  .toList(),
            ),
      variableTargets: override.containsKey('variable_targets')
          ? parseVariableTargets(override['variable_targets'])
          : null,
      reps: (override['reps'] as num?)?.toInt(),
      cycles: (override['cycles'] as num?)?.toInt(),
      cycleRestSeconds: (override['cycle_rest_seconds'] as num?)?.toInt(),
      restSeconds: (override['rest_seconds'] as num?)?.toInt(),
      worktimeSeconds: (override['hb_worktime_seconds'] as num?)?.toInt(),
      hand: override['hand'] as String?,
      granularity: override['granularity'] as String?,
    );
  }
}
