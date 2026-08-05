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

  /// Play a given training.
  const PlayTrainingScreen(
    this.training, {
    this.useSensor = true,
    this.sessionType = SessionType.crimpy,
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
    ...expandTrainingItems(widget.training, useSensor: widget.useSensor),
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
    timer.init();
    _serieController = AnimationController(
      vsync: this,
      duration: Duration(seconds: timer.currentItem.durationSeconds),
    );
    WakelockPlus.enable();
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

  /// Whether the background took the workout down, as opposed to the user
  /// pausing it themselves. Only the former resumes on its own.
  var _pausedByBackground = false;

  @override
  void onLeftForeground() {
    if (timer.finished || !timer.isRunning) return;
    _pausedByBackground = true;
    _stop();
    ref.read(bleRepositoryProvider).pauseStreaming();
  }

  @override
  void onReturnedToForeground() async {
    if (!_pausedByBackground) return;
    _pausedByBackground = false;
    await showWorkoutPausedDialog(context);
    if (!mounted) return;
    ref.read(bleRepositoryProvider).resumeStreaming();
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

    // Header above the circle (kind-specific).
    final Widget header = sensor
        ? HandLabel(handSide: rep!.handSide, gripPosition: rep.gripPosition)
        : item is RestItem
        ? const SizedBox.shrink()
        : _stageHeader(rep?.label, rep?.targetLoad ?? 0);

    // Content below the circle: preview the next step during a rest, or while
    // working when a rest is coming up next.
    final bool showNext =
        nextRep != null && (item is RestItem || nextRep is RestItem);
    final bool hasComment = rep?.comment?.trim().isNotEmpty ?? false;
    final Widget below = sensor
        ? timerDisplay
        : showNext
        ? NextRepPreview(nextRep: nextRep)
        : (item is! RestItem && hasComment)
        ? _commentBox(rep!.comment!)
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
                Gauge(rep!.targetLoad, size: gaugeSize)
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

  Widget _stageHeader(String? label, double targetWeight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
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
          if (targetWeight > 0)
            Text(
              'TARGET ${targetWeight.toStringAsFixed(targetWeight.truncateToDouble() == targetWeight ? 0 : 1)} kg',
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: CrimpyTheme.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  /// Coach comment shown during a step. Width-constrained and scrollable so a
  /// long comment wraps and stays readable instead of overflowing.
  Widget _commentBox(String text) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 360, maxHeight: 160),
    child: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: CrimpyTheme.primaryOrange.withValues(alpha: 0.10),
          border: Border.all(
            color: CrimpyTheme.primaryOrange.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
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
      ),
    ),
  );

  Widget _buildConfirmContent(double timerFontSize) {
    final rep = timer.currentItem as ConfirmItem;
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
          if (rep.comment?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            _commentBox(rep.comment!),
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

              // Space taken by the top header + context pill, the fixed
              // header/below slots around the circle, the progress bar and the
              // controls. Whatever is left is available to the gauge.
              const chromeHeight = 320.0;
              final gaugeSpace = availableHeight - chromeHeight;

              // Calculate gauge size (max 300, but scale down if needed)
              final gaugeSize = (gaugeSpace * 0.6).clamp(200.0, 300.0);

              // Scale timer text based on available space
              final timerFontSize = (availableHeight * 0.06).clamp(32.0, 48.0);

              final totalTrainingSeconds = _itemsWithPreparation.fold(
                0,
                (s, r) => s + r.durationSeconds,
              );

              return Column(
                children: [
                  // Header. The total time is only meaningful when every step
                  // is timed; self-paced (rep-based) steps make it unknown.
                  TrainingHeader(
                    elapsedMilliseconds: timer.elapsedMilliseconds,
                    remainingMilliseconds:
                        totalTrainingSeconds * 1000 - timer.elapsedMilliseconds,
                    showRemaining: !_itemsWithPreparation.any(
                      (r) => r is ConfirmItem,
                    ),
                  ),
                  // Fixed context slot (set/rep/round), always at the same place
                  // and shown during rests via look-ahead to the next step.
                  _contextSlot(),
                  // Main content area
                  Expanded(
                    child: Center(
                      child: timer.currentItem is ConfirmItem
                          ? _buildConfirmContent(timerFontSize)
                          : _buildTimedContent(gaugeSize, timerFontSize),
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
