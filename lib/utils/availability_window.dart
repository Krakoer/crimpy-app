import 'package:crimpy/utils/datetimes.dart';

/// How many calendar weeks the availability screen lets the athlete edit: this
/// week and the next two. The week switcher offers exactly these, because
/// further out the athlete does not know and the coach is not writing it yet.
const int editableAvailabilityWeeks = 3;

/// The range of calendar weeks an availability listing was read for, both ends
/// inclusive and both Mondays.
///
/// Carried beside the weeks it produced so nothing answers for a week the
/// request could not have held. A window that does not cover a week says
/// nothing about it, which is not the same as the athlete not having declared
/// it: reading the second out of the first is what puts a week the athlete
/// already answered back on the screen as blank.
class AvailabilityWindow {
  final DateTime from;
  final DateTime to;

  AvailabilityWindow({required DateTime from, required DateTime to})
    : from = getStartOfWeek(from),
      to = getStartOfWeek(to);

  /// The weeks the availability screen can edit, as of [now].
  factory AvailabilityWindow.editable(DateTime now) {
    final from = getStartOfWeek(now);
    return AvailabilityWindow(
      from: from,
      to: addCalendarDays(from, (editableAvailabilityWeeks - 1) * 7),
    );
  }

  /// One calendar week alone, for reading a week that falls outside the
  /// editable window.
  factory AvailabilityWindow.single(DateTime day) =>
      AvailabilityWindow(from: day, to: day);

  /// Whether the week [day] falls in is inside this window.
  bool covers(DateTime day) {
    final week = getStartOfWeek(day);
    return !week.isBefore(from) && !week.isAfter(to);
  }

  @override
  bool operator ==(Object other) =>
      other is AvailabilityWindow && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}
