import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'dart:core';
import '../../../theme/crimpy_theme.dart';

class PostAssessmentScreen extends ConsumerWidget {
  final AssessmentType type;

  // Results in the form (prevValue, newValue). previousValue value can be null if the assessment was done for the first time.
  final (double?, double)? rightHandResults;
  final (double?, double)? leftHandResults;

  final AssessmentResultModel saveAssessment;
  final SessionModel saveTraining;
  final List<RepDataModel> saveReps;

  /// Screen to show the results of an assessment, and to allow the user to choose whether to save the results or discard them.
  ///
  /// - If both hands were tested, pass the right/left hand related values to `rightHandResults`/`leftHandResults`.
  /// - If only one hand was tested, pass the results to `rightHandResults` or `leftHandResults` depending on the tested hand.
  ///
  /// Results must be in the form `(prevValue, newValue)`. `previousValue` can be null if the assessment was done for the first time.
  const PostAssessmentScreen({
    required this.type,
    this.rightHandResults,
    this.leftHandResults,
    required this.saveAssessment,
    required this.saveReps,
    required this.saveTraining,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${assessmentTypeToString(type)} assessment results"),
      ),
      body: Column(
        children: [
          SizedBox(height: 100),
          // If they gave their max, it's always a good job rigth ?
          Text(
            "Great job! 💪",
            style: Theme.of(context).textTheme.displaySmall,
          ),
          SizedBox(height: 16),
          // Show the results cards for the provided hands.
          Column(
            children: [
              if (rightHandResults != null)
                ResultCard(
                  prevValue: rightHandResults!.$1,
                  newValue: rightHandResults!.$2,
                  // If `leftHandResults` was provided, it's a two hands assessment.
                  // In that case, tell the card the result is right hand related to show the hand side.
                  rightHand: leftHandResults != null ? true : null,
                ),
              if (leftHandResults != null)
                ResultCard(
                  prevValue: leftHandResults!.$1,
                  newValue: leftHandResults!.$2,
                  // If `rightHandResults` was provided, it's a two hands assessment.
                  // In that case, tell the card the result is left hand related to show the hand side.
                  rightHand: rightHandResults != null ? false : null,
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            child: Text("Save new result"),
            onPressed: () {
              ref
                  .read(assessmentsProvider(type).notifier)
                  .saveAssessment(saveAssessment, saveTraining, saveReps);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Discard"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final double? prevValue;
  final double newValue;
  final bool? rightHand;

  /// Display the assessment results in a card.
  /// If `rightHand` is not null, the hand side will be displayed above the card (use this option for both hands assessments).
  const ResultCard({
    super.key,
    required this.newValue,
    this.prevValue,
    this.rightHand,
  });

  @override
  Widget build(BuildContext context) {
    // Compute relative percentage between the previous and the new results.
    final percentage =
        prevValue == null
            ? double.infinity
            : ((newValue - prevValue!) / prevValue! * 100).round();
    final isPositive = prevValue == null ? true : newValue >= prevValue!;
    final percentageColor =
        isPositive
            ? CrimpyTheme.accentYellow
            : Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // If the hand side was provided, display it above the card.
        if (rightHand != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              rightHand! ? "Right Hand" : "Left Hand",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        CrimpyCards.assessment(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous value text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Previous',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: CrimpyTheme.gray500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${prevValue == null ? "--" : prevValue!.toStringAsFixed(1)} kg",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),

                // Arrow with percentage
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    // Percentage change
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: percentageColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: percentageColor, width: 1),
                      ),
                      child: Text(
                        "${isPositive ? '+' : ''}$percentage%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: percentageColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Arrow
                    Icon(Icons.arrow_forward, size: 36, color: percentageColor),
                  ],
                ),

                // New value text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Current',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: CrimpyTheme.gray500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${newValue.toStringAsFixed(1)} kg",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
