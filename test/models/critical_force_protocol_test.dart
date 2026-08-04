import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:flutter_test/flutter_test.dart';

List<TrainingExecutionItem> criticalForceReps() => builtinAssessments
    .firstWhere((a) => a.type == AssessmentType.criticalForce)
    .trainingGenerator()
    .reps;

void main() {
  group('critical force protocol', () {
    test('has exactly one work rep per configured pull', () {
      final pulls = criticalForceReps().whereType<TimedItem>().toList();

      expect(pulls, hasLength(criticalForceRepCount));
    });

    test('starts with the lead-in rest', () {
      final reps = criticalForceReps();

      expect(reps.first, isA<RestItem>());
      expect(reps.first.durationSeconds, criticalForceLeadInTime);
    });

    test('ends on a pull rather than a trailing rest', () {
      final reps = criticalForceReps();

      expect(reps.last, isA<TimedItem>());
      expect(reps.last.durationSeconds, criticalForceWorkTime);
    });

    test('alternates work and rest after the lead-in', () {
      final afterLeadIn = criticalForceReps().skip(1).toList();

      for (var i = 0; i < afterLeadIn.length; i++) {
        final rep = afterLeadIn[i];
        // Even positions are pulls, odd ones the rest that follows.
        expect(
          rep is RestItem,
          i.isOdd,
          reason: 'rep at position $i has the wrong kind',
        );
        expect(
          rep.durationSeconds,
          i.isOdd ? criticalForceRestTime : criticalForceWorkTime,
        );
      }
    });

    test('runs for the expected total duration', () {
      final total = criticalForceReps().fold<int>(
        0,
        (sum, rep) => sum + rep.durationSeconds,
      );

      expect(
        total,
        criticalForceLeadInTime +
            criticalForceRepCount * criticalForceWorkTime +
            (criticalForceRepCount - 1) * criticalForceRestTime,
      );
    });
  });
}
