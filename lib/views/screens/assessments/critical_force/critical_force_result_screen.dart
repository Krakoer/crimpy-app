import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/critical_force_result.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/assessments/post_assessment_screen.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CriticalForceResultScreen extends ConsumerWidget {
  final double? previousCriticalForce;
  final CriticalForceResults results;
  final AssessmentResultModel saveAssessment;
  final SessionModel saveSession;
  final List<RepDataModel> saveReps;
  final List<BleDataPoint> data;

  /// The readings on the analysis' time footing, for the trace.
  final List<CriticalForceSample> samples;

  const CriticalForceResultScreen({
    this.previousCriticalForce,
    required this.results,
    required this.data,
    required this.samples,
    required this.saveAssessment,
    required this.saveSession,
    required this.saveReps,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lateOff = results.lateOffCount;
    return Scaffold(
      appBar: AppBar(title: Text("Critical Force assessment results")),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: CrimpyTheme.spaceLgPlus),
            Text(
              "Great job!",
              style: CrimpyTheme.headline.copyWith(
                color: CrimpyTheme.textPrimary,
              ),
            ),
            SizedBox(height: CrimpyTheme.spaceLg),
            ResultCard(
              prevValue: previousCriticalForce,
              newValue: results.criticalForce,
            ),
            SizedBox(height: CrimpyTheme.spaceLgPlus),
            Text(
              "Critical force:",
              style: CrimpyTheme.headline.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "${results.criticalForce.toStringAsFixed(2)} kg",
              style: CrimpyTheme.numerals(
                48,
              ).copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              results.firstCountedPull == results.lastCountedPull
                  ? "Mean of pull ${results.lastCountedPull}"
                  : "Mean of pulls ${results.firstCountedPull}-${results.lastCountedPull}",
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
            if (lateOff > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CrimpyTheme.spaceLg,
                  vertical: CrimpyTheme.spaceXs,
                ),
                child: Text(
                  lateOff == 1
                      ? "1 pull was held on after the bell. Force past the bell does not count."
                      : "$lateOff pulls were held on after the bell. Force past the bell does not count.",
                  textAlign: TextAlign.center,
                  style: CrimpyTheme.body.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ),
            SfCartesianChart(
              plotAreaBorderWidth: 0,
              series: <CartesianSeries>[
                FastLineSeries<CriticalForceSample, double>(
                  width: 2,
                  dataSource: samples,
                  xValueMapper: (CriticalForceSample sample, _) => sample.t,
                  yValueMapper: (CriticalForceSample sample, _) => sample.kg,
                ),
                // Each pull's mean, in the middle of its window.
                ScatterSeries<CriticalForcePull, double>(
                  dataSource: [
                    for (final pull in results.pulls)
                      if (pull.meanKg != null) pull,
                  ],
                  xValueMapper: (pull, _) => (pull.start + pull.end) / 2,
                  yValueMapper: (pull, _) => pull.meanKg,
                  markerSettings: MarkerSettings(isVisible: true),
                ),
                // Dashed line at the Critical Force, across the test.
                LineSeries<(double, double), double>(
                  dataSource: [
                    (results.pulls.first.start, results.criticalForce),
                    (results.pulls.last.end, results.criticalForce),
                  ],
                  xValueMapper: (data, _) => data.$1,
                  yValueMapper: (data, _) => data.$2,
                  dashArray: <double>[5, 5],
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
              primaryYAxis: NumericAxis(
                axisLine: AxisLine(color: Colors.transparent),
                majorGridLines: MajorGridLines(width: 0),
                majorTickLines: MajorTickLines(size: 0),
              ),
              primaryXAxis: NumericAxis(
                axisLine: AxisLine(color: Colors.transparent),
                majorTickLines: MajorTickLines(size: 0),
                majorGridLines: MajorGridLines(width: 0),
                autoScrollingMode: AutoScrollingMode.end,
                decimalPlaces: 0,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(
                      assessmentsProvider(
                        BuiltinAssessmentIds.criticalForce,
                      ).notifier,
                    )
                    .saveAssessment(
                      saveAssessment,
                      saveSession,
                      saveReps,
                      data: data,
                    );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving assessment: $e')),
                  );
                }
                return;
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text("Save new result"),
          ),
          TextButton(
            child: Text("Discard"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
