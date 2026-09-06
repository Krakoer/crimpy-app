String formatDurationMinSec(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "${twoDigitMinutes}mn ${twoDigitSeconds}s";
}

/// Format a time in milliseconds to a HH:MM:SS format
String formatMillisHHMMSS(int milli) {
  final dur = Duration(milliseconds: milli);
  String hours = dur.inHours.toString().padLeft(2, '0');
  String minutes = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = dur.inSeconds.remainder(60).toString().padLeft(2, '0');

  return "$hours:$minutes:$seconds";
}

/// Minutes and seconds of a duration in milliseconds, e.g. "04:12". Minutes
/// keep counting past an hour rather than rolling over.
String formatMillisMinutesSeconds(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  final minutes = duration.inMinutes.toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// A length of time read as a length rather than as a count of seconds, so a
/// minute reads as one: "45s", "1mn 30s", "2mn". This is the wording the
/// training item tiles use, and the override chips beside them follow it.
String formatSecondsAsLength(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  if (minutes > 0 && rest > 0) return '${minutes}mn ${rest}s';
  if (minutes > 0) return '${minutes}mn';
  return '${rest}s';
}

/// Format duration in seconds to human-readable format:
/// 34s, 1m 34s, 4m, 1h 3m, etc...
String formatDurationHMS(int seconds) {
  if (seconds < 60) {
    return '${seconds}s';
  } else if (seconds < 3600) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return secs > 0 ? '${minutes}m ${secs}s' : '${minutes}m';
  } else {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }
}

/// A weight in kilograms, kept to a single decimal and only when it carries
/// one, so a live readout does not jitter between widths for nothing.
String formatKilograms(double kilograms) => kilograms.toStringAsFixed(
  kilograms.truncateToDouble() == kilograms ? 0 : 1,
);

const _monthAbbreviations = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

/// Day and abbreviated month, e.g. "4 AUG".
String formatDayMonth(DateTime date) =>
    '${date.day} ${_monthAbbreviations[date.month - 1]}';

/// Whether two instants fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
