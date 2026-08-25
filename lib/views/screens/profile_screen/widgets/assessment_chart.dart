import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../theme/crimpy_theme.dart';

class ForceChart extends StatefulWidget {
  final List<(DateTime, double)> leftData;
  final List<(DateTime, double)> rightData;
  final Color accentLeft;
  final Color accentRight;
  final VoidCallback onStartAssessment;

  /// Hidden when a single series is drawn, since there are no hands to tell
  /// apart and naming the one line "Right Hand" would misread the result.
  final bool showLegend;

  const ForceChart({
    super.key,
    required this.leftData,
    required this.rightData,
    required this.accentLeft,
    required this.accentRight,
    required this.onStartAssessment,
    this.showLegend = true,
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

  @override
  Widget build(BuildContext context) {
    // Merge left + right to compute overall domain
    final allData = [...widget.leftData, ...widget.rightData].toList();

    // Round dates to day
    List<(DateTime, double)> leftData = widget.leftData
        .map((d) => (d.$1.copyWith(hour: 0, minute: 0, second: 0), d.$2))
        .toList();
    List<(DateTime, double)> rightData = widget.rightData
        .map((d) => (d.$1.copyWith(hour: 0, minute: 0, second: 0), d.$2))
        .toList();

    return CrimpyCards.assessment(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                intervalType: DateTimeIntervalType.days,
                dateFormat: DateFormat.MMMd(), // needs intl package
                labelStyle: TextStyle(color: CrimpyTheme.primaryBlack),
                rangePadding: ChartRangePadding.additional,
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: CrimpyTheme.gray300,
                ),
                labelStyle: TextStyle(color: CrimpyTheme.primaryBlack),
              ),
              legend: Legend(
                isVisible: widget.showLegend,
                position: LegendPosition.bottom,
              ),
              series: <LineSeries<(DateTime, double), DateTime>>[
                if (widget.showLegend)
                  LineSeries<(DateTime, double), DateTime>(
                    name: "Left Hand",
                    dataSource: allData.isEmpty
                        ? _generateFakeData()
                        : leftData,
                    xValueMapper: (data, _) => data.$1,
                    yValueMapper: (data, _) => data.$2,
                    color: widget.accentLeft,
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                LineSeries<(DateTime, double), DateTime>(
                  name: widget.showLegend ? "Right Hand" : "Result",
                  dataSource: allData.isEmpty ? _generateFakeData() : rightData,
                  xValueMapper: (data, _) => data.$1,
                  yValueMapper: (data, _) => data.$2,
                  color: widget.accentRight,
                  width: 2,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
              ],
            ),
          ),
          if (allData.isEmpty) ...[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: CrimpyTheme.primaryWhite.withValues(alpha: 0.7),
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
