import 'package:flutter/material.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';

class SetsViewWidget extends StatelessWidget {
  final List<RepSet> sets;
  final Color sessionColor;

  const SetsViewWidget({
    super.key,
    required this.sets,
    required this.sessionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(sets.length, (setIndex) {
        final set = sets[setIndex];
        final workReps = set.reps.where((r) => !r.isRest).toList();

        int setSuccessCount = 0;
        double setAvgWeight = 0;
        double setAvgTarget = 0;

        for (final rep in workReps) {
          setAvgWeight += rep.averageWeight;
          setAvgTarget += rep.targetWeight;
          if (rep.targetWeight > 0 &&
              rep.averageWeight / rep.targetWeight >= 0.9) {
            setSuccessCount++;
          }
        }

        if (workReps.isNotEmpty) {
          setAvgWeight /= workReps.length;
          setAvgTarget /= workReps.length;
        }

        return Column(
          children: [
            SetCardWidget(
              label: set.label,
              workReps: workReps,
              successCount: setSuccessCount,
              avgWeight: setAvgWeight,
              avgTarget: setAvgTarget,
              sessionColor: sessionColor,
            ),
            if (setIndex < sets.length - 1) const SizedBox(height: 12),
          ],
        );
      }),
    );
  }
}

class SetCardWidget extends StatelessWidget {
  /// Names the set the way it was played, hand included where the block works
  /// the hands separately.
  final String label;
  final List<RepDataModel> workReps;
  final int successCount;
  final double avgWeight;
  final double avgTarget;
  final Color sessionColor;

  const SetCardWidget({
    super.key,
    required this.label,
    required this.workReps,
    required this.successCount,
    required this.avgWeight,
    required this.avgTarget,
    required this.sessionColor,
  });

  /// The edge every rep of the set was pulled on, or null when the set mixes
  /// several edges or prescribes none.
  int? get _sharedEdgeSizeMm {
    final edges = workReps.map((r) => r.edgeSizeMm).toSet();
    return edges.length == 1 ? edges.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final bool allSuccess =
        workReps.isNotEmpty && successCount == workReps.length;
    final Color statusColor = allSuccess
        ? Colors.green.shade600
        : Colors.orange.shade600;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sessionColor.withValues(alpha: 0.05),
        border: Border.all(
          color: sessionColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Set header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sessionColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: sessionColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                [
                  '${workReps.length} reps',
                  if (_sharedEdgeSizeMm != null) '${_sharedEdgeSizeMm}mm',
                ].join(' - '),
                style: TextStyle(fontSize: 12, color: CrimpyTheme.gray600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$successCount/${workReps.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Performance visualization
          SetPerformanceBar(workReps: workReps, sessionColor: sessionColor),
          const SizedBox(height: 8),
          // Set statistics
          Row(
            children: [
              Expanded(
                child: _buildSetStat(
                  'Avg Performed',
                  '${avgWeight.toStringAsFixed(1)} kg',
                  statusColor,
                ),
              ),
              Container(width: 1, height: 20, color: CrimpyTheme.gray300),
              Expanded(
                child: _buildSetStat(
                  'Target',
                  '${avgTarget.toStringAsFixed(1)} kg',
                  CrimpyTheme.gray700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: CrimpyTheme.gray600)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class SetPerformanceBar extends StatelessWidget {
  final List<RepDataModel> workReps;
  final Color sessionColor;

  const SetPerformanceBar({
    super.key,
    required this.workReps,
    required this.sessionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(workReps.length, (index) {
        final rep = workReps[index];
        final bool hasTarget = rep.targetWeight > 0;
        final double successRate = hasTarget
            ? rep.averageWeight / rep.targetWeight
            : 1.0;
        final bool isSuccess = successRate >= 0.9;

        final Color repColor = !hasTarget
            ? sessionColor.withValues(alpha: 0.3)
            : isSuccess
            ? Colors.green.shade600
            : successRate >= 0.75
            ? Colors.orange.shade600
            : Colors.red.shade600;

        return Container(
          width: 48,
          height: 32,
          decoration: BoxDecoration(
            color: repColor.withValues(alpha: 0.2),
            border: Border.all(color: repColor, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: hasTarget
                ? Text(
                    '${(successRate * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: repColor,
                    ),
                  )
                : Icon(Icons.fitness_center, size: 12, color: repColor),
          ),
        );
      }),
    );
  }
}
