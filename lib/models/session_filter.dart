import 'package:collection/collection.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';

/// Represents the filters available for filtering sessions.
///
/// Lives with the models rather than with the providers that happen to expose
/// it: the database and both repositories need it, and none of them should
/// have to reach into the viewmodel layer for a domain type.
class SessionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isAssessment;

  /// Keeps only these activities, or every one of them when empty.
  final Set<SessionActivity> activities;

  const SessionFilter({
    this.startDate,
    this.endDate,
    this.isAssessment,
    this.activities = const {},
  });

  @override
  bool operator ==(Object other) {
    return other is SessionFilter &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isAssessment == isAssessment &&
        const SetEquality<SessionActivity>().equals(
          other.activities,
          activities,
        );
  }

  @override
  int get hashCode => Object.hash(
    startDate,
    endDate,
    isAssessment,
    Object.hashAllUnordered(activities),
  );

  bool matchesSession(SessionModel session) {
    if (isAssessment != null && session.isAssessment != isAssessment) {
      return false;
    }
    if (activities.isNotEmpty && !activities.contains(session.activity)) {
      return false;
    }
    if (startDate != null && session.date.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && session.date.isAfter(endDate!)) {
      return false;
    }
    return true;
  }
}
