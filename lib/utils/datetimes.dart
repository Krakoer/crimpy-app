/// Get the start of the week (Monday) of the given day.
DateTime getStartOfWeek(DateTime date) {
  int weekday = date.weekday;
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: weekday - 1));
}

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
