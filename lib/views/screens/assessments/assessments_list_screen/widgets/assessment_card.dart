import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssessmentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final VoidCallback? onTap;
  final String? lastResult;

  const AssessmentCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.onTap,
    this.lastResult,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CrimpyCards.assessment(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: CrimpyTheme.assessmentColor),
          const SizedBox(width: CrimpyTheme.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CrimpyTheme.titleSmall.copyWith(
                    color: CrimpyTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: CrimpyTheme.spaceXs),
                Text(
                  description,
                  style: CrimpyTheme.bodySmall.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
                if (lastResult != null) ...[
                  const SizedBox(height: CrimpyTheme.spaceSm),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clockRotateLeft,
                        size: 10,
                        color: CrimpyTheme.textMutedSmall,
                      ),
                      const SizedBox(width: CrimpyTheme.spaceXs),
                      Text(
                        lastResult!,
                        style: CrimpyTheme.labelSmall.copyWith(
                          color: CrimpyTheme.textMutedSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: CrimpyTheme.spaceMd),
          FaIcon(
            FontAwesomeIcons.chevronRight,
            color: CrimpyTheme.textMutedSmall,
            size: 12,
          ),
        ],
      ),
    );
  }
}
