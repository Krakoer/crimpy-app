import 'dart:async';

import 'package:crimpy/logger.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/assessment_tutorials.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/utils/critical_force_analysis.dart';
import 'package:crimpy/views/screens/assessments/critical_force/analysis_error_screen.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_result_screen.dart';
import 'package:crimpy/views/screens/assessments/critical_force/minimalist_graph.dart';
import 'package:crimpy/views/widgets/assessment_tutorial_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/views/widgets/workout_lifecycle.dart';
import 'package:crimpy/views/widgets/workout_timer.dart';

class CriticalForceRunScreen extends ConsumerStatefulWidget {
  final List<RepModel> reps;
  final HandSide hand;
  const CriticalForceRunScreen({
    required this.reps,
    required this.hand,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CriticalForceRunScreenState();
}

class _CriticalForceRunScreenState extends ConsumerState<CriticalForceRunScreen>
    with WorkoutLifecycleMixin {
  int get _totalPulls => widget.reps.where((rep) => !rep.isRest).length;

  late WorkoutTimer timer = WorkoutTimer(
    repetitions: widget.reps,
    onSecondChange: () => setState(() => {}),
    onFinished: () async {
      final data = ref.read(bleDataStreamProvider.notifier).getData();
      // Create session model
      final saveSession = SessionModel(
        name:
            "Critical Force assessment - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
        isAssessment: true,
      );

      try {
        // Calculate critical force from the data
        final startTime = data[0].timestamp.millisecondsSinceEpoch;
        final timestamps = data
            .map((e) => (e.timestamp.millisecondsSinceEpoch - startTime) / 1000)
            .toList();
        final forces = data.map((e) => e.value).toList();
        final results = analyseData(timestamps, forces, 7, 3, start: 9.5);
        final criticalLoad = results.criticalLoad;
        // Get previous critical force value
        final previousCriticalForce = await ref
            .read(assessmentsProvider(AssessmentType.criticalForce).notifier)
            .getLastValueForHand(widget.hand);

        // Create assessment model
        final saveAssessment = AssessmentResultModel(
          type: AssessmentType.criticalForce,
          rightValue: widget.hand.isRightHand ? criticalLoad : null,
          leftValue: !widget.hand.isRightHand ? criticalLoad : null,
        );
        // Create rep models
        final saveReps = widget.reps
            .map(
              (r) => RepDataModel(
                averageWeight: 0,
                duration: r.durationInSeconds,
                index: r.index,
                isRest: r.isRest,
                // The protocol reps are hand agnostic; the assessed hand is the
                // one picked when starting the run.
                handSide: widget.hand,
                targetWeight: r.targetWeight,
              ),
            )
            .toList();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => CriticalForceResultScreen(
                data: data,
                results: results,
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
    timer.init();
    timer.play();
    super.initState();
  }

  @override
  void dispose() {
    timer.dispose();
    super.dispose();
  }

  // Critical Force is the asymptote of the force decline under continuous
  // pulling, so the fatigue curve is the measurement. Any extra rest lets the
  // forearm recover and inflates the result, and the analysis cannot detect it:
  // it models every interval as a fixed work + rest cycle and never looks at
  // the real gap between pulls. An interrupted run is therefore discarded.
  var _interrupted = false;

  @override
  void onLeftForeground() {
    if (timer.finished || _interrupted) return;
    _interrupted = true;
    timer.stop();
    ref.read(bleRepositoryProvider).pauseStreaming();
  }

  @override
  void onReturnedToForeground() async {
    if (!_interrupted) return;
    final navigator = Navigator.of(context);
    await showAssessmentInterruptedDialog(
      context,
      reason:
          'Critical Force measures how your pulling force declines without a '
          'break, so the test has to run start to finish in one go.',
    );
    // The run is over, but the sensor feed is shared: hand it back before
    // leaving or the rest of the app sees a frozen reading.
    ref.read(bleRepositoryProvider).resumeStreaming();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text("Critical Force Test"),
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
                  content: AssessmentTutorials.getCriticalForceTutorial(
                    widget.hand,
                    gripPosition,
                  ),
                  tutorialId: AssessmentTutorials.getCriticalForceTutorialId(
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
                                "Pulling in",
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
              // Show a minimalist graph in the background
              MinimalistGraph(),
              // Show the number of reps we're at
              Positioned(
                top: 10,
                child: Text(
                  "${timer.repCount}/$_totalPulls",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
