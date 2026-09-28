import 'dart:math';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/assessment_tutorials.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/reps.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/assessments/assessment_cue_box.dart';
import 'package:crimpy/views/screens/assessments/assessment_run_phase.dart';
import 'package:crimpy/views/screens/assessments/post_assessment_screen.dart';
import 'package:crimpy/views/widgets/assessment_tutorial_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/widgets/workout_lifecycle.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:intl/intl.dart';

class MvcRunScreen extends ConsumerStatefulWidget {
  final List<TrainingExecutionItem> reps;
  final AssessmentType type;

  /// The run's clock, which a test sets by hand.
  @visibleForTesting
  final CrimpyWatch? watch;

  const MvcRunScreen({
    required this.reps,
    super.key,
    required this.type,
    this.watch,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MvcRunScreenState();
}

class _MvcRunScreenState extends ConsumerState<MvcRunScreen>
    with WorkoutLifecycleMixin {
  // Store max score for right hand
  double rightMax = -1;
  // Store max score for left hand
  double leftMax = -1;
  GripPosition get _gripPosition =>
      widget.reps.whereType<TimedItem>().first.gripPosition;

  /// Set while an interruption is being handled, so a dialog closed to uncover
  /// the run does not restart the clock behind the paused dialog.
  bool _handlingInterruption = false;

  /// Stores the peak reached during the step that just ended, against the hand
  /// that step was for. Rests carry no result.
  void _recordMaxForFinishedStep() {
    final step = timer.currentItem;
    if (step is! TimedItem) return;
    if (step.handSide.isRightHand) {
      rightMax = ref.read(bleSessionProvider).max;
    } else {
      leftMax = ref.read(bleSessionProvider).max;
    }
  }

  late WorkoutTimer timer = WorkoutTimer(
    items: widget.reps,
    watch: widget.watch,
    // The countdown repaints on its own. The force readings used to be the
    // only thing rebuilding the screen, so a lost sensor froze the seconds
    // under its alarm while the run went on counting.
    onSecondChange: () {
      if (mounted) setState(() {});
    },
    onNextRep: (_) {
      _recordMaxForFinishedStep();
      // Reset session stats for next rep.
      ref.read(bleSessionProvider.notifier).reset();
    },
    onFinished: () async {
      // Add final rep (onNextRep is not called when finished)
      _recordMaxForFinishedStep();
      // Get previous values for printing results screen.
      // Not ideal, if it takes time the screen will just freeze.
      // TODO: Move this logic to PostAssessmentScreen and show progress indicator/error text accordingly.
      final gripPosition = _gripPosition;
      final prevValueRight = await ref
          .read(
            assessmentsProvider(
              BuiltinAssessmentIds.idOf(widget.type),
            ).notifier,
          )
          .getLastValueForHand(HandSide.right, gripPosition: gripPosition);
      final prevValueLeft = await ref
          .read(
            assessmentsProvider(
              BuiltinAssessmentIds.idOf(widget.type),
            ).notifier,
          )
          .getLastValueForHand(HandSide.left, gripPosition: gripPosition);

      if (mounted) {
        // Push result screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => PostAssessmentScreen(
              definition: BuiltinAssessmentIds.definitionOf(widget.type),
              rightHandResults: (prevValueRight, rightMax),
              leftHandResults: (prevValueLeft, leftMax),
              saveAssessment: AssessmentResultModel(
                assessmentId: BuiltinAssessmentIds.idOf(widget.type),
                rightValue: rightMax,
                leftValue: leftMax,
                gripPosition: _gripPosition,
              ),
              saveTraining: SessionModel(
                name:
                    "MVC assessment (${_gripPosition.shortName}) - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                isAssessment: true,
                origin: SessionOrigin.played,
              ),
              saveReps: buildRepsData([rightMax, leftMax], widget.reps),
            ),
          ),
        );
      }
    },
  );

  @override
  void initState() {
    super.initState();
    timer.init();
    timer.play();
  }

  @override
  void dispose() {
    timer.dispose();
    super.dispose();
  }

  // Max Force is measured per pull with rest in between, so extra rest does not
  // affect the result: the run is suspended and picked up where it left off,
  // keeping everything already recorded.
  @override
  void onLeftForeground() {
    if (timer.finished) return;
    timer.stop();
    sensorRepository.pauseStreaming();
  }

  @override
  Future<void> onReturnedToForeground() async {
    if (timer.finished) return;
    _handlingInterruption = true;
    popDownToRun();
    await showWorkoutPausedDialog(context);
    _handlingInterruption = false;
    if (!mounted) return;
    sensorRepository.resumeStreaming();
    setState(() => timer.play());
  }

  /// What the cue box asks for on the current step.
  String _prompt(RunPhase phase) {
    if (phase == RunPhase.alarm) return 'No sensor';
    if (timer.currentItem is! RestItem) return 'Pull!';
    return "Pulling with ${timer.currentItemIndex == 0 ? "right" : "left"} hand in";
  }

  @override
  Widget build(BuildContext context) {
    final sensorLost =
        ref.watch(connectionStateProvider) != BleConnectionState.connected;
    final phase = assessmentStepPhase(
      steps: widget.reps,
      stepIndex: timer.currentItemIndex,
      sensorLost: sensorLost,
    );
    // Last BLE value to print on screen & compute the height of the colored box.
    // A lost sensor leaves its last sample behind, which is not a reading.
    final lastValue = sensorLost ? 0.0 : ref.watch(bleLastValueProvider) ?? 0;
    // BLE session stats to watch the max value and compute the height of the max bar.
    final bleSession = ref.watch(bleSessionProvider);
    // Height of the screen
    double height = MediaQuery.of(context).size.height;
    // Screen padding
    final padding = MediaQuery.of(context).viewPadding;
    // Height (without status bar, toolbar, and bottom padding due to SafeArea)
    double trueHeight = height - padding.top - padding.bottom - kToolbarHeight;

    // Bottom padding for the max bar.
    // Max is 90% of screen at 100kg.
    double paddingMax = min(0.9, bleSession.max / (100 / 0.9)) * trueHeight;
    // Height factor for current value box.
    // Same computation as paddingMax.
    double heightFactor = min(0.9, lastValue / (100 / 0.9));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (res, didPop) async {
        if (res) {
          return;
        }
        setState(() {
          timer.stop();
        });
        final NavigatorState navigator = Navigator.of(context);
        // Ask user if they want to leave assessment
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Leave the workout?'),
            content: Text(
              'If you leave this workout, you will lose your progress.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    timer.play();
                  });
                  Navigator.of(context).pop(false);
                },
                child: Text('Keep going'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: CrimpyTheme.destructiveButton,
                child: Text('Leave'),
              ),
            ],
          ),
        );

        // If user chose to leave, leave the workout.
        if (shouldPop ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: phase == RunPhase.calm
            ? CrimpyTheme.phaseCalmGround
            : null,
        appBar: AppBar(
          title: Text("Max Force Test"),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () async {
                // Pause timer while showing tutorial
                setState(() {
                  timer.stop();
                });

                final gripPosition = _gripPosition;

                // Show tutorial (forced, no "don't show again")
                await showTutorialIfNeeded(
                  context: context,
                  content: AssessmentTutorials.getMvcTutorial(gripPosition),
                  tutorialId: AssessmentTutorials.getMvcTutorialId(
                    gripPosition,
                  ),
                  forceShow: true,
                );

                // Resume timer after tutorial is closed, unless it was closed
                // to uncover the run for the paused dialog, which resumes the
                // run itself once the user is back in position.
                if (!mounted || _handlingInterruption) return;
                setState(() {
                  timer.play();
                });
              },
              tooltip: 'Show tutorial',
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Text to show current sensor value.
              Padding(
                padding: EdgeInsets.only(bottom: trueHeight * 0.75),
                child: Text(
                  "${lastValue.toStringAsFixed(2)} kg",
                  style: CrimpyTheme.numerals(
                    70,
                  ).copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              // Box to represent current sensor value. Only visible during active reps.
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: FractionallySizedBox(
                  heightFactor: heightFactor,
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: timer.currentItem is RestItem
                          ? Colors.transparent
                          : CrimpyTheme.phaseColor(
                              phase,
                            ).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              // Box of text to show the user the action to do (rest or pull).
              Positioned(
                top: 230,
                child: AssessmentCueBox(
                  phase: phase,
                  prompt: _prompt(phase),
                  secondsRemaining: timer.currentItemRemaining,
                ),
              ),
              // If on an active rep, show the max bar with max value.
              if (timer.currentItem is! RestItem)
                Padding(
                  padding: EdgeInsets.only(bottom: paddingMax),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: CrimpyTheme.spaceSm,
                        ),
                        child: Text(
                          "${bleSession.max.toStringAsFixed(2)} kg",
                          style: CrimpyTheme.tabular(CrimpyTheme.headline)
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 2,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.symmetric(),
                            shape: BoxShape.rectangle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
