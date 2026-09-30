import 'package:crimpy/utils/consistency.dart';
import 'package:crimpy/views/screens/home_screen/widgets/consistency_strip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<ConsistencyDay> _days() => [
  for (var i = 0; i < consistencyStripDays; i++)
    ConsistencyDay(
      day: DateTime(2026, 9, 16 + i),
      tracked: i >= 2,
      owed: i.isEven ? 1 : 0,
      done: i % 4 == 0 ? 1 : 0,
    ),
];

Future<void> _show(WidgetTester tester, {VoidCallback? onTap}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConsistencyStrip(days: _days(), onTap: onTap),
        ),
      ),
    );

void main() {
  testWidgets('heads the strip with no count or score', (tester) async {
    await _show(tester);

    expect(find.text('LAST 14 DAYS'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d+ of \d+')), findsNothing);
    expect(find.textContaining('streak', findRichText: true), findsNothing);
    expect(find.text('16 SEP'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
  });

  testWidgets('says the aggregate only to a screen reader, as one element', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _show(tester, onTap: () {});

    final node = tester.getSemantics(find.byType(CustomPaint).last);
    expect(node.label, 'LAST 14 DAYS');
    expect(node.value, describeConsistency(_days()));
    expect(node.hint, 'Opens the history');
    handle.dispose();
  });

  testWidgets('tapping it opens what the card leads to', (tester) async {
    var opened = false;
    await _show(tester, onTap: () => opened = true);

    await tester.tap(find.byType(ConsistencyStrip));
    expect(opened, isTrue);
  });
}
