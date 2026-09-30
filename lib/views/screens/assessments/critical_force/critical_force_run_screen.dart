import 'dart:async';

import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/assessment_tutorials.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/utils/reps.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/utils/critical_force_analysis.dart';
import 'package:crimpy/utils/run_clock_log.dart';
import 'package:clock/clock.dart';
import 'package:crimpy/views/screens/assessments/assessment_cue_box.dart';
import 'package:crimpy/views/screens/assessments/assessment_run_phase.dart';
import 'package:crimpy/views/screens/assessments/critical_force/analysis_error_screen.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_result_screen.dart';
import 'package:crimpy/views/screens/assessments/critical_force/minimalist_graph.dart';
import 'package:crimpy/views/widgets/assessment_tutorial_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/views/widgets/workout_lifecycle.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';

class CriticalForceRunScreen extends ConsumerStatefulWidget {
  final List<TrainingExecutionItem> reps;
  final HandSide hand;

  /// The run's clock, which a test sets by hand.
  @visibleForTesting
  final CrimpyWatch? watch;

  const CriticalForceRunScreen({
    required this.reps,
    required this.hand,
    this.watch,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CriticalForceRunScreenState();
}

class _CriticalForceRunScreenState extends ConsumerState<CriticalForceRunScreen>
    with WorkoutLifecycleMixin {
  int get _totalPulls => widget.reps.whereType<TimedItem>().length;

  /// The pulls run so far, on the run's clock in milliseconds: from the bell
  /// that started each to the bell that ended it.
  final List<({int start, int end})> _pullWindows = [];
  int? _pullStartedAtMs;

  @visibleForTesting
  List<({int start, int end})> get pullWindows => _pullWindows;

  /// Places each reading on the run's clock. The clock stops while a dialog is
  /// open over the run, and what the sensor reads then belongs to no pull.
  final _clockLog = RunClockLog();

  void _startClock() {
    _clockLog.started(clock.now(), timer.elapsedMilliseconds);
    timer.play();
  }

  void _stopClock() {
    timer.stop();
    _clockLog.stopped(clock.now());
  }

  /// Records the bell at [atMs] on the run's clock, between the step the run
  /// leaves and the one it enters (null when the run ends).
  void _recordBell(int atMs, {required TrainingExecutionItem? entering}) {
    final startedAt = _pullStartedAtMs;
    if (timer.currentItem is TimedItem && startedAt != null) {
      _pullWindows.add((start: startedAt, end: atMs));
      _pullStartedAtMs = null;
    }
    if (entering is TimedItem) _pullStartedAtMs = atMs;
  }

  late WorkoutTimer timer = WorkoutTimer(
    items: widget.reps,
    watch: widget.watch,
    onSecondChange: () => setState(() => {}),
    // Called on each bell before the run moves on, when the timer already
    // holds the start of the step it enters.
    onNextRep: (_) =>
        _recordBell(timer.startCurrentRep, entering: timer.nextItem),
    onFinished: () async {
      _recordBell(
        timer.startCurrentRep + timer.currentItemDuration * 1000,
        entering: null,
      );
      final data = ref.read(bleDataStreamProvider.notifier).getData();
      // Create session model
      final saveSession = SessionModel(
        name:
            "Critical Force assessment - ${DateFormat('dd/MM/yyyy').format(currentTrainingDay())}",
        isAssessment: true,
        origin: SessionOrigin.played,
      );

      try {
        final samples = [
          for (final point in data)
            if (_clockLog.runClockAt(point.timestamp) case final atMs?)
              (t: atMs / 1000, kg: point.value),
        ];
        final results = analyseCriticalForce(samples, [
          for (final window in _pullWindows)
            (start: window.start / 1000, end: window.end / 1000),
        ]);
        final criticalLoad = results.criticalForce;
        // Get previous critical force value
        final previousCriticalForce = await ref
            .read(
              assessmentsProvider(BuiltinAssessmentIds.criticalForce).notifier,
            )
            .getLastValueForHand(widget.hand);

        // Create assessment model
        final saveAssessment = AssessmentResultModel(
          assessmentId: BuiltinAssessmentIds.criticalForce,
          rightValue: widget.hand.isRightHand ? criticalLoad : null,
          leftValue: !widget.hand.isRightHand ? criticalLoad : null,
        );
        // Create rep models
        final saveReps = buildRepsData(
          const [],
          widget.reps,
          // The protocol steps are hand agnostic; the assessed hand is the one
          // picked when starting the run.
          handSide: widget.hand,
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => CriticalForceResultScreen(
                data: data,
                samples: samples,
                results: results,
                pausedSeconds: _pullWindows.isEmpty
                    ? 0
                    : _clockLog.pausedMsAfter(_pullWindows.first.start) ~/ 1000,
                previousCriticalForce: previousCriticalForce,
                saveAssessment: saveAssessment,
                saveSession: saveSession,
                saveReps: saveReps,
              ),
            ),
          );
        }
      } catch (exception) {
        // On error, save the session data for debugging purposes. This is best
        // effort: a failed save must not hide the analysis error being reported.
        unawaited(
          ref
              .read(sessionsProvider.notifier)
              .saveSession(saveSession, [], data: data)
              .catchError((Object e) {
                AppLoggerHelper.error('Failed to save debug session: $e');
                return "";
              }),
        );
        // Show error screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AnalysisErrorScreen(
                errorMessage: exception.toString(),
                onDiscard: () => Navigator.of(context).pop(),
              ),
            ),
          );
        }
      }
    },
  );

  @override
  void initState() {
    super.initState();
    timer.init();
    if (timer.currentItem is TimedItem) _pullStartedAtMs = 0;
    _startClock();
  }

  @override
  void dispose() {
    timer.dispose();
    super.dispose();
  }

  // Critical Force is where the force settles under continuous pulling, so the
  // fatigue curve is the measurement. Any extra rest lets the forearm recover
  // and inflates the result, and the analysis cannot detect it: it only reads
  // the force inside each pull's window. An interrupted run is therefore
  // discarded.
  var _interrupted = false;

  @override
  void onLeftForeground() {
    if (timer.finished || _interrupted) return;
    _interrupted = true;
    _stopClock();
    sensorRepository.pauseStreaming();
  }

  @override
  Future<void> onReturnedToForeground() async {
    if (!_interrupted) return;
    await showAssessmentInterruptedDialog(
      context,
      reason:
          'Critical Force measures how your pulling force declines without a '
          'break, so the test has to run start to finish in one go.',
    );
    // A single pop would close whichever dialog the user had open over the run
    // and leave the discarded run on screen.
    popDownToRun();
    runNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final phase = assessmentStepPhase(
      steps: widget.reps,
      stepIndex: timer.currentItemIndex,
      sensorLost:
          ref.watch(connectionStateProvider) != BleConnectionState.connected,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (res, didPop) async {
        if (res) {
          return;
        }
        setState(_stopClock);
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
                onPressed: () => Navigator.of(context).pop(false),
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

        // If user chose to leave, leave the workout. Any other way out of the
        // dialog, a tap beside it included, keeps the run going, unless an
        // interruption has already discarded it.
        if (shouldPop ?? false) {
          navigator.pop();
        } else if (mounted && !_interrupted) {
          setState(_startClock);
        }
      },
      child: Scaffold(
        backgroundColor: phase == RunPhase.calm
            ? CrimpyTheme.phaseCalmGround
            : null,
        appBar: AppBar(
          title: Text("Critical Force Test"),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Pause timer while showing tutorial
                setState(_stopClock);

                // Get grip position from first non-rest rep
                final gripPosition = widget.reps
                    .whereType<TimedItem>()
                    .first
                    .gripPosition;

                // Show tutorial (forced, no "don't show again")
                showTutorialIfNeeded(
                  context: context,
                  content: AssessmentTutorials.getCriticalForceTutorial(
                    widget.hand,
                    gripPosition,
                  ),
                  tutorialId: AssessmentTutorials.getCriticalForceTutorialId(
                    gripPosition,
                  ),
                  forceShow: true,
                ).then((_) {
                  // An interruption discards the run, so closing the tutorial
                  // it was opened over must not put the clock back on.
                  if (mounted && !_interrupted) {
                    setState(_startClock);
                  }
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
              // Box of text to show the user the action to do (rest or pull).
              Positioned(
                top: 230,
                child: AssessmentCueBox(
                  phase: phase,
                  prompt: phase == RunPhase.alarm
                      ? 'No sensor'
                      : timer.currentItem is! RestItem
                      ? 'Pull!'
                      : 'Pulling in',
                  secondsRemaining: timer.currentItemRemaining,
                ),
              ),
              // Show a minimalist graph in the background
              MinimalistGraph(),
              // Show the number of reps we're at
              Positioned(
                top: 10,
                child: Text(
                  "${timer.repCount}/$_totalPulls",
                  style: CrimpyTheme.tabular(
                    CrimpyTheme.titleLarge,
                  ).copyWith(color: CrimpyTheme.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
