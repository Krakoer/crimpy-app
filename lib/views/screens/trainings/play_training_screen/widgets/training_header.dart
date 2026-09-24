import 'package:crimpy/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingHeader extends StatelessWidget {
  final int elapsedMilliseconds;
  final int remainingMilliseconds;

  /// Whether to show the total remaining time. Hidden for self-paced
  /// (rep-based) trainings where the total duration is unknown.
  final bool showRemaining;

  const TrainingHeader({
    super.key,
    required this.elapsedMilliseconds,
    required this.remainingMilliseconds,
    this.showRemaining = true,
  });

  Widget _time(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: CrimpyTheme.textMutedSmall,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: CrimpyTheme.primaryBlack,
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _time(
            context,
            'ELAPSED',
            formatMillisMinutesSeconds(elapsedMilliseconds),
          ),
          if (showRemaining)
            _time(
              context,
              'LEFT',
              formatMillisMinutesSeconds(remainingMilliseconds),
            ),
        ],
      ),
    );
  }
}
