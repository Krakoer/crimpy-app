import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/assessment_chart_axes.dart';
import 'package:crimpy/views/widgets/series_swatch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// One line of a [DayLineChart]: its name, its points, and how it is stroked.
typedef DayLineSeries = ({
  String name,
  List<(DateTime, double)> data,
  SeriesStroke stroke,
});

/// Lines over calendar days, drawn by the honest axes of Krakoer/crimpy#164:
/// the value axis never spans less than [minimumAxisSpan] of the unit, so a
/// difference only looks big when it is, and the date axis counts whole days
/// from the first point to the last, both of them labelled. Every chart that
/// states a measured load over time draws through here, the profile's
/// assessments and the history's training loads alike, so the two cannot come
/// to read the same numbers differently.
///
/// It draws whatever it is handed. A single day is a value rather than a trend,
/// and deciding that is the caller's: [testedDays] says how many there are.
class DayLineChart extends StatelessWidget {
  final List<DayLineSeries> series;
  final Color color;
  final AssessmentUnit unit;

  const DayLineChart({
    super.key,
    required this.series,
    required this.color,
    this.unit = AssessmentUnit.kilograms,
  });

  static List<(DateTime, double)> _byDay(List<(DateTime, double)> data) => [
    for (final (date, value) in data)
      (DateTime(date.year, date.month, date.day), value),
  ];

  LineSeries<(DateTime, double), num> _line(
    DayLineSeries line,
    DateTime first,
  ) => LineSeries<(DateTime, double), num>(
    name: line.name,
    dataSource: _byDay(line.data),
    xValueMapper: (point, _) => dayOffset(first, point.$1),
    yValueMapper: (point, _) => point.$2,
    color: color,
    width: 2,
    dashArray: line.stroke.chartDashArray,
    markerSettings: MarkerSettings(
      isVisible: true,
      color: color,
      borderColor: color,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final allData = [for (final line in series) ..._byDay(line.data)];
    final dates = allData.map((point) => point.$1).toList()..sort();
    final spanDays = dayOffset(dates.first, dates.last);
    final range = valueAxisRange(allData.map((point) => point.$2), unit)!;

    return SfCartesianChart(
      // Whole days since the first day rather than a date axis: its labels
      // start at the minimum and are written by calendar arithmetic, so the
      // first and the last day are both labelled and a clock change cannot
      // move one onto the wrong date.
      primaryXAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        interval: dateLabelInterval(spanDays).toDouble(),
        labelStyle: TextStyle(color: CrimpyTheme.textPrimary),
        axisLabelFormatter: (details) => ChartAxisLabel(
          DateFormat.MMMd().format(dayAt(dates.first, details.value.round())),
          details.textStyle,
        ),
        minimum: 0,
        maximum: spanDays.toDouble(),
        rangePadding: ChartRangePadding.none,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        plotOffset: 8,
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        minimum: range.min,
        maximum: range.max,
        interval: range.interval,
        rangePadding: ChartRangePadding.none,
        majorGridLines: MajorGridLines(
          width: 0.5,
          color: CrimpyTheme.outlineSubtle,
        ),
        labelStyle: TextStyle(color: CrimpyTheme.textPrimary),
      ),
      series: <LineSeries<(DateTime, double), num>>[
        for (final line in series)
          if (line.data.isNotEmpty) _line(line, dates.first),
      ],
    );
  }
}
