import 'package:crimpy/database/builtins.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/utils/hangboard_layout.dart';
import 'package:crimpy/utils/reps.dart';
import 'package:flutter_test/flutter_test.dart';

TimedItem hang({int? edgeSizeMm}) => TimedItem(
  label: 'Hang',
  durationSeconds: 7,
  targetLoad: 30,
  handSide: HandSide.right,
  gripPosition: GripPosition.halfCrimp,
  collectSensorData: true,
  isHang: true,
  edgeSizeMm: edgeSizeMm,
);

/// MVC on both hands in every grip, so every builtin training is available.
List<AssessmentResultModel> maxForce() => [
  for (final grip in GripPosition.values)
    AssessmentResultModel(
      assessmentId: BuiltinAssessmentIds.maxForce,
      rightValue: 50,
      leftValue: 48,
      gripPosition: grip,
    ),
];

void main() {
  group('recorded reps', () {
    test('carry the edge the step prescribed', () {
      final reps = buildRepsData(
        [25.0],
        [hang(edgeSizeMm: 18), const RestItem(durationSeconds: 3)],
      );

      expect(reps[0].edgeSizeMm, 18);
    });

    test('carry no edge for a rest', () {
      final reps = buildRepsData(
        [25.0],
        [hang(edgeSizeMm: 18), const RestItem(durationSeconds: 3)],
      );

      expect(reps[1].edgeSizeMm, isNull);
    });

    test('carry no edge when the step prescribes none', () {
      final reps = buildRepsData([25.0], [hang()]);

      expect(reps.single.edgeSizeMm, isNull);
    });
  });

  group('builtin assessments', () {
    test('pull on the default edge', () {
      for (final assessment in builtinAssessments) {
        final pulls = assessment
            .trainingGenerator()
            .reps
            .whereType<TimedItem>();
        for (final pull in pulls) {
          expect(
            pull.edgeSizeMm,
            defaultEdgeSizeMm,
            reason: '${assessment.name} pulls on an unset edge',
          );
        }
      }
    });
  });

  group('builtin trainings', () {
    test('prescribe the default edge on every rep', () {
      for (final builtin in builtinTrainings) {
        final training = builtin.generateNewFormatTraining(maxForce());
        expect(
          training,
          isNotNull,
          reason: '${builtin.name} generated nothing',
        );

        for (final item in training!.items) {
          final layout = HangboardLayout.of(item);
          final grid = layout.grid;
          for (var set = 0; set < grid.sets; set++) {
            for (var rep = 0; rep < grid.reps; rep++) {
              expect(
                layout.edgeSizeMm(set, rep),
                defaultEdgeSizeMm,
                reason: '${builtin.name} set $set rep $rep has no edge',
              );
            }
          }
        }
      }
    });
  });
}
