import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/critical_force_result.dart';
import 'package:crimpy/models/max_force_offer.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/datetimes.dart';

/// A run that finished and was not saved yet: everything its review screen is
/// built from, written to the device the moment the run ends so the app dying
/// on the review does not take the run with it. Krakoer/crimpy#146.
///
/// The review is always built from a draft, the one just written and the one
/// read back on the next launch alike, so a resumed review cannot differ from
/// the one the athlete left.
sealed class FinishedRunDraft {
  /// Who ran it: the signed in user's id, or [guestOwner]. A draft is offered
  /// back only to the same one, since saving it under another would put the run
  /// into another athlete's history, or into the store they just left.
  final String owner;

  const FinishedRunDraft({required this.owner});

  static const guestOwner = 'guest';

  /// Bumped whenever the shape changes, so a draft written by an older build is
  /// dropped rather than read into fields that no longer mean the same thing.
  static const _version = 1;

  /// What the offer on the next launch names the run by.
  String get title;

  /// When the run started, which dates it.
  DateTime get startedAt;

  Map<String, dynamic> toJson() => {
    'version': _version,
    'owner': owner,
    ..._fieldsToJson(),
  };

  Map<String, dynamic> _fieldsToJson();

  /// Reads a draft back, or throws [FormatException] for one this build cannot
  /// read, which the store drops.
  static FinishedRunDraft fromJson(Map<String, dynamic> json) {
    if (json['version'] != _version) {
      throw FormatException('Unknown draft version ${json['version']}');
    }
    final owner = json['owner'] as String;
    return switch (json['kind']) {
      TrainingReviewDraft._kind => TrainingReviewDraft._fromJson(owner, json),
      CriticalForceResultDraft._kind => CriticalForceResultDraft._fromJson(
        owner,
        json,
      ),
      final kind => throw FormatException('Unknown draft kind $kind'),
    };
  }
}

/// A training run waiting on its review: the inputs of the post workout screen.
class TrainingReviewDraft extends FinishedRunDraft {
  static const _kind = 'training_review';

  final Training template;
  final List<RepDataModel> results;
  @override
  final DateTime startedAt;
  final List<SessionItemResultModel> itemResults;
  final List<MeasuredPull> measuredPulls;
  final AssessmentResults assessmentResults;
  final double? bodyweightKg;
  final SessionActivity activity;
  final String? trainingId;
  final String? programSessionId;

  const TrainingReviewDraft({
    required super.owner,
    required this.template,
    required this.results,
    required this.startedAt,
    this.itemResults = const [],
    this.measuredPulls = const [],
    this.assessmentResults = AssessmentResults.none,
    this.bodyweightKg,
    this.activity = SessionActivity.hangboard,
    this.trainingId,
    this.programSessionId,
  });

  @override
  String get title => template.title;

  @override
  Map<String, dynamic> _fieldsToJson() => {
    'kind': _kind,
    'template': _trainingToJson(template),
    'results': [for (final rep in results) rep.toJson()],
    'started_at': startedAt.toUtc().toIso8601String(),
    'item_results': [for (final result in itemResults) result.toJson()],
    'measured_pulls': [for (final pull in measuredPulls) pull.toJson()],
    'assessment_results': _assessmentResultsToJson(assessmentResults),
    if (bodyweightKg != null) 'bodyweight_kg': bodyweightKg,
    'activity': activity.index,
    if (trainingId != null) 'training_id': trainingId,
    if (programSessionId != null) 'program_session_id': programSessionId,
  };

  static TrainingReviewDraft _fromJson(
    String owner,
    Map<String, dynamic> json,
  ) => TrainingReviewDraft(
    owner: owner,
    template: _trainingFromJson(json['template'] as Map<String, dynamic>),
    results: _maps(json['results']).map(RepDataModel.fromJson).toList(),
    startedAt: parseApiInstant(json['started_at'] as String),
    itemResults: _maps(
      json['item_results'],
    ).map(SessionItemResultModel.fromJson).toList(),
    measuredPulls: _maps(
      json['measured_pulls'],
    ).map(MeasuredPull.fromJson).toList(),
    assessmentResults: _assessmentResultsFromJson(
      json['assessment_results'] as Map<String, dynamic>,
    ),
    bodyweightKg: (json['bodyweight_kg'] as num?)?.toDouble(),
    activity: enumFromIndex(
      SessionActivity.values,
      json['activity'] as num?,
      SessionActivity.hangboard,
    ),
    trainingId: json['training_id'] as String?,
    programSessionId: json['program_session_id'] as String?,
  );
}

