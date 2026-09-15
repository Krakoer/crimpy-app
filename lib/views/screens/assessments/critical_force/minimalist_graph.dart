import 'dart:math';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class MinimalistGraph extends ConsumerWidget {
  const MinimalistGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleData = ref.watch(bleDataStreamProvider);
    final session = ref.watch(bleSessionProvider);

    // A BLE stream: a held value is last second's reading, not the sensor now.
    // ignore: keep_the_held_value
    return bleData.when(
      data: (data) {
        return SfCartesianChart(
          margin: EdgeInsets.zero,
          plotAreaBorderWidth: 0,
          primaryXAxis: DateTimeAxis(
            isVisible: false,
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            minorGridLines: const MinorGridLines(width: 0),
          ),
          primaryYAxis: NumericAxis(
            isVisible: false,
            maximum: max(70, session.max),
            minimum: -10,
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            minorGridLines: const MinorGridLines(width: 0),
          ),
          borderWidth: 0,
          series: [
            LineSeries<BleDataPoint, DateTime>(
              dataSource: data,
              xValueMapper: (BleDataPoint p, _) => p.timestamp,
              yValueMapper: (BleDataPoint p, _) => p.value,
              color: CrimpyTheme.accentYellow.withValues(alpha: 0.8),
              width: 3,
              markerSettings: const MarkerSettings(isVisible: false),
              animationDuration: 0,
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (e, st) => const SizedBox(),
    );
  }
}
