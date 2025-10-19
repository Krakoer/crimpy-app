import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class TrainingControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onPlayPause;
  final VoidCallback onSkip;

  const TrainingControls({
    super.key,
    required this.isRunning,
    required this.onPlayPause,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPlayPause,
            icon: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 56),
            color: CrimpyTheme.primaryOrange,
            iconSize: 56,
          ),
          const SizedBox(width: 48),
          IconButton(
            onPressed: onSkip,
            icon: const Icon(Icons.skip_next, size: 56),
            color: CrimpyTheme.primaryBlack,
            iconSize: 56,
          ),
        ],
      ),
    );
  }
}