/// A Critical Force run waiting on its result being saved: what the result
/// screen shows and what its save writes. The analysis is not stored but run
/// again on the readings it was run on, which gives the same result.
class CriticalForceResultDraft extends FinishedRunDraft {
  static const _kind = 'critical_force_result';

  final double? previousCriticalForce;
  final AssessmentResultModel saveAssessment;
  final SessionModel saveSession;
  final List<RepDataModel> saveReps;
  final List<BleDataPoint> data;
  final List<CriticalForceSample> samples;
  final List<CriticalForceWindow> pullWindows;
  final int pausedSeconds;

  /// The hand and edge the test was pulled with, which its share of max and
  /// the Max Force its hardest pull may beat are read on. The grip is the
  /// one the result is recorded on.
  final HandSide hand;
  final int? edgeSizeMm;

  GripPosition get gripPosition =>
      saveAssessment.gripPosition ?? GripPosition.halfCrimp;

  const CriticalForceResultDraft({
    required super.owner,
    required this.hand,
    required this.edgeSizeMm,
    required this.saveAssessment,
    required this.saveSession,
    required this.saveReps,
    required this.data,
    required this.samples,
    required this.pullWindows,
    this.pausedSeconds = 0,
    this.previousCriticalForce,
  });

  @override
  String get title => saveSession.name;

  @override
  DateTime get startedAt => saveSession.date;

  @override
  Map<String, dynamic> _fieldsToJson() => {
    'kind': _kind,
    if (previousCriticalForce != null)
      'previous_critical_force': previousCriticalForce,
    'assessment': {
      'assessment_id': saveAssessment.assessmentId,
      if (saveAssessment.rightValue != null)
        'right_value': saveAssessment.rightValue,
      if (saveAssessment.leftValue != null)
        'left_value': saveAssessment.leftValue,
      if (saveAssessment.gripPosition != null)
        'grip_position': saveAssessment.gripPosition!.name,
      if (saveAssessment.details != null) 'details': saveAssessment.details,
    },
    'hand': hand.name,
    // Written even when null, so a draft without an edge reads back without
    // one rather than as a draft kept before the edge was.
    'edge_size_mm': edgeSizeMm,
    'session': {
      'name': saveSession.name,
      'date': saveSession.date.toUtc().toIso8601String(),
    },
    'reps': [for (final rep in saveReps) rep.toJson()],
    'data': ForceCurve.toJson(data),
    'samples': [
      for (final sample in samples) [sample.t, sample.kg],
    ],
    'pull_windows': [
      for (final window in pullWindows) [window.start, window.end],
    ],
    'paused_seconds': pausedSeconds,
  };

