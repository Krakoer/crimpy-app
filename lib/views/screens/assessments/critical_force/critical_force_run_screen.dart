import 'dart:async';

import 'package:crimpy/logger.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/assessment_tutorials.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/assessments/critical_force/analysis.dart';
import 'package:crimpy/views/screens/assessments/critical_force/analysis_error_screen.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_result_screen.dart';
import 'package:crimpy/views/screens/assessments/critical_force/minimalist_graph.dart';
import 'package:crimpy/views/widgets/assessment_tutorial_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:crimpy/models/training_model.dart';
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

class _CriticalForceRunScreenState
    extends ConsumerState<CriticalForceRunScreen> {
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
                handSide: r.handSide,
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
                  "${timer.repCount}/24",
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
