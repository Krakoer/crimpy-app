import 'dart:async';

import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/widgets/ble/connection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks for the bodyweight, either typed in or measured by hanging on the
/// sensor. Returns the saved weight in kilograms, or null when dismissed.
Future<double?> showBodyweightDialog(BuildContext context) =>
    showDialog<double>(
      context: context,
      builder: (_) => const BodyweightDialog(),
    );

/// The bodyweight to run [training] with. Trainings loaded in percent of the
/// bodyweight cannot be turned into kilograms without one, so the dialog is
/// shown when it is still missing. Returns null when the user skips it.
Future<double?> resolveBodyweight(
  BuildContext context,
  WidgetRef ref,
  Training training,
) async {
  final current = await ref.read(bodyweightProvider.future);
  if (current != null || !training.needsBodyweight) return current;
  if (!context.mounted) return null;
  return showBodyweightDialog(context);
}

class BodyweightDialog extends ConsumerStatefulWidget {
  const BodyweightDialog({super.key});

  @override
  ConsumerState<BodyweightDialog> createState() => _BodyweightDialogState();
}

class _BodyweightDialogState extends ConsumerState<BodyweightDialog> {
  static const int _measureSeconds = 5;

  final TextEditingController _controller = TextEditingController();
  Timer? _measureTimer;
  int _secondsLeft = 0;
  String? _error;

  bool get _measuring => _measureTimer != null;

  @override
  void initState() {
    super.initState();
    final current = ref.read(bodyweightProvider).value;
    if (current != null) _controller.text = _format(current);
  }

  @override
  void dispose() {
    _measureTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  static String _format(double kilograms) => kilograms.toStringAsFixed(1);

  /// Records the peak the sensor sees while the user hangs with their full
  /// weight on it. The peak, rather than the average, keeps the ramp up at the
  /// start of the hang out of the result.
  void _startMeasure() {
    ref.read(bleSessionProvider.notifier).reset();
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft -= 1);
        return;
      }
      timer.cancel();
      final measured = ref.read(bleSessionProvider).max;
      setState(() {
        _measureTimer = null;
        _secondsLeft = 0;
        if (measured > 0) _controller.text = _format(measured);
      });
    });
    setState(() {
      _error = null;
      _secondsLeft = _measureSeconds;
      _measureTimer = timer;
    });
  }

  Future<void> _connectSensor() async {
    await showDialog<bool>(
      context: context,
      builder: (_) => const ConnectionDialog(),
    );
  }

  Future<void> _save() async {
    final entered = double.tryParse(
      _controller.text.trim().replaceAll(',', '.'),
    );
    if (entered == null || entered <= 0) {
      setState(() => _error = 'Enter a weight in kilograms');
      return;
    }
    await ref.read(bodyweightProvider.notifier).set(entered);
    if (!mounted) return;
    Navigator.of(context).pop(entered);
  }

  @override
  Widget build(BuildContext context) {
    final connected =
        ref.watch(connectionStateProvider) == BleConnectionState.connected;
    final lastValue = ref.watch(bleLastValueProvider);

    return AlertDialog(
      title: const Text('Body weight'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your body weight is used to turn loads set as a percentage of it '
            'into kilograms.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: !_measuring,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              labelText: 'Weight',
              suffixText: 'kg',
              hintText: 'e.g., 68.5',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_measuring)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hang with all your weight on the sensor.'),
                const SizedBox(height: 8),
                Text(
                  '${lastValue == null ? "--" : lastValue.toStringAsFixed(1)} kg'
                  ' - $_secondsLeft',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            )
          else if (connected)
            OutlinedButton.icon(
              onPressed: _startMeasure,
              icon: const Icon(Icons.speed),
              label: const Text('Measure with the sensor'),
            )
          else
            OutlinedButton.icon(
              onPressed: _connectSensor,
              icon: const Icon(Icons.bluetooth),
              label: const Text('Connect a sensor to measure'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _measuring ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _measuring ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
