import 'package:crimpy/models/common.dart';
import 'package:crimpy/utils/load_trends.dart';
import 'package:crimpy/views/screens/home_screen/history/session_history_screen/widgets/load_trend_deck.dart';
import 'package:crimpy/views/widgets/day_line_chart.dart';
import 'package:crimpy/views/widgets/series_swatch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _halfCrimp = (position: GripPosition.halfCrimp, edgeSizeMm: 20);
const _openHand = (position: GripPosition.openHand, edgeSizeMm: null);

TrainingLoadTrend _trend() => TrainingLoadTrend(
  key: 'repeaters',
  title: 'Repeaters 20mm',
  grips: [
    LoadGripTrend(
      grip: _halfCrimp,
      sessions: 2,
      hands: [
        (
          HandSide.right,
          [
            (date: DateTime(2026, 9, 8), kilograms: 20.0),
            (date: DateTime(2026, 9, 19), kilograms: 21.4),
          ],
        ),
      ],
    ),
    LoadGripTrend(
      grip: _openHand,
      sessions: 1,
      hands: [
        (HandSide.right, [(date: DateTime(2026, 9, 12), kilograms: 15.0)]),
      ],
    ),
    LoadGripTrend(
      grip: (position: GripPosition.threeFinger, edgeSizeMm: 20),
      sessions: 2,
      hands: [
        (
          HandSide.left,
          [
            (date: DateTime(2026, 9, 8), kilograms: 18.0),
            (date: DateTime(2026, 9, 19), kilograms: 18.2),
          ],
        ),
        (
          HandSide.right,
          [
            (date: DateTime(2026, 9, 8), kilograms: 19.0),
            (date: DateTime(2026, 9, 19), kilograms: 20.5),
          ],
        ),
      ],
    ),
  ],
);

Future<void> _show(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: LoadTrendList(trends: [_trend()])),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('charts the most weighed grip and says what moved', (
    tester,
  ) async {
    await _show(tester);

    expect(find.text('LOAD PER GRIP'), findsOneWidget);
    expect(find.text('Repeaters 20mm'), findsOneWidget);
    expect(find.text('Half Crimp 20 mm'), findsOneWidget);
    expect(find.text('Open Hand'), findsOneWidget);
    expect(find.byType(DayLineChart), findsOneWidget);
    expect(find.text('Up 1.4 kg since Sep 8.'), findsOneWidget);
    expect(
      find.text('Mean load per session, over the pulls the sensor measured.'),
      findsOneWidget,
    );
  });

  // A single day is a value, not a trend, the rule the profile's assessment
  // charts follow (Krakoer/crimpy#164).
  testWidgets('states a grip weighed on one day rather than charting it', (
    tester,
  ) async {
    await _show(tester);

    await tester.tap(find.text('Open Hand'));
    await tester.pumpAndSettle();

    expect(find.byType(DayLineChart), findsNothing);
    expect(
      find.text(
        'One day on this grip so far, at 15.0 kg. The line starts from the '
        'second.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('draws a line per hand and states each of them', (tester) async {
    await _show(tester);

    await tester.tap(find.text('3-Finger Drag 20 mm'));
    await tester.pumpAndSettle();

    final chart = tester.widget<DayLineChart>(find.byType(DayLineChart));
    expect(chart.series.map((line) => line.name), ['Left Hand', 'Right Hand']);
    expect(chart.series.map((line) => line.stroke), [
      SeriesStroke.solid,
      SeriesStroke.dashed,
    ]);
    expect(
      find.text(
        'Left Hand: Within half a kilo since Sep 8: grip noise, not progress.',
      ),
      findsOneWidget,
    );
    expect(find.text('Right Hand: Up 1.5 kg since Sep 8.'), findsOneWidget);
  });
}
