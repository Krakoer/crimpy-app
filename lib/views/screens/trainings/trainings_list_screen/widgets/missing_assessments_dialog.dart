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
        padding: const EdgeInsets.all(CrimpyTheme.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon header
            Container(
              padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
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
            const SizedBox(height: CrimpyTheme.spaceMd),

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
              padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
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
                        padding: const EdgeInsets.symmetric(
                          vertical: CrimpyTheme.spaceSm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.circleCheck,
                              color: CrimpyTheme.assessmentColor,
                              size: 18,
                            ),
                            const SizedBox(width: CrimpyTheme.spaceMd),
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
                                    const SizedBox(height: CrimpyTheme.spaceXs),
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
            const SizedBox(height: CrimpyTheme.spaceXl),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: CrimpyTheme.spaceMd),
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
