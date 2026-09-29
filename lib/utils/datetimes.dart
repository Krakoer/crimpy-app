import 'package:clock/clock.dart';

/// [date] moved [days] calendar days, at local midnight.
///
/// Counted in calendar days rather than by adding a Duration: a Duration is
/// elapsed time, so across a DST change `add(Duration(days: 7))` lands an hour
/// either side of midnight instead of on the same time of day a week later.
/// Use this anywhere a date is stepped by a whole number of days.
DateTime addCalendarDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

/// The hour a training day turns over, local time. A session started before it
/// belongs to the evening before: a hang begun at 23:47 and one begun at 00:20
/// are the same night's training, and filing the second under the next morning
/// scores one evening as two days and leaves the one the athlete trained on
/// looking missed.
const int trainingDayStartHour = 4;

/// The training day [instant] belongs to, at local midnight: its calendar day,
/// or the one before when it falls before [trainingDayStartHour].
///
/// Stepped with [addCalendarDays] rather than by subtracting hours, so a DST
/// night neither loses nor gains the hour that decides it.
DateTime trainingDayOf(DateTime instant) =>
    addCalendarDays(instant, instant.hour < trainingDayStartHour ? -1 : 0);

/// The training day it is now: what "today" means wherever the app asks what
/// the athlete owes or has done today. Until 04:00 it is still yesterday.
DateTime currentTrainingDay() => trainingDayOf(clock.now());

/// Whole calendar days from [from] to [to], negative when [to] is earlier.
///
/// The counterpart to [addCalendarDays]: `difference(...).inDays` on two local
/// midnights returns 6 or 8 for a week that spans a DST change, because it
/// truncates elapsed hours. Comparing the dates in UTC counts the days.
int calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// Get the start of the week (Monday) of the given day, at local midnight.
DateTime getStartOfWeek(DateTime date) =>
    addCalendarDays(date, -(date.weekday - DateTime.monday));

/// The Monday of the week after the one [date] falls in, at local midnight.
DateTime getStartOfNextWeek(DateTime date) =>
    addCalendarDays(getStartOfWeek(date), 7);

/// An instant the API sends, read as the local time it happened at.
///
/// Every instant the API carries is UTC: the backend formats them with
/// `time.Time.UTC().Format(time.RFC3339)`, so they arrive with a `Z`. Parsing
/// one leaves a UTC [DateTime], and every render site in the app reads the
/// fields straight off it, so a session recorded at 09:12 in UTC+2 reads back
/// as 07:12 unless the zone is dropped here.
///
/// The conversion belongs at the parse boundary and nowhere else: past this
/// point a [DateTime] in a model is a local instant, whether it came from the
/// API or from the device, so nothing downstream has to know which. Anything
/// on its way back out converts explicitly with `toUtc()`.
///
/// This is for instants only. A calendar date the API sends as `YYYY-MM-DD`
/// (a program start date) is not an instant and must not go through here:
/// it has no zone to convert from, and shifting it moves it a day.
DateTime parseApiInstant(String raw) => DateTime.parse(raw).toLocal();

/// [parseApiInstant] for a value that may be absent or malformed, which is
/// null rather than an exception.
DateTime? tryParseApiInstant(String? raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
