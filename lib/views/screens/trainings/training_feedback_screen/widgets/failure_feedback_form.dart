import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

class FailureFeedbackForm extends StatelessWidget {
  final List<RepDataModel> reps;
  const FailureFeedbackForm({required this.reps, super.key});

  @override
  Widget build(BuildContext context) {
    final workingReps = reps.where((r) => !r.isRest).toList();
    final percentageSuccess =
        (workingReps.where((r) => r.averageWeight >= r.targetWeight).length /
                workingReps.length *
                100)
            .round();
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "you managed to do ",
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
      ],
    );
  }
}
