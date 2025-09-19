/// Get the start of the week (Monday) of the given day.
DateTime getStartOfWeek(DateTime date) {
  int weekday = date.weekday;
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: weekday - 1));
}
