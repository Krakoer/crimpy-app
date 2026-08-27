import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_open_results_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pullUps = TrainingItem(
  id: 'pullup-1',
  type: TrainingItemType.exercise,
  position: 0,
  exerciseName: 'Pull up',
  repsIsMax: true,
);

const _emom = TrainingItem(
  id: 'emom-1',
  type: TrainingItemType.emom,
  position: 0,
  cycles: 10,
  intervalSeconds: 60,
  items: [_pullUps],
);

const _prescription = [_emom];

void main() {
  test('reads each count against the item it answers', () {
    final results = openItemResults(const [
      SessionItemResultModel(
        trainingItemId: 'pullup-1',
        occurrence: 1,
        field: SessionItemField.reps,
        value: 18,
      ),
      SessionItemResultModel(
        trainingItemId: 'pullup-1',
        occurrence: 0,
        field: SessionItemField.reps,
        value: 23,
      ),
      SessionItemResultModel(
        trainingItemId: 'emom-1',
        occurrence: 0,
        field: SessionItemField.cycles,
        value: 7,
      ),
    ], _prescription);

    expect(results, hasLength(2));
    final emom = results.firstWhere((r) => r.prescribed.contains('rounds'));
    expect(emom.values, [7]);
    expect(emom.prescribed, 'of 10 rounds');
    final amrap = results.firstWhere((r) => r.label == 'Pull up');
    // The passes read in the order they were played, not in the order they
    // happened to arrive.
    expect(amrap.values, [23, 18]);
  });

  test(
    'leaves out a count naming an item the prescription no longer holds',
    () {
      final results = openItemResults(const [
        SessionItemResultModel(
          trainingItemId: 'deleted',
          occurrence: 0,
          field: SessionItemField.reps,
          value: 12,
        ),
      ], _prescription);

      expect(results, isEmpty);
    },
  );

  testWidgets('shows what the athlete managed against what was asked', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionOpenResultsCard(
            results: openItemResults(const [
              SessionItemResultModel(
                trainingItemId: 'pullup-1',
                occurrence: 0,
                field: SessionItemField.reps,
                value: 23,
              ),
              SessionItemResultModel(
                trainingItemId: 'emom-1',
                occurrence: 0,
                field: SessionItemField.cycles,
                value: 7,
              ),
            ], _prescription),
          ),
        ),
      ),
    );

    expect(find.text('What you managed'), findsOneWidget);
    expect(find.text('Pull up'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('of 10 rounds'), findsOneWidget);
  });
}
