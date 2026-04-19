import 'dart:math';

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/assessment_tutorials.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/reps.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/assessments/post_assessment_screen.dart';
import 'package:crimpy/views/widgets/assessment_tutorial_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';
import 'package:intl/intl.dart';

class MvcRunScreen extends ConsumerStatefulWidget {
  final List<RepModel> reps;
  final AssessmentType type;
  const MvcRunScreen({required this.reps, super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MvcRunScreenState();
}

class _MvcRunScreenState extends ConsumerState<MvcRunScreen> {
  // Store max score for right hand
  double rightMax = -1;
  // Store max score for left hand
  double leftMax = -1;
  late WorkoutTimer timer = WorkoutTimer(
    repetitions: widget.reps,
    onNextRep: (_) {
      // When current rep was a workout rep
      if (!timer.currentRep.isRest) {
        // Store the result in the correct variable.
        if (timer.currentRep.handSide.isRightHand) {
          rightMax = ref.read(bleSessionProvider).max;
        } else {
          leftMax = ref.read(bleSessionProvider).max;
        }
      }
      // Reset session stats for next rep.
      ref.read(bleSessionProvider.notifier).reset();
    },
    onFinished: () async {
      // Add final rep (onNextRep is not called when finished)
      if (!timer.currentRep.isRest) {
        if (timer.currentRep.handSide.isRightHand) {
          rightMax = ref.read(bleSessionProvider).max;
        } else {
          leftMax = ref.read(bleSessionProvider).max;
        }
      }
      // Get previous values for printing results screen.
      // Not ideal, if it takes time the screen will just freeze.
      // TODO: Move this logic to PostAssessmentScreen and show progress indicator/error text accordingly.
      final gripPosition = widget.reps
          .firstWhere((r) => !r.isRest)
          .gripPosition;
      final prevValueRight = await ref
          .read(assessmentsProvider(widget.type).notifier)
          .getLastValueForHand(HandSide.right, gripPosition: gripPosition);
      final prevValueLeft = await ref
          .read(assessmentsProvider(widget.type).notifier)
          .getLastValueForHand(HandSide.left, gripPosition: gripPosition);

      if (mounted) {
        // Push result screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => PostAssessmentScreen(
              type: widget.type,
              rightHandResults: (prevValueRight, rightMax),
              leftHandResults: (prevValueLeft, leftMax),
              saveAssessment: AssessmentResultModel(
                type: widget.type,
                rightValue: rightMax,
                leftValue: leftMax,
                gripPosition: widget.reps
                    .firstWhere((r) => !r.isRest)
                    .gripPosition,
              ),
              saveTraining: SessionModel(
                name:
                    "MVC assessment (${widget.reps.firstWhere((r) => !r.isRest).gripPosition.shortName}) - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                isAssessment: true,
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
    timer.init();
    timer.play();
    super.initState();
  }

  @override
  void dispose() {
    timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Last BLE value to print on screen & compute the height of the colored box.
    final lastValue =
        ref.watch(bleDataStreamProvider.notifier).lastValue() ?? 0;
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
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        );

        // If user clicked on `Yes`, leave workout.
        if (shouldPop ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Max Force Test"),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Pause timer while showing tutorial
                setState(() {
                  timer.stop();
                });

                // Get grip position from first non-rest rep
                final gripPosition = widget.reps
                    .firstWhere((r) => !r.isRest)
                    .gripPosition;

                // Show tutorial (forced, no "don't show again")
                showTutorialIfNeeded(
                  context: context,
                  content: AssessmentTutorials.getMvcTutorial(gripPosition),
                  tutorialId: AssessmentTutorials.getMvcTutorialId(
                    gripPosition,
                  ),
                  forceShow: true,
                ).then((_) {
                  // Resume timer after tutorial is closed
                  if (mounted) {
                    setState(() {
                      timer.play();
                    });
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
              // Text to show current sensor value.
              Padding(
                padding: EdgeInsets.only(bottom: trueHeight * 0.75),
                child: Text(
                  "${lastValue.toStringAsFixed(2)} kg",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
                      color: timer.currentRep.isRest
                          ? Colors.transparent
                          : CrimpyTheme.accentYellow.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              // Box of text to show the user the action to do (rest or pull).
              Positioned(
                top: 230,
                child: Opacity(
                  opacity: 0.7,
                  child: Container(
                    width: 200,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CrimpyTheme.accentYellow,
                      border: Border.all(
                        color: CrimpyTheme.borderDefault,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CrimpyTheme.borderDefault,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: !timer.currentRep.isRest
                        ? Text(
                            "Pull!\n${timer.currentRepRemaining}",
                            style: TextStyle(
                              fontSize: 39,
                              color: CrimpyTheme.primaryWhite,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Column(
                            children: [
                              Text(
                                "Pulling with ${timer.currentRepIndex == 0 ? "right" : "left"} hand in",
                                style: TextStyle(
                                  fontSize: 29,
                                  color: CrimpyTheme.primaryWhite,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "${timer.currentRepRemaining}",
                                style: TextStyle(
                                  fontSize: 39,
                                  color: CrimpyTheme.primaryWhite,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              // If on an active rep, show the max bar with max value.
              if (!timer.currentRep.isRest)
                Padding(
                  padding: EdgeInsets.only(bottom: paddingMax),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "${bleSession.max.toStringAsFixed(2)} kg",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 27,
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
