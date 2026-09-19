import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/views/screens/availability/widgets/day_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<DayAvailability> _pumpCard(
  WidgetTester tester, {
  required DayAvailability day,
  required Future<void> Function(WidgetTester tester) act,
}) async {
  var current = day;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: DayScheduleCard(
              label: 'Tuesday',
              dateLabel: '9/6',
              day: current,
              enabled: true,
              onChanged: (updated) => setState(() => current = updated),
            ),
          ),
        ),
      ),
    ),
  );
  await act(tester);
  await tester.pumpAndSettle();
  return current;
}

Future<void> _fill(
  WidgetTester tester, {
  required String label,
  String? duration,
  String? when,
  String? where,
}) async {
  await tester.enterText(find.widgetWithText(TextField, 'What'), label);
  if (duration != null) {
    await tester.enterText(
      find.widgetWithText(TextField, 'How long'),
      duration,
    );
  }
  if (when != null) {
    await tester.enterText(find.widgetWithText(TextField, 'When'), when);
  }
  if (where != null) {
    await tester.enterText(find.widgetWithText(TextField, 'Where'), where);
  }
}

void main() {
  const emptyTuesday = DayAvailability(dayOfWeek: 1);

  testWidgets('an empty day says so and offers to fill itself', (tester) async {
    await _pumpCard(tester, day: emptyTuesday, act: (tester) async {});

    expect(find.text('Nothing planned'), findsOneWidget);
    expect(find.text('Add something'), findsOneWidget);
  });

  testWidgets('adding an activity carries all four fields', (tester) async {
    final day = await _pumpCard(
      tester,
      day: emptyTuesday,
      act: (tester) async {
        await tester.tap(find.text('Add something'));
        await tester.pumpAndSettle();
        await _fill(
          tester,
          label: 'Bouldering',
          duration: '90',
          when: 'after work',
          where: 'Arkose',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      },
    );

    expect(day.activities, hasLength(1));
    expect(day.activities.single.label, 'Bouldering');
    expect(day.activities.single.durationMinutes, 90);
    expect(day.activities.single.when, 'after work');
    expect(day.activities.single.where, 'Arkose');
  });

  testWidgets('a day holds more than one activity, in order', (tester) async {
    final day = await _pumpCard(
      tester,
      day: const DayAvailability(
        dayOfWeek: 1,
        activities: [DayActivity(label: 'Bouldering')],
      ),
      act: (tester) async {
        await tester.tap(find.text('Add something'));
        await tester.pumpAndSettle();
        await _fill(tester, label: 'Stretching');
        await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      },
    );

    expect(day.activities.map((activity) => activity.label), [
      'Bouldering',
      'Stretching',
    ]);
  });

  testWidgets('an activity with no name is refused rather than saved', (
    tester,
  ) async {
    final day = await _pumpCard(
      tester,
      day: emptyTuesday,
      act: (tester) async {
        await tester.tap(find.text('Add something'));
        await tester.pumpAndSettle();
        await _fill(tester, label: '   ', duration: '45');
        await tester.tap(find.widgetWithText(FilledButton, 'Add'));
        await tester.pumpAndSettle();
        expect(find.text('This one needs a name'), findsOneWidget);
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      },
    );

    expect(day.activities, isEmpty);
  });

  testWidgets('a blank duration is dropped rather than sent as zero', (
    tester,
  ) async {
    final day = await _pumpCard(
      tester,
      day: emptyTuesday,
      act: (tester) async {
        await tester.tap(find.text('Add something'));
        await tester.pumpAndSettle();
        await _fill(tester, label: 'Rest day walk');
        await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      },
    );

    expect(day.activities.single.durationMinutes, isNull);
    expect(day.activities.single.when, isNull);
    expect(day.activities.single.where, isNull);
  });

  testWidgets('removing an activity takes it off the day', (tester) async {
    final day = await _pumpCard(
      tester,
      day: const DayAvailability(
        dayOfWeek: 1,
        activities: [
          DayActivity(label: 'Bouldering'),
          DayActivity(label: 'Stretching'),
        ],
      ),
      act: (tester) async => tester.tap(find.byTooltip('Remove Bouldering')),
    );

    expect(day.activities.map((activity) => activity.label), ['Stretching']);
  });

  testWidgets('editing an activity replaces it in place', (tester) async {
    final day = await _pumpCard(
      tester,
      day: const DayAvailability(
        dayOfWeek: 1,
        activities: [
          DayActivity(label: 'Bouldering'),
          DayActivity(label: 'Stretching'),
        ],
      ),
      act: (tester) async {
        await tester.tap(find.text('Bouldering'));
        await tester.pumpAndSettle();
        await _fill(tester, label: 'Lead climbing');
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      },
    );

    expect(day.activities.map((activity) => activity.label), [
      'Lead climbing',
      'Stretching',
    ]);
  });

  testWidgets('a full day stops offering to add more', (tester) async {
    await _pumpCard(
      tester,
      day: DayAvailability(
        dayOfWeek: 1,
        activities: [
          for (var i = 0; i < maxActivitiesPerDay; i++)
            DayActivity(label: 'Climb $i'),
        ],
      ),
      act: (tester) async {},
    );

    expect(find.text('Add something'), findsNothing);
    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'That is a full day'),
    );
    expect(button.onPressed, isNull);
  });

  test('a duration reads as hours once it passes one', () {
    expect(formatPlannedMinutes(45), '45min');
    expect(formatPlannedMinutes(60), '1h');
    expect(formatPlannedMinutes(90), '1h30');
    expect(formatPlannedMinutes(125), '2h05');
  });
}
