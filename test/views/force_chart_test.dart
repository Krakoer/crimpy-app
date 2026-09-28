import 'package:crimpy/views/screens/profile_screen/widgets/assessment_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// The date labels Syncfusion actually lays out for a [ForceChart] holding
/// tests on [dates]: the chart's own x axis is rebuilt with a formatter that
/// records each label it is asked for, and pumped. See Krakoer/crimpy#164.
Future<List<String>> renderedDateLabels(
  WidgetTester tester,
  List<DateTime> dates,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ForceChart(
          leftData: [for (final date in dates) (date, 20)],
          rightData: [for (final date in dates) (date, 21)],
          seriesColor: Colors.black,
          onStartAssessment: () {},
        ),
      ),
    ),
  );
  final chart = tester.widget<SfCartesianChart>(find.byType(SfCartesianChart));
  final axis = chart.primaryXAxis as NumericAxis;

  final labels = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: NumericAxis(
              minimum: axis.minimum,
              maximum: axis.maximum,
              interval: axis.interval,
              rangePadding: axis.rangePadding,
              axisLabelFormatter: (details) {
                final label = axis.axisLabelFormatter!(details);
                labels.add(label.text);
                return label;
              },
            ),
            series: chart.series,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return labels.toSet().toList();
}

void main() {
  // The ranges review found mislabelled on the former date axis, which floored
  // its first label and stepped by 24 hours: a 44 day span from the 15th, and
  // spans over the autumn and spring clock changes. Run this under
  // TZ=Europe/Paris to see the clock changes; it holds in any zone.
  testWidgets('labels both ends of a 44 day span from the 15th', (
    tester,
  ) async {
    expect(
      await renderedDateLabels(tester, [
        DateTime(2026, 5, 15, 9),
        DateTime(2026, 6, 28, 18),
      ]),
      ['May 15', 'May 26', 'Jun 6', 'Jun 17', 'Jun 28'],
    );
  });

  testWidgets('labels both ends across the autumn clock change', (
    tester,
  ) async {
    expect(
      await renderedDateLabels(tester, [
        DateTime(2026, 10, 12, 9),
        DateTime(2026, 11, 1, 20),
      ]),
      ['Oct 12', 'Oct 17', 'Oct 22', 'Oct 27', 'Nov 1'],
    );
  });

  testWidgets('labels both ends across the spring clock change', (
    tester,
  ) async {
    expect(
      await renderedDateLabels(tester, [
        DateTime(2026, 3, 16, 1),
        DateTime(2026, 4, 5, 23),
      ]),
      ['Mar 16', 'Mar 21', 'Mar 26', 'Mar 31', 'Apr 5'],
    );
  });

  testWidgets('labels only the two ends of a span nothing divides', (
    tester,
  ) async {
    expect(
      await renderedDateLabels(tester, [
        DateTime(2026, 9, 20),
        DateTime(2026, 9, 27),
      ]),
      ['Sep 20', 'Sep 27'],
    );
  });
}
