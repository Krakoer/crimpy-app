import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingProgressInfo extends StatelessWidget {
  final int currentRepIndex;
  final int totalReps;

  const TrainingProgressInfo({
    super.key,
    required this.currentRepIndex,
    required this.totalReps,
  });

  @override
  Widget build(BuildContext context) {
    final value = totalReps <= 0
        ? 0.0
        : (currentRepIndex / totalReps).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: CrimpyTheme.gray200,
          color: CrimpyTheme.primaryOrange,
        ),
      ),
    );
  }
}
