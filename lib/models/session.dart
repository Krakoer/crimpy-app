import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/utils/datetimes.dart';

/// What the athlete reported about one pass through a prescribed item. It
/// started as the two counts the prescription itself leaves open, an AMRAP with
/// no rep count until it has been run and an emom the athlete dropped out of,
/// and now carries what they did on any step at all: the set of pull ups that
/// passed through no sensor, the dip taken at a load nobody prescribed, and the
/// line of text that is the whole of the coaching loop.
///
/// Every reported field is nullable, since a pass reports whichever of them the
/// athlete has something to say about. A pass reporting none of them is not
/// worth storing, which is what [reported] is asked before writing one.
class SessionItemResultModel {
  /// The prescription item the report answers, keyed the way a rep is.
  final String trainingItemId;

  /// Which pass through that item the report belongs to, from 0.
  final int occurrence;

  /// How many repetitions the pass did, which an AMRAP has no other record of.
  final int? reps;

  /// How many rounds of a block the pass was carried through before the athlete
  /// dropped out, which an emom has no other record of.
  final int? cycles;

  /// The load the pass was actually worked at, in kilograms, reported rather
  /// than measured so it covers the steps no sensor sees.
  final double? loadKg;

  /// How long the pass actually held, in seconds.
  final int? durationSeconds;

  /// What the athlete wrote about the pass.
  final String? note;

  const SessionItemResultModel({
    required this.trainingItemId,
    required this.occurrence,
    this.reps,
    this.cycles,
    this.loadKg,
    this.durationSeconds,
    this.note,
  });

  /// Whether the pass says anything at all. A report of nothing is dropped
  /// rather than sent, which is what the server does with one anyway.
  bool get reported =>
      reps != null ||
      cycles != null ||
      loadKg != null ||
      durationSeconds != null ||
      (note != null && note!.trim().isNotEmpty);

  factory SessionItemResultModel.fromJson(Map<String, dynamic> json) =>
      SessionItemResultModel(
        trainingItemId: json['training_item_id'] as String,
        occurrence: (json['occurrence'] as num?)?.toInt() ?? 0,
        reps: (json['reps'] as num?)?.toInt(),
        cycles: (json['cycles'] as num?)?.toInt(),
        loadKg: (json['load_kg'] as num?)?.toDouble(),
        durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
        note: json['note'] as String?,
      );

  /// The report as the API takes it, with every field the pass said nothing
  /// about left out rather than sent as a zero the athlete never gave.
  Map<String, dynamic> toJson() => {
    'training_item_id': trainingItemId,
    'occurrence': occurrence,
    if (reps != null) 'reps': reps,
    if (cycles != null) 'cycles': cycles,
    if (loadKg != null) 'load_kg': loadKg,
    if (durationSeconds != null) 'duration_seconds': durationSeconds,
    if (note != null) 'note': note,
  };

  /// The same report, answering [trainingItemId] instead. The guest import
  /// rewrites the local item id into the one the server minted for it, since
  /// the report is stored against an item the server has never seen.
  SessionItemResultModel withTrainingItem(String trainingItemId) =>
      SessionItemResultModel(
        trainingItemId: trainingItemId,
        occurrence: occurrence,
        reps: reps,
        cycles: cycles,
        loadKg: loadKg,
        durationSeconds: durationSeconds,
        note: note,
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

  /// What the coach answered the [notes] with, null while they have not.
  /// [coachReplyAt] dates that answer and [coachReplyRead] says whether it has
  /// been opened since it was last written, which is what the unread badge and
  /// the notification are raised from. Always null on a guest-mode session:
  /// there is no coach to answer one.
  final String? coachReply;
  final DateTime? coachReplyAt;
  final bool coachReplyRead;

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
    this.coachReply,
    this.coachReplyAt,
    this.coachReplyRead = false,
    date,
  }) : date = date ?? DateTime.now();

  /// Whether the coach has answered and the athlete has not opened it yet.
  bool get hasUnreadCoachReply => coachReply != null && !coachReplyRead;

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
    date: parseApiInstant(json['date'] as String),
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
    coachReply: json['coach_reply'] as String?,
    coachReplyAt: tryParseApiInstant(json['coach_reply_at'] as String?),
    coachReplyRead: json['coach_reply_read'] as bool? ?? false,
  );

  /// The prescription this session has to hand over for anything to be keyed
  /// against it, or null when it has none worth sending.
  ///
  /// Null when the store can resolve one for itself, which it does from the
  /// training or the coach slot the session names. Null too when the snapshot
  /// holds a step with no name: the API refuses the whole request over one, so
  /// sending it would cost the run rather than the reports it could not carry.
  /// Sessions frozen before a generated step had a name of its own are exactly
  /// that case, and they are already on devices waiting to be imported.
  List<TrainingItem>? get ownPrescription {
    if (trainingId != null || programSessionId != null) return null;
    final items = prescriptionItems;
    if (items == null || items.isEmpty) return null;
    return everyItemIsNamed(items) ? items : null;
  }

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
    coachReply: coachReply,
    coachReplyAt: coachReplyAt,
    coachReplyRead: coachReplyRead,
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
    coachReply: coachReply,
    coachReplyAt: coachReplyAt,
    coachReplyRead: coachReplyRead,
  );

  /// The same session with the coach's answer marked as seen, so the list can
  /// drop its badge without refetching every session.
  SessionModel withCoachReplyRead() => SessionModel(
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
    coachReply: coachReply,
    coachReplyAt: coachReplyAt,
    coachReplyRead: true,
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
