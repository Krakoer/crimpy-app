import 'package:flutter/material.dart';

class ConfirmRedoAssessmentDialog extends StatelessWidget {
  final Function runAssessment;

  /// Dialog to ask the use to confirm if they want to run the assessment despite having already done the assessment the same day.
  /// Call `runAssessment` when the user click on the `Run anyway``button.
  const ConfirmRedoAssessmentDialog({super.key, required this.runAssessment});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Assessment already done today"),
      content: Text(
        "You already did this assessment today. Do you really want to redo it? This will discard you previous assessment results.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            runAssessment();
          },
          child: Text("Run anyway"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
