import 'dart:async';

import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:crimpy/views/screens/availability/week_availability_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubMyAvailability extends MyAvailability {
  _StubMyAvailability(this._weeks, {this.saveGate, this.onSave});

  final List<WeekAvailability> _weeks;

  /// Held open by a test that wants to look at the screen while the send is in
  /// flight. Left null, a save completes immediately.
  final Completer<void>? saveGate;

  /// Handed what the screen sent, so a test can look at it without the stub
  /// holding state of its own.
  final void Function(WeekAvailability week)? onSave;

  @override
  Future<List<WeekAvailability>> build() async => _weeks;

  @override
  Future<void> saveWeek(WeekAvailability week) async {
    onSave?.call(week);
    if (saveGate != null) await saveGate!.future;
  }
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

/// Opens the screen on top of another route, so a back that is allowed through
/// has somewhere to land. On the root route the navigator has nothing to pop
/// and the gesture is a no-op whatever PopScope says.
Future<void> _pumpPushedScreen(
  WidgetTester tester, {
  required List<WeekAvailability> declared,
  Completer<void>? saveGate,
  void Function(WeekAvailability week)? onSave,
}) async {
  final stub = _StubMyAvailability(
    declared,
    saveGate: saveGate,
    onSave: onSave,
  );
  await tester.binding.setSurfaceSize(const Size(800, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [myAvailabilityProvider.overrideWith(() => stub)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WeekAvailabilityScreen(weekStart: _monday),
                ),
              ),
              child: const Text('open the week'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open the week'));
  await tester.pumpAndSettle();
}

/// Raises the system back gesture at the route, the way the platform does.
Future<void> _invokeBack(WidgetTester tester) async {
  await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
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

  testWidgets('leaving a dirty week with the back button asks first', (
    tester,
  ) async {
    await _pumpPushedScreen(
      tester,
      declared: [
        _weekWith({
          1: const [DayActivity(label: 'Bouldering')],
        }),
      ],
    );

    await tester.tap(find.byTooltip('Remove Bouldering'));
    await tester.pumpAndSettle();

    // A back that popped straight out would take the edit with it, and the
    // week now holds typed activities rather than two text fields.
    await _invokeBack(tester);
    expect(find.text('Leave this week?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Stay'));
    await tester.pumpAndSettle();
    expect(find.byType(WeekAvailabilityScreen), findsOneWidget);
    expect(_sendButton(tester).onPressed, isNotNull);
  });

  testWidgets('leaving an untouched week does not ask', (tester) async {
    await _pumpPushedScreen(
      tester,
      declared: [
        _weekWith({
          1: const [DayActivity(label: 'Bouldering')],
        }),
      ],
    );

    await _invokeBack(tester);

    expect(find.text('Leave this week?'), findsNothing);
    expect(find.byType(WeekAvailabilityScreen), findsNothing);
    expect(find.text('open the week'), findsOneWidget);
  });

  testWidgets('the undo of a removed activity does not follow the week', (
    tester,
  ) async {
    // The snack bar is presented above the navigator, so it survives the week
    // switch on its own. Its action would put Tuesday's activity back into
    // whatever week is on screen, since a day is matched by index and carries
    // no week of its own.
    await _pumpScreen(
      tester,
      declared: [
        _weekWith({
          1: const [DayActivity(label: 'Bouldering')],
        }),
      ],
    );

    await tester.tap(find.byTooltip('Remove Bouldering'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.textContaining('In 2 weeks'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Discard'));
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsNothing);
    expect(find.text('Bouldering'), findsNothing);
  });

  testWidgets('sending retires the undo before the request goes out', (
    tester,
  ) async {
    // Every other control goes dead while the send is in flight. An undo left
    // tappable would restore into a week whose body is already on the wire, and
    // the restore would be thrown away without a word.
    final gate = Completer<void>();
    WeekAvailability? sent;
    await _pumpPushedScreen(
      tester,
      declared: [
        _weekWith({
          1: const [DayActivity(label: 'Bouldering')],
        }),
      ],
      saveGate: gate,
      onSave: (week) => sent = week,
    );

    await tester.tap(find.byTooltip('Remove Bouldering'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Send to my coach'));
    // Two frames plus the snack bar's exit animation: clearSnackBars runs the
    // normal dismiss rather than removing the widget outright.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Undo'), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();
    expect(sent!.days[1].activities, isEmpty);
  });

  testWidgets('a back taken during the send does not pop twice', (
    tester,
  ) async {
    // Navigator.pop resolves to the topmost present route, and a route already
    // popping is not one. A second pop would take the route underneath, which
    // from the home card is the root.
    final gate = Completer<void>();
    await _pumpPushedScreen(
      tester,
      declared: [
        _weekWith({
          1: const [DayActivity(label: 'Bouldering')],
        }),
      ],
      saveGate: gate,
    );

    await tester.tap(find.byTooltip('Remove Bouldering'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Send to my coach'));
    await tester.pump();

    // The response has to land while the route is still transitioning out:
    // that is the window where the State is mounted but the route is no longer
    // the present one, so a second pop reaches past it.
    unawaited(tester.state<NavigatorState>(find.byType(Navigator)).maybePop());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    gate.complete();
    await tester.pump();
    await tester.pumpAndSettle();

    // Back on the route the week was opened from, rather than out of it.
    expect(find.text('open the week'), findsOneWidget);
  });

  testWidgets('removing an activity and undoing leaves nothing to send', (
    tester,
  ) async {
    // The week is byte identical to the one on the server again, so there is
    // nothing to say. Re-sending would re-date the declaration and put the week
    // at the top of the coach's feed as an answer that was never changed.
    await _pumpPushedScreen(
      tester,
      declared: [
        _weekWith({
          1: const [DayActivity(label: 'Bouldering', durationMinutes: 90)],
        }),
      ],
    );

    await tester.tap(find.byTooltip('Remove Bouldering'));
    await tester.pumpAndSettle();
    expect(_sendButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Bouldering'), findsOneWidget);
    expect(_sendButton(tester).onPressed, isNull);
  });

  testWidgets('opening the editor retires a pending undo', (tester) async {
    // The undo carries the day as it stood before the removal. Left standing,
    // it could put that snapshot back over an activity added after it.
    await _pumpPushedScreen(
      tester,
      declared: [
        _weekWith({
          1: const [DayActivity(label: 'Bouldering')],
        }),
      ],
    );

    await tester.tap(find.byTooltip('Remove Bouldering'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Add something').first);
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsNothing);
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
