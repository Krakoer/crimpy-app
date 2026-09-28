import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/week_histogram_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/roboto.dart';

void main() {
  setUpAll(loadRoboto);

  final monday = DateTime(2026, 9, 21);

  // The home card's content width on a 360dp phone: the screen's 16dp gutter
  // and the card's 16dp padding and 2dp line on each side.
  const phoneContentWidth = 360.0 - 2 * (16 + 16 + 2);

  Future<void> pumpWeek(
    WidgetTester tester,
    Duration onTuesday, {
    Duration onWednesday = Duration.zero,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: phoneContentWidth,
              child: WeekHistogramWidget(
                startOfWeek: monday,
                maxBarHeight: 75,
                sessions: [
                  SessionModel(
                    name: 'Bouldering',
                    isAssessment: false,
                    origin: SessionOrigin.logged,
                    activity: SessionActivity.climbing,
                    durationInSeconds: onTuesday.inSeconds,
                    date: DateTime(2026, 9, 22, 18),
                  ),
                  if (onWednesday > Duration.zero)
                    SessionModel(
                      name: 'Stretching',
                      isAssessment: false,
                      origin: SessionOrigin.logged,
                      activity: SessionActivity.stretching,
                      durationInSeconds: onWednesday.inSeconds,
                      date: DateTime(2026, 9, 23, 18),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a long day keeps its length on one line inside its column', (
    tester,
  ) async {
    await pumpWeek(
      tester,
      const Duration(minutes: 90),
      onWednesday: const Duration(minutes: 5),
    );

    expect(tester.takeException(), isNull);
    final long = find.text('1 h 30 min');
    expect(long, findsOneWidget);
    final column = tester.getSize(find.byType(Expanded).at(1)).width;
    expect(tester.getRect(long).width, lessThanOrEqualTo(column + 0.01));

    final longParagraph = tester.renderObject<RenderParagraph>(long);
    final shortParagraph = tester.renderObject<RenderParagraph>(
      find.text('5 min'),
    );
    expect(longParagraph.size.height, shortParagraph.size.height);
  });

  testWidgets('a day with nothing logged carries no label', (tester) async {
    await pumpWeek(tester, const Duration(minutes: 45));

    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('0 min'), findsNothing);
    expect(find.textContaining('0s'), findsNothing);
  });

  testWidgets('a day under a minute reads its seconds, not zero', (
    tester,
  ) async {
    await pumpWeek(tester, const Duration(seconds: 30));

    expect(find.text('30s'), findsOneWidget);
    expect(find.text('0 min'), findsNothing);
  });

  testWidgets('the day names stay on one line with or without a label', (
    tester,
  ) async {
    await pumpWeek(tester, const Duration(minutes: 45));

    final dayNames = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ].map((name) => tester.getCenter(find.text(name)).dy).toSet();
    expect(dayNames, hasLength(1));
  });
}
