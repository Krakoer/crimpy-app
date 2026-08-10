enum TrainingItemType {
  repeater,
  hangboardRep,
  free,
  exercise,
  circuit,
  group;

  static TrainingItemType fromString(String value) => switch (value) {
    'repeater' => TrainingItemType.repeater,
    'hangboard_rep' => TrainingItemType.hangboardRep,
    'free' => TrainingItemType.free,
    'exercise' => TrainingItemType.exercise,
    'circuit' => TrainingItemType.circuit,
    'group' => TrainingItemType.group,
    _ => TrainingItemType.free,
  };

  String get apiValue => switch (this) {
    TrainingItemType.repeater => 'repeater',
    TrainingItemType.hangboardRep => 'hangboard_rep',
    TrainingItemType.free => 'free',
    TrainingItemType.exercise => 'exercise',
    TrainingItemType.circuit => 'circuit',
    TrainingItemType.group => 'group',
  };
}

class Load {
  final double value;
  final String unit;

  const Load({required this.value, required this.unit});

  static const Load bodyweight = Load(value: 0.0, unit: 'bw');

  factory Load.fromJson(Map<String, dynamic> json) => Load(
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
    unit: json['unit'] as String? ?? 'kg',
  );

  Map<String, dynamic> toJson() => {'value': value, 'unit': unit};

  bool get isBodyweight => unit == 'bw' || (unit != 'max' && value == 0.0);

  /// Whether this rep is performed at maximum effort rather than a fixed load.
  bool get isMax => unit == 'max';

  /// Whether the load is expressed relative to the athlete bodyweight, and so
  /// needs one to be turned into kilograms. Kept in step with [kilograms] by
  /// test, so a load that resolves against the bodyweight always asks for one.
  bool get needsBodyweight => !isBodyweight && unit == 'percent_bw';

  /// The load in kilograms, the unit the sensor measures. Null when there is no
  /// number to hit: a max effort rep, a plain bodyweight hang, a load set as a
  /// percentage of a bodyweight that is not known yet, or a unit the app does
  /// not read. Guessing at an unknown unit would put its bare number on the
  /// gauge as if it were kilograms.
  double? kilograms(double? bodyweightKg) {
    if (isMax || isBodyweight) return null;
    return switch (unit) {
      'percent_bw' => bodyweightKg == null ? null : bodyweightKg * value / 100,
      'kg' => value,
      _ => null,
    };
  }

  /// Human-readable load, e.g. "+35 kg", "100 %BW", "MAX", or "BW". A load set
  /// in another unit also shows what the sensor will ask for, e.g.
  /// "80 %BW (56 kg)", since the gauge reads in kilograms.
  String label({double? bodyweightKg}) {
    if (isMax) return 'MAX';
    if (isBodyweight) return 'BW';
    final u = switch (unit) {
      'percent_bw' => '%BW',
      'bw' => 'BW',
      _ => unit,
    };
    final base = '${_format(value)} $u';
    if (unit == 'kg') return base;
    final kg = kilograms(bodyweightKg);
    return kg == null ? base : '$base (${_format(kg)} kg)';
  }

  static String _format(double value) => value.truncateToDouble() == value
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
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

  // Repeater/exercise: reps per cycle or total reps
  final int? reps;

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
    this.reps,
    this.duration,
    this.hand,
    this.granularity,
    this.loads,
    this.leftLoads,
    this.edgeSizesMm,
    this.handPositions,
    this.loadIsMax = false,
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
  int? get effectiveReps => (reps ?? 0) > 0 ? reps : null;

  /// Duration in seconds when this is a time-based item, null otherwise.
  int? get effectiveDuration => (duration ?? 0) > 0 ? duration : null;

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
  String? loadLabel({double? bodyweightKg}) {
    final first = loads?.firstOrNull;
    if (loadIsMax || (first?.isMax ?? false)) return 'MAX';
    if (first == null || first.isBodyweight) return null;
    if (_isPlainBodyweightExercise(first)) return null;
    return first.label(bodyweightKg: bodyweightKg);
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
      reps: (json['reps'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      hand: json['hand'] as String?,
      granularity: json['granularity'] as String?,
      loads: parseLoads(json['loads']),
      leftLoads: parseLoads(json['left_loads']),
      edgeSizesMm: parseIntList(json['edge_sizes_mm']),
      handPositions: parseHandPositions(json['hand_positions']),
      loadIsMax: json['load_is_max'] as bool? ?? false,
      freeText: json['free_text'] as String?,
      comment: json['comment'] as String?,
      exerciseId: json['exercise_id'] as String?,
      exerciseName: json['exercise_name'] as String?,
      groupTitle: json['group_title'] as String?,
      items: nestedItems,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'type': type.apiValue};
    if (worktimeSeconds != null) map['worktime_seconds'] = worktimeSeconds;
    if (restSeconds != null) map['rest_seconds'] = restSeconds;
    if (cycles != null) map['cycles'] = cycles;
    if (cycleRestSeconds != null) map['cycle_rest_seconds'] = cycleRestSeconds;
    if (reps != null) map['reps'] = reps;
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
    if (freeText != null) map['free_text'] = freeText;
    if (comment != null) map['comment'] = comment;
    if (exerciseId != null) map['exercise_id'] = exerciseId;
    if (groupTitle != null) map['group_title'] = groupTitle;
    if (items.isNotEmpty) {
      map['items'] = items.map((i) => i.toJson()).toList();
    }
    return map;
  }

  TrainingItem copyWith({
    int? position,
    int? worktimeSeconds,
    int? restSeconds,
    int? cycles,
    int? cycleRestSeconds,
    int? reps,
    int? duration,
    String? hand,
    String? granularity,
    List<Load>? loads,
    List<Load>? leftLoads,
    List<int>? edgeSizesMm,
    List<List<String>>? handPositions,
    bool? loadIsMax,
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
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      hand: hand ?? this.hand,
      granularity: granularity ?? this.granularity,
      loads: loads ?? this.loads,
      leftLoads: leftLoads ?? this.leftLoads,
      edgeSizesMm: edgeSizesMm ?? this.edgeSizesMm,
      handPositions: handPositions ?? this.handPositions,
      loadIsMax: loadIsMax ?? this.loadIsMax,
      freeText: freeText,
      comment: comment,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      groupTitle: groupTitle,
      items: items ?? this.items,
    );
  }

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
