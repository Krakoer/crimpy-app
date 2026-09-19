import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/widgets/ble/connection_dialog.dart';
import 'package:crimpy/views/widgets/bodyweight_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pushes the run screen for [training], asking for whatever the run needs
/// first. If the training can be measured with the force sensor, a sensor
/// already connected is used as is; otherwise the athlete is asked whether they
/// have one and lets them connect, and the run goes on without the gauge when
/// they decline. Loads set in percent of the body weight also need one, so it
/// is asked for when still missing.
///
/// Shared by every entry point that starts a training the athlete did not write
/// themselves, so a scheduled session and an assessment run on their own terms
/// ask the same questions.
Future<void> startTrainingRun(
  BuildContext context,
  WidgetRef ref,
  Training training, {
  required SessionActivity activity,
  String? trainingId,
  String? programSessionId,
  AssessmentResults results = AssessmentResults.none,
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
      final hasSensor = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Force sensor'),
          content: const Text(
            'Do you have a Crimpy force sensor to measure this training?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Run without'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes, connect'),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      if (hasSensor == true) {
        final picked = await showDialog<bool>(
          context: context,
          builder: (_) => const ConnectionDialog(),
        );
        if (!context.mounted) return;
        // The dialog answers true the moment a device is tapped, while the
        // connection is still being opened, so the state is only trusted to
        // add a sensor the dialog did not report, never to take one away.
        useSensor = picked == true || isConnected();
      }
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
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PlayTrainingScreen(
        training,
        useSensor: useSensor,
        activity: activity,
        trainingId: trainingId,
        programSessionId: programSessionId,
        bodyweightKg: bodyweight,
        results: measured,
      ),
    ),
  );
}
