/// The two ways the app writes a length of time. A clock is read while it runs,
/// on the run screen; a length is read at rest, everywhere else. See
/// Krakoer/crimpy#169.
library;

/// A running clock, minutes and two-digit seconds: "0:07", "3:11", "12:05".
/// Past an hour the hours lead: "1:02:05". A negative duration reads as zero,
/// since a clock never counts below it.
String formatClock(Duration duration) {
  final totalSeconds = duration.isNegative ? 0 : duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = _twoDigits(totalSeconds % 60);
  if (hours == 0) return '$minutes:$seconds';
  return '$hours:${_twoDigits(minutes)}:$seconds';
}

/// A length read at a glance, to the nearest minute: "25 min", "1 h",
/// "1 h 30 min". Under a minute it keeps its seconds, "45s", so a short step
/// does not read as nothing; none at all is "0 min".
String formatLength(Duration duration) {
  final totalSeconds = duration.isNegative ? 0 : duration.inSeconds;
  if (totalSeconds > 0 && totalSeconds < 60) return '${totalSeconds}s';
  return _hoursAndMinutes((totalSeconds / 60).round());
}

/// A length given in whole minutes, as [formatLength] writes it.
String formatMinutes(int minutes) => formatLength(Duration(minutes: minutes));

/// A prescribed length, kept to the second since it is what the athlete is
/// asked to do: "45s", "1 min 30s", "2 min". The same words as
/// [formatLength], without the rounding.
String formatExactLength(int seconds) {
  if (seconds < 60) return '${seconds < 0 ? 0 : seconds}s';
  final rest = seconds % 60;
  final minutes = _hoursAndMinutes(seconds ~/ 60);
  return rest == 0 ? minutes : '$minutes ${rest}s';
}

String _hoursAndMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) return '$minutes min';
  if (minutes == 0) return '$hours h';
  return '$hours h $minutes min';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
