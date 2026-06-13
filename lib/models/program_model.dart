import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training_model.dart';

/// Maps a backend training_type string to the app SessionType.
SessionType sessionTypeFromApi(String? value) => switch (value) {
  'crimpy' => SessionType.crimpy,
  'climbing' => SessionType.climbing,
  'stretching' => SessionType.stretching,
  'workout' => SessionType.workout,
  _ => SessionType.crimpy,
};

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// A coach-assigned training program (metadata only, schedule lives in weeks).
class Program {
  final String id;
  final String coachId;
  final String userId;
  final String name;
  final String? objective;
  final DateTime startDate;
  final int? durationWeeks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Program({
    required this.id,
    required this.coachId,
    required this.userId,
    required this.name,
    this.objective,
    required this.startDate,
    this.durationWeeks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Program.fromJson(Map<String, dynamic> json) => Program(
    id: json['id'] as String,
    coachId: json['coach_id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    objective: json['objective'] as String?,
    startDate: DateTime.parse(json['start_date'] as String),
    durationWeeks: (json['duration_weeks'] as num?)?.toInt(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  /// Inclusive last day of the program, or null when duration is unset.
  DateTime? get endDate => durationWeeks == null
      ? null
      : _dateOnly(startDate).add(Duration(days: durationWeeks! * 7 - 1));

  /// 1-based week number containing [day], clamped to at least 1.
  int currentWeekNumber(DateTime day) {
    final diff = _dateOnly(day).difference(_dateOnly(startDate)).inDays;
    final week = (diff ~/ 7) + 1;
    return week < 1 ? 1 : week;
  }

  /// Whether [day] falls within the program span.
  bool isActiveOn(DateTime day) {
    final d = _dateOnly(day);
    if (d.isBefore(_dateOnly(startDate))) return false;
    final end = endDate;
    return end == null || !d.isAfter(end);
  }
}

/// A week entry in the program list (no sessions).
class WeekSummary {
  final String id;
  final String programId;
  final int weekNumber;
  final String? notes;

  const WeekSummary({
    required this.id,
    required this.programId,
    required this.weekNumber,
    this.notes,
  });

  factory WeekSummary.fromJson(Map<String, dynamic> json) => WeekSummary(
    id: json['id'] as String,
    programId: json['program_id'] as String,
    weekNumber: (json['week_number'] as num).toInt(),
    notes: json['notes'] as String?,
  );
}

/// A fully detailed week with its scheduled sessions.
class Week {
  final String id;
  final String programId;
  final int weekNumber;
  final String? notes;
  final List<WeekSession> sessions;

  const Week({
    required this.id,
    required this.programId,
    required this.weekNumber,
    this.notes,
    this.sessions = const [],
  });

  factory Week.fromJson(Map<String, dynamic> json) => Week(
    id: json['id'] as String,
    programId: json['program_id'] as String,
    weekNumber: (json['week_number'] as num).toInt(),
    notes: json['notes'] as String?,
    sessions:
        (json['sessions'] as List<dynamic>? ?? [])
            .map((e) => WeekSession.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position)),
  );

  /// Sessions placed on a specific day of the week, ordered by day then position.
  List<WeekSession> get scheduledSessions =>
      sessions.where((s) => s.dayOfWeek != null).toList()
        ..sort((a, b) => a.dayOfWeek!.compareTo(b.dayOfWeek!));

  /// Sessions to be done any day (times_per_week or everyday).
  List<WeekSession> get flexibleSessions =>
      sessions.where((s) => s.dayOfWeek == null).toList();
}

/// How a session is scheduled within a week.
enum SessionSchedule { dayOfWeek, timesPerWeek, everyday }

/// A training scheduled within a week of a program.
class WeekSession {
  final String id;
  final String trainingId;
  final String trainingTitle;
  final String trainingType;
  final int? dayOfWeek; // 0=Mon ... 6=Sun
  final int? timesPerWeek;
  final bool isEveryday;
  final int position;
  final String? notes;
  final List<SessionOverride> overrides;

  const WeekSession({
    required this.id,
    required this.trainingId,
    required this.trainingTitle,
    required this.trainingType,
    this.dayOfWeek,
    this.timesPerWeek,
    this.isEveryday = false,
    required this.position,
    this.notes,
    this.overrides = const [],
  });

  factory WeekSession.fromJson(Map<String, dynamic> json) => WeekSession(
    id: json['id'] as String,
    trainingId: json['training_id'] as String,
    trainingTitle: json['training_title'] as String? ?? '',
    trainingType: json['training_type'] as String? ?? '',
    dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
    timesPerWeek: (json['times_per_week'] as num?)?.toInt(),
    isEveryday: json['is_everyday'] as bool? ?? false,
    position: (json['position'] as num?)?.toInt() ?? 0,
    notes: json['notes'] as String?,
    overrides: (json['overrides'] as List<dynamic>? ?? [])
        .map((e) => SessionOverride.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  SessionType get sessionType => sessionTypeFromApi(trainingType);

  SessionSchedule get schedule {
    if (dayOfWeek != null) return SessionSchedule.dayOfWeek;
    if (isEveryday) return SessionSchedule.everyday;
    return SessionSchedule.timesPerWeek;
  }

  /// Calendar date of this session, given the owning program and week number.
  /// Null for flexible (non day-of-week) sessions.
  DateTime? scheduledDate(Program program, int weekNumber) {
    if (dayOfWeek == null) return null;
    return _dateOnly(
      program.startDate,
    ).add(Duration(days: (weekNumber - 1) * 7 + dayOfWeek!));
  }
}

/// A sparse per-item override applied on top of a training template.
class SessionOverride {
  final String id;
  final String itemId;
  final Map<String, dynamic> overrides;

  const SessionOverride({
    required this.id,
    required this.itemId,
    required this.overrides,
  });

  factory SessionOverride.fromJson(Map<String, dynamic> json) =>
      SessionOverride(
        id: json['id'] as String,
        itemId: json['item_id'] as String,
        overrides: (json['overrides'] as Map<String, dynamic>? ?? {}),
      );
}

/// Applies a session's sparse per-item overrides on top of a training template,
/// walking the full item tree and matching by item id.
Training effectiveTraining(Training base, List<SessionOverride> overrides) {
  if (overrides.isEmpty) return base;
  final byItemId = {for (final o in overrides) o.itemId: o.overrides};

  List<TrainingItem> apply(List<TrainingItem> items) => items.map((item) {
    final merged = byItemId.containsKey(item.id)
        ? item.applyOverride(byItemId[item.id]!)
        : item;
    if (merged.items.isEmpty) return merged;
    return merged.copyWith(items: apply(merged.items));
  }).toList();

  return Training(
    id: base.id,
    title: base.title,
    description: base.description,
    isFavorite: base.isFavorite,
    items: apply(base.items),
  );
}
