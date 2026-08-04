import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:flutter_test/flutter_test.dart';

List<RepModel> criticalForceReps() => builtinAssessments
    .firstWhere((a) => a.type == AssessmentType.criticalForce)
    .trainingGenerator()
    .reps;

void main() {
  group('critical force protocol', () {
    test('has exactly one work rep per configured pull', () {
      final pulls = criticalForceReps().where((r) => !r.isRest).toList();

      expect(pulls, hasLength(criticalForceRepCount));
    });

    test('starts with the lead-in rest', () {
      final reps = criticalForceReps();

      expect(reps.first.isRest, isTrue);
      expect(reps.first.durationInSeconds, criticalForceLeadInTime);
    });

    test('ends on a pull rather than a trailing rest', () {
      final reps = criticalForceReps();

      expect(reps.last.isRest, isFalse);
      expect(reps.last.durationInSeconds, criticalForceWorkTime);
    });

    test('alternates work and rest after the lead-in', () {
      final afterLeadIn = criticalForceReps().skip(1).toList();

      for (var i = 0; i < afterLeadIn.length; i++) {
        final rep = afterLeadIn[i];
        // Even positions are pulls, odd ones the rest that follows.
        expect(
          rep.isRest,
          i.isOdd,
          reason: 'rep at position $i has the wrong kind',
        );
        expect(
          rep.durationInSeconds,
          i.isOdd ? criticalForceRestTime : criticalForceWorkTime,
        );
      }
    });

    test('runs for the expected total duration', () {
      final total = criticalForceReps().fold<int>(
        0,
        (sum, rep) => sum + rep.durationInSeconds,
      );

      expect(
        total,
        criticalForceLeadInTime +
            criticalForceRepCount * criticalForceWorkTime +
            (criticalForceRepCount - 1) * criticalForceRestTime,
      );
    });

    test('indexes reps consecutively from zero', () {
      final reps = criticalForceReps();

      expect(
        reps.map((r) => r.index).toList(),
        List.generate(reps.length, (i) => i),
      );
    });
  });
}
