import 'dart:async';
import 'dart:math';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/assessment_tutorials.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/views/screens/assessments/post_assessment_screen.dart';
import 'package:crimpy/views/widgets/assessment_tutorial_dialog.dart';
import 'package:crimpy/views/widgets/workout_lifecycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:crimpy/models/ble_data_model.dart';

class Endurance60RunScreen extends ConsumerStatefulWidget {
  final HandSide hand;
  final double mvcValue;
  final GripPosition gripPosition;

  const Endurance60RunScreen({
    required this.hand,
    required this.mvcValue,
    required this.gripPosition,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Endurance60RunScreenState();
}

class _Endurance60RunScreenState extends ConsumerState<Endurance60RunScreen>
    with WorkoutLifecycleMixin {
  // Assessment state
  bool _isInTargetZone = false;
  DateTime? _targetZoneEntryTime;
  DateTime? _outOfZoneTime;
  bool _assessmentStarted = false;
  bool _assessmentEnded = false;

  // Stopwatch for elapsed time
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // Computed values
  late double _targetForce;
  late double _minForce;
  late double _maxForce;

  @override
  void initState() {
    super.initState();
    _targetForce = widget.mvcValue * 0.6;
    _minForce = _targetForce - (widget.mvcValue * 0.05); // 60% - 5%
    _maxForce = _targetForce + (widget.mvcValue * 0.05); // 60% + 5%

    // Start a timer to update UI every 100ms
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {});
        _checkAssessmentState();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  // The measurement is time to failure holding 60% of MVC, so a break in the
  // hold ends the attempt. There is nothing to resume: the run is discarded.
  var _interrupted = false;

  @override
  void onLeftForeground() {
    if (_assessmentEnded || _interrupted) return;
    _interrupted = true;
    _timer?.cancel();
    _stopwatch.stop();
    ref.read(bleRepositoryProvider).pauseStreaming();
  }

  @override
  void onReturnedToForeground() async {
    if (!_interrupted) return;
    final navigator = Navigator.of(context);
    await showAssessmentInterruptedDialog(
      context,
      reason:
          'The 60% Endurance test measures how long you can hold the target '
          'force without letting go, so it cannot be paused and resumed.',
    );
    // The run is over, but the sensor feed is shared: hand it back before
    // leaving or the rest of the app sees a frozen reading.
    ref.read(bleRepositoryProvider).resumeStreaming();
    navigator.pop();
  }

  void _checkAssessmentState() {
    final lastValue = ref.read(bleDataStreamProvider.notifier).lastValue() ?? 0;
    final now = DateTime.now();
    final isInZone = lastValue >= _minForce && lastValue <= _maxForce;

    if (isInZone && !_isInTargetZone) {
      // Entered target zone
      _isInTargetZone = true;
      _targetZoneEntryTime = now;
      _outOfZoneTime = null;
    } else if (!isInZone && _isInTargetZone) {
      // Left target zone
      _isInTargetZone = false;
      _targetZoneEntryTime = null;
      _outOfZoneTime = now;
    } else if (!isInZone &&
        _outOfZoneTime != null &&
        _assessmentStarted &&
        !_assessmentEnded) {
      // Still out of zone — check if out for more than 1s to end
      final duration = now.difference(_outOfZoneTime!);
      if (duration.inMilliseconds >= 1000) {
        _endAssessment();
      }
    } else if (isInZone &&
        _targetZoneEntryTime != null &&
        !_assessmentStarted) {
      // In zone — check if in for more than 1s to start
      final duration = now.difference(_targetZoneEntryTime!);
      if (duration.inMilliseconds >= 1000) {
        _startAssessment();
      }
    }
  }

  void _startAssessment() {
    setState(() {
      _assessmentStarted = true;
      _stopwatch.start();
    });
  }

  void _endAssessment() async {
    if (_assessmentEnded) return;

    setState(() {
      _assessmentEnded = true;
      _stopwatch.stop();
    });

    // Calculate duration in seconds
    final durationSeconds = _stopwatch.elapsed.inMilliseconds / 1000;

    // Get previous value
    final previousValue = await ref
        .read(assessmentsProvider(AssessmentType.endurance60).notifier)
        .getLastValueForHand(widget.hand, gripPosition: widget.gripPosition);

    // Create assessment result
    final saveAssessment = AssessmentResultModel(
      type: AssessmentType.endurance60,
      rightValue: widget.hand.isRightHand ? durationSeconds : null,
      leftValue: !widget.hand.isRightHand ? durationSeconds : null,
      gripPosition: widget.gripPosition,
    );

    // Create session model
    final saveSession = SessionModel(
      name:
          "60% Endurance assessment - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
      isAssessment: true,
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => PostAssessmentScreen(
            type: AssessmentType.endurance60,
            rightHandResults: widget.hand.isRightHand
                ? (previousValue, durationSeconds)
                : null,
            leftHandResults: !widget.hand.isRightHand
                ? (previousValue, durationSeconds)
                : null,
            saveAssessment: saveAssessment,
            saveTraining: saveSession,
            saveReps: [],
          ),
        ),
      );
    }
  }

