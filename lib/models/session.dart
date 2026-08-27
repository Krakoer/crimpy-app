import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_item_model.dart';

/// Which open field a count answers, mirroring the field column the server
/// stores it in.
enum SessionItemField {
  reps,
  cycles;

  static SessionItemField fromApi(String? value) =>
      value == 'cycles' ? SessionItemField.cycles : SessionItemField.reps;

  String get apiValue => name;
}

/// A count the run resolved for an item the prescription left open: the reps an
/// AMRAP turned out to be, or the rounds an emom was carried through before the
/// athlete dropped out. Neither is recorded anywhere else, since a set of pull
/// ups passes through no sensor and so leaves no rep behind.
class SessionItemResultModel {
  /// The prescription item the count answers, keyed the way a rep is.
  final String trainingItemId;

  /// Which pass through that item the count belongs to, from 0.
  final int occurrence;

  final SessionItemField field;
  final int value;

  const SessionItemResultModel({
    required this.trainingItemId,
    required this.occurrence,
    required this.field,
    required this.value,
  });

  factory SessionItemResultModel.fromJson(Map<String, dynamic> json) =>
      SessionItemResultModel(
        trainingItemId: json['training_item_id'] as String,
        occurrence: (json['occurrence'] as num?)?.toInt() ?? 0,
        field: SessionItemField.fromApi(json['field'] as String?),
        value: (json['value'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'training_item_id': trainingItemId,
    'occurrence': occurrence,
    'field': field.apiValue,
    'value': value,
  };

  /// The same count, answering [trainingItemId] instead. The guest import
  /// rewrites the local item id into the one the server minted for it, since
  /// the count is stored against an item the server has never seen.
  SessionItemResultModel withTrainingItem(String trainingItemId) =>
      SessionItemResultModel(
        trainingItemId: trainingItemId,
        occurrence: occurrence,
        field: field,
        value: value,
      );
}

class SessionModel {
  final String? id;
  final String name;
  final String? notes;
  final DateTime date;
  final List<BleDataPoint>? dataPoints;
  final List<RepDataModel>? reps;
  final bool isAssessment;
  final SessionActivity activity;
  final SessionOrigin origin;

  /// Template the session was played from, kept so it can be shown against what
  /// was prescribed and so its reps can name the blocks they came from. The
  /// training is set for any run started from one, the athlete's own included;
  /// the program session only for a run stepped through a coach's week. Both
  /// null on a logged session and on a builtin, which has no row to link to.
  final String? trainingId;
  final String? programSessionId;
  final int? durationInSeconds;

  /// How many reps the session holds, as reported by a listing that did not
  /// carry the reps themselves. Null when unknown; [repCount] prefers the reps
  /// when they are loaded.
  final int? reportedRepCount;

  /// What the athlete was asked to do, frozen onto the session by the server
  /// when it was created. It is the only copy that cannot drift as the training
  /// is edited afterwards, and the only one an athlete can read for a training
  /// their coach owns, so it is what the reps are read block by block against.
  /// Null on a session the server never saw, a guest-mode run among them.
  final List<TrainingItem>? prescriptionItems;

  /// What the run answered the open items of the prescription with, empty when
  /// it had none. Only the detail endpoint carries them.
  final List<SessionItemResultModel> itemResults;

  SessionModel({
    this.id,
    this.notes,
    this.dataPoints,
    this.reps,
    required this.name,
    required this.isAssessment,
    required this.origin,
    this.activity = SessionActivity.hangboard,
    this.trainingId,
    this.programSessionId,
    this.durationInSeconds,
    this.reportedRepCount,
    this.prescriptionItems,
    this.itemResults = const [],
    date,
  }) : date = date ?? DateTime.now();

  /// Parses a session as returned by the API, which speaks snake_case in
  /// both directions.
  factory SessionModel.fromJson(
    Map<String, dynamic> json, {
    List<RepDataModel>? reps,
    List<SessionItemResultModel> itemResults = const [],
    List<BleDataPoint>? dataPoints,
  }) => SessionModel(
    id: json['id'] as String,
    name: json['name'] as String,
    notes: json['notes'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
    reps: reps,
    dataPoints: dataPoints,
    isAssessment: json['is_assessment'] as bool? ?? false,
    activity: enumFromIndex(
      SessionActivity.values,
      json['activity'] as num?,
      SessionActivity.hangboard,
    ),
    origin: sessionOriginFromApi(json['origin'] as String?),
    trainingId: json['training_id'] as String?,
    programSessionId: json['program_session_id'] as String?,
    durationInSeconds: (json['duration'] as num? ?? 0).toInt(),
    reportedRepCount: (json['rep_count'] as num?)?.toInt(),
    prescriptionItems: prescriptionItemsOf(json['prescription']),
    itemResults: itemResults,
  );

  /// The items of a frozen prescription, or null when there is none to read.
  /// The listing endpoint leaves the prescription out, so a session read from
  /// it has no items until its detail is loaded.
  ///
  /// Public because the local store freezes its own copy under the same
  /// envelope the server sends, and reads it back through here: one shape and
  /// one reader, so the two stores cannot answer the same session differently.
  static List<TrainingItem>? prescriptionItemsOf(Object? prescription) {
    if (prescription is! Map<String, dynamic>) return null;
    final raw = prescription['items'];
    if (raw is! List) return null;
    return raw
        .whereType<Map<String, dynamic>>()
        .map(TrainingItem.fromJson)
        .toList();
  }

  /// Carries the untouched fields over, so an edit cannot quietly drop the
  /// origin or the template links the session was created with.
  SessionModel copyWith({
    String? name,
    String? notes,
    DateTime? date,
    int? durationInSeconds,
  }) => SessionModel(
    id: id,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    date: date ?? this.date,
    dataPoints: dataPoints,
    reps: reps,
    isAssessment: isAssessment,
    activity: activity,
    origin: origin,
    trainingId: trainingId,
    programSessionId: programSessionId,
    durationInSeconds: durationInSeconds ?? this.durationInSeconds,
    reportedRepCount: reportedRepCount,
    prescriptionItems: prescriptionItems,
    itemResults: itemResults,
  );

  /// The same session played from [trainingId], or from no training when it is
  /// null. Separate from [copyWith], which carries a field over when it is
  /// given none and so cannot clear one. The guest import needs both: it swaps
  /// the local training id for the one the server minted, and lets go of a
  /// training the athlete deleted after playing it.
  SessionModel withTrainingId(String? trainingId) => SessionModel(
    id: id,
    name: name,
    notes: notes,
    date: date,
    dataPoints: dataPoints,
    reps: reps,
    isAssessment: isAssessment,
    activity: activity,
    origin: origin,
    trainingId: trainingId,
    programSessionId: programSessionId,
    durationInSeconds: durationInSeconds,
    reportedRepCount: reportedRepCount,
    prescriptionItems: prescriptionItems,
    itemResults: itemResults,
  );

  int get duration =>
      durationInSeconds ??
      (reps == null ? 0 : reps!.fold(0, (prev, r) => prev + r.duration));

  /// Whether there is per-rep data to show. Presence of reps decides it, never
  /// the activity: a coach hangboard block logged under any label still has
  /// every rep the sensor recorded.
  bool get hasReps => reps != null && reps!.isNotEmpty;

  /// How many reps the session holds, from the reps themselves once loaded and
  /// from the listing otherwise. Null only when neither is available.
  int? get repCount => reps?.length ?? reportedRepCount;
}

class RepDataModel {
  final double averageWeight;
  final bool isRest;
  final HandSide handSide;
  final int duration;
  final double targetWeight;
  final int index;
  final GripPosition gripPosition;

  /// Depth of the edge the rep was pulled on, null when the step prescribed
  /// none: a rest, or an exercise done off the hangboard.
  final int? edgeSizeMm;

  /// Item of the training the rep was played from, so the reps of a session can
  /// be read block by block. Null for a rep recorded outside a training.
  final String? trainingItemId;

  /// Whether the step prescribed a load nothing measured, which is the sensor
  /// dropping while a hang it was meant to read was running. Such a rep carries
  /// no target, exactly as a step nothing was ever going to measure does, so
  /// this is what tells the two apart when a run is graded.
  final bool targetUnmeasured;

  RepDataModel({
    required this.averageWeight,
    required this.duration,
    required this.index,
    required this.isRest,
    required this.handSide,
    required this.targetWeight,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
    this.edgeSizeMm,
    this.trainingItemId,
    this.targetUnmeasured = false,
  });

  /// Parses a repetition as returned by the API.
  factory RepDataModel.fromJson(Map<String, dynamic> json) => RepDataModel(
    averageWeight: (json['average_weight'] as num).toDouble(),
    duration: (json['duration'] as num).toInt(),
    index: (json['index'] as num).toInt(),
    isRest: json['is_rest'] as bool,
    handSide: handSideFromApi(json['hand'] as String),
    targetWeight: (json['target_weight'] as num).toDouble(),
    gripPosition: enumFromIndex(
      GripPosition.values,
      json['grip_position'] as num?,
      GripPosition.halfCrimp,
    ),
    edgeSizeMm: (json['edge_size_mm'] as num?)?.toInt(),
    trainingItemId: json['training_item_id'] as String?,
    targetUnmeasured: json['target_unmeasured'] as bool? ?? false,
  );

  /// The same rep played from [trainingItemId], or from no item when it is
  /// null. The guest import rewrites the local item id into the one the server
  /// minted, and drops the link when the item is no longer there to rewrite.
  RepDataModel withTrainingItem(String? trainingItemId) => RepDataModel(
    averageWeight: averageWeight,
    duration: duration,
    index: index,
    isRest: isRest,
    handSide: handSide,
    targetWeight: targetWeight,
    gripPosition: gripPosition,
    edgeSizeMm: edgeSizeMm,
    trainingItemId: trainingItemId,
    targetUnmeasured: targetUnmeasured,
  );
}
