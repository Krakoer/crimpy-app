import 'package:crimpy/views/screens/trainings/play_training_screen/layouts/full_tank_layout.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/open_reps_dialog.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/utils/video_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
import 'package:crimpy/views/widgets/workout_lifecycle.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayTrainingScreen extends ConsumerStatefulWidget {
  final Training training;

  /// Whether to run with the force sensor (live gauge + data collection).
  final bool useSensor;

  /// Category the resulting session is logged under.
  final SessionActivity activity;

  /// What the run was started from, carried onto the session so it can later be
  /// shown against what was prescribed and read block by block. The training is
  /// set for any run started from one, the athlete's own included; the program
  /// session only inside a program. Both null for a builtin, which is generated
  /// on the fly and has no row to link to.
  final String? trainingId;
  final String? programSessionId;

  /// Body weight the loads set in percent of it are computed from. Those loads
  /// have no target when it is unknown.
  final double? bodyweightKg;

  /// Resolves the loads, durations and reps the coach set as a percentage of an
  /// assessment. Without it they all run at their fallback.
  final AssessmentResults results;

  /// Play a given training.
  const PlayTrainingScreen(
    this.training, {
    this.useSensor = true,
    this.activity = SessionActivity.hangboard,
    this.trainingId,
    this.programSessionId,
    this.bodyweightKg,
    this.results = AssessmentResults.none,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlayTrainingScreenState();
}

class _PlayTrainingScreenState extends ConsumerState<PlayTrainingScreen>
    with WorkoutLifecycleMixin {
  /// List of the average weights done during the training.
  List<RepDataModel> repResults = [];

  /// What the run recorded against the prescribed items as it was played: the
  /// reps an AMRAP turned out to be, and the rounds of an emom the athlete
  /// dropped out of. No rep carries either, and the post workout screen adds
  /// the loads, the durations and the notes to them.
  final List<SessionItemResultModel> itemResults = [];

  /// Duration of the preparation rest in seconds
  static const int _preparationDuration = 10;

  late final List<TrainingExecutionItem> _itemsWithPreparation = [
    const RestItem(durationSeconds: _preparationDuration),
    ...expandTrainingItems(
      widget.training,
      useSensor: widget.useSensor,
      bodyweightKg: widget.bodyweightKg,
      // Merged here rather than trusted from the caller, so a run always reads
      // the training against the definitions it carries. They name an
      // assessment the athlete has no result for, and a caller that rebuilds
      // the results between the screen and the run would otherwise drop them.
      results: widget.results.withDefinitions(
        widget.training.referencedAssessments,
      ),
    ),
  ];

  /// Records the step that just finished. The preparation rest sits at index 0
  /// and is not part of the training, so it is skipped.
  void _recordFinishedItem() {
    if (timer.currentItemIndex == 0) return;
    final item = timer.currentItem;
    final timed = item is TimedItem ? item : null;
    // Stats of the step that just ran: the session is reset at every step
    // boundary, so no sample means the sensor answered nothing while this one
    // was running, whatever the run started with.
    //
    // A single sample is enough to count as measured, deliberately. Partial
    // coverage cannot be read as a lost sensor: a hang the athlete let go of
    // halfway leaves exactly the same short run of samples, and that one is a
    // real miss the coach has to see. Dropping it would hide a failed rep,
    // which is worse than grading a half measured one.
    final sensorStats = ref.read(bleSessionProvider);
    final sensorDelivered = sensorStats.nbPoints > 0;
    repResults.add(
      RepDataModel(
        handSide: timed?.handSide ?? HandSide.both,
        targetWeight:
            timed?.recordedTargetLoad(sensorDelivered: sensorDelivered) ?? 0,
        // A target the step prescribed and the run never measured is not a
        // miss, so the rep says so rather than being graded on the zero above.
        targetUnmeasured:
            timed?.targetUnmeasured(sensorDelivered: sensorDelivered) ?? false,
        // Only a step the sensor measured carries an average, and it is the
        // same condition that decides whether the target above is recorded.
        averageWeight:
            (timed?.measured(sensorDelivered: sensorDelivered) ?? false)
            ? sensorStats.avg
            : 0,
        duration: item.durationSeconds,
        index: timer.currentItemIndex - 1,
        isRest: item is RestItem,
        gripPosition: timed?.gripPosition ?? GripPosition.halfCrimp,
        edgeSizeMm: timed?.edgeSizeMm,
        trainingItemId: item.trainingItemId,
      ),
    );
  }

  // Setup the workout timer
  late WorkoutTimer timer = WorkoutTimer(
    items: _itemsWithPreparation,
    // Audible 2-1 countdown + transition cue, useful when the phone is on
    // the ground during a hangboard session.
    playSound: true,
    // Set state each second to update the UI.
    onSecondChange: () => setState(() {}),
    onNextRep: (_) {
      _recordFinishedItem();

      // Reset the session for average computation.
      ref.read(bleSessionProvider.notifier).reset();
      setState(() {});
    },
    onFinished: () async {
      _recordFinishedItem();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PostWorkoutScreen(
            template: widget.training,
            results: repResults,
            itemResults: itemResults,
            // The same results the run resolved its prescription against, so
            // the review states the numbers the athlete was actually played.
            assessmentResults: widget.results.withDefinitions(
              widget.training.referencedAssessments,
            ),
            bodyweightKg: widget.bodyweightKg,
            activity: widget.activity,
            trainingId: widget.trainingId,
            programSessionId: widget.programSessionId,
          ),
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    timer.init();
    WakelockPlus.enable();
  }

  void _start() {
    sensorRepository.resumeStreaming();
    setState(timer.play);
  }

  /// Suspends the run. The sensor stream goes down with it: samples taken while
  /// paused belong to no rep, and counting them drags down the average force of
  /// the rep the pause interrupts.
  void _stop() {
    sensorRepository.pauseStreaming();
    setState(timer.stop);
  }

  /// Finishes the self-paced step the run is on. An AMRAP prescribes no rep
  /// count, so it asks for the one the athlete reached before moving on, and
  /// stays put when they back out of answering.
  Future<void> _confirmStep() async {
    final step = timer.currentItem;
    if (step is ConfirmItem && step.repsAreOpen) {
      final done = await showOpenRepsDialog(context, step.label);
      if (done == null || !mounted) return;
      _recordItemResult(step, reps: done);
    }
    if (!timer.isRunning) _start();
    setState(() => timer.confirmRep());
  }

  /// Ends the emom the run is inside, recording the rounds the athlete carried
  /// through before dropping out. The rounds still queued are not played: the
  /// block stops where they stopped.
  Future<void> _dropOutOfEmom() async {
    final step = timer.currentItem;
    final emom = step.emom;
    if (emom == null) return;
    final wasRunning = timer.isRunning;
    if (wasRunning) _stop();
    final confirmed = await confirmEmomDropOut(context, emom.round);
    if (!mounted) return;
    if (!confirmed) {
      if (wasRunning) _start();
      return;
    }
    if (emom.itemId != null) {
      itemResults.add(
        SessionItemResultModel(
          trainingItemId: emom.itemId!,
          occurrence: emom.occurrence,
          cycles: emom.round,
        ),
      );
    }
    timer.dropRemainingBlock(emom.blockKey);
    _start();
    setState(timer.skipRep);
  }

  void _recordItemResult(TrainingExecutionItem step, {int? reps, int? cycles}) {
    final itemId = step.trainingItemId;
    if (itemId == null) return;
    itemResults.add(
      SessionItemResultModel(
        trainingItemId: itemId,
        occurrence: step.occurrence,
        reps: reps,
        cycles: cycles,
      ),
    );
  }

  /// Whether the step the run is on can be dropped out of, which is a working
  /// step of an emom. A rest is the block running itself out, so there is
  /// nothing to fail during one.
  bool get _canDropOutOfEmom =>
      timer.currentItem.emom != null && timer.currentItem is! RestItem;

  /// Whether the background took the workout down, as opposed to the user
  /// pausing it themselves. Only the former resumes on its own.
  var _pausedByBackground = false;

  @override
  void onLeftForeground() {
    if (timer.finished || !timer.isRunning) return;
    _pausedByBackground = true;
    _stop();
  }

  @override
  Future<void> onReturnedToForeground() async {
    if (!_pausedByBackground) return;
    _pausedByBackground = false;
    await showWorkoutPausedDialog(context);
    if (!mounted) return;
    _start();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    timer.dispose();
    super.dispose();
  }

  /// Set/rep/round context of the current step. During a rest the context of
  /// the step the rest leads into is shown, so the set and rep card stays
  /// filled between reps. The look-ahead stops at the next working step to avoid borrowing a
  /// label from an unrelated block later in the training.
  String? _currentContext() {
    for (var i = timer.currentItemIndex; i < timer.items.length; i++) {
      final item = timer.items[i];
      final subtitle = switch (item) {
        TimedItem() => item.subtitle,
        ConfirmItem() => item.subtitle,
        RestItem() => null,
      };
      if (subtitle != null) return subtitle;
      if (item is! RestItem) return null;
    }
    return null;
  }

  /// Coach comment attached to a step, if it carries one. A rest is not a step
  /// a coach comments on, so it never has one of its own.
  String? _commentOf(TrainingExecutionItem? item) {
    final comment = switch (item) {
      TimedItem() => item.comment,
      ConfirmItem() => item.comment,
      _ => null,
    };
    final trimmed = comment?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  /// What the block the step came from is for, if it names one. A rest is not
  /// part of a block the coach gave a reason, so it never has one of its own.
  String? _goalOf(TrainingExecutionItem? item) {
    final goal = switch (item) {
      TimedItem() => item.goal,
      ConfirmItem() => item.goal,
      _ => null,
    };
    final trimmed = goal?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  /// The rule the step is resolved by, if the block it came from names one. A
  /// rest is not a step a coach writes a rule for, so it never has one of its
  /// own.
  String? _protocolOf(TrainingExecutionItem? item) {
    final protocol = switch (item) {
      TimedItem() => item.protocol,
      ConfirmItem() => item.protocol,
      _ => null,
    };
    final trimmed = protocol?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Demo video attached to a step, if the exercise it came from carries a
  /// usable one. A rest has no exercise behind it, so it never has one.
  String? _videoOf(TrainingExecutionItem? item) {
    final link = switch (item) {
      TimedItem() => item.videoLink,
      ConfirmItem() => item.videoLink,
      _ => null,
    };
    return isPlayableVideoLink(link) ? link : null;
  }

  /// Total timed length of the run, preparation included. Self-paced steps
  /// count for nothing, which is what makes the time left unknown. Read off the
  /// queue rather than fixed once, since dropping out of an emom takes the
  /// rounds that will not be played out of it.
  int get _totalTrainingSeconds =>
      _itemsWithPreparation.fold(0, (sum, item) => sum + item.durationSeconds);

  bool get _isFullyTimed =>
      !_itemsWithPreparation.any((item) => item is ConfirmItem);

  /// The gauge is the whole screen, timer and controls included.
  Widget _buildFullTank() {
    final index = timer.currentItemIndex;
    final hasNext = index < timer.items.length - 1;
    final nextItem = hasNext ? timer.items[index + 1] : null;

    return FullTankLayout(
      item: timer.currentItem,
      nextItem: nextItem,
      secondsRemaining: timer.currentItemRemaining,
      elapsedMilliseconds: timer.elapsedMilliseconds,
      remainingMilliseconds:
          _totalTrainingSeconds * 1000 - timer.elapsedMilliseconds,
      showRemaining: _isFullyTimed,
      isPreparation: index == 0,
      isRunning: timer.isRunning,
      repContext: _currentContext(),
      goal: _goalOf(timer.currentItem),
      nextGoal: _goalOf(nextItem),
      comment: _commentOf(timer.currentItem),
      nextComment: _commentOf(nextItem),
      protocol: _protocolOf(timer.currentItem),
      nextProtocol: _protocolOf(nextItem),
      videoLink: _videoOf(timer.currentItem),
      nextVideoLink: _videoOf(nextItem),
      onPlayPause: timer.isRunning ? _stop : _start,
      onSkip: () {
        _start();
        timer.skipRep();
      },
      onConfirm: _confirmStep,
      showDropOut: _canDropOutOfEmom,
      onDropOut: _dropOutOfEmom,
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
        final wasRunning = timer.isRunning;
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
          return;
        }
        // Staying puts the run back as it was. A self paced step offers no play
        // control, so a run left stopped on one has nothing to resume with
        // short of declaring the step done.
        if (wasRunning && mounted) _start();
      },
      child: Scaffold(
        backgroundColor: CrimpyTheme.bgPrimary,
        // The tank reaches the top of the screen. Leaving the workout still
        // runs through the confirmation on the system back gesture.
        body: SafeArea(child: _buildFullTank()),
      ),
    );
  }
}
