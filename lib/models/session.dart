import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';

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
  /// was prescribed. Both null on a logged session.
  final String? trainingId;
  final String? programSessionId;
  final int? durationInSeconds;
  final RepeaterConfig? repeaterConfig;

  /// How many reps the session holds, as reported by a listing that did not
  /// carry the reps themselves. Null when unknown; [repCount] prefers the reps
  /// when they are loaded.
  final int? reportedRepCount;

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
    this.repeaterConfig,
    this.reportedRepCount,
    date,
  }) : date = date ?? DateTime.now();

  /// Parses a session as returned by the API, which speaks snake_case in
  /// both directions.
  factory SessionModel.fromJson(
    Map<String, dynamic> json, {
    List<RepDataModel>? reps,
  }) => SessionModel(
    id: json['id'] as String,
    name: json['name'] as String,
    notes: json['notes'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
    reps: reps,
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
    repeaterConfig: RepeaterConfig.fromJson(json),
    reportedRepCount: (json['rep_count'] as num?)?.toInt(),
  );

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
    repeaterConfig: repeaterConfig,
    reportedRepCount: reportedRepCount,
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

  RepDataModel({
    required this.averageWeight,
    required this.duration,
    required this.index,
    required this.isRest,
    required this.handSide,
    required this.targetWeight,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
    this.edgeSizeMm,
  });

  /// Parses a repetition as returned by the API.
  factory RepDataModel.fromJson(Map<String, dynamic> json) => RepDataModel(
    averageWeight: (json['average_weight'] as num).toDouble(),
    duration: (json['duration'] as num).toInt(),
    index: (json['index'] as num).toInt(),
    isRest: json['is_rest'] as bool,
    handSide: (json['right_hand'] as bool) ? HandSide.right : HandSide.left,
    targetWeight: (json['target_weight'] as num).toDouble(),
    gripPosition: enumFromIndex(
      GripPosition.values,
      json['grip_position'] as num?,
      GripPosition.halfCrimp,
    ),
    edgeSizeMm: (json['edge_size_mm'] as num?)?.toInt(),
  );
}

/// Stores repeater configuration for a session.
/// This is saved with the session so we can properly display sets later,
/// even if the original training template is modified or deleted.
class RepeaterConfig {
  final int sets;
  final int repsPerSet;
  final int workTime;
  final int restTime;
  final int setRest;
  final bool splitHand;

  const RepeaterConfig({
    required this.sets,
    required this.repsPerSet,
    required this.workTime,
    required this.restTime,
    required this.setRest,
    required this.splitHand,
  });

  /// Builds the config from an API session payload, or null when that session
  /// was not a repeater.
  static RepeaterConfig? fromJson(Map<String, dynamic> json) {
    const keys = [
      'RepeaterSets',
      'RepeaterReps',
      'RepeaterWorkTime',
      'RepeaterRestTime',
      'RepeaterSetRest',
      'RepeaterSplitHand',
    ];
    if (keys.any((k) => json[k] == null)) return null;
    return RepeaterConfig(
      sets: (json['repeater_sets'] as num).toInt(),
      repsPerSet: (json['repeater_reps'] as num).toInt(),
      workTime: (json['repeater_work_time'] as num).toInt(),
      restTime: (json['repeater_rest_time'] as num).toInt(),
      setRest: (json['repeater_set_rest'] as num).toInt(),
      splitHand: json['repeater_split_hand'] as bool,
    );
  }
}
