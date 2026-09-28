import 'dart:math';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/utils/assessment_chart_axes.dart';
import 'package:crimpy/views/screens/profile_screen/widgets/series_swatch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../theme/crimpy_theme.dart';

/// An assessment's history, in the metric's one hue: the left hand solid and
/// the right dashed, the stat cards above it naming which is which. The value
/// axis never spans less than [minimumAxisSpan] and the date axis runs from the
/// first test to the last. A single tested day is a value, not a chart, and
/// the stat cards already show it, so the chart only appears from the second.
/// See Krakoer/crimpy#164.
class ForceChart extends StatefulWidget {
  final List<(DateTime, double)> leftData;
  final List<(DateTime, double)> rightData;
  final Color seriesColor;
  final AssessmentUnit unit;
  final VoidCallback onStartAssessment;

  /// False for an assessment measured as a single number, which is stored on
  /// the right and drawn as one solid line.
  final bool perHand;

  const ForceChart({
    super.key,
    required this.leftData,
    required this.rightData,
    required this.seriesColor,
    required this.onStartAssessment,
    this.unit = AssessmentUnit.kilograms,
    this.perHand = true,
  });

  @override
  State<ForceChart> createState() => _ForceChartState();
}

class _ForceChartState extends State<ForceChart> {
  List<(DateTime, double)> _generateFakeData() {
    final now = DateTime.now();

    return List.generate(6, (i) {
      final r = Random().nextDouble() * 2 - 1;
      return (
        DateTime(now.year, now.month - (5 - i)),
        (25 + i * 4).toDouble() + 8 * r,
      );
    });
  }

  static List<(DateTime, double)> _byDay(List<(DateTime, double)> data) => [
    for (final (date, value) in data)
      (DateTime(date.year, date.month, date.day), value),
  ];

  LineSeries<(DateTime, double), DateTime> _line(
    String name,
    List<(DateTime, double)> data,
    SeriesStroke stroke,
  ) => LineSeries<(DateTime, double), DateTime>(
    name: name,
    dataSource: data,
    xValueMapper: (point, _) => point.$1,
    yValueMapper: (point, _) => point.$2,
    color: widget.seriesColor,
    width: 2,
    dashArray: stroke.chartDashArray,
    markerSettings: MarkerSettings(
      isVisible: true,
      color: widget.seriesColor,
      borderColor: widget.seriesColor,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.leftData.isEmpty && widget.rightData.isEmpty;
    // The placeholder behind Start Assessment previews both hands, the way a
    // real per hand chart draws them.
    final leftData = !widget.perHand
        ? const <(DateTime, double)>[]
        : isEmpty
        ? _generateFakeData()
        : _byDay(widget.leftData);
    final rightData = isEmpty ? _generateFakeData() : _byDay(widget.rightData);
    final allData = [...leftData, ...rightData];

    if (!isEmpty && testedDays(allData.map((point) => point.$1)) < 2) {
      return CrimpyCards.assessment(
        child: Padding(
          padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
          child: Text(
            'One test so far. The chart starts from the second.',
            style: CrimpyTheme.body.copyWith(color: CrimpyTheme.textSecondary),
          ),
        ),
      );
    }

    final dates = allData.map((point) => point.$1).toList()..sort();
    final spanDays =
        DateTime.utc(dates.last.year, dates.last.month, dates.last.day)
            .difference(
              DateTime.utc(
                dates.first.year,
                dates.first.month,
                dates.first.day,
              ),
            )
            .inDays;
    final range = valueAxisRange(
      allData.map((point) => point.$2),
      widget.unit,
    )!;

    return CrimpyCards.assessment(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(CrimpyTheme.spaceMd),
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                intervalType: DateTimeIntervalType.days,
                interval: dateLabelInterval(spanDays).toDouble(),
                dateFormat: DateFormat.MMMd(),
                labelStyle: TextStyle(color: CrimpyTheme.textPrimary),
                minimum: dates.first,
                maximum: dates.last,
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
              series: <LineSeries<(DateTime, double), DateTime>>[
                if (widget.perHand && leftData.isNotEmpty)
                  _line('Left Hand', leftData, SeriesStroke.solid),
                _line(
                  widget.perHand ? 'Right Hand' : 'Result',
                  rightData,
                  widget.perHand ? SeriesStroke.dashed : SeriesStroke.solid,
                ),
              ],
            ),
          ),
          if (isEmpty) ...[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: CrimpyTheme.corners,
                child: Container(
                  color: CrimpyTheme.bgPrimary.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.onStartAssessment,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Assessment"),
              style: null, // Use theme default
            ),
          ],
        ],
      ),
    );
  }
}
