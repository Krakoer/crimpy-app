enum TrainingItemType {
  repeater,
  hangboardRep,
  free,
  exercise,
  circuit,
  section;

  static TrainingItemType fromString(String value) => switch (value) {
    'repeater' => TrainingItemType.repeater,
    'hangboard_rep' => TrainingItemType.hangboardRep,
    'free' => TrainingItemType.free,
    'exercise' => TrainingItemType.exercise,
    'circuit' => TrainingItemType.circuit,
    'section' => TrainingItemType.section,
    _ => TrainingItemType.free,
  };

  String get apiValue => switch (this) {
    TrainingItemType.repeater => 'repeater',
    TrainingItemType.hangboardRep => 'hangboard_rep',
    TrainingItemType.free => 'free',
    TrainingItemType.exercise => 'exercise',
    TrainingItemType.circuit => 'circuit',
    TrainingItemType.section => 'section',
  };
}

class Load {
  final double value;
  final String unit;

  const Load({required this.value, required this.unit});

  static const Load bodyweight = Load(value: 0.0, unit: 'bw');

  factory Load.fromJson(Map<String, dynamic> json) => Load(
    value: (json['value'] as num).toDouble(),
    unit: json['unit'] as String,
  );

  Map<String, dynamic> toJson() => {'value': value, 'unit': unit};

  bool get isBodyweight => unit == 'bw' || value == 0.0;
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

  // Exercise reference
  final String? exerciseId;

  // Section label
  final String? sectionTitle;

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
    this.exerciseId,
    this.sectionTitle,
    this.items = const [],
  });

  factory TrainingItem.fromJson(Map<String, dynamic> json) {
    List<Load>? parseLoads(dynamic raw) {
      if (raw == null) return null;
      final list = raw as List<dynamic>;
      if (list.isEmpty) return null;
      return list.map((e) => Load.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<String>? parseStringList(dynamic raw) {
      if (raw == null) return null;
      final list = raw as List<dynamic>;
      if (list.isEmpty) return null;
      return list.map((e) => e as String).toList();
    }

    List<int>? parseIntList(dynamic raw) {
      if (raw == null) return null;
      final list = raw as List<dynamic>;
      if (list.isEmpty) return null;
      return list.map((e) => (e as num).toInt()).toList();
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
      exerciseId: json['exercise_id'] as String?,
      sectionTitle: json['section_title'] as String?,
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
    if (exerciseId != null) map['exercise_id'] = exerciseId;
    if (sectionTitle != null) map['section_title'] = sectionTitle;
    if (items.isNotEmpty) {
      map['items'] = items.map((i) => i.toJson()).toList();
    }
    return map;
  }
}
