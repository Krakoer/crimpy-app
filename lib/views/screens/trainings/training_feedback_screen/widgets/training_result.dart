import 'package:collection/collection.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/views/screens/trainings/training_feedback_screen/widgets/failure_feedback_form.dart';
import 'package:crimpy/views/screens/trainings/training_feedback_screen/widgets/success_feedback_form.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
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

    // Calculate success percentage for this hand
    final workingReps = reps.where((r) => !r.isRest).toList();
    final int percentageSuccess =
        (workingReps
                    .where((rep) => rep.averageWeight >= rep.targetWeight)
                    .length /
                workingReps.length *
                100)
            .round();

    // Get hand color
    final handColor = handSide == HandSide.right
        ? CrimpyTheme.accentOrange
        : handSide == HandSide.left
        ? CrimpyTheme.accentTeal
        : CrimpyTheme.accentYellow;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgPrimary,
        border: Border(
          left: BorderSide(color: handColor, width: 4),
          top: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
          right: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
          bottom: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: CrimpyTheme.borderDefault,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hand label and stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  switch (handSide) {
                    HandSide.right => "RIGHT HAND",
                    HandSide.left => "LEFT HAND",
                    HandSide.both => "BOTH HANDS",
                  },
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: handColor,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: success
                        ? CrimpyTheme.bgSuccess
                        : CrimpyTheme.bgWarning,
                    border: Border.all(
                      color: success
                          ? CrimpyTheme.statusSuccess
                          : CrimpyTheme.statusWarning,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$percentageSuccess%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: success
                          ? CrimpyTheme.statusSuccess
                          : CrimpyTheme.statusWarning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Current weight display
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgSecondary,
                border: Border.all(color: CrimpyTheme.borderDefault, width: 1),
              ),
              child: Row(
                children: [
                  Text(
                    'Current Weight: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CrimpyTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${currentWeight.toStringAsFixed(1)}kg',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Feedback form
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
