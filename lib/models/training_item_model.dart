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

  /// Human-readable load, e.g. "+35 kg", "100 %BW", "MAX", or "BW".
  String get label {
    if (isMax) return 'MAX';
    if (isBodyweight) return 'BW';
    final n = value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    final u = switch (unit) {
      'percent_bw' => '%BW',
      'bw' => 'BW',
      _ => unit,
    };
    return '$n $u';
  }
}

/// Flattens nested JSON arrays into a single-level list. Per-rep fields such as
/// hand_positions are stored two-dimensionally for split-hand items
/// (one array per hand); flattening keeps parsing robust to both shapes.
List<dynamic> flattenJsonList(dynamic raw) {
  if (raw is! List) return raw == null ? const [] : [raw];
  final out = <dynamic>[];
  for (final element in raw) {
    if (element is List) {
      out.addAll(flattenJsonList(element));
    } else {
      out.add(element);
    }
  }
  return out;
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

  // Hand: 'both', 'split', 'left', 'right'
  final String? hand;

  // Per-rep arrays (sized by reps for repeater, size 1 for hangboard_rep)
  final List<Load>? loads;
  final List<Load>? leftLoads;
  final List<String>? handPositions;
  final List<int>? edgeSizesMm;

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
    this.loads,
    this.leftLoads,
    this.handPositions,
    this.edgeSizesMm,
    this.loadIsMax = false,
    this.freeText,
    this.comment,
    this.exerciseId,
    this.exerciseName,
    this.groupTitle,
    this.items = const [],
  });

  /// Reps to perform when this is a rep-based item, null otherwise.
  /// An item is never both rep-based and time-based.
  int? get effectiveReps => (reps ?? 0) > 0 ? reps : null;

  /// Duration in seconds when this is a time-based item, null otherwise.
  int? get effectiveDuration => (duration ?? 0) > 0 ? duration : null;

  /// First-rep load shown to the user, or null when bodyweight / unset.
  String? get loadLabel {
    final first = loads?.firstOrNull;
    if (loadIsMax || (first?.isMax ?? false)) return 'MAX';
    if (first == null || first.isBodyweight) return null;
    return first.label;
  }

  /// Whether this item can be performed with the crimpy force sensor: a
  /// single-hand hangboard/repeater item with a non-bodyweight target load.
  bool get usesSensor {
    if (type != TrainingItemType.hangboardRep &&
        type != TrainingItemType.repeater) {
      return false;
    }
    if (hand == null || hand == 'both') return false;
    bool hasLoad(List<Load>? l) => (l ?? []).any((e) => !e.isBodyweight);
    return hasLoad(loads) || hasLoad(leftLoads);
  }

  factory TrainingItem.fromJson(Map<String, dynamic> json) {
    List<Load>? parseLoads(dynamic raw) {
      final flat = flattenJsonList(raw);
      if (flat.isEmpty) return null;
      return flat.whereType<Map<String, dynamic>>().map(Load.fromJson).toList();
    }

    List<String>? parseStringList(dynamic raw) {
      final flat = flattenJsonList(raw);
      if (flat.isEmpty) return null;
      return flat.map((e) => e.toString()).toList();
    }

    List<int>? parseIntList(dynamic raw) {
      final flat = flattenJsonList(raw);
      if (flat.isEmpty) return null;
      return flat.whereType<num>().map((e) => e.toInt()).toList();
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
      loads: parseLoads(json['loads']),
      leftLoads: parseLoads(json['left_loads']),
      handPositions: parseStringList(json['hand_positions']),
      edgeSizesMm: parseIntList(json['edge_sizes_mm']),
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
    int? worktimeSeconds,
    int? restSeconds,
    int? cycles,
    int? cycleRestSeconds,
    int? reps,
    int? duration,
    String? hand,
    List<Load>? loads,
    List<Load>? leftLoads,
    List<String>? handPositions,
    List<int>? edgeSizesMm,
    bool? loadIsMax,
    List<TrainingItem>? items,
  }) {
    return TrainingItem(
      id: id,
      type: type,
      position: position,
      parentId: parentId,
      worktimeSeconds: worktimeSeconds ?? this.worktimeSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      cycles: cycles ?? this.cycles,
      cycleRestSeconds: cycleRestSeconds ?? this.cycleRestSeconds,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      hand: hand ?? this.hand,
      loads: loads ?? this.loads,
      leftLoads: leftLoads ?? this.leftLoads,
      handPositions: handPositions ?? this.handPositions,
      edgeSizesMm: edgeSizesMm ?? this.edgeSizesMm,
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

    List<Load>? parseLoads(dynamic raw) {
      if (raw == null) return null;
      return flattenJsonList(
        raw,
      ).whereType<Map<String, dynamic>>().map(Load.fromJson).toList();
    }

    final bothHands = override['both_hands'] as bool?;
    return copyWith(
      loads: parseLoads(override['loads']),
      leftLoads: parseLoads(override['left_loads']),
      handPositions: override['hand_positions'] == null
          ? null
          : flattenJsonList(
              override['hand_positions'],
            ).map((e) => e.toString()).toList(),
      edgeSizesMm: override['edge_sizes_mm'] == null
          ? null
          : flattenJsonList(
              override['edge_sizes_mm'],
            ).whereType<num>().map((e) => e.toInt()).toList(),
      reps: (override['reps'] as num?)?.toInt(),
      cycles: (override['cycles'] as num?)?.toInt(),
      cycleRestSeconds: (override['cycle_rest_seconds'] as num?)?.toInt(),
      restSeconds: (override['rest_seconds'] as num?)?.toInt(),
      worktimeSeconds: (override['hb_worktime_seconds'] as num?)?.toInt(),
      hand: bothHands == null ? null : (bothHands ? 'both' : 'split'),
    );
  }
}
