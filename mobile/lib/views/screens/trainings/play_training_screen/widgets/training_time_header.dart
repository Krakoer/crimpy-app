import 'package:flutter/material.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingTimeHeader extends StatelessWidget {
  final int elapsedMilliseconds;
  final int timeLeftMilliseconds;

  /// Shows the given elapsed and remaining time.
  const TrainingTimeHeader({
    super.key,
    required this.elapsedMilliseconds,
    required this.timeLeftMilliseconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border.all(color: CrimpyTheme.borderDefault, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TimeDisplay(
            label: 'ELAPSED',
            time: formatMillisHHMMSS(elapsedMilliseconds),
          ),
          Container(width: 2, height: 32, color: CrimpyTheme.borderDefault),
          _TimeDisplay(
            label: 'REMAINING',
            time: formatMillisHHMMSS(timeLeftMilliseconds),
          ),
        ],
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String label;
  final String time;

  const _TimeDisplay({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: CrimpyTheme.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
