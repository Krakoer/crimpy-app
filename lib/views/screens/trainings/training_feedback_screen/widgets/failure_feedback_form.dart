import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

class FailureFeedbackForm extends StatefulWidget {
  final List<RepDataModel> reps;
  final LoadAdjustmentFunction? loadAdjustmentFunction;
  final double currentWeight;
  final void Function(double) onNewWeightChange;

  const FailureFeedbackForm({
    required this.reps,
    required this.loadAdjustmentFunction,
    required this.currentWeight,
    required this.onNewWeightChange,
    super.key,
  });

  @override
  State<FailureFeedbackForm> createState() => _FailureFeedbackFormState();
}

class _FailureFeedbackFormState extends State<FailureFeedbackForm> {
  @override
  void initState() {
    super.initState();
    // Calculate and set the new weight based on failure rate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.loadAdjustmentFunction != null) {
        final workingReps = widget.reps.where((r) => !r.isRest).toList();
        final percentageSuccess =
            (workingReps.where((r) => r.averageWeight >= r.targetWeight).length /
                    workingReps.length *
                    100);
        final failureRate = 100 - percentageSuccess;

        final multiplier = widget.loadAdjustmentFunction!(failureRate: failureRate);
        final newWeight = widget.currentWeight * (1 + multiplier);
        widget.onNewWeightChange(newWeight);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workingReps = widget.reps.where((r) => !r.isRest).toList();
    final percentageSuccess =
        (workingReps.where((r) => r.averageWeight >= r.targetWeight).length /
                workingReps.length *
                100)
            .round();

    final failureRate = 100 - percentageSuccess;
    String recommendationText = "";

    if (widget.loadAdjustmentFunction != null) {
      final multiplier = widget.loadAdjustmentFunction!(failureRate: failureRate.toDouble());
      final newWeight = widget.currentWeight * (1 + multiplier);
      final variation = (multiplier * 100).round();
      recommendationText = " → ${newWeight.toStringAsFixed(1)}kg (${variation >= 0 ? '+' : ''}$variation%)";
    }

    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "You managed to do ",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: CrimpyTheme.gray500),
              ),
              TextSpan(
                text: "$percentageSuccess%",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontSize: 12),
              ),
              TextSpan(
                text: " of the reps",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: CrimpyTheme.gray500),
              ),
            ],
          ),
        ),
        if (recommendationText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            "Recommended adjustment: $recommendationText",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
