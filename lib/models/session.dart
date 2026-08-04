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
  final SessionType sessionType;
  final int? durationInSeconds;
  final RepeaterConfig? repeaterConfig;

  SessionModel({
    this.id,
    this.notes,
    this.dataPoints,
    this.reps,
    required this.name,
    required this.isAssessment,
    this.sessionType = SessionType.crimpy,
    this.durationInSeconds,
    this.repeaterConfig,
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
    sessionType: enumFromIndex(
      SessionType.values,
      json['SessionType'] as num?,
      SessionType.crimpy,
    ),
    durationInSeconds: (json['Duration'] as num? ?? 0).toInt(),
    repeaterConfig: RepeaterConfig.fromJson(json),
  );

  int get duration =>
      durationInSeconds ??
      (reps == null ? 0 : reps!.fold(0, (prev, r) => prev + r.duration));
}

class RepDataModel {
  final double averageWeight;
  final bool isRest;
  final HandSide handSide;
  final int duration;
  final double targetWeight;
  final int index;
  final GripPosition gripPosition;

  RepDataModel({
    required this.averageWeight,
    required this.duration,
    required this.index,
    required this.isRest,
    required this.handSide,
    required this.targetWeight,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
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
