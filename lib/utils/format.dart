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
