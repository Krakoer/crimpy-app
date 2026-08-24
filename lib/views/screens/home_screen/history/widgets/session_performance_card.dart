import 'package:flutter/material.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';

class SessionPerformanceCard extends StatelessWidget {
  final List<RepDataModel> reps;

  /// The blocks the reps were played from, null for a session that names none.
  /// A session that played more than one drops its average weight rather than
  /// pooling them, and reads it per block instead. Max weight, work time and
  /// work reps still aggregate over the whole session.
  final List<RepBlock>? blocks;

  const SessionPerformanceCard({super.key, required this.reps, this.blocks});

  @override
  Widget build(BuildContext context) {
    final workReps = reps.where((r) => !r.isRest).toList();

    if (workReps.isEmpty) {
      return const SizedBox.shrink();
    }

    final avgWeight =
        workReps.fold<double>(0, (sum, r) => sum + r.averageWeight) /
        workReps.length;
    final maxWeight = workReps.fold<double>(
      0,
      (max, r) => r.averageWeight > max ? r.averageWeight : max,
    );
    final totalWorkTime = workReps.fold(0, (sum, r) => sum + r.duration);

    final stats = <(String, String)>[
      if (!poolsUnlikeBlocks(blocks))
        ('Avg Weight', '${avgWeight.toStringAsFixed(1)} kg'),
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
