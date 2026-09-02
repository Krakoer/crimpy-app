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
  // Tall enough to lay out all seven rows and the button below them: in the
  // default viewport the ListView never builds the button to be found.
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

bool _sendEnabled(WidgetTester tester) =>
    tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Send to my coach'),
        )
        .onPressed !=
    null;

void main() {
  testWidgets('a week never declared can be sent untouched', (tester) async {
    // An athlete with no time at all next week is answering their coach, not
    // staying silent. Gating the button on an edit left them no way to say it,
    // so the API kept reading the missing week as no answer and the reminder
    // kept firing at someone who had nothing left to add.
    await _pumpScreen(tester, declared: const []);

    expect(_sendEnabled(tester), isTrue);
  });

  testWidgets('a declared week waits for an edit before it can be sent', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      declared: [
        WeekAvailability(
          weekStart: _monday,
          days: [
            for (var day = 0; day < 7; day++)
              DayAvailability(dayOfWeek: day, isAvailable: day == 1),
          ],
        ),
      ],
    );

    expect(_sendEnabled(tester), isFalse);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(_sendEnabled(tester), isTrue);
  });
}
