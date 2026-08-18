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

  /// Parses a session as returned by the API, which uses PascalCase keys.
  factory SessionModel.fromJson(
    Map<String, dynamic> json, {
    List<RepDataModel>? reps,
  }) => SessionModel(
    id: json['ID'] as String,
    name: json['Name'] as String,
    notes: json['Notes'] as String? ?? '',
    date: DateTime.parse(json['Date'] as String),
    reps: reps,
    isAssessment: json['IsAssessment'] as bool? ?? false,
    activity: enumFromIndex(
      SessionActivity.values,
      json['Activity'] as num?,
      SessionActivity.hangboard,
    ),
    origin: sessionOriginFromApi(json['Origin'] as String?),
    trainingId: json['TrainingID'] as String?,
    programSessionId: json['ProgramSessionID'] as String?,
    durationInSeconds: (json['Duration'] as num? ?? 0).toInt(),
    repeaterConfig: RepeaterConfig.fromJson(json),
    reportedRepCount: (json['RepCount'] as num?)?.toInt(),
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

  /// Parses a repetition as returned by the API, which uses PascalCase keys.
  factory RepDataModel.fromJson(Map<String, dynamic> json) => RepDataModel(
    averageWeight: (json['AverageWeight'] as num).toDouble(),
    duration: (json['Duration'] as num).toInt(),
    index: (json['Index'] as num).toInt(),
    isRest: json['IsRest'] as bool,
    handSide: (json['RightHand'] as bool) ? HandSide.right : HandSide.left,
    targetWeight: (json['TargetWeight'] as num).toDouble(),
    gripPosition: enumFromIndex(
      GripPosition.values,
      json['GripPosition'] as num?,
      GripPosition.halfCrimp,
    ),
    edgeSizeMm: (json['EdgeSizeMm'] as num?)?.toInt(),
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
  /// was not a repeater. The API returns these fields in PascalCase.
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
      sets: (json['RepeaterSets'] as num).toInt(),
      repsPerSet: (json['RepeaterReps'] as num).toInt(),
      workTime: (json['RepeaterWorkTime'] as num).toInt(),
      restTime: (json['RepeaterRestTime'] as num).toInt(),
      setRest: (json['RepeaterSetRest'] as num).toInt(),
      splitHand: json['RepeaterSplitHand'] as bool,
    );
  }
}
