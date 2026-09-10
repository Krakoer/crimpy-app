import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/views/widgets/training_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpItems(WidgetTester tester, List<TrainingItem> items) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ListView(children: buildTrainingItemTiles(items))),
      ),
    );

void main() {
  testWidgets('nested exercises and their comments are listed', (tester) async {
    await _pumpItems(tester, [
      TrainingItem(
        id: 'c',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 3,
        items: [
          TrainingItem(
            id: 'e1',
            type: TrainingItemType.exercise,
            position: 0,
            duration: 35,
            exerciseName: 'Pigeon',
            comment: 'Right leg',
          ),
          TrainingItem(
            id: 'e2',
            type: TrainingItemType.exercise,
            position: 1,
            duration: 35,
            exerciseName: 'Pigeon',
            comment: 'Left leg',
          ),
        ],
      ),
    ]);

    expect(find.text('Circuit'), findsOneWidget);
    expect(find.text('3 cycles'), findsOneWidget);
    expect(find.text('Pigeon'), findsNWidgets(2));
    expect(find.text('Right leg'), findsOneWidget);
    expect(find.text('Left leg'), findsOneWidget);
  });

  testWidgets('an item without a comment shows no comment block', (
    tester,
  ) async {
    await _pumpItems(tester, [
      TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 10,
        exerciseName: 'Frog',
        comment: '  ',
      ),
    ]);

    expect(find.text('Frog'), findsOneWidget);
    expect(find.byType(TrainingItemComment), findsNothing);
  });

  testWidgets('an exercise with a video offers it and shows its description', (
    tester,
  ) async {
    await _pumpItems(tester, [
      const TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 8,
        exerciseName: 'Pull up',
        exerciseDescription: 'Dead hang start, chin over the bar.',
        exerciseVideoLink: 'https://example.com/pull-up',
      ),
    ]);

    expect(find.text('Dead hang start, chin over the bar.'), findsOneWidget);
    expect(find.text('WATCH DEMO'), findsOneWidget);
  });

  testWidgets('an exercise without a video offers none', (tester) async {
    await _pumpItems(tester, [
      const TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 8,
        exerciseName: 'Pull up',
      ),
    ]);

    expect(find.text('WATCH DEMO'), findsNothing);
  });

  // The coach types the link by hand, so a non address must read as no video
  // rather than as a button that fails on tap.
  testWidgets('a link that is not an address offers no button', (tester) async {
    await _pumpItems(tester, [
      const TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 8,
        exerciseName: 'Pull up',
        exerciseVideoLink: 'ask me for the video',
      ),
    ]);

    expect(find.text('WATCH DEMO'), findsNothing);
  });
}
