import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/utils/format.dart';
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

  testWidgets('a removed activity can be put back where it was', (
    tester,
  ) async {
    // The remove is one tap on a control beside the row that opens the editor,
    // and the activity holds four fields the athlete typed. Without the undo a
    // mis-tap costs all four.
    final day = await _pumpCard(
      tester,
      day: const DayAvailability(
        dayOfWeek: 1,
        activities: [
          DayActivity(label: 'Bouldering'),
          DayActivity(label: 'Stretching', durationMinutes: 20),
          DayActivity(label: 'Long run'),
        ],
      ),
      act: (tester) async {
        await tester.tap(find.byTooltip('Remove Stretching'));
        await tester.pumpAndSettle();
        expect(find.text('Removed Stretching'), findsOneWidget);
        await tester.tap(find.text('Undo'));
      },
    );

    expect(day.activities.map((activity) => activity.label), [
      'Bouldering',
      'Stretching',
      'Long run',
    ]);
    expect(day.activities[1].durationMinutes, 20);
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

  testWidgets('a field too long for the API is refused at the field', (
    tester,
  ) async {
    // maxLength counts grapheme clusters and the API counts runes, so a field
    // the box let through can still be refused by the save, which takes the
    // whole week down with it and names no field.
    final day = await _pumpCard(
      tester,
      day: emptyTuesday,
      act: (tester) async {
        await tester.tap(find.text('Add something'));
        await tester.pumpAndSettle();
        await _fill(
          tester,
          label: 'Bouldering',
          where: 'e\u0301' * (maxActivityTextLength + 1),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Add'));
        await tester.pumpAndSettle();
        expect(find.text('Shorten this a little'), findsOneWidget);
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      },
    );

    expect(day.activities, isEmpty);
  });

  testWidgets('an edit that changed nothing is not reported as one', (
    tester,
  ) async {
    // Reporting it would mark the week dirty, and sending it re-dates the
    // declaration, which puts the week back at the top of the coach's feed as
    // an answer the athlete did not give.
    var reported = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DayScheduleCard(
            label: 'Tuesday',
            dateLabel: '9/6',
            day: const DayAvailability(
              dayOfWeek: 1,
              activities: [
                DayActivity(
                  label: 'Bouldering',
                  durationMinutes: 90,
                  when: 'after work',
                ),
              ],
            ),
            enabled: true,
            onChanged: (_) => reported++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Bouldering'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(reported, 0);
  });

  test('a planned duration reads as hours once it passes one', () {
    expect(formatMinutesAsLength(45), '45m');
    expect(formatMinutesAsLength(60), '1h');
    expect(formatMinutesAsLength(90), '1h 30m');
    expect(formatMinutesAsLength(125), '2h 5m');
  });
}
