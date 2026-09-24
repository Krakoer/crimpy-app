import 'dart:math';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/bodyweight_measurement.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Measures the athlete bodyweight by watching the sensor until the reading
/// holds still. Pops the measured weight in kilograms, or null when left.
Future<double?> showBodyweightMeasureScreen(BuildContext context) =>
    Navigator.of(context).push<double>(
      MaterialPageRoute(builder: (_) => const BodyweightMeasureScreen()),
    );

class BodyweightMeasureScreen extends ConsumerStatefulWidget {
  const BodyweightMeasureScreen({super.key});

  @override
  ConsumerState<BodyweightMeasureScreen> createState() =>
      _BodyweightMeasureScreenState();
}

class _BodyweightMeasureScreenState
    extends ConsumerState<BodyweightMeasureScreen> {
  final BodyweightMeasurement _measurement = BodyweightMeasurement();
  int _consumed = 0;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(bleSessionProvider.notifier).reset();
    });
  }

  void _consume(List<BleDataPoint> points) {
    // The session reset empties the buffer, so a shorter list is a new run
    // rather than samples we already fed in.
    if (points.length < _consumed) _consumed = 0;
    for (final point in points.skip(_consumed)) {
      _measurement.add(point);
    }
    _consumed = points.length;

    final result = _measurement.result;
    if (result != null && !_leaving) {
      _leaving = true;
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bleDataStreamProvider, (_, next) {
      final points = next.value;
      if (points != null && mounted) _consume(points);
    });

    final lastValue = ref.watch(bleLastValueProvider);
    final bleData = ref.watch(bleDataStreamProvider);
    final holding = _measurement.phase == BodyweightMeasurementPhase.holding;

    return Scaffold(
      appBar: AppBar(title: const Text('Measure body weight')),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _graph(bleData, lastValue, holding),
            Positioned(top: 20, child: _statusBox(holding)),
            Positioned(bottom: 20, child: _readingBox(lastValue)),
          ],
        ),
      ),
    );
  }

  // A BLE stream: a held value is last second's reading, not the sensor now.
  Widget _graph(
    AsyncValue<List<BleDataPoint>> bleData,
    double? lastValue,
    bool holding,
  ) {
    // ignore: keep_the_held_value
    return bleData.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox();

        final now = data.last.timestamp;
        const halfWindow = Duration(seconds: 8);

        return SfCartesianChart(
          margin: EdgeInsets.zero,
          plotAreaBorderWidth: 0,
          primaryXAxis: DateTimeAxis(
            isVisible: false,
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            minorGridLines: const MinorGridLines(width: 0),
            minimum: now.subtract(halfWindow),
            maximum: now.add(halfWindow),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            maximum: max(100, (lastValue ?? 0) + 20),
            minimum: -5,
            majorGridLines: const MajorGridLines(width: 1),
            axisLine: const AxisLine(width: 1),
            minorGridLines: const MinorGridLines(width: 0),
          ),
          borderWidth: 0,
          series: [
            LineSeries<BleDataPoint, DateTime>(
              dataSource: data,
              xValueMapper: (BleDataPoint p, _) => p.timestamp,
              yValueMapper: (BleDataPoint p, _) => p.value,
              color: holding
                  ? CrimpyTheme.markOn(CrimpyTheme.accentGreen)
                  // The same series, held to the same 3:1 non-text floor.
                  : CrimpyTheme.markOn(
                      CrimpyTheme.accentYellow,
                    ).withValues(alpha: 0.8),
              width: 3,
              markerSettings: const MarkerSettings(isVisible: false),
              animationDuration: 0,
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
    );
  }

  Widget _statusBox(bool holding) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      // The label on this box is white. The alpha is gone as well as the
      // hue darkened: at 0.9 even the darkened gold only reaches 4.03:1,
      // and the bare accents read 2.06:1 and 3.33:1 under white.
      color: holding
          ? CrimpyTheme.fillOn(CrimpyTheme.accentGreen)
          : CrimpyTheme.fillOn(CrimpyTheme.accentYellow),
      border: Border.all(color: CrimpyTheme.borderDefault, width: 2),
      boxShadow: const [
        BoxShadow(
          color: CrimpyTheme.borderDefault,
          offset: Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          holding ? 'Hold still' : 'Hang with all your weight on the sensor',
          style: const TextStyle(
            fontSize: 20,
            color: CrimpyTheme.primaryWhite,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (holding) ...[
          const SizedBox(height: 8),
          Text(
            '${_measurement.secondsRemaining}',
            style: const TextStyle(
              fontSize: 40,
              color: CrimpyTheme.primaryWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _readingBox(double? lastValue) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${lastValue == null ? "--" : lastValue.toStringAsFixed(1)} kg',
          style: const TextStyle(
            fontSize: 48,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _measurement.phase == BodyweightMeasurementPhase.holding
              ? 'Recording ${_measurement.stableValue!.toStringAsFixed(1)} kg'
              : 'Waiting for a steady reading',
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    ),
  );
}
