import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:crimpy/views/screens/availability/week_availability_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubMyAvailability extends MyAvailability {
  _StubMyAvailability(this._weeks);

  final List<WeekAvailability> _weeks;

  @override
  Future<List<WeekAvailability>> build() async => _weeks;
}

final _monday = DateTime(2026, 6, 8);

Future<void> _pumpScreen(
  WidgetTester tester, {
  required List<WeekAvailability> declared,
}) async {
  // Tall enough to lay out all seven cards under the summary: in the default
  // viewport the ListView never builds the ones at the bottom.
  await tester.binding.setSurfaceSize(const Size(800, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myAvailabilityProvider.overrideWith(
          () => _StubMyAvailability(declared),
        ),
      ],
      child: MaterialApp(home: WeekAvailabilityScreen(weekStart: _monday)),
    ),
  );
  await tester.pumpAndSettle();
}

FilledButton _sendButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.ancestor(
    of: find.textContaining('coach'),
    matching: find.byType(FilledButton),
  ),
);

WeekAvailability _weekWith(Map<int, List<DayActivity>> planned) =>
    WeekAvailability(
      weekStart: _monday,
      days: [
        for (var day = 0; day < 7; day++)
          DayAvailability(dayOfWeek: day, activities: planned[day] ?? const []),
      ],
    );

void main() {
  testWidgets('a week never declared can be sent untouched', (tester) async {
    // An athlete with nothing on next week is answering their coach, not
    // staying silent. Gating the button on an edit left them no way to say it,
    // so the API kept reading the missing week as no answer and the reminder
    // kept firing at someone who had nothing left to add.
    await _pumpScreen(tester, declared: const []);

    expect(_sendButton(tester).onPressed, isNotNull);
    expect(find.text('Nothing on this week yet'), findsOneWidget);
  });

  testWidgets('a declared week waits for an edit before it can be sent', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      declared: [
        _weekWith({
          1: const [DayActivity(label: 'Bouldering')],
        }),
      ],
    );

    expect(_sendButton(tester).onPressed, isNull);

    await tester.tap(find.byTooltip('Remove Bouldering'));
    await tester.pumpAndSettle();

    expect(_sendButton(tester).onPressed, isNotNull);
  });

  testWidgets('a declared week with nothing on it still reads as declared', (
    tester,
  ) async {
    // The declaration is a fact of its own now: a week the athlete answered by
    // planning nothing comes back from the API as a week, and the screen must
    // not offer to send it again as though it had never been answered.
    await _pumpScreen(tester, declared: [_weekWith(const {})]);

    expect(find.text('Nothing on this week'), findsOneWidget);
    expect(_sendButton(tester).onPressed, isNull);
  });

  testWidgets('the summary counts what the week holds', (tester) async {
    await _pumpScreen(
      tester,
      declared: [
        _weekWith({
          1: const [
            DayActivity(label: 'Bouldering', durationMinutes: 90),
            DayActivity(label: 'Stretching', durationMinutes: 20),
          ],
          4: const [DayActivity(label: 'Long run', durationMinutes: 70)],
        }),
      ],
    );

    expect(find.text('3 things across 2 days'), findsOneWidget);
    expect(find.text('3h'), findsOneWidget);
  });

  testWidgets('every day of the week gets a card', (tester) async {
    await _pumpScreen(tester, declared: const []);

    for (final name in [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
  });
}
