import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingHeader extends StatelessWidget {
  final int elapsedMilliseconds;
  final int remainingMilliseconds;

  const TrainingHeader({
    super.key,
    required this.elapsedMilliseconds,
    required this.remainingMilliseconds,
  });

  String formatTime(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formatTime(elapsedMilliseconds),
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: CrimpyTheme.primaryBlack,
              fontWeight: FontWeight.w500,
              fontSize: 25,
            ),
          ),
          Text(
            formatTime(remainingMilliseconds),
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: CrimpyTheme.primaryBlack,
              fontWeight: FontWeight.w500,
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}
