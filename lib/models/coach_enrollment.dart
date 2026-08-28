/// The coach an athlete is enrolled with. Read only: enrolling happens through
/// a link the coach sends, and leaving happens from the web portal.
class CoachEnrollment {
  final String enrollmentId;
  final String coachId;
  final String coachFirstname;
  final String coachLastname;
  final DateTime enrolledAt;

  const CoachEnrollment({
    required this.enrollmentId,
    required this.coachId,
    required this.coachFirstname,
    required this.coachLastname,
    required this.enrolledAt,
  });

  /// The coach as an athlete would name them, falling back to "your coach"
  /// when the account carries no name at all.
  String get coachName {
    final name = '$coachFirstname $coachLastname'.trim();
    return name.isEmpty ? 'Your coach' : name;
  }

  factory CoachEnrollment.fromJson(Map<String, dynamic> json) =>
      CoachEnrollment(
        enrollmentId: json['enrollment_id'] as String,
        coachId: json['coach_id'] as String,
        coachFirstname: json['coach_firstname'] as String? ?? '',
        coachLastname: json['coach_lastname'] as String? ?? '',
        enrolledAt: DateTime.parse(json['enrolled_at'] as String).toLocal(),
      );
}
