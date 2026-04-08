import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/ble_data_model.dart';
import '../../theme/crimpy_theme.dart';
import '../../viewmodels/ble_view_model.dart';
import '../widgets/ble/battery_bluetooth_indicator.dart';
import '../widgets/ble/connection_dialog.dart';

class ChartScreen extends ConsumerWidget {
  /// Shows a chart of the live sensor data.
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateProvider);
    final dataStream = ref.watch(bleDataStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Chart'),
        actions: [
          // Battery level and connection status
          BatteryBluetoothIndicator(
            connectionState: connectionState,
            onBluetoothPressed: () => _showConnectionDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context, connectionState, dataStream, ref),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        // Only allow reset when connected
        onPressed:
            connectionState == BleConnectionState.connected
                ? () {
                  ref.read(bleSessionProvider.notifier).reset();
                }
                : null,
        tooltip: 'Reset Session',
        child: const Icon(Icons.restart_alt),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BleConnectionState connectionState,
    AsyncValue<List<BleDataPoint>> dataStream,
    WidgetRef ref,
  ) {
    final currentSession = ref.watch(bleSessionProvider);

    // If not connected, show connection prompt
    if (connectionState != BleConnectionState.connected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getConnectionIcon(connectionState),
              size: 60,
              color:
                  connectionState == BleConnectionState.connecting
                      ? CrimpyTheme.accentOrange
                      : CrimpyTheme.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              connectionState == BleConnectionState.connecting
                  ? 'Connecting to device...'
                  : 'Not connected to any device',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showConnectionDialog(context, ref),
              child: const Text('Connect to Device'),
            ),
          ],
        ),
      );
    }

    // If connected, show data or waiting message
    return dataStream.when(
      data: (dataPoints) {
        if (dataPoints.isEmpty) {
          return const Center(child: Text('Waiting for data...'));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    intervalType: DateTimeIntervalType.seconds,
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                  ),
                  series: <LineSeries<BleDataPoint, DateTime>>[
                    LineSeries<BleDataPoint, DateTime>(
                      onRendererCreated: (ChartSeriesController controller) {
                        // Store the series controller for potential future updates
                      },
                      animationDuration: 0, // No animation for real-time data
                      dataSource: dataPoints,
                      xValueMapper: (BleDataPoint data, _) => data.timestamp,
                      yValueMapper: (BleDataPoint data, _) => data.value,
                      name: 'BLE Data',
                      color: Theme.of(context).colorScheme.secondary,
                      markerSettings: const MarkerSettings(isVisible: false),
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(enable: true),
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: const InteractiveTooltip(
                      enable: true,
                      format: 'Value: point.y',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CrimpyCards.stats(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          "Current value",
                          "${dataPoints.last.value.toStringAsFixed(1)} kg",
                        ),
                        _buildStatItem(
                          context,
                          "Elapsed time",
                          "${currentSession.elapsed.inSeconds} s",
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          "Max value",
                          "${currentSession.max.toStringAsFixed(1)} kg",
                        ),
                        _buildStatItem(
                          context,
                          "Average value",
                          "${currentSession.avg.toStringAsFixed(1)} kg",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Center(child: Text('Error loading data: $e')),
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: CrimpyTheme.gray500),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  IconData _getConnectionIcon(BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return Icons.bluetooth_connected;
      case BleConnectionState.connecting:
        return Icons.bluetooth_searching;
      case BleConnectionState.failed:
        return Icons.bluetooth_disabled;
      case BleConnectionState.disconnected:
        return Icons.bluetooth;
    }
  }

  void _showConnectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ConnectionDialog(),
    );
  }
}