  String _formatElapsedTime() {
    final seconds = _stopwatch.elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lastValue = ref.watch(bleLastValueProvider) ?? 0;
    final bleData = ref.watch(bleDataStreamProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (res, didPop) async {
        if (res) {
          return;
        }

        final NavigatorState navigator = Navigator.of(context);

        // Ask user if they want to leave assessment
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Leave the assessment?'),
            content: Text(
              'If you leave this assessment, you will lose your progress.',
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
        appBar: AppBar(
          title: Text("60% Endurance Test"),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                // Pause stopwatch while showing tutorial
                _stopwatch.stop();

                // Show tutorial (forced, no "don't show again")
                showTutorialIfNeeded(
                  context: context,
                  content: AssessmentTutorials.get60PercentTutorial(
                    widget.hand,
                    widget.gripPosition,
                  ),
                  tutorialId: AssessmentTutorials.get60PercentTutorialId(),
                  forceShow: true,
                ).then((_) {
                  // Resume stopwatch after tutorial is closed
                  if (_assessmentStarted && !_assessmentEnded && mounted) {
                    _stopwatch.start();
                  }
                });
              },
              tooltip: 'Show tutorial',
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Live graph with scrolling
              bleData.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const SizedBox();
                  }

                  // Calculate time window to keep current point at middle
                  final now = data.last.timestamp;
                  final halfWindow = Duration(seconds: 15);

                  // Current point should be at middle, so show 15s before and 15s after
                  final visibleStart = now.subtract(halfWindow);
                  final visibleEnd = now.add(halfWindow);

                  // Create data points for the target band that span the full width
                  final bandData = [
                    BleDataPoint(_targetForce, visibleStart),
                    BleDataPoint(_targetForce, visibleEnd),
                  ];

                  return SfCartesianChart(
                    margin: EdgeInsets.zero,
                    plotAreaBorderWidth: 0,
                    primaryXAxis: DateTimeAxis(
                      isVisible: false,
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      minorGridLines: const MinorGridLines(width: 0),
                      // Keep current point at middle of screen
                      minimum: visibleStart,
                      maximum: visibleEnd,
                    ),
                    primaryYAxis: NumericAxis(
                      isVisible: true,
                      maximum: max(widget.mvcValue, lastValue + 5),
                      minimum: -5,
                      majorGridLines: const MajorGridLines(width: 1),
                      axisLine: const AxisLine(width: 1),
                      minorGridLines: const MinorGridLines(width: 0),
                    ),
                    borderWidth: 0,
                    series: [
                      // Target zone band - spans full width
                      RangeAreaSeries<BleDataPoint, DateTime>(
                        dataSource: bandData,
                        xValueMapper: (BleDataPoint p, _) => p.timestamp,
                        highValueMapper: (_, __) => _maxForce,
                        lowValueMapper: (_, __) => _minForce,
                        color: CrimpyTheme.accentYellow.withValues(alpha: 0.3),
                        borderColor: CrimpyTheme.accentYellow,
                        borderWidth: 2,
                        animationDuration: 0,
                      ),
                      // Force line
                      LineSeries<BleDataPoint, DateTime>(
                        dataSource: data,
                        xValueMapper: (BleDataPoint p, _) => p.timestamp,
                        yValueMapper: (BleDataPoint p, _) => p.value,
                        color: _isInTargetZone
                            ? Colors.green
                            : CrimpyTheme.accentYellow.withValues(alpha: 0.8),
                        width: 3,
                        markerSettings: const MarkerSettings(isVisible: false),
                        animationDuration: 0,
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error: $e'),
              ),

              // Status indicator box
              Positioned(
                top: 20,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _assessmentStarted
                        ? Colors.green.withValues(alpha: 0.9)
                        : CrimpyTheme.accentYellow.withValues(alpha: 0.9),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_assessmentStarted)
                        Text(
                          'Hold 60% MVC for 1s to start',
                          style: TextStyle(
                            fontSize: 20,
                            color: CrimpyTheme.primaryWhite,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      else
                        Column(
                          children: [
                            Text(
                              'Time: ${_formatElapsedTime()}',
                              style: TextStyle(
                                fontSize: 32,
                                color: CrimpyTheme.primaryWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _isInTargetZone ? 'Keep going!' : 'Out of zone!',
                              style: TextStyle(
                                fontSize: 18,
                                color: CrimpyTheme.primaryWhite,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Current force display
              Positioned(
                bottom: 20,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${lastValue.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Target: ${_targetForce.toStringAsFixed(1)} kg (${_minForce.toStringAsFixed(1)} - ${_maxForce.toStringAsFixed(1)})',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
