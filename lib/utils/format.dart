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
