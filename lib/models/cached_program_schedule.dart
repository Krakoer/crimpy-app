import 'package:crimpy/models/program_model.dart';

/// A local copy of the active program schedule, kept so reminders can be
/// planned while offline. Programs are server-owned and never persisted
/// otherwise, so without this the reminders would only work online.
class CachedProgramSchedule {
  final Program program;

  /// The weeks covering the reminder horizon, ordered by week number. Weeks the
  /// coach has not published yet are simply absent.
  final List<Week> weeks;

  final DateTime cachedAt;

  const CachedProgramSchedule({
    required this.program,
    required this.weeks,
    required this.cachedAt,
  });

  Week? weekNumbered(int weekNumber) {
    for (final week in weeks) {
      if (week.weekNumber == weekNumber) return week;
    }
    return null;
  }

  factory CachedProgramSchedule.fromJson(Map<String, dynamic> json) =>
      CachedProgramSchedule(
        program: Program.fromJson(json['program'] as Map<String, dynamic>),
        weeks: (json['weeks'] as List<dynamic>? ?? [])
            .map((e) => Week.fromJson(e as Map<String, dynamic>))
            .toList(),
        cachedAt: DateTime.parse(json['cached_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'program': program.toJson(),
    'weeks': weeks.map((w) => w.toJson()).toList(),
    'cached_at': cachedAt.toIso8601String(),
  };
}
