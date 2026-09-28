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
      padding: const EdgeInsets.symmetric(
        vertical: CrimpyTheme.spaceLgPlus,
        horizontal: CrimpyTheme.spaceMd,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: CrimpyTheme.title.copyWith(
              color: CrimpyTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: CrimpyTheme.spaceXs),
          Text(
            label,
            style: CrimpyTheme.body.copyWith(color: CrimpyTheme.textSecondary),
          ),
          const SizedBox(height: CrimpyTheme.spaceSm),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: CrimpyTheme.corners,
            ),
          ),
        ],
      ),
    );
  }
}
