String formatDurationMinSec(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
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
