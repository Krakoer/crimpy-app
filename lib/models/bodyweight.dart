/// One dated bodyweight measurement.
///
/// Every finger and pulling number a coach reads is a ratio to the bodyweight
/// of the day rather than an absolute, so what matters as much as the number is
/// when it was taken. [measuredAt] is when the athlete weighed themselves, not
/// when the row reached the server: a measurement taken offline keeps the day
/// it belongs to.
class BodyweightEntry {
  final String id;
  final double weightKg;
  final DateTime measuredAt;

  const BodyweightEntry({
    required this.id,
    required this.weightKg,
    required this.measuredAt,
  });

  factory BodyweightEntry.fromJson(Map<String, dynamic> json) =>
      BodyweightEntry(
        id: json['id'] as String,
        weightKg: (json['weight_kg'] as num).toDouble(),
        measuredAt: DateTime.parse(json['measured_at'] as String).toLocal(),
      );
}
