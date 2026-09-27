import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class MissingAssessmentsDialog extends StatelessWidget {
  final List<AssessmentRequirement> missingAssessments;
  final VoidCallback onGoToAssessments;

  const MissingAssessmentsDialog({
    required this.missingAssessments,
    required this.onGoToAssessments,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon header
            Container(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.assessment,
                color: CrimpyTheme.assessmentColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Assessment Required',
              style: CrimpyTheme.title.copyWith(color: CrimpyTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Complete these assessments to unlock this training:',
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Assessment list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgSecondary,
                borderRadius: CrimpyTheme.corners,
                border: Border.all(color: CrimpyTheme.outlineSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: missingAssessments
                    .map(
                      (requirement) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.circleCheck,
                              color: CrimpyTheme.assessmentColor,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    builtinAssessmentLabel(
                                      requirement.assessmentId,
                                    ),
                                    style: CrimpyTheme.body.copyWith(
                                      color: CrimpyTheme.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (requirement.gripPosition != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Grip: ${requirement.gripPosition!.displayName}',
                                      style: CrimpyTheme.bodySmall.copyWith(
                                        color: CrimpyTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onGoToAssessments();
                    },
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    label: const Text('Go to Assessments'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
