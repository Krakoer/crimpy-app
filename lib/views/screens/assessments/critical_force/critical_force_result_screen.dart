import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/assessments/post_assessment_screen.dart';
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

  const CriticalForceResultScreen({
    this.previousCriticalForce,
    required this.results,
    required this.data,
    required this.saveAssessment,
    required this.saveSession,
    required this.saveReps,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startTime = data[0].timestamp.millisecondsSinceEpoch;
    final timestamps = data
        .map((e) => (e.timestamp.millisecondsSinceEpoch - startTime) / 1000)
        .toList();
    final forces = data.map((e) => e.value).toList();
    return Scaffold(
      appBar: AppBar(title: Text("Critical Force assessment results")),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Great job! 💪",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 16),
            ResultCard(
              prevValue: previousCriticalForce,
              newValue: results.criticalLoad,
            ),
            SizedBox(height: 20),
            Text(
              "Critical force:",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 30,
              ),
            ),
            Text(
              "${results.criticalLoad.toStringAsFixed(2)} kg",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 45,
                fontWeight: FontWeight.bold,
              ),
            ),
            SfCartesianChart(
              plotAreaBorderWidth: 0,
              series: <CartesianSeries>[
                FastLineSeries<(double, double), double>(
                  width: 2,
                  dataSource: List.generate(
                    timestamps.length,
                    (index) => (timestamps[index], forces[index]),
                  ),
                  xValueMapper: ((double, double) data, _) => data.$1,
                  yValueMapper: ((double, double) data, _) => data.$2,
                ),
                // Print points on tmeans, fmeans
                ScatterSeries<(double, double), double>(
                  dataSource: List.generate(
                    results.tmeans.length,
                    (index) => (results.tmeans[index], results.fmeans[index]),
                  ),
                  xValueMapper: (data, _) => data.$1,
                  yValueMapper: (data, _) => data.$2,
                  markerSettings: MarkerSettings(isVisible: true),
                ),
                // Print dashed horizontal line at criticalLoad
                LineSeries<(double, double), double>(
                  dataSource: [
                    (timestamps[0], results.criticalLoad),
                    (timestamps.last, results.criticalLoad),
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
                        AssessmentType.criticalForce,
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
