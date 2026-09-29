import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/widgets/ble/connection_dialog.dart';
import 'package:crimpy/views/widgets/ble/remembered_sensor_dialog.dart';
import 'package:crimpy/views/widgets/bodyweight_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pushes the run screen for [training], asking for whatever the run needs
/// first. If the training can be measured with the force sensor, a sensor
/// already connected is used as is, the remembered one is connected to
/// directly, and an athlete who said they have none is not asked. Otherwise,
/// or when the remembered sensor is not found, the athlete is asked whether
/// they have one and lets them connect, and the run goes on without the gauge
/// when they decline. Loads set in percent of the body weight also need one, so it
/// is asked for when still missing.
///
/// Shared by every entry point that starts a training, so a scheduled session,
/// a training from the library and an assessment run on their own terms ask
/// the same questions.
///
/// [replaceCurrentRoute] puts the run in place of the screen it was started
/// from, so the end of the run goes back past it.
Future<void> startTrainingRun(
  BuildContext context,
  WidgetRef ref,
  Training training, {
  required SessionActivity activity,
  String? trainingId,
  String? programSessionId,
  AssessmentResults results = AssessmentResults.none,
  bool replaceCurrentRoute = false,
}) async {
  bool isConnected() =>
      ref.read(connectionStateProvider) == BleConnectionState.connected;

  var useSensor = false;
  if (training.canUseSensor) {
    // A connected sensor answers the question by itself: asking anyway sent
    // the athlete into a connection dialog that had nothing left to do, and
    // closing it ran the training unmeasured.
    useSensor = isConnected();
    if (!useSensor) {
      useSensor = await resolveSensorForRun(context, ref);
      if (!context.mounted) return;
    }
  }
  // After the sensor, so a user who just connected one is offered the
  // measurement rather than being asked to connect all over again.
  final bodyweight = await resolveBodyweight(context, ref, training);
  if (!context.mounted) return;
  // Awaited rather than taken from the watched value, so a run started before
  // the first fetch lands still gets the athlete numbers instead of silently
  // running everything at the coach fallbacks.
  var measured = results;
  try {
    measured = (await ref.read(
      assessmentResultsProvider.future,
    )).withDefinitions(training.referencedAssessments);
  } catch (_) {
    // A failed fetch runs on the fallbacks rather than blocking the training.
  }
  if (!context.mounted) return;
  ref.read(bleSessionProvider.notifier).reset();
  final route = MaterialPageRoute<void>(
    builder: (_) => PlayTrainingScreen(
      training,
      useSensor: useSensor,
      activity: activity,
      trainingId: trainingId,
      programSessionId: programSessionId,
      bodyweightKg: bodyweight,
      results: measured,
    ),
  );
  final navigator = Navigator.of(context);
  if (replaceCurrentRoute) {
    navigator.pushReplacement(route);
  } else {
    navigator.push(route);
  }
}

/// Whether a run can measure with a sensor, when none is connected yet:
/// connects the remembered one, answers no for an athlete who has none, and
/// otherwise asks.
Future<bool> resolveSensorForRun(BuildContext context, WidgetRef ref) async {
  bool isConnected() =>
      ref.read(connectionStateProvider) == BleConnectionState.connected;

  SensorOwnership ownership;
  try {
    ownership = await ref.read(sensorOwnershipProvider.future);
  } catch (_) {
    // Nothing readable remembered: ask, as before anything was.
    ownership = const SensorOwnershipUnknown();
  }
  if (!context.mounted) return false;

  // Nothing can reach a sensor with the phone's Bluetooth off. The scan
  // behind Connect offers to turn it on.
  final bluetoothOff =
      ownership is RememberedSensor && !await _bluetoothOn(ref);
  if (!context.mounted) return false;

  SensorDevice? notFound;
  switch (ownership) {
    case NoSensorOwned():
      return false;
    case RememberedSensor(:final device) when bluetoothOff:
      notFound = device;
    case RememberedSensor(:final device):
      final result = await showDialog<RememberedSensorResult>(
        context: context,
        barrierDismissible: false,
        builder: (_) => RememberedSensorDialog(device: device),
      );
      if (!context.mounted) return false;
      switch (result) {
        case RememberedSensorResult.connected:
          return true;
        case RememberedSensorResult.runWithout || null:
          return isConnected();
        case RememberedSensorResult.notFound:
          notFound = device;
      }
    case SensorOwnershipUnknown():
      break;
  }

  final answer = await showDialog<_SensorAnswer>(
    context: context,
    builder: (_) =>
        _HaveSensorDialog(notFound: notFound, bluetoothOff: bluetoothOff),
  );
  if (!context.mounted) return false;
  switch (answer) {
    case _SensorAnswer.connect:
      final picked = await showDialog<bool>(
        context: context,
        builder: (_) => const ConnectionDialog(),
      );
      // The dialog answers true the moment a device is tapped, while the
      // connection is still being opened, so the state is only trusted to
      // add a sensor the dialog did not report, never to take one away.
      return picked == true || isConnected();
    case _SensorAnswer.noSensor:
      await ref.read(sensorOwnershipProvider.notifier).rememberNoSensor();
      return false;
    case _SensorAnswer.runWithout || null:
      return false;
  }
}

/// Whether the phone's Bluetooth is on, asked of the platform: the state held
/// before anything asked reads off even when it is on. A platform that cannot
/// say gets the benefit of the doubt, since the direct connect times out on
/// its own.
Future<bool> _bluetoothOn(WidgetRef ref) async {
  try {
    return await ref
        .read(bleAdapterOnProvider.notifier)
        .fetch()
        .timeout(const Duration(seconds: 2));
  } catch (_) {
    return true;
  }
}

enum _SensorAnswer { connect, runWithout, noSensor }

/// Asks whether the athlete has a sensor for this run. [notFound] is the
/// remembered sensor that did not answer, when that is why it asks.
class _HaveSensorDialog extends StatefulWidget {
  const _HaveSensorDialog({this.notFound, this.bluetoothOff = false});

  final SensorDevice? notFound;

  /// Why [notFound] was not reached: the phone's Bluetooth is off.
  final bool bluetoothOff;

  @override
  State<_HaveSensorDialog> createState() => _HaveSensorDialogState();
}

class _HaveSensorDialogState extends State<_HaveSensorDialog> {
  bool _hasNoSensor = false;

  @override
  Widget build(BuildContext context) {
    final notFound = widget.notFound;
    return AlertDialog(
      title: const Text('Force sensor'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notFound != null && widget.bluetoothOff)
            Text(
              "Bluetooth is off, so ${notFound.name} cannot be reached. "
              "Connect to turn it on, or run without the sensor.",
            )
          else if (notFound != null)
            Text(
              'Could not reach ${notFound.name}. Check that it is on and '
              'nearby, or pick it again from the list.',
            )
          else ...[
            const Text(
              'Do you have a Crimpy force sensor to measure this training?',
            ),
            const SizedBox(height: CrimpyTheme.spaceSm),
            // Only an athlete who runs without one can mean they have none.
            CheckboxListTile(
              value: _hasNoSensor,
              onChanged: (value) =>
                  setState(() => _hasNoSensor = value ?? false),
              title: const Text("I don't have one, don't ask again"),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            _hasNoSensor ? _SensorAnswer.noSensor : _SensorAnswer.runWithout,
          ),
          child: const Text('Run without'),
        ),
        FilledButton(
          onPressed: _hasNoSensor
              ? null
              : () => Navigator.of(context).pop(_SensorAnswer.connect),
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
