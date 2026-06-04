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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          '${currentRepIndex + 1}/$totalReps',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: CrimpyTheme.primaryBlack,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
