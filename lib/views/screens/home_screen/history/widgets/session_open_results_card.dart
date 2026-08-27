import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:flutter/material.dart';

/// What the athlete managed on the steps the coach left open. Neither an AMRAP
/// nor an emom the athlete dropped out of leaves a rep behind, so this card is
/// the only place either shows up.
class SessionOpenResultsCard extends StatelessWidget {
  final List<OpenItemResult> results;

  const SessionOpenResultsCard({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you managed',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final result in results)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      result.label,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        result.values.join(', '),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CrimpyTheme.primaryOrange,
                        ),
                      ),
                      Text(
                        result.prescribed,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CrimpyTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
