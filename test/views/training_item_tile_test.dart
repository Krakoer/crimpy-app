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
        exerciseComment: 'Keep the shoulders engaged at the bottom.',
        exerciseVideoLink: 'https://example.com/pull-up',
      ),
    ]);

    expect(find.text('Dead hang start, chin over the bar.'), findsOneWidget);
    // The coach's execution notes, which is a different field from the note
    // they attached to this step.
    expect(
      find.text('Keep the shoulders engaged at the bottom.'),
      findsOneWidget,
    );
    expect(find.text('WATCH DEMO'), findsOneWidget);
  });

  // The item's own comment is about this step; the exercise's is about the
  // movement everywhere it is used. Both show, and they do not replace one
  // another.
  testWidgets('a step comment and the exercise notes both show', (
    tester,
  ) async {
    await _pumpItems(tester, [
      const TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 8,
        exerciseName: 'Pull up',
        comment: 'Add 10kg today',
        exerciseComment: 'Keep the shoulders engaged at the bottom.',
      ),
    ]);

    expect(find.text('Add 10kg today'), findsOneWidget);
    expect(
      find.text('Keep the shoulders engaged at the bottom.'),
      findsOneWidget,
    );
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

  testWidgets('the goal of an item is listed beside its comment', (
    tester,
  ) async {
    await _pumpItems(tester, [
      TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 10,
        exerciseName: 'Pull up',
        goal: 'resi doigts',
        comment: 'First rep in pronation',
      ),
    ]);

    expect(find.text('GOAL'), findsOneWidget);
    expect(find.text('resi doigts'), findsOneWidget);
    expect(find.text('First rep in pronation'), findsOneWidget);
    expect(find.byType(TrainingItemGoal), findsOneWidget);
    expect(find.byType(TrainingItemComment), findsOneWidget);
  });

  testWidgets('an item without a goal shows no goal block', (tester) async {
    await _pumpItems(tester, [
      TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 10,
        exerciseName: 'Frog',
        goal: '  ',
      ),
    ]);

    expect(find.text('Frog'), findsOneWidget);
    expect(find.byType(TrainingItemGoal), findsNothing);
  });

  // The breakdown is where the athlete reads the whole rule, uncapped, before
  // they start: the run screen line caps it and the tank cannot scroll.
  testWidgets('the protocol of an item is listed beside its goal and comment', (
    tester,
  ) async {
    const rule =
        'Hang to failure or 40s. If you go past 40s add 5kg; if you fall '
        'short, put your feet on the ground.';
    await _pumpItems(tester, [
      const TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 10,
        exerciseName: 'Pull up',
        goal: 'resi doigts',
        comment: 'First rep in pronation',
        protocol: rule,
      ),
    ]);

    expect(find.text('PROTOCOL'), findsOneWidget);
    expect(find.text(rule), findsOneWidget);
    expect(find.byType(TrainingItemProtocol), findsOneWidget);
    expect(find.byType(TrainingItemGoal), findsOneWidget);
    expect(find.byType(TrainingItemComment), findsOneWidget);
  });

  testWidgets('an item without a protocol shows no protocol block', (
    tester,
  ) async {
    await _pumpItems(tester, [
      const TrainingItem(
        id: 'e1',
        type: TrainingItemType.exercise,
        position: 0,
        reps: 10,
        exerciseName: 'Frog',
        protocol: '  ',
      ),
    ]);

    expect(find.text('Frog'), findsOneWidget);
    expect(find.byType(TrainingItemProtocol), findsNothing);
  });
}
