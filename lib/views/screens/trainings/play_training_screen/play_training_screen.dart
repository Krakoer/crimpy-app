import 'package:crimpy/views/screens/trainings/play_training_screen/layouts/full_tank_layout.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_header.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/hand_label.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_timer_display.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/next_rep_preview.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_progress_info.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_controls.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/run_screen_style.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/viewmodels/run_screen_style_view_model.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/widgets/gauge.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
import 'package:crimpy/views/widgets/workout_circle.dart';
import 'package:crimpy/views/widgets/workout_lifecycle.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayTrainingScreen extends ConsumerStatefulWidget {
  final Training training;

  /// Whether to run with the force sensor (live gauge + data collection).
  final bool useSensor;

  /// Category the resulting session is logged under.
  final SessionType sessionType;

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
    this.sessionType = SessionType.crimpy,
    this.bodyweightKg,
    this.results = AssessmentResults.none,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlayTrainingScreenState();
}

class _PlayTrainingScreenState extends ConsumerState<PlayTrainingScreen>
    with TickerProviderStateMixin, WorkoutLifecycleMixin {
  // Controller that controls the circle around the gauge.
  late AnimationController _serieController;

  /// List of the average weights done during the training.
  List<RepDataModel> repResults = [];

  /// Duration of the preparation rest in seconds
  static const int _preparationDuration = 10;

  late final List<TrainingExecutionItem> _itemsWithPreparation = [
    const RestItem(durationSeconds: _preparationDuration),
    ...expandTrainingItems(
      widget.training,
      useSensor: widget.useSensor,
      bodyweightKg: widget.bodyweightKg,
      results: widget.results,
    ),
  ];

  /// Records the step that just finished. The preparation rest sits at index 0
  /// and is not part of the training, so it is skipped.
  void _recordFinishedItem() {
    if (timer.currentItemIndex == 0) return;
    final item = timer.currentItem;
    final timed = item is TimedItem ? item : null;
    repResults.add(
      RepDataModel(
        handSide: timed?.handSide ?? HandSide.both,
        targetWeight: timed?.targetLoad ?? 0,
        // Only collect a sensor average for gauge (sensor) steps.
        averageWeight: (timed?.collectSensorData ?? false)
            ? ref.read(bleSessionProvider).avg
            : 0,
        duration: item.durationSeconds,
        index: timer.currentItemIndex - 1,
        isRest: item is RestItem,
        gripPosition: timed?.gripPosition ?? GripPosition.halfCrimp,
      ),
    );
  }

  // Setup the workout timer
  late WorkoutTimer timer = WorkoutTimer(
    items: _itemsWithPreparation,
    // Audible 3-2-1 countdown + transition cue, useful when the phone is on
    // the ground during a hangboard session.
    playSound: true,
    // Set state each second to update the UI.
    onSecondChange: () => setState(() {}),
    onNextRep: (nextRepDuration) {
      _recordFinishedItem();

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
      _recordFinishedItem();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PostWorkoutScreen(
            template: widget.training,
            results: repResults,
            sessionType: widget.sessionType,
          ),
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    timer.init();
    _serieController = AnimationController(
      vsync: this,
      duration: Duration(seconds: timer.currentItem.durationSeconds),
    );
    WakelockPlus.enable();
  }

  void _start() {
    sensorRepository.resumeStreaming();
    setState(() {
      timer.play();
      _serieController.forward();
    });
  }

  /// Suspends the run. The sensor stream goes down with it: samples taken while
  /// paused belong to no rep, and counting them drags down the average force of
  /// the rep the pause interrupts.
  void _stop() {
    sensorRepository.pauseStreaming();
    setState(() {
      timer.stop();
      _serieController.stop();
    });
  }

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
    _serieController.dispose();
    super.dispose();
  }

  Widget _buildTimedContent(double gaugeSize, double timerFontSize) {
    final item = timer.currentItem;
    final rep = item is TimedItem ? item : null;
    final isPrep = timer.currentItemIndex == 0;
    final hasNext = timer.currentItemIndex < timer.items.length - 1;
    final nextRep = hasNext ? timer.items[timer.currentItemIndex + 1] : null;
    final sensor = rep?.collectSensorData ?? false;

    final timerDisplay = TrainingTimerDisplay(
      secondsRemaining: timer.currentItemRemaining,
      isRest: item is RestItem,
      fontSize: sensor ? timerFontSize * 1.4 : timerFontSize,
      isPrep: isPrep,
    );

    // Header above the circle (kind-specific), with the coach comment of the
    // running step right under the name it applies to.
    final Widget header = item is RestItem
        ? const SizedBox.shrink()
        : _headerBlock(
            title: sensor
                ? HandLabel(
                    handSide: rep!.handSide,
                    gripPosition: rep.gripPosition,
                    edgeSizeMm: rep.edgeSizeMm,
                  )
                : _stageHeader(
                    rep?.label,
                    rep?.targetLoad ?? 0,
                    gripPosition: rep != null && rep.isHang
                        ? rep.gripPosition
                        : null,
                    edgeSizeMm: rep?.edgeSizeMm,
                  ),
            comment: _commentOf(item),
          );

    // Content below the circle: preview the next step during a rest, or while
    // working when a rest is coming up next. During a rest the comment of the
    // upcoming step follows its name, so the athlete reads it before starting.
    final bool showNext =
        nextRep != null && (item is RestItem || nextRep is RestItem);
    final Widget below = sensor
        ? timerDisplay
        : showNext
        ? _nextUpBlock(nextRep, item is RestItem ? _commentOf(nextRep) : null)
        : const SizedBox.shrink();

    // Equal flexible regions above and below keep the circle vertically
    // centred at the same place regardless of step kind, and absorb any slack
    // so the column never overflows. Surrounding content scales down to fit.
    Widget slot(Widget child) => Expanded(
      child: Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      ),
    );

    return Column(
      children: [
        slot(header),
        SizedBox(
          width: gaugeSize,
          height: gaugeSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _serieController,
                builder: (ctx, child) => WorkoutCircle(
                  value: _serieController.value,
                  rest: item is RestItem,
                  size: gaugeSize,
                ),
              ),
              if (sensor)
                // The ring owns the outer edge of the box, so the gauge is
                // inset past its stroke instead of painting over it.
                Gauge(
                  rep!.targetLoad,
                  size: gaugeSize - 2 * WorkoutCircle.strokeWidth,
                  paused: !timer.isRunning,
                )
              else
                timerDisplay,
            ],
          ),
        ),
        slot(below),
      ],
    );
  }

  /// Set/rep/round context of the current step. During a rest the context of
  /// the step the rest leads into is shown, so the pill stays filled between
  /// reps. The look-ahead stops at the next working step to avoid borrowing a
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

  Widget _contextSlot() {
    final context = _currentContext();
    return SizedBox(
      height: 40,
      child: Center(
        child: context == null
            ? const SizedBox.shrink()
            : _subtitleText(context),
      ),
    );
  }

  Widget _subtitleText(String text) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: CrimpyTheme.primaryOrange.withValues(alpha: 0.12),
      border: Border.all(color: CrimpyTheme.primaryOrange, width: 1.5),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: CrimpyTheme.primaryOrange,
      ),
    ),
  );

  Widget _stageHeader(
    String? label,
    double targetWeight, {
    GripPosition? gripPosition,
    int? edgeSizeMm,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          (label ?? 'WORK').toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: CrimpyTheme.primaryOrange,
          ),
        ),
        if (gripPosition != null)
          Text(
            [
              gripPosition.displayName,
              if (edgeSizeMm != null) '${edgeSizeMm}mm',
            ].join(' - '),
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CrimpyTheme.gray400,
            ),
          ),
        if (targetWeight > 0)
          Text(
            'TARGET ${formatKilograms(targetWeight)} kg',
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CrimpyTheme.textMuted,
            ),
          ),
      ],
    );
  }

  /// Name of the running step and the coach comment that goes with it.
  Widget _headerBlock({required Widget title, String? comment}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        title,
        if (comment != null) ...[
          const SizedBox(height: 8),
          _commentText(comment),
        ],
      ],
    ),
  );

  /// Name of the upcoming step and the coach comment that goes with it.
  Widget _nextUpBlock(TrainingExecutionItem nextRep, String? comment) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      NextRepPreview(nextRep: nextRep),
      if (comment != null) ...[
        const SizedBox(height: 8),
        _commentText(comment),
      ],
    ],
  );

  /// Coach comment shown during the run. Width-constrained so a long
  /// instruction wraps instead of shrinking the whole block it belongs to.
  Widget _commentText(String text) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 320),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        height: 1.4,
        color: CrimpyTheme.textSecondary,
      ),
    ),
  );

  /// Total timed length of the run, preparation included. Self-paced steps
  /// count for nothing, which is what makes the time left unknown.
  late final int _totalTrainingSeconds = _itemsWithPreparation.fold(
    0,
    (sum, item) => sum + item.durationSeconds,
  );

  late final bool _isFullyTimed = !_itemsWithPreparation.any(
    (item) => item is ConfirmItem,
  );

  /// The design where the gauge is the whole screen. It owns the body outright
  /// rather than slotting into the ring layout, timer and controls included.
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
      comment: _commentOf(timer.currentItem),
      nextComment: _commentOf(nextItem),
      onPlayPause: timer.isRunning ? _stop : _start,
      onSkip: () {
        _start();
        timer.skipRep();
      },
      onConfirm: () {
        if (!timer.isRunning) _start();
        setState(() => timer.confirmRep());
      },
    );
  }

  Widget _buildConfirmContent(double timerFontSize) {
    final rep = timer.currentItem as ConfirmItem;
    final comment = _commentOf(rep);
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
            rep.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CrimpyTheme.textPrimary,
            ),
          ),
          if (comment != null) ...[
            const SizedBox(height: 8),
            _commentText(comment),
          ],
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
    // The stored design is read asynchronously. Committing to one before it
    // lands would show the wrong design for the first frames of a cold start,
    // and then swap it under the athlete as they are about to hang.
    final style = ref.watch(runScreenStyleProvider).value;
    final isFullTank = style == RunScreenStyle.fullTank;

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
      child: style == null
          ? const Scaffold(backgroundColor: CrimpyTheme.bgPrimary)
          : Scaffold(
              backgroundColor: CrimpyTheme.bgPrimary,
              // The full tank reaches the top of the screen. Leaving the workout
              // still runs through the confirmation on the system back gesture.
              appBar: isFullTank
                  ? null
                  : AppBar(
                      title: Text(widget.training.title),
                      centerTitle: true,
                    ),
              body: SafeArea(
                child: isFullTank
                    ? _buildFullTank()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate available height
                          final availableHeight = constraints.maxHeight;

                          // Space taken by the top header + context pill, the fixed
                          // header/below slots around the circle, the progress bar and the
                          // controls. Whatever is left is available to the gauge.
                          const chromeHeight = 320.0;
                          final gaugeSpace = availableHeight - chromeHeight;

                          // Calculate gauge size (max 300, but scale down if needed)
                          final gaugeSize = (gaugeSpace * 0.6).clamp(
                            200.0,
                            300.0,
                          );

                          // Scale timer text based on available space
                          final timerFontSize = (availableHeight * 0.06).clamp(
                            32.0,
                            48.0,
                          );

                          return Column(
                            children: [
                              // Header. The total time is only meaningful when every step
                              // is timed; self-paced (rep-based) steps make it unknown.
                              TrainingHeader(
                                elapsedMilliseconds: timer.elapsedMilliseconds,
                                remainingMilliseconds:
                                    _totalTrainingSeconds * 1000 -
                                    timer.elapsedMilliseconds,
                                showRemaining: _isFullyTimed,
                              ),
                              // Fixed context slot (set/rep/round), always at the same place
                              // and shown during rests via look-ahead to the next step.
                              _contextSlot(),
                              // Main content area
                              Expanded(
                                child: Center(
                                  child: timer.currentItem is ConfirmItem
                                      ? _buildConfirmContent(timerFontSize)
                                      : _buildTimedContent(
                                          gaugeSize,
                                          timerFontSize,
                                        ),
                                ),
                              ),
                              // Progress info
                              // Adjust indices: preparation rep is at index 0, actual training starts at index 1
                              // So we subtract 1 to show the correct rep number relative to the actual training
                              TrainingProgressInfo(
                                currentRepIndex: timer.currentItemIndex > 0
                                    ? timer.currentItemIndex - 1
                                    : 0,
                                totalReps: _itemsWithPreparation.length - 1,
                              ),
                              const SizedBox(height: 8),
                              // Controls
                              if (timer.currentItem is ConfirmItem)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
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
                                        backgroundColor:
                                            CrimpyTheme.primaryOrange,
                                        foregroundColor: CrimpyTheme.bgPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
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
