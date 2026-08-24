import 'package:flutter/material.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';

class SessionPerformanceCard extends StatelessWidget {
  final List<RepDataModel> reps;

  /// Whether one number stated for this whole session would pool across the
  /// blocks it played. The average weight is dropped when it would, and read
  /// per block instead. Max weight, work time and work reps still aggregate
  /// over the whole session either way: the heaviest rep of a run is one rep
  /// whichever block it was hung in.
  final bool poolsBlocks;

  const SessionPerformanceCard({
    super.key,
    required this.reps,
    required this.poolsBlocks,
  });

  @override
  Widget build(BuildContext context) {
    final workReps = reps.where((r) => !r.isRest).toList();

    if (workReps.isEmpty) {
      return const SizedBox.shrink();
    }

    // Both over the reps the sensor weighed, so a run it dropped out of is not
    // averaged down by the zeros it recorded for the rest of it. Null when it
    // weighed none of them, which drops the stat rather than stating a zero the
    // athlete never pulled. A run nothing weighed keeps only the work time and
    // the rep count, which hold whatever the sensor caught.
    final avgWeight = measuredAvgWeight(workReps);
    final maxWeight = measuredMaxWeight(workReps);
    final totalWorkTime = workReps.fold(0, (sum, r) => sum + r.duration);

    final stats = <(String, String)>[
      if (!poolsBlocks && avgWeight != null)
        ('Avg Weight', '${avgWeight.toStringAsFixed(1)} kg'),
      if (maxWeight != null)
        ('Max Weight', '${maxWeight.toStringAsFixed(1)} kg'),
      ('Work Time', '${totalWorkTime}s'),
      ('Work Reps', '${workReps.length}'),
    ];

    return CrimpyCards.stats(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Stats',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          for (var row = 0; row * 2 < stats.length; row++) ...[
            if (row > 0) const SizedBox(height: 12),
            Row(
              children: [
                for (var column = 0; column < 2; column++)
                  Expanded(
                    child: row * 2 + column < stats.length
                        ? _buildPerformanceStat(
                            context,
                            stats[row * 2 + column].$1,
                            stats[row * 2 + column].$2,
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: CrimpyTheme.gray600, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
