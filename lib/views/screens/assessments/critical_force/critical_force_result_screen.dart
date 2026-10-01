import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/critical_force_result.dart';
import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/utils/critical_force_analysis.dart';
import 'package:crimpy/viewmodels/finished_run_draft_view_model.dart';
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

  /// Whole seconds the run stood paused once the first pull had started.
  final int pausedSeconds;

  const CriticalForceResultScreen({
    this.previousCriticalForce,
    required this.results,
    required this.data,
    required this.samples,
    this.pausedSeconds = 0,
    required this.saveAssessment,
    required this.saveSession,
    required this.saveReps,
    super.key,
  });

  /// The result of a finished run as it was kept on the device, which is how
  /// every run reaches this screen: straight from the run, and again on the
  /// next launch when the app died before the result was saved. [results] is
  /// the analysis the run already made; a resumed run makes it again, on the
  /// same readings.
  CriticalForceResultScreen.fromDraft(
    CriticalForceResultDraft draft, {
    CriticalForceResults? results,
    Key? key,
  }) : this(
         key: key,
         previousCriticalForce: draft.previousCriticalForce,
         results:
             results ?? analyseCriticalForce(draft.samples, draft.pullWindows),
         data: draft.data,
         samples: draft.samples,
         pausedSeconds: draft.pausedSeconds,
         saveAssessment: draft.saveAssessment,
         saveSession: draft.saveSession,
         saveReps: draft.saveReps,
       );

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
              _countedPullsLabel(results),
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
            if (pausedSeconds > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CrimpyTheme.spaceLg,
                  vertical: CrimpyTheme.spaceXs,
                ),
                child: Text(
                  "The test was paused for $pausedSeconds s. Extra rest lets the forearm recover, so this result may read high.",
                  textAlign: TextAlign.center,
                  style: CrimpyTheme.body.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
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
            // The chart takes what the numbers above leave, so the screen
            // fits a small phone.
            Expanded(
              child: SfCartesianChart(
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
            ),
            // Room for the save and discard buttons floating over the bottom,
            // so they do not sit on the chart.
            const SizedBox(
              height: kMinInteractiveDimension + CrimpyTheme.spaceLg,
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
              // Stored, so the copy kept in case the app died here goes. A save
              // that failed keeps it.
              await forgetFinishedRun(
                ref.read(finishedRunDraftRepositoryProvider),
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text("Save new result"),
          ),
          TextButton(
            child: Text("Discard"),
            onPressed: () async {
              await forgetFinishedRun(
                ref.read(finishedRunDraftRepositoryProvider),
              );
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// Which pulls the Critical Force is the mean of, saying so when holes in the
/// readings left some of them out.
String _countedPullsLabel(CriticalForceResults results) {
  final span = "pulls ${results.firstCountedPull}-${results.lastCountedPull}";
  final spanLength = results.lastCountedPull - results.firstCountedPull + 1;
  return results.averagedPullCount == spanLength
      ? "Mean of $span"
      : "Mean of ${results.averagedPullCount} of $span";
}
