import 'dart:math';

import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:crimpy/theme.dart';

class PostWorkoutScreen extends ConsumerStatefulWidget {
  final Training template;
  final List<RepDataModel> results;

  /// Show the results of the workout to the user, and allow them to add a note to the session.
  const PostWorkoutScreen({
    required this.results,
    required this.template,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostWorkoutScreenState();
}

class _PostWorkoutScreenState extends ConsumerState<PostWorkoutScreen> {
  final _trainingNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _trainingNameController.text =
        "${widget.template.title} - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}";
    super.initState();
  }

  @override
  void dispose() {
    _trainingNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Percentage of reps the user has succeded.
    final workingReps = widget.results.where((r) => !r.isRest).toList();
    final int percentageSuccess =
        (workingReps
                    .where((rep) => rep.averageWeight >= rep.targetWeight)
                    .length /
                workingReps.length *
                100)
            .round();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (res, didPop) async {
        if (res) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Leave without saving training?'),
            content: Text(
              'Are you sure you want to quit without saving this training to your history?',
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
        appBar: AppBar(title: Text(widget.template.title)),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 100),
              Text(
                "Well done! 💪",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              // Show the success percentage
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "you managed to do ",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CrimpyTheme.gray500,
                      ),
                    ),
                    TextSpan(
                      text: "$percentageSuccess%",
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 12),
                    ),
                    TextSpan(
                      text: " of the reps",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CrimpyTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              // Form for session name and notes.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _trainingNameController,
                        decoration: const InputDecoration(
                          labelText: 'Training Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a training name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: "How did you feel?",
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 20,
                        minLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ElevatedButton(
          style: null,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Repeater config is no longer stored on the training template
              const RepeaterConfig? repeaterConfig = null;

              ref
                  .read(sessionsProvider.notifier)
                  .saveSession(
                    SessionModel(
                      name: _trainingNameController.text,
                      date: DateTime.now(),
                      notes: _noteController.text,
                      isAssessment: false,
                      repeaterConfig: repeaterConfig,
                    ),
                    widget.results,
                  );
              Navigator.of(context).pop();
            }
          },
          child: Text("Save training"),
        ),
      ),
    );
  }
}

// Kept for archive but not used.
class WeightComparisonGraph extends StatelessWidget {
  final List<double> targetWeights;
  final List<double> effectiveWeights;

  const WeightComparisonGraph({
    super.key,
    required this.targetWeights,
    required this.effectiveWeights,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the lists are of the same length
    if (targetWeights.length != effectiveWeights.length ||
        targetWeights.isEmpty) {
      return const Center(child: Text('Invalid data for graph'));
    }

    // Create data points for chart
    final data = List.generate(targetWeights.length, (index) {
      return RepData(
        repIndex: index + 1,
        targetWeight: targetWeights[index],
        actualWeight: effectiveWeights[index],
        isBelowTarget: effectiveWeights[index] < targetWeights[index],
      );
    });

    return SfCartesianChart(
      margin: const EdgeInsets.all(10),
      legend: Legend(
        isVisible: false,
        position: LegendPosition.top,
        alignment: ChartAlignment.far,
      ),
      primaryXAxis: NumericAxis(
        // Horizontal axis for weights
        minimum:
            (min(targetWeights.reduce(min), effectiveWeights.reduce(min)) * 0.2)
                .floor()
                .toDouble(),
        maximum:
            max(targetWeights.reduce(max), effectiveWeights.reduce(max)) * 1.2,
        title: AxisTitle(text: 'Weight'),
        labelStyle: TextStyle(fontSize: 10),
        axisLine: const AxisLine(width: 1),
        majorGridLines: const MajorGridLines(width: 0), // No vertical grid
        interval: 5,
        tickPosition: TickPosition.inside,
        decimalPlaces: 1,
      ),
      primaryYAxis: NumericAxis(
        // Vertical axis for rep indices (inverted)
        title: AxisTitle(text: 'Rep'),
        minimum: 1,
        maximum: targetWeights.length + 0.5,
        interval: 1,
        plotOffset: 20,
        isInversed: true, // Make the axis go from top to bottom
        axisLine: const AxisLine(width: 1),
        labelStyle: TextStyle(fontSize: 10),
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          int index = args.value.toInt() - 1;
          if (index >= 0 && index < data.length) {
            return ChartAxisLabel(
              '${data[index].repIndex}',
              data[index].isBelowTarget
                  ? TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )
                  : TextStyle(color: CrimpyTheme.primaryBlack, fontSize: 20),
            );
          }
          return ChartAxisLabel(
            args.text,
            TextStyle(color: CrimpyTheme.primaryBlack, fontSize: 20),
          );
        },
      ),
      series: <CartesianSeries>[
        // Target weights (grey points)
        ScatterSeries<RepData, double>(
          name: 'Target',
          dataSource: data,
          xValueMapper: (RepData data, _) => data.targetWeight,
          yValueMapper: (RepData data, _) => data.repIndex.toDouble(),
          color: CrimpyTheme.primaryWhite,
          borderColor: CrimpyTheme.gray400,
          markerSettings: const MarkerSettings(
            height: 10,
            width: 10,
            shape: DataMarkerType.circle,
          ),
        ),
        // Actual weights (black points)
        ScatterSeries<RepData, double>(
          name: 'Actual',
          dataSource: data,
          xValueMapper: (RepData data, _) => data.actualWeight,
          yValueMapper: (RepData data, _) => data.repIndex.toDouble(),
          color: CrimpyTheme.primaryWhite,
          borderColor: CrimpyTheme.primaryBlack,
          markerSettings: const MarkerSettings(
            height: 10,
            width: 10,
            shape: DataMarkerType.circle,
          ),
        ),
      ],
    );
  }
}

// Data model for chart
class RepData {
  final int repIndex;
  final double targetWeight;
  final double actualWeight;
  final bool isBelowTarget;

  RepData({
    required this.repIndex,
    required this.targetWeight,
    required this.actualWeight,
    required this.isBelowTarget,
  });
}
