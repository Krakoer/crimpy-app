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
  test('reads each report against the item it answers', () {
    final results = reportedItems(const [
      SessionItemResultModel(
        trainingItemId: 'pullup-1',
        occurrence: 1,
        reps: 18,
      ),
      SessionItemResultModel(
        trainingItemId: 'pullup-1',
        occurrence: 0,
        reps: 23,
      ),
      SessionItemResultModel(
        trainingItemId: 'emom-1',
        occurrence: 0,
        cycles: 7,
      ),
    ], _prescription);

    expect(results, hasLength(2));
    final emom = results.firstWhere((r) => r.prescribed == 'of 10 rounds');
    expect(emom.passes.map((p) => p.achieved), ['7 rounds']);
    final amrap = results.firstWhere((r) => r.label == 'Pull up');
    // The passes read in the order they were played, not in the order they
    // happened to arrive.
    expect(amrap.passes.map((p) => p.achieved), ['23 reps', '18 reps']);
    expect(amrap.prescribed, 'as many reps as possible');
  });

  test('reads a load, a duration and a note off one pass', () {
    final results = reportedItems(const [
      SessionItemResultModel(
        trainingItemId: 'pullup-1',
        occurrence: 0,
        reps: 8,
        loadKg: 17.5,
        durationSeconds: 90,
        note: '  hard on the shoulders  ',
      ),
    ], _prescription);

    expect(results.single.passes.single.achieved, '8 reps, 1mn 30s at 17.5 kg');
    expect(results.single.passes.single.note, 'hard on the shoulders');
  });

  test('reads a pass that carried nothing but a note', () {
    final results = reportedItems(const [
      SessionItemResultModel(
        trainingItemId: 'pullup-1',
        occurrence: 0,
        note: 'did it with a band, no dumbbell available',
      ),
    ], _prescription);

    expect(results.single.passes.single.achieved, isNull);
    expect(
      results.single.passes.single.note,
      'did it with a band, no dumbbell available',
    );
  });

  test(
    'leaves out a report naming an item the prescription no longer holds',
    () {
      final results = reportedItems(const [
        SessionItemResultModel(
          trainingItemId: 'deleted',
          occurrence: 0,
          reps: 12,
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
            items: reportedItems(const [
              SessionItemResultModel(
                trainingItemId: 'pullup-1',
                occurrence: 0,
                reps: 23,
                note: 'hard on the shoulders',
              ),
              SessionItemResultModel(
                trainingItemId: 'emom-1',
                occurrence: 0,
                cycles: 7,
              ),
            ], _prescription),
          ),
        ),
      ),
    );

    expect(find.text('What you managed'), findsOneWidget);
    expect(find.text('Pull up'), findsOneWidget);
    expect(find.text('23 reps'), findsOneWidget);
    expect(find.text('7 rounds'), findsOneWidget);
    expect(find.text('of 10 rounds'), findsOneWidget);
    // The line the athlete wrote is the whole point of the card, so it reads in
    // full rather than as a marker that a note exists.
    expect(find.text('hard on the shoulders'), findsOneWidget);
  });
}
