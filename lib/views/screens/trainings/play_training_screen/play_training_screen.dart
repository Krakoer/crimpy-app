import 'package:crimpy/views/screens/trainings/training_feedback_screen/training_feedback_screen.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_header.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/hand_label.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_timer_display.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/next_rep_preview.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_progress_info.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/widgets/gauge.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
import 'package:crimpy/views/widgets/workout_circle.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class PlayTrainingScreen extends ConsumerStatefulWidget {
  final TrainingWithReps training;

  /// Play a given training.
  const PlayTrainingScreen(this.training, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlayTrainingScreenState();
}

class _PlayTrainingScreenState extends ConsumerState<PlayTrainingScreen>
    with TickerProviderStateMixin {
  // Controller that controls the circle around the gauge.
  late AnimationController _serieController;

  /// List of the average weights done during the training.
  List<RepDataModel> repResults = [];

  /// Duration of the preparation rest in seconds
  static const int _preparationDuration = 10;

  /// Get reps with a 10-second preparation rest prepended
  List<RepModel> get _repsWithPreparation {
    return [
      RepModel(
        durationInSeconds: _preparationDuration,
        isRest: true,
        handSide: HandSide.left,
        targetWeight: 0.0,
        index: -1,
        gripPosition: GripPosition.halfCrimp,
      ),
      ...widget.training.reps,
    ];
  }

  // Setup the workout timer
  late WorkoutTimer timer = WorkoutTimer(
    repetitions: _repsWithPreparation,
    // Set state each second to update the UI.
    onSecondChange: () => setState(() {}),
    onNextRep: (nextRepDuration) {
      // Only save rep results for actual training reps (not the preparation rest)
      // The preparation rest has index -1
      if (timer.currentRep.index >= 0) {
        repResults.add(
          RepDataModel(
            handSide: timer.currentRep.handSide,
            targetWeight: timer.currentRep.targetWeight,
            // Add avg if it was not a rest
            averageWeight: timer.currentRep.isRest
                ? 0
                : ref.read(bleSessionProvider).avg,
            duration: timer.currentRep.durationInSeconds,
            index: timer.currentRep.index,
            isRest: timer.currentRep.isRest,
            gripPosition: timer.currentRep.gripPosition,
          ),
        );
      }

      // Setup the animation controller for the next rep.
      _serieController.duration = Duration(seconds: nextRepDuration);
      _serieController.reset();
      _serieController.forward();

      // Reset the session for average computation.
      ref.read(bleSessionProvider.notifier).reset();
      setState(() {});
    },
    onFinished: () async {
      _serieController.stop();
      // Add the final average (only if it's an actual training rep, not preparation)
      if (timer.currentRep.index >= 0) {
        repResults.add(
          RepDataModel(
            handSide: timer.currentRep.handSide,
            targetWeight: timer.currentRep.targetWeight,
            // Add avg if it was not a rest
            averageWeight: timer.currentRep.isRest
                ? 0
                : ref.read(bleSessionProvider).avg,
            duration: timer.currentRep.durationInSeconds,
            index: timer.currentRep.index,
            isRest: timer.currentRep.isRest,
            gripPosition: timer.currentRep.gripPosition,
          ),
        );
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              // If the training can compute new weights, show feedback screen.
              // Otherwise show regular post-training screen.
              (context) => widget.training.computeNewWeights == null
              ? PostWorkoutScreen(
                  template: widget.training,
                  results: repResults,
                )
              : TrainingFeedbackScreen(
                  template: widget.training,
                  results: repResults,
                ),
        ),
      );
    },
  );

  @override
  void initState() {
    timer.init();
    _serieController = AnimationController(
      vsync: this,
      duration: Duration(seconds: timer.currentRep.durationInSeconds),
    );
    super.initState();
  }

  void _start() {
    setState(() {
      timer.play();
      _serieController.forward();
    });
  }

  void _stop() {
    setState(() {
      timer.stop();
      _serieController.stop();
    });
  }

  @override
  void dispose() {
    timer.dispose();
    _serieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (res, didPop) async {
        if (res) {
          return;
        }
        _stop();
        final NavigatorState navigator = Navigator.of(context);
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave the workout?'),
            content: const Text(
              'If you leave this workout, you will lose your progress.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (shouldPop ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: CrimpyTheme.bgPrimary,
        appBar: AppBar(title: Text(widget.training.name), centerTitle: true),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available height
              final availableHeight = constraints.maxHeight;

              // Determine sizes based on available height
              // Reserve space for header (~60), footer (~70), controls (~70), spacing (~40)
              // Remaining space for gauge and timer
              final reservedSpace = 240;
              final gaugeSpace = availableHeight - reservedSpace;

              // Calculate gauge size (max 300, but scale down if needed)
              final gaugeSize = (gaugeSpace * 0.6).clamp(200.0, 300.0);

              // Scale timer text based on available space
              final timerFontSize = (availableHeight * 0.06).clamp(32.0, 48.0);

              return Column(
                children: [
                  // Header
                  TrainingHeader(
                    elapsedMilliseconds: timer.elapsedMilliseconds,
                    remainingMilliseconds:
                        widget.training.totalDuration.inMilliseconds +
                        (_preparationDuration * 1000) -
                        timer.elapsedMilliseconds,
                  ),
                  // Main content area with gauge
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Hand label (above gauge during work)
                          if (!timer.currentRep.isRest)
                            HandLabel(
                              handSide: timer.currentRep.handSide,
                              gripPosition: timer.currentRep.gripPosition,
                            ),
                          // Workout circle with gauge
                          SizedBox(
                            width: gaugeSize,
                            height: gaugeSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Gauge(timer.currentRep.targetWeight),
                                AnimatedBuilder(
                                  animation: _serieController,
                                  builder: (ctx, child) => WorkoutCircle(
                                    value: _serieController.value,
                                    rest: timer.currentRep.isRest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Timer and status display
                          TrainingTimerDisplay(
                            secondsRemaining: timer.currentRepRemaining,
                            isRest: timer.currentRep.isRest,
                            fontSize: timerFontSize * 1.4,
                            isPrep: timer.currentRepIndex == 0,
                          ),
                          // Next rep preview (during rest)
                          if (timer.currentRep.isRest &&
                              timer.currentRepIndex <
                                  timer.repetitions.length - 1)
                            NextRepPreview(
                              nextRep:
                                  timer.repetitions[timer.currentRepIndex + 1],
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Progress info
                  // Adjust indices: preparation rep is at index 0, actual training starts at index 1
                  // So we subtract 1 to show the correct rep number relative to the actual training
                  TrainingProgressInfo(
                    currentRepIndex: timer.currentRepIndex > 0
                        ? timer.currentRepIndex - 1
                        : 0,
                    totalReps: widget.training.reps.length,
                    repeater: widget.training.repeater,
                  ),
                  const SizedBox(height: 8),
                  // Controls
                  TrainingControls(
                    isRunning: timer.isRunning,
                    onPlayPause: timer.isRunning ? _stop : _start,
                    onSkip: () {
                      _start();
                      timer.skipRep();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
