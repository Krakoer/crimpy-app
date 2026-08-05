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

void main() {
  setUp(_stubPlugins);

  testWidgets('the comment of a step is shown while a rest follows it', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PlayTrainingScreen(_stretchingCircuit(), useSensor: false),
        ),
      ),
    );

    // Preparation rest first: it leads into the first exercise, whose comment
    // is shown ahead of time next to the upcoming step.
    expect(find.text('Right leg'), findsOneWidget);
    expect(find.textContaining('Next:'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(const Duration(seconds: 11));

    // Now running the exercise itself, which is followed by a rest.
    expect(find.text('Right leg'), findsOneWidget);
  });
}
