import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/ble_data_model.dart';
import '../../../viewmodels/ble_view_model.dart';

class BatteryBluetoothIndicator extends ConsumerWidget {
  final BleConnectionState connectionState;
  final VoidCallback onBluetoothPressed;

  const BatteryBluetoothIndicator({
    super.key,
    required this.connectionState,
    required this.onBluetoothPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryLevel = ref.watch(batteryLevelProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (batteryLevel != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${batteryLevel.round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getBatteryColor(batteryLevel),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  _getBatteryIcon(batteryLevel),
                  size: 20,
                  color: _getBatteryColor(batteryLevel),
                ),
              ],
            ),
          ),
        IconButton(
          icon: Icon(_getConnectionIcon(connectionState)),
          onPressed: onBluetoothPressed,
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
      case BleConnectionState.disconnected:
        return Icons.bluetooth_disabled;
    }
  }

  IconData _getBatteryIcon(double level) {
    if (level >= 85) return Icons.battery_full;
    if (level >= 70) return Icons.battery_6_bar;
    if (level >= 55) return Icons.battery_5_bar;
    if (level >= 40) return Icons.battery_4_bar;
    if (level >= 25) return Icons.battery_3_bar;
    if (level >= 15) return Icons.battery_2_bar;
    if (level >= 5) return Icons.battery_1_bar;
    return Icons.battery_0_bar;
  }

  Color _getBatteryColor(double level) {
    if (level > 20) return Colors.green;
    if (level > 10) return Colors.orange;
    return Colors.red;
  }
}
