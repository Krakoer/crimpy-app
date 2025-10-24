import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class AssessmentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  /// Card in the assessments list.
  const AssessmentCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CrimpyCards.assessment(
      onTap: onTap,
      child: Row(
        children: [
          // Icon
          Icon(icon, size: 36, color: CrimpyTheme.primaryOrange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                // Description
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: CrimpyTheme.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }
}
