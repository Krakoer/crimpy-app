import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The width of a section heading inside the 16px padding of a 360dp phone,
/// which is the line every assertion here is about.
const _lineWidth = 328.0;

Future<void> _pump(WidgetTester tester, String label) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: _lineWidth, child: SectionLabel(label)),
        ),
      ),
    ),
  );
}

Rect _rule(WidgetTester tester) => tester.getRect(find.byType(Container).first);

Rect _line(WidgetTester tester) => tester.getRect(find.byType(SizedBox).first);

bool _clipped(WidgetTester tester) => tester
    .renderObject<RenderParagraph>(find.byType(RichText).first)
    .didExceedMaxLines;

void main() {
  // What the class is: a heading with a rule filling the rest of the line. A
  // Flexible label beside the Expanded rule pinned the rule at half the line,
  // leaving a short heading trailed by a rule that stopped in mid air.
  testWidgets('runs the rule to the end of the line after a short label', (
    tester,
  ) async {
    await _pump(tester, 'Goal');

    expect(_rule(tester).right, closeTo(_line(tester).right, 0.5));
    expect(_clipped(tester), isFalse);
  });

  // The phases a coach writes are the reason the label had to stop overflowing
  // in the first place, so one that fits the line has to be shown whole.
  testWidgets('shows a label that fits the line in full', (tester) async {
    for (final label in [
      'capacity, 3 week block',
      'deload, then max strength',
    ]) {
      await _pump(tester, label);

      expect(_clipped(tester), isFalse, reason: label);
      expect(
        _rule(tester).right,
        closeTo(_line(tester).right, 0.5),
        reason: label,
      );
    }
  });

  // The longest name the write path allows is longer than the line, so it is
  // ellipsized rather than overflowing, and a stub of rule survives so the row
  // still reads as a heading.
  testWidgets('ellipsizes a label longer than the line and keeps some rule', (
    tester,
  ) async {
    await _pump(tester, 'a' * 60);

    expect(tester.takeException(), isNull);
    expect(_clipped(tester), isTrue);
    expect(_rule(tester).width, greaterThanOrEqualTo(24));
    expect(_rule(tester).right, closeTo(_line(tester).right, 0.5));
  });
}
