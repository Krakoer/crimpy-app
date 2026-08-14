import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The screen keeps the screen awake and preloads sounds; neither plugin exists
/// in a test binding, so both channels answer with a no-op.
void _stubPlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final channel in const [
    MethodChannel('dev.fluttercommunity.plus/wakelock'),
    MethodChannel('xyz.luan/audioplayers'),
    MethodChannel('xyz.luan/audioplayers.global'),
  ]) {
    messenger.setMockMethodCallHandler(channel, (call) async => null);
  }
}

Training _stretchingCircuit() => const Training(
  id: 't1',
  title: 'Stretch routine',
  items: [
    TrainingItem(
      id: 'c',
      type: TrainingItemType.circuit,
      position: 0,
      cycles: 3,
      cycleRestSeconds: 10,
      items: [
        TrainingItem(
          id: 'e1',
          type: TrainingItemType.exercise,
          position: 0,
          duration: 35,
          restSeconds: 10,
          exerciseName: 'Pigeon',
          comment: 'Right leg',
        ),
        TrainingItem(
          id: 'e2',
          type: TrainingItemType.exercise,
          position: 1,
          duration: 35,
          restSeconds: 10,
          exerciseName: 'Pigeon',
          comment: 'Left leg',
        ),
      ],
    ),
  ],
);

/// An uncommented exercise ahead of a commented one, both at the top level.
Training _oneCommentedExercise() => const Training(
  id: 't2',
  title: 'Two exercises',
  items: [
    TrainingItem(
      id: 'e1',
      type: TrainingItemType.exercise,
      position: 0,
      duration: 20,
      restSeconds: 10,
      exerciseName: 'Frog',
    ),
    TrainingItem(
      id: 'e2',
      type: TrainingItemType.exercise,
      position: 1,
      duration: 20,
      exerciseName: 'Pigeon',
      comment: 'Right leg',
    ),
  ],
);

Future<void> _pumpRun(WidgetTester tester, Training training) =>
    tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PlayTrainingScreen(training, useSensor: false),
        ),
      ),
    );

/// Moves to the next step of the run, the way the skip button does.
Future<void> _skip(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.skip_next));
  await tester.pump();
}

void main() {
  setUp(_stubPlugins);

  testWidgets('the comment of a step is shown while a rest follows it', (
    tester,
  ) async {
    await _pumpRun(tester, _stretchingCircuit());

    // Preparation rest first: it leads into the first exercise, whose comment
    // is shown ahead of time under the name of that upcoming step.
    expect(find.text('Right leg'), findsOneWidget);
    expect(find.textContaining('Next:'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Right leg')).dy,
      greaterThan(tester.getTopLeft(find.textContaining('Next:')).dy),
    );

    await _skip(tester);

    // Now running the exercise itself: the comment follows its title, above
    // the timer.
    expect(find.text('Right leg'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Right leg')).dy,
      greaterThan(tester.getTopLeft(find.text('PIGEON')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Right leg')).dy,
      lessThan(tester.getTopLeft(find.text('00:35')).dy),
    );
  });

  testWidgets('a rest only carries the comment of the step it leads into', (
    tester,
  ) async {
    await _pumpRun(tester, _stretchingCircuit());

    // Prep rest -> first exercise -> its rest, which leads into the second one.
    await _skip(tester);
    await _skip(tester);
    expect(find.text('Left leg'), findsOneWidget);
    expect(find.text('Right leg'), findsNothing);

    // Second exercise, then the single rest closing the cycle: the rest the
    // circuit sets stands in for the one the last exercise carries rather than
    // running after it. It leads into the first exercise of cycle two.
    await _skip(tester);
    await _skip(tester);
    expect(find.text('Right leg'), findsOneWidget);
    expect(find.text('Left leg'), findsNothing);

    await _skip(tester);
    expect(find.text('Right leg'), findsOneWidget);
  });

  testWidgets('an uncommented step shows no comment of its own', (
    tester,
  ) async {
    await _pumpRun(tester, _oneCommentedExercise());

    // Preparation rest leads into the uncommented exercise.
    expect(find.text('Right leg'), findsNothing);

    // Running that exercise: the comment of the later one must not appear.
    await _skip(tester);
    expect(find.text('FROG'), findsOneWidget);
    expect(find.text('Right leg'), findsNothing);

    // Its rest leads into the commented exercise, so the comment appears.
    await _skip(tester);
    expect(find.text('Right leg'), findsOneWidget);
  });
}
