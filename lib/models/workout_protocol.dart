import 'package:crimpy/models/training_execution_model.dart';

/// A flat sequence of steps, as used by the assessment protocols.
///
/// Assessments are a straight run of pulls and rests with no nesting, so they
/// keep this shape rather than the [Training] item tree.
class TrainingWithReps {
  final String id;
  final String name;
  final List<TrainingExecutionItem> reps;

  TrainingWithReps({required this.id, required this.name, required this.reps});

  Duration get totalDuration =>
      Duration(seconds: reps.fold(0, (prev, r) => prev + r.durationSeconds));
}
