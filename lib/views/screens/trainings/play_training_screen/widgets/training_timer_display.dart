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
        // A working step carries no label: the gauge, or the step name above
        // the circle, already says what it is.
        if (isPrep || isRest) ...[
          const SizedBox(height: 12),
          Text(
            isPrep ? "PREPARATION" : 'REST',
            // 16px bold on the white run screen, so the 4.5:1 text floor: the bare
            // accent reads 4.05:1 there. statusSuccess clears it at 4.91:1 and
            // stays. See Krakoer/crimpy#128.
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: isRest
                  ? CrimpyTheme.statusSuccess
                  : CrimpyTheme.textOn(CrimpyTheme.primaryOrange),
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }
}
