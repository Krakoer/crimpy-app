import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingTimerDisplay extends StatelessWidget {
  final int secondsRemaining;
  final bool isRest;
  final bool isPrep;
  final double fontSize;

  const TrainingTimerDisplay({
    super.key,
    required this.secondsRemaining,
    required this.isRest,
    required this.isPrep,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Large timer
        Text(
          "${(secondsRemaining / 60).floor().toString().padLeft(2, '0')}:${(secondsRemaining % 60).toString().padLeft(2, '0')}",
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: CrimpyTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 12),
        // Status label
        Text(
          isPrep
              ? "PREPARATION"
              : isRest
              ? 'REST'
              : 'WORK',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: isRest
                ? CrimpyTheme.statusSuccess
                : CrimpyTheme.primaryOrange,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
