import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_header.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/hand_label.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_timer_display.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/next_rep_preview.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_progress_info.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_controls.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/utils/training_expander.dart';
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
  final Training training;

  /// Whether to run with the force sensor (live gauge + data collection).
  final bool useSensor;

  /// Play a given training.
  const PlayTrainingScreen(this.training, {this.useSensor = true, super.key});

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

  late final List<RepModel> _repsWithPreparation = _buildReps();

  List<RepModel> _buildReps() {
    return [
      RepModel(
        durationInSeconds: _preparationDuration,
        isRest: true,
        handSide: HandSide.both,
        targetWeight: 0.0,
        index: -1,
        gripPosition: GripPosition.halfCrimp,
      ),
      ..._executionToRepModels(
        expandTrainingItems(widget.training, useSensor: widget.useSensor),
      ),
    ];
  }

  static List<RepModel> _executionToRepModels(
    List<TrainingExecutionItem> items,
  ) {
    final result = <RepModel>[];
    int idx = 0;
    for (final item in items) {
      switch (item) {
        case TimedItem():
          result.add(
            RepModel(
              durationInSeconds: item.durationSeconds,
              isRest: false,
              handSide: item.handSide,
              targetWeight: item.targetLoad,
              index: idx++,
              gripPosition: item.gripPosition,
              showGauge: item.collectSensorData,
              label: item.label,
            ),
          );
        case RestItem():
          result.add(
            RepModel(
              durationInSeconds: item.durationSeconds,
              isRest: true,
              handSide: HandSide.both,
              targetWeight: 0,
              index: idx++,
            ),
          );
        case ConfirmItem():
          result.add(
            RepModel(
              durationInSeconds: 0,
              isRest: false,
              isConfirm: true,
              handSide: HandSide.both,
              targetWeight: 0,
              index: idx++,
              label: item.label,
              reps: item.reps,
              load: item.load,
            ),
          );
      }
    }
    return result;
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
            // Only collect a sensor average for gauge (sensor) steps.
            averageWeight: timer.currentRep.showGauge
                ? ref.read(bleSessionProvider).avg
                : 0,
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
            // Only collect a sensor average for gauge (sensor) steps.
            averageWeight: timer.currentRep.showGauge
                ? ref.read(bleSessionProvider).avg
                : 0,
            duration: timer.currentRep.durationInSeconds,
            index: timer.currentRep.index,
            isRest: timer.currentRep.isRest,
            gripPosition: timer.currentRep.gripPosition,
          ),
        );
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PostWorkoutScreen(template: widget.training, results: repResults),
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

  Widget _buildTimedContent(double gaugeSize, double timerFontSize) {
    final rep = timer.currentRep;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label above the gauge during work.
        if (!rep.isRest)
          rep.showGauge
              ? HandLabel(
                  handSide: rep.handSide,
                  gripPosition: rep.gripPosition,
                )
              : Text(
                  (rep.label ?? 'WORK').toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
        SizedBox(
          width: gaugeSize,
          height: gaugeSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (rep.showGauge) Gauge(rep.targetWeight),
              AnimatedBuilder(
                animation: _serieController,
                builder: (ctx, child) => WorkoutCircle(
                  value: _serieController.value,
                  rest: rep.isRest,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        TrainingTimerDisplay(
          secondsRemaining: timer.currentRepRemaining,
          isRest: rep.isRest,
          fontSize: timerFontSize * 1.4,
          isPrep: timer.currentRepIndex == 0,
        ),
        if (rep.isRest && timer.currentRepIndex < timer.repetitions.length - 1)
          NextRepPreview(nextRep: timer.repetitions[timer.currentRepIndex + 1]),
      ],
    );
  }

  Widget _buildConfirmContent(double timerFontSize) {
    final rep = timer.currentRep;
    final details = [
      if (rep.reps != null) '${rep.reps} reps',
      if (rep.load != null) rep.load!,
    ].join('  -  ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (rep.label ?? 'Exercise').toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CrimpyTheme.textPrimary,
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: timerFontSize,
                fontWeight: FontWeight.w800,
                color: CrimpyTheme.primaryOrange,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Tap DONE when finished',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              color: CrimpyTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
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
        appBar: AppBar(title: Text(widget.training.title), centerTitle: true),
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

              final totalTrainingSeconds = _repsWithPreparation.fold(
                0,
                (s, r) => s + r.durationInSeconds,
              );

              return Column(
                children: [
                  // Header. The total time is only meaningful when every step
                  // is timed; self-paced (rep-based) steps make it unknown.
                  TrainingHeader(
                    elapsedMilliseconds: timer.elapsedMilliseconds,
                    remainingMilliseconds:
                        totalTrainingSeconds * 1000 - timer.elapsedMilliseconds,
                    showRemaining: !_repsWithPreparation.any(
                      (r) => r.isConfirm,
                    ),
                  ),
                  // Main content area
                  Expanded(
                    child: Center(
                      child: timer.currentRep.isConfirm
                          ? _buildConfirmContent(timerFontSize)
                          : _buildTimedContent(gaugeSize, timerFontSize),
                    ),
                  ),
                  // Progress info
                  // Adjust indices: preparation rep is at index 0, actual training starts at index 1
                  // So we subtract 1 to show the correct rep number relative to the actual training
                  TrainingProgressInfo(
                    currentRepIndex: timer.currentRepIndex > 0
                        ? timer.currentRepIndex - 1
                        : 0,
                    totalReps: _repsWithPreparation.length - 1,
                  ),
                  const SizedBox(height: 8),
                  // Controls
                  if (timer.currentRep.isConfirm)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!timer.isRunning) _start();
                            setState(() => timer.confirmRep());
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('DONE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CrimpyTheme.primaryOrange,
                            foregroundColor: CrimpyTheme.bgPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    )
                  else
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
