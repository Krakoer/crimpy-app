import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/utils/format.dart';

/// Build overview header with training stats
class RepeaterOverviewHeader extends StatelessWidget {
  final RepeaterModel repeater;

  const RepeaterOverviewHeader({super.key, required this.repeater});

  @override
  Widget build(BuildContext context) {
    final totalDuration = repeater.generateReps().fold(
      0,
      (i, rep) => i + rep.duration,
    );

    return CrimpyCard.simple(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      backgroundColor: CrimpyTheme.bgSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main stats in a grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Sets',
                  '${repeater.sets}',
                  CrimpyTheme.accentOrange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Reps/Set',
                  '${repeater.repsBySet}',
                  CrimpyTheme.accentGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Duration',
                  formatDurationHMS(totalDuration),
                  CrimpyTheme.accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Work',
                  '${repeater.workTime}s',
                  CrimpyTheme.errorColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Rest',
                  '${repeater.restTime}s',
                  CrimpyTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Set Rest',
                  formatDurationHMS(repeater.restBteweenSets),
                  CrimpyTheme.accentTeal,
                ),
              ),
            ],
          ),
          if (repeater.splitHand) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgInfo,
                border: Border.all(color: CrimpyTheme.statusInfo, width: 1),
              ),
              child: Text(
                'Split Hand Training',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: CrimpyTheme.statusInfo,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build a single stat item
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CrimpyTheme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