  static CriticalForceResultDraft _fromJson(
    String owner,
    Map<String, dynamic> json,
  ) {
    final assessment = json['assessment'] as Map<String, dynamic>;
    final session = json['session'] as Map<String, dynamic>;
    List<(double, double)> pairs(Object? raw) => [
      for (final pair in (raw as List<dynamic>).cast<List<dynamic>>())
        ((pair[0] as num).toDouble(), (pair[1] as num).toDouble()),
    ];
    final rightValue = (assessment['right_value'] as num?)?.toDouble();
    final grip = assessment['grip_position'] as String?;
    return CriticalForceResultDraft(
      owner: owner,
      // A draft kept before these were stored: the hand its value is on, and
      // the protocol's own edge.
      hand: switch (json['hand']) {
        final String name => HandSide.values.byName(name),
        _ => rightValue != null ? HandSide.right : HandSide.left,
      },
      edgeSizeMm: json.containsKey('edge_size_mm')
          ? (json['edge_size_mm'] as num?)?.toInt()
          : BuiltinAssessmentIds.maxForceEdgeSizeMm,
      previousCriticalForce: (json['previous_critical_force'] as num?)
          ?.toDouble(),
      saveAssessment: AssessmentResultModel(
        assessmentId: assessment['assessment_id'] as String,
        rightValue: rightValue,
        leftValue: (assessment['left_value'] as num?)?.toDouble(),
        gripPosition: grip == null ? null : GripPosition.values.byName(grip),
        details: (assessment['details'] as Map<String, dynamic>?)
            ?.cast<String, Object?>(),
      ),
      saveSession: SessionModel(
        name: session['name'] as String,
        date: parseApiInstant(session['date'] as String),
        isAssessment: true,
        origin: SessionOrigin.played,
      ),
      saveReps: _maps(json['reps']).map(RepDataModel.fromJson).toList(),
      data: ForceCurve.fromJson(json['data'] as Map<String, dynamic>?),
      samples: [for (final (t, kg) in pairs(json['samples'])) (t: t, kg: kg)],
      pullWindows: [
        for (final (start, end) in pairs(json['pull_windows']))
          (start: start, end: end),
      ],
      pausedSeconds: (json['paused_seconds'] as num?)?.toInt() ?? 0,
    );
  }
}

List<Map<String, dynamic>> _maps(Object? raw) =>
    (raw as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

/// The training as it was played, ids and all. Not [Training.toJson], which is
/// the write payload and leaves the id and the referenced assessments out: the
/// reps and the review key on the item ids, and the prescription snapshot is
/// the shape that keeps them, the one the local store freezes a session's
/// prescription in.
Map<String, dynamic> _trainingToJson(Training training) => {
  'id': training.id,
  'title': training.title,
  if (training.description != null) 'description': training.description,
  if (training.goal != null) 'goal': training.goal,
  if (training.comment != null) 'comment': training.comment,
  'items': [for (final item in training.items) item.toPrescriptionJson()],
  if (training.assessment != null) 'assessment': training.assessment!.toJson(),
  'referenced_assessments': [
    for (final definition in training.referencedAssessments)
      definition.toJson(),
  ],
  'reviews_each_step': training.reviewsEachStep,
};

Training _trainingFromJson(Map<String, dynamic> json) {
  final read = Training.fromJson(json);
  // Never read from a store, so fromJson does not know it; kept because a
  // generated training asks for no line per step, and the resumed review must
  // not start asking for one.
  final reviewsEachStep = json['reviews_each_step'] as bool? ?? true;
  return reviewsEachStep
      ? read
      : Training(
          id: read.id,
          title: read.title,
          description: read.description,
          goal: read.goal,
          comment: read.comment,
          items: read.items,
          assessment: read.assessment,
          referencedAssessments: read.referencedAssessments,
          reviewsEachStep: false,
        );
}

/// The numbers the run was played against, stored rather than looked up again
/// on resume: a result recorded since would change the loads the review
/// states from the ones the athlete hung.
Map<String, dynamic> _assessmentResultsToJson(AssessmentResults results) => {
  'last': {
    for (final MapEntry(key: id, value: values) in results.lastById.entries)
      id: {
        if (values.right != null) 'right': values.right,
        if (values.left != null) 'left': values.left,
      },
  },
  'definitions': [
    for (final definition in results.definitions.values) definition.toJson(),
  ],
};

AssessmentResults _assessmentResultsFromJson(Map<String, dynamic> json) {
  final last = (json['last'] as Map<String, dynamic>? ?? const {}).map((
    id,
    raw,
  ) {
    final values = raw as Map<String, dynamic>;
    return MapEntry(
      id,
      AssessmentHandValues(
        right: (values['right'] as num?)?.toDouble(),
        left: (values['left'] as num?)?.toDouble(),
      ),
    );
  });
  final definitions = [
    for (final raw in _maps(json['definitions']))
      AssessmentDefinition.fromJson(raw),
  ];
  return AssessmentResults(
    last,
    definitions: {
      for (final definition in definitions) definition.id: definition,
    },
  );
}
