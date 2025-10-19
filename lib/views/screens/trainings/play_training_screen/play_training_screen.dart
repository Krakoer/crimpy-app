import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_footer.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/widgets/training_time_header.dart';
import 'package:crimpy/views/screens/trainings/training_feedback_screen/training_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
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

  // Setup the workout timer
  late WorkoutTimer timer = WorkoutTimer(
    repetitions: widget.training.reps,
    // Set state each second to update the UI.
    onSecondChange: () => setState(() {}),
    onNextRep: (nextRepDuration) {
      repResults.add(
        RepDataModel(
          handSide: timer.currentRep.handSide,
          targetWeight: timer.currentRep.targetWeight,
          // Add avg if it was not a rest
          averageWeight:
              timer.currentRep.isRest ? 0 : ref.read(bleSessionProvider).avg,
          duration: timer.currentRep.durationInSeconds,
          index: timer.currentRep.index,
          isRest: timer.currentRep.isRest,
        ),
      );

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
      // Add the final average.
      repResults.add(
        RepDataModel(
          handSide: timer.currentRep.handSide,
          targetWeight: timer.currentRep.targetWeight,
          // Add avg if it was not a rest
          averageWeight:
              timer.currentRep.isRest ? 0 : ref.read(bleSessionProvider).avg,
          duration: timer.currentRep.durationInSeconds,
          index: timer.currentRep.index,
          isRest: timer.currentRep.isRest,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              // If the training can compute new weights, show feedback screen.
              // Otherwise show regular post-training screen.
              (context) =>
                  widget.training.computeNewWeights == null
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
          builder:
              (context) => AlertDialog(
                title: Text('Leave the workout?'),
                content: Text(
                  'If you leave this workout, you will lose your progress.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Yes'),
                  ),
                ],
              ),
        );

        if (shouldPop ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pause/Play button
            IconButton(
              onPressed: timer.isRunning ? _stop : _start,
              color: CrimpyTheme.primaryBlack,
              iconSize: 40,
              icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
            ),
            // Skip rep button
            IconButton(
              onPressed: () {
                _start();
                timer.skipRep();
              },
              color: CrimpyTheme.primaryBlack,
              iconSize: 40,
              icon: Icon(Icons.skip_next),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header that displays global elapsed and remaining time.
            TrainingTimeHeader(
              elapsedMilliseconds: timer.elapsedMilliseconds,
              timeLeftMilliseconds:
                  widget.training.totalDuration.inMilliseconds -
                  timer.elapsedMilliseconds,
            ),
            // Workout circle with gauge
            Container(
              padding: EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Gauge(timer.currentRep.targetWeight),
                  AnimatedBuilder(
                    animation: _serieController,
                    builder:
                        (ctx, child) => WorkoutCircle(
                          value: _serieController.value,
                          rest: timer.currentRep.isRest,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Footer below the gauge
            TrainingFooter(
              currentRepIndex: timer.currentRepIndex + 1,
              numberReps: timer.repetitions.length,
              timeLeftMilliseconds:
                  widget.training.totalDuration.inMilliseconds -
                  timer.elapsedMilliseconds,
            ),
            SizedBox(height: 20),
            // Time remaining for current rep
            Text(
              "${(timer.currentRepRemaining / 60).floor().toString().padLeft(2, '0')}:${(timer.currentRepRemaining % 60).toString().padLeft(2, '0')}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 54),
            ),
          ],
        ),
      ),
    );
  }
}
