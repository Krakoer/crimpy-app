import 'dart:math';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/utils/assessment_chart_axes.dart';
import 'package:crimpy/views/widgets/series_swatch.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/day_line_chart.dart';
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

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.leftData.isEmpty && widget.rightData.isEmpty;
    // The placeholder behind Start Assessment previews both hands, the way a
    // real per hand chart draws them.
    final leftData = !widget.perHand
        ? const <(DateTime, double)>[]
        : isEmpty
        ? _generateFakeData()
        : widget.leftData;
    final rightData = isEmpty ? _generateFakeData() : widget.rightData;

    if (!isEmpty &&
        testedDays([...leftData, ...rightData].map((point) => point.$1)) < 2) {
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

    return CrimpyCards.assessment(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(CrimpyTheme.spaceMd),
            child: DayLineChart(
              color: widget.seriesColor,
              unit: widget.unit,
              series: [
                if (widget.perHand)
                  (
                    name: 'Left Hand',
                    data: leftData,
                    stroke: SeriesStroke.solid,
                  ),
                (
                  name: widget.perHand ? 'Right Hand' : 'Result',
                  data: rightData,
                  stroke: widget.perHand
                      ? SeriesStroke.dashed
                      : SeriesStroke.solid,
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
