import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/utils/bodyweight_measurement.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/screens/bodyweight/bodyweight_measure_screen.dart';
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
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = ref.read(bodyweightProvider).value;
    if (current != null) _controller.text = _format(current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _format(double kilograms) => kilograms.toStringAsFixed(1);

  Future<void> _measure() async {
    final measured = await showBodyweightMeasureScreen(context);
    if (measured == null || !mounted) return;
    setState(() {
      _error = null;
      _controller.text = _format(measured);
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
    if (entered == null || !isPlausibleBodyweight(entered)) {
      setState(
        () => _error =
            'Enter a weight between '
            '${BodyweightMeasurement.minimumPlausibleKg.toStringAsFixed(0)} and '
            '${BodyweightMeasurement.maximumPlausibleKg.toStringAsFixed(0)} kg',
      );
      return;
    }
    // Captured before the await: the dialog is gone by the time there is
    // something to say.
    final messenger = ScaffoldMessenger.of(context);
    final sent = await ref.read(bodyweightProvider.notifier).set(entered);
    if (!mounted) return;
    Navigator.of(context).pop(entered);
    if (!sent) {
      // The run resolves against it either way, so this is not a failure to
      // report as one. What the athlete cannot know without being told is that
      // their coach is not seeing this yet.
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Saved on this device. Your coach will see it when you are back '
            'online.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected =
        ref.watch(connectionStateProvider) == BleConnectionState.connected;

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
          if (connected)
            OutlinedButton.icon(
              onPressed: _measure,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
