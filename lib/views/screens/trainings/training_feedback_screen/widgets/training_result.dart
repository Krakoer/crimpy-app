import 'package:collection/collection.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/views/screens/trainings/training_feedback_screen/widgets/failure_feedback_form.dart';
import 'package:crimpy/views/screens/trainings/training_feedback_screen/widgets/success_feedback_form.dart';
import 'package:flutter/material.dart';

class TrainingResultCard extends StatelessWidget {
  final HandSide handSide;
  final List<RepDataModel> reps;
  final LoadAdjustmentFunction loadAdjustmentFunction;
  final void Function(double) onNewWeightChange;

  const TrainingResultCard({
    required this.handSide,
    required this.reps,
    required this.loadAdjustmentFunction,
    required this.onNewWeightChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final success =
        reps.firstWhereOrNull(
          (r) => !r.isRest && r.averageWeight < r.targetWeight,
        ) ==
        null;

    final currentWeight = reps.firstWhere((r) => !r.isRest).targetWeight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                switch (handSide) {
                  HandSide.right => "Right Hand",
                  HandSide.left => "Left Hand",
                  HandSide.both => "",
                },
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Well done! 💪",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            success
                ? SuccessFeedbackForm(
                  loadAdjustmentFunction: loadAdjustmentFunction,
                  currentWeight: currentWeight,
                  onNewWeightChange: onNewWeightChange,
                )
                : FailureFeedbackForm(
                    reps: reps,
                    loadAdjustmentFunction: loadAdjustmentFunction,
                    currentWeight: currentWeight,
                    onNewWeightChange: onNewWeightChange,
                  ),
          ],
        ),
      ),
    );
  }
}
