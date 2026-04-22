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
    final theme = Theme.of(context);

    return CrimpyCards.assessment(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: CrimpyTheme.primaryOrange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(description, style: theme.textTheme.bodySmall),
                if (lastResult != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clockRotateLeft,
                        size: 10,
                        color: CrimpyTheme.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        lastResult!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: CrimpyTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          FaIcon(
            FontAwesomeIcons.chevronRight,
            color: CrimpyTheme.textMuted,
            size: 12,
          ),
        ],
      ),
    );
  }
}
