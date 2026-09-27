import 'package:crimpy/logger.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter/material.dart';
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
    final adapterOn = ref.read(bleAdapterOnProvider);
    // Only start scan if not connected
    if (connectionState != BleConnectionState.connected && adapterOn) {
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
    final adapterOn = ref.watch(bleAdapterOnProvider);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BLE Connection',
                  style: CrimpyTheme.title.copyWith(
                    color: CrimpyTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const Divider(),
            if (adapterOn) ...[
              if (connectionState == BleConnectionState.connected)
                _buildConnectedView()
              else
                _buildScanView(),

              const SizedBox(height: CrimpyTheme.spaceSm),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (connectionState == BleConnectionState.connected)
                    FilledButton(
                      style: CrimpyTheme.destructiveButton,
                      onPressed: () {
                        ref.read(connectionStateProvider.notifier).disconnect();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Disconnect'),
                    )
                  else if (!_isScanning)
                    FilledButton(
                      onPressed: _startScan,
                      child: const Text('Scan Again'),
                    ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
                child: Center(
                  child: ElevatedButton(
                    child: const Text('Turn Bluetooth ON'),
                    onPressed: () async {
                      try {
                        await ref.read(bleAdapterOnProvider.notifier).turnOn();
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
      padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected to:',
            style: CrimpyTheme.bodySmall.copyWith(
              color: CrimpyTheme.textSecondary,
            ),
          ),
          const SizedBox(height: CrimpyTheme.spaceSm),
          Row(
            children: [
              Icon(
                Icons.bluetooth_connected,
                color: CrimpyTheme.markOn(CrimpyTheme.sensorConnected),
                size: 24,
              ),
              const SizedBox(width: CrimpyTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device?.name ?? 'Unknown Device',
                      style: CrimpyTheme.titleSmall.copyWith(
                        color: CrimpyTheme.textPrimary,
                      ),
                    ),
                    Text(
                      device?.id ?? '',
                      style: CrimpyTheme.bodySmall.copyWith(
                        color: CrimpyTheme.textSecondary,
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

    Widget buildScanResults(List<SensorDevice> devices) {
      setState(() {
        _isScanning = false;
      });

      if (devices.isEmpty) {
        return Center(
          child: const Padding(
            padding: EdgeInsets.all(CrimpyTheme.spaceLg),
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
            title: Text(device.name),
            subtitle: Text(device.id),
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
              padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
              child: Text('Error scanning: $error'),
            ),
          ),

          _ => const Center(
            child: Padding(
              padding: EdgeInsets.all(CrimpyTheme.spaceXl),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: CrimpyTheme.spaceLg),
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
