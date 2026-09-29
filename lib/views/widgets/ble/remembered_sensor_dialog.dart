import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How long a run waits for the remembered sensor before asking instead. Short:
/// the athlete is standing at the board, and a sensor that is on and nearby
/// answers in a second or two.
const rememberedSensorConnectTimeout = Duration(seconds: 8);

/// What came of connecting to the remembered sensor.
enum RememberedSensorResult { connected, notFound, runWithout }

/// Connects straight to the remembered [device], showing that it is at it,
/// and closes on the result. "Run without" stays available while it tries.
class RememberedSensorDialog extends ConsumerStatefulWidget {
  const RememberedSensorDialog({required this.device, super.key});

  final SensorDevice device;

  @override
  ConsumerState<RememberedSensorDialog> createState() =>
      _RememberedSensorDialogState();
}

class _RememberedSensorDialogState
    extends ConsumerState<RememberedSensorDialog> {
  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    final connected = await ref
        .read(connectionStateProvider.notifier)
        .connectToDevice(
          widget.device,
          timeout: rememberedSensorConnectTimeout,
        );
    if (!mounted) return;
    Navigator.of(context).pop(
      connected
          ? RememberedSensorResult.connected
          : RememberedSensorResult.notFound,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Force sensor'),
      content: Row(
        children: [
          const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: CrimpyTheme.spaceLg),
          Expanded(child: Text('Connecting to ${widget.device.name}...')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(RememberedSensorResult.runWithout),
          child: const Text('Run without'),
        ),
      ],
    );
  }
}
