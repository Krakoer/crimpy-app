import 'package:crimpy/logger.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/ble_view_model.dart';
import '../../../theme/crimpy_theme.dart';

class ConnectionDialog extends ConsumerStatefulWidget {
  const ConnectionDialog({super.key});

  @override
  ConsumerState<ConnectionDialog> createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends ConsumerState<ConnectionDialog> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    final connectionState = ref.read(connectionStateProvider);
    final adapterState = ref.read(bleAdapterStateProvider);
    // Only start scan if not connected
    if (connectionState != BleConnectionState.connected &&
        adapterState == BluetoothAdapterState.on) {
      _startScan();
    }
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
    });

    final _ = ref.refresh(scanResultsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final adapterState = ref.watch(bleAdapterStateProvider);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BLE Connection',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const Divider(),
            if (adapterState == BluetoothAdapterState.on) ...[
              if (connectionState == BleConnectionState.connected)
                _buildConnectedView()
              else
                _buildScanView(),

              const SizedBox(height: 8),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (connectionState == BleConnectionState.connected)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: CrimpyTheme.primaryWhite,
                      ),
                      onPressed: () {
                        ref.read(connectionStateProvider.notifier).disconnect();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Disconnect'),
                    )
                  else if (!_isScanning)
                    ElevatedButton(
                      onPressed: _startScan,
                      child: const Text('Scan Again'),
                    ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    child: const Text('Turn Bluetooth ON'),
                    onPressed: () async {
                      try {
                        await FlutterBluePlus.turnOn();
                      } catch (e) {
                        AppLoggerHelper.warning(
                          "Error while turning bluetooth adapter on: $e",
                        );
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedView() {
    final device = ref.watch(connectedDeviceProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected to:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: CrimpyTheme.gray500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.bluetooth_connected,
                color: CrimpyTheme.accentYellow,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device?.platformName ?? 'Unknown Device',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      device?.remoteId.toString() ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CrimpyTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanView() {
    final scanResults = ref.watch(scanResultsProvider);

    Widget buildScanResults(List<BluetoothDevice> devices) {
      setState(() {
        _isScanning = false;
      });

      if (devices.isEmpty) {
        return Center(
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No devices found. Try scanning again.'),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(
              device.platformName.isNotEmpty
                  ? device.platformName
                  : 'Unknown Device',
            ),
            subtitle: Text(device.remoteId.toString()),
            onTap: () {
              ref
                  .read(connectionStateProvider.notifier)
                  .connectToDevice(device);
              Navigator.of(context).pop(true);
            },
          );
        },
      );
    }

    return Flexible(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: switch (scanResults) {
          // A BLE stream: a held value is last second's reading, not the sensor now.
          // ignore: keep_the_held_value
          AsyncData(:final value) => buildScanResults(value),
          AsyncValue(:final error?) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error scanning: $error'),
            ),
          ),

          _ => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning for devices...'),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}
