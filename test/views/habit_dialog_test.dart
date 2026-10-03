import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/views/screens/trainings/widgets/habit_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Future<TrainingHabit?> Function()> _open(WidgetTester tester) async {
  TrainingHabit? chosen;
  var closed = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            chosen = await showDialog<TrainingHabit>(
              context: context,
              builder: (_) => const HabitDialog(trainingId: 'hangs'),
            );
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  return () async => closed ? chosen : null;
}

void main() {
  testWidgets('saves the weekdays picked, and not before one is', (
    tester,
  ) async {
    final result = await _open(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final save = find.widgetWithText(FilledButton, 'Save habit');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.tap(find.text('Mo'));
    await tester.tap(find.text('Th'));
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();

    final habit = (await result())!;
    expect(habit.trainingId, 'hangs');
    expect(habit.weekdays, {0, 3});
    expect(habit.isPerWeek, isFalse);
  });

  testWidgets('saves a count per week', (tester) async {
    final result = await _open(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Times a week'));
    await tester.pump();
    expect(find.text('2 times a week'), findsOneWidget);
    await tester.tap(find.byTooltip('More'));
    await tester.pump();
    await tester.tap(find.text('Save habit'));
    await tester.pumpAndSettle();

    expect((await result())!.timesPerWeek, 3);
  });

  test('describes a habit in a line', () {
    expect(
      describeHabit(
        TrainingHabit.onWeekdays(
          trainingId: 'x',
          weekdays: const {4, 0, 2},
          since: DateTime(2026, 9, 1),
        ),
      ),
      'Mo, We, Fr',
    );
    expect(
      describeHabit(
        TrainingHabit.perWeek(
          trainingId: 'x',
          timesPerWeek: 1,
          since: DateTime(2026, 9, 1),
        ),
      ),
      'Once a week',
    );
  });
}
