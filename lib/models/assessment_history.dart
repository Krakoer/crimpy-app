import 'package:crimpy/models/assessment_model.dart';

/// The results the athlete has for one assessment, oldest first, with what that
/// assessment is. Driven by what was actually measured rather than by a fixed
/// list, so a coach assessment takes its place the moment it is first done.
class AssessedHistory {
  final AssessmentDefinition definition;
  final List<AssessmentModel> records;

  const AssessedHistory({required this.definition, required this.records});

  /// The best number recorded on one side, 0 when that side was never measured,
  /// which is what the stat cards read as "--".
  double best(double? Function(AssessmentModel) side) => records
      .map((record) => side(record) ?? 0)
      .fold<double>(
        0,
        (previous, value) => value > previous ? value : previous,
      );

  /// The measured points on one side, for a chart.
  List<(DateTime, double)> series(double? Function(AssessmentModel) side) => [
    for (final record in records)
      if (side(record) != null) (record.date, side(record)!),
  ];
}

/// Groups a flat history by the assessment each result measures, oldest first
/// within each, and orders the assessments so the ones Crimpy ships come before
/// a coach's own.
///
/// [alwaysShown] are listed even with nothing measured against them, which is
/// how the assessments Crimpy ships keep their section, and the invitation to go
/// and do one, on a profile that has no results yet.
Map<String, AssessedHistory> groupAssessmentHistory(
  List<AssessmentModel> assessments, {
  List<AssessmentDefinition> alwaysShown = const [],
}) {
  final byId = <String, List<AssessmentModel>>{};
  final definitions = <String, AssessmentDefinition>{};
  for (final definition in alwaysShown) {
    byId[definition.id] = [];
    definitions[definition.id] = definition;
  }
  for (final assessment in assessments) {
    byId.putIfAbsent(assessment.assessmentId, () => []).add(assessment);
    definitions.putIfAbsent(
      assessment.assessmentId,
      () => assessment.definition,
    );
  }

  final ordered = byId.keys.toList()
    ..sort((a, b) {
      final aBuiltin = definitions[a]!.isBuiltin;
      final bBuiltin = definitions[b]!.isBuiltin;
      if (aBuiltin != bBuiltin) return aBuiltin ? -1 : 1;
      return definitions[a]!.label.compareTo(definitions[b]!.label);
    });

  return {
    for (final id in ordered)
      id: AssessedHistory(
        definition: definitions[id]!,
        records: byId[id]!..sort((a, b) => a.date.compareTo(b.date)),
      ),
  };
}
