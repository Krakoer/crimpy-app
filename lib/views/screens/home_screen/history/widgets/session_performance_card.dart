import 'package:flutter/material.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class SessionPerformanceCard extends StatelessWidget {
  final List<RepDataModel> reps;

  const SessionPerformanceCard({super.key, required this.reps});

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
          Row(
            children: [
              Expanded(
                child: _buildPerformanceStat(
                  context,
                  'Avg Weight',
                  '${avgWeight.toStringAsFixed(1)} kg',
                ),
              ),
              Expanded(
                child: _buildPerformanceStat(
                  context,
                  'Max Weight',
                  '${maxWeight.toStringAsFixed(1)} kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceStat(
                  context,
                  'Work Time',
                  '${totalWorkTime}s',
                ),
              ),
              Expanded(
                child: _buildPerformanceStat(
                  context,
                  'Work Reps',
                  '${workReps.length}',
                ),
              ),
            ],
          ),
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
