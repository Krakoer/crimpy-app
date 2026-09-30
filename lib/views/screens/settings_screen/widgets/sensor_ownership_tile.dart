import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The athlete's sensor as a run will treat it: the one it connects to, none,
/// or asked each time, with the way to change it.
class SensorOwnershipTile extends ConsumerWidget {
  const SensorOwnershipTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sensorOwnershipProvider.notifier);
    final stored = ref.watch(sensorOwnershipProvider);
    final ownership = stored.value;
    final (title, subtitle, action, onPressed) = switch (ownership) {
      RememberedSensor(:final device) => (
        device.name,
        'Connects when a run starts',
        'Forget',
        controller.forget,
      ),
      NoSensorOwned() => (
        'No force sensor',
        'Runs start without asking for one',
        'I have one',
        controller.forget,
      ),
      SensorOwnershipUnknown() || null => (
        'Force sensor',
        'Asked when a run starts',
        "I don't have one",
        controller.rememberNoSensor,
      ),
    };
    return ListTile(
      leading: const Icon(Icons.bluetooth),
      title: Text(title),
      subtitle: Text(subtitle),
      // Only once something was read: a read still loading, or failed, says
      // nothing about a sensor this would forget.
      trailing: TextButton(
        onPressed: stored.hasValue ? onPressed : null,
        child: Text(action),
      ),
    );
  }
}
