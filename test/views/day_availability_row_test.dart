import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/views/screens/availability/widgets/day_availability_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<DayAvailability> _pumpRow(
  WidgetTester tester, {
  required DayAvailability day,
  required Future<void> Function(WidgetTester tester) act,
}) async {
  var current = day;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => DayAvailabilityRow(
            label: 'Tuesday',
            day: current,
            enabled: true,
            onChanged: (updated) => setState(() => current = updated),
          ),
        ),
      ),
    ),
  );
  await act(tester);
  await tester.pumpAndSettle();
  return current;
}

void main() {
  const tuesdayOff = DayAvailability(dayOfWeek: 1);
  const tuesdayOn = DayAvailability(dayOfWeek: 1, isAvailable: true);

  testWidgets('turning a day on asks how long', (tester) async {
    expect(find.text('How long'), findsNothing);

    final day = await _pumpRow(
      tester,
      day: tuesdayOff,
      act: (tester) async => tester.tap(find.byType(Switch)),
    );

    expect(day.isAvailable, isTrue);
    expect(find.text('How long'), findsOneWidget);
  });

  testWidgets('a duration is carried as minutes', (tester) async {
    final day = await _pumpRow(
      tester,
      day: tuesdayOn,
      act: (tester) async =>
          tester.enterText(find.byType(TextField).first, '90'),
    );

    expect(day.durationMinutes, 90);
  });

  testWidgets('clearing the duration drops it rather than sending zero', (
    tester,
  ) async {
    final day = await _pumpRow(
      tester,
      day: const DayAvailability(
        dayOfWeek: 1,
        isAvailable: true,
        durationMinutes: 90,
      ),
      act: (tester) async => tester.enterText(find.byType(TextField).first, ''),
    );

    // The API refuses a zero duration, and an empty field means the athlete did
    // not say, not that they can train for no time at all.
    expect(day.durationMinutes, isNull);
  });

  testWidgets('a day that is off still takes a note', (tester) async {
    // Telling a coach "travelling" about a day off is worth as much as a
    // duration on a day on, so the note field does not hide with the switch.
    final day = await _pumpRow(
      tester,
      day: tuesdayOff,
      act: (tester) async =>
          tester.enterText(find.byType(TextField).last, 'travelling'),
    );

    expect(day.isAvailable, isFalse);
    expect(day.note, 'travelling');
  });

  testWidgets('a row keyed to another week does not keep the old text', (
    tester,
  ) async {
    // Switching weeks resolves from an already loaded provider without ever
    // painting the spinner, so an unkeyed row would be reused and show the
    // previous week's note over the new week's model.
    Widget rowFor(DateTime weekStart, DayAvailability day) => MaterialApp(
      home: Scaffold(
        body: DayAvailabilityRow(
          key: ValueKey((weekStart, day.dayOfWeek)),
          label: 'Tuesday',
          day: day,
          enabled: true,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.pumpWidget(
      rowFor(
        DateTime(2026, 6, 8),
        const DayAvailability(
          dayOfWeek: 1,
          isAvailable: true,
          note: 'gym after work',
        ),
      ),
    );
    expect(find.text('gym after work'), findsOneWidget);

    await tester.pumpWidget(rowFor(DateTime(2026, 6, 1), tuesdayOff));
    await tester.pumpAndSettle();

    expect(find.text('gym after work'), findsNothing);
  });

  testWidgets('a note of only spaces is dropped', (tester) async {
    final day = await _pumpRow(
      tester,
      day: tuesdayOn,
      act: (tester) async =>
          tester.enterText(find.byType(TextField).last, '   '),
    );

    expect(day.note, isNull);
  });
}
