import 'package:flutter/material.dart';
import '../../../../theme/crimpy_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const StatCard(this.label, this.value, this.accentColor, {super.key});

  @override
  Widget build(BuildContext context) {
    return CrimpyCards.stats(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: CrimpyTheme.gray500),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
