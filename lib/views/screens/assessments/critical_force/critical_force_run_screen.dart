import 'dart:async';

import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/logger.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/assessment_tutorials.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/database/builtins.dart';
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
import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/viewmodels/finished_run_draft_view_model.dart';
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
    // Only the first pull starts the clock once the lead-in is over, so a
    // dialog closed while the test waits for it must not.
    if (_waitingForFirstPull || _finished) return;
    _clockLog.started(clock.now(), timer.elapsedMilliseconds);
    timer.play();
  }

  /// Whether the lead-in is over and the test is waiting, armed, for the
  /// athlete to pull. The first reading over [criticalForceStartKg] starts
  /// pull 1, and from then on the clock never waits again.
  var _waitingForFirstPull = false;
  DateTime? _waitStartedAt;

  @visibleForTesting
  bool get waitingForFirstPull => _waitingForFirstPull;

  /// Stops the clock on the bell that would start pull 1, when a lead-in came
  /// before it.
  void _armFirstPull(TrainingExecutionItem? entering) {
    if (entering is! TimedItem || timer.currentItem is! RestItem) return;
    if (widget.reps
        .take(timer.currentItemIndex + 1)
        .any((i) => i is TimedItem)) {
      return;
    }
    _stopClock();
    _waitingForFirstPull = true;
    _waitStartedAt = clock.now();
  }

  /// Starts pull 1 on the first reading over the start force since the test
  /// began waiting. The pull is anchored on that reading, not on the tick that
  /// finds it, so none of it falls before the window.
  void _startOnFirstPull() {
    final waitStartedAt = _waitStartedAt;
    // A dialog over the run holds it, a pull under it included.
    if (!_waitingForFirstPull || waitStartedAt == null || _dialogOpen) return;
    final data = ref.read(bleDataStreamProvider.notifier).getData();
    BleDataPoint? first;
    for (var i = data.length - 1; i >= 0; i--) {
      final point = data[i];
      if (point.timestamp.isBefore(waitStartedAt)) break;
      if (point.value > criticalForceStartKg) first = point;
    }
    if (first == null) return;
    _waitingForFirstPull = false;
    final at = timer.elapsedMilliseconds;
    timer.startCurrentRep = at;
    _pullStartedAtMs = at;
    _clockLog.started(first.timestamp, at);
    // The run clock picks up from the reading, not from the tick that found
    // it, so the bells stay on the windows the readings are sorted into.
    final lag = clock.now().difference(first.timestamp).inMilliseconds;
    timer.skipAhead(lag < 0 ? 0 : lag);
    timer.play();
    setState(() {});
  }

  /// Whether a dialog is open over the run, which holds its clock.
  var _dialogOpen = false;

  void _pauseForDialog() {
    _dialogOpen = true;
    _stopClock();
  }

  void _resumeAfterDialog() {
    _dialogOpen = false;
    // A pull made under the dialog does not start the test.
    if (_waitingForFirstPull) _waitStartedAt = clock.now();
    _startClock();
  }

  /// Whether the run has been finished, on the last bell or by hand.
  var _finished = false;

  /// Whether enough pulls have run for the test to be finished by hand.
  bool get _canFinishEarly =>
      !_finished &&
      !_waitingForFirstPull &&
      _pullWindows.length >= criticalForceMinPullsToFinish &&
      _pullWindows.length < _totalPulls;

  /// Ends the test on the pulls already run. The one in progress is dropped.
  void _finishEarly() {
    if (!_canFinishEarly) return;
    _stopClock();
    timer.finished = true;
    _finish();
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
    onNextRep: (_) {
      _recordBell(timer.startCurrentRep, entering: timer.nextItem);
      _armFirstPull(timer.nextItem);
    },
    onTick: _startOnFirstPull,
    onFinished: () async {
      _recordBell(
        timer.startCurrentRep + timer.currentItemDuration * 1000,
        entering: null,
      );
      await _finish();
    },
  );

  /// Analyses the pulls run and moves on to the result.
  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
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
        _stepsRun(),
        // The protocol steps are hand agnostic; the assessed hand is the one
        // picked when starting the run.
        handSide: widget.hand,
      );
      // Kept on the device before the result is shown, so the app dying on
      // the result screen does not take the run with it. Krakoer/crimpy#146.
      final owner = await finishedRunOwner(
        ref.read(runDraftOwnerProvider.future),
      );
      final draft = CriticalForceResultDraft(
        // Only kept below when the owner is known; the result itself never
        // reads it.
        owner: owner ?? FinishedRunDraft.guestOwner,
        data: data,
        samples: samples,
        pullWindows: [
          for (final window in _pullWindows)
            (start: window.start / 1000, end: window.end / 1000),
        ],
        pausedSeconds: _pullWindows.isEmpty
            ? 0
            : _clockLog.pausedMsAfter(_pullWindows.first.start) ~/ 1000,
        previousCriticalForce: previousCriticalForce,
        saveAssessment: saveAssessment,
        saveSession: saveSession,
        saveReps: saveReps,
      );
      if (owner != null) {
        await keepFinishedRun(
          ref.read(finishedRunDraftRepositoryProvider),
          draft,
        );
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                CriticalForceResultScreen.fromDraft(draft, results: results),
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
  }

  /// The protocol's steps up to the last pull run, so a test finished by hand
  /// does not record the pulls it never reached.
  List<TrainingExecutionItem> _stepsRun() {
    var pulls = 0;
    for (final (index, step) in widget.reps.indexed) {
      if (step is TimedItem && ++pulls == _pullWindows.length) {
        return widget.reps.sublist(0, index + 1);
      }
    }
    return widget.reps;
  }

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
        setState(_pauseForDialog);
        final NavigatorState navigator = Navigator.of(context);
        final canFinish = _canFinishEarly;
        final pullsRun = _pullWindows.length;
        // Ask user if they want to leave assessment
        final choice = await showDialog<_LeaveChoice>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Leave the workout?'),
            content: Text(
              canFinish
                  ? 'If you leave this workout, you will lose your progress. '
                        'You can finish it on the $pullsRun pulls already run '
                        'instead.'
                  : 'If you leave this workout, you will lose your progress.',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_LeaveChoice.keepGoing),
                child: Text('Keep going'),
              ),
              if (canFinish)
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_LeaveChoice.finish),
                  child: Text('Finish'),
                ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_LeaveChoice.leave),
                style: CrimpyTheme.destructiveButton,
                child: Text('Leave'),
              ),
            ],
          ),
        );

        // If user chose to leave, leave the workout. Any other way out of the
        // dialog, a tap beside it included, keeps the run going, unless an
        // interruption has already discarded it.
        if (choice == _LeaveChoice.leave) {
          navigator.pop();
        } else if (mounted && !_interrupted) {
          _dialogOpen = false;
          if (choice == _LeaveChoice.finish) {
            _finishEarly();
          } else {
            setState(_resumeAfterDialog);
          }
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
                setState(_pauseForDialog);

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
                    setState(_resumeAfterDialog);
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
                      : _waitingForFirstPull
                      ? 'Pull to start'
                      : timer.currentItem is! RestItem
                      ? 'Pull!'
                      : 'Pulling in',
                  // The clock starts on the first pull, so there is nothing
                  // to count down while it waits for it.
                  secondsRemaining: _waitingForFirstPull
                      ? null
                      : timer.currentItemRemaining,
                ),
              ),
              // Show a minimalist graph in the background
              MinimalistGraph(),
              if (_canFinishEarly)
                Positioned(
                  bottom: CrimpyTheme.spaceXl,
                  child: OutlinedButton(
                    onPressed: _finishEarly,
                    child: Text('Finish with ${_pullWindows.length} pulls'),
                  ),
                ),
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

/// How the athlete answered the leave dialog.
enum _LeaveChoice { keepGoing, finish, leave }
