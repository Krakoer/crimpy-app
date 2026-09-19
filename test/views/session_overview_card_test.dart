import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SessionModel _session({int? rpe, bool rpeFailed = false}) => SessionModel(
  id: 's1',
  name: 'Board',
  isAssessment: false,
  origin: SessionOrigin.logged,
  activity: SessionActivity.hangboard,
  durationInSeconds: 3600,
  date: DateTime(2026, 9, 19, 18, 30),
  rpe: rpe,
  rpeFailed: rpeFailed,
);

/// Renders the card at the width of a narrow phone, which is where an anchor
/// that cannot wrap runs off the card.
Future<void> _pump(
  WidgetTester tester,
  SessionModel session, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SessionOverviewCard(session: session),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('reads the answer back with the anchor that explains it', (
    tester,
  ) async {
    await _pump(tester, _session(rpe: 7));

    expect(find.text('Session RPE 7'), findsOneWidget);
    expect(
      find.text('Needs less than a day of rest before repeating it'),
      findsOneWidget,
    );
  });

  // The anchor is a sentence where every other stat is a figure, so it has to
  // wrap rather than run off the card.
  testWidgets('fits the longest anchor on a narrow phone', (tester) async {
    await _pump(tester, _session(rpe: 7));

    expect(tester.takeException(), isNull);
  });

  testWidgets('still fits it at a large system text scale', (tester) async {
    await _pump(tester, _session(rpe: 7), textScale: 1.6);

    expect(tester.takeException(), isNull);
  });

  testWidgets('names a failure by the word rather than by a number', (
    tester,
  ) async {
    await _pump(tester, _session(rpeFailed: true));

    expect(find.text('Session RPE ECHEC'), findsOneWidget);
    expect(find.text('Could not be carried through'), findsOneWidget);
  });

  testWidgets('says nothing about an RPE the athlete never gave', (
    tester,
  ) async {
    await _pump(tester, _session());

    expect(find.textContaining('Session RPE'), findsNothing);
  });
}
