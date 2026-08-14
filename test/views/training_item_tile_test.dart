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

    expect(find.text('Cycle'), findsOneWidget);
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
}
