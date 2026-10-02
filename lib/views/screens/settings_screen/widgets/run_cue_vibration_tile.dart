import 'package:crimpy/viewmodels/run_cue_preferences_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Turns the run screen's vibrations on and off. The beeps' own setting, when
/// there is one, belongs next to it.
class RunCueVibrationTile extends ConsumerWidget {
  const RunCueVibrationTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibrates = ref.watch(runCueVibrationProvider).value;
    return SwitchListTile(
      secondary: const Icon(Icons.vibration),
      title: const Text('Vibrate on run cues'),
      subtitle: const Text(
        'A buzz as a pull starts, two at let go, a tick as a step runs out',
      ),
      value: vibrates ?? false,
      onChanged: vibrates == null
          ? null
          : (value) => ref.read(runCueVibrationProvider.notifier).set(value),
    );
  }
}
