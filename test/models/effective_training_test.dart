import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _pullUpPyramid = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000001',
  label: 'Pull up pyramid',
  unit: AssessmentUnit.repetitions,
  prompt: 'How many pull ups did you do?',
  trainingId: 't-assessment',
);

Training _assessmentTraining() => const Training(
  id: 't-assessment',
  title: 'Pull up pyramid',
  assessment: _pullUpPyramid,
  items: [
    TrainingItem(
      id: 'item-1',
      type: TrainingItemType.exercise,
      position: 0,
      reps: 8,
    ),
  ],
);

void main() {
  group('effectiveTraining', () {
    test('keeps the assessment when there is nothing to override', () {
      final merged = effectiveTraining(_assessmentTraining(), const []);

      expect(merged.assessment?.id, _pullUpPyramid.id);
    });

    // A coach tuning any item of the week used to rebuild the training without
    // its assessment, which dropped the question the run exists to ask: the
    // session saved as an ordinary training and the result was never recorded.
    test('keeps the assessment through a per item override', () {
      final merged = effectiveTraining(_assessmentTraining(), const [
        SessionOverride(id: 'o1', itemId: 'item-1', overrides: {'reps': 12}),
      ]);

      expect(merged.assessment?.id, _pullUpPyramid.id);
      expect(merged.assessment?.prompt, 'How many pull ups did you do?');
      // The override still applies, which is the point of the rebuild.
      expect(merged.items.single.reps, 12);
    });

    test('carries the rest of the training through an override', () {
      const base = Training(
        id: 't1',
        title: 'Board work',
        description: 'Steep board',
        goal: 'Power',
        comment: 'Keep it crisp',
        isFavorite: true,
        items: [
          TrainingItem(
            id: 'item-1',
            type: TrainingItemType.exercise,
            position: 0,
            reps: 8,
          ),
        ],
      );

      final merged = effectiveTraining(base, const [
        SessionOverride(id: 'o1', itemId: 'item-1', overrides: {'reps': 10}),
      ]);

      expect(merged.title, 'Board work');
      expect(merged.description, 'Steep board');
      expect(merged.goal, 'Power');
      expect(merged.comment, 'Keep it crisp');
      expect(merged.isFavorite, isTrue);
    });
  });
}
