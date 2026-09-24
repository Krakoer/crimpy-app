import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';

class RepItemWidget extends StatelessWidget {
  final RepDataModel rep;
  final int index;
  final Color sessionColor;

  const RepItemWidget({
    super.key,
    required this.rep,
    required this.index,
    required this.sessionColor,
  });

  @override
  Widget build(BuildContext context) {
    if (rep.isRest) {
      return _buildRestItem();
    }

    return _buildWorkItem();
  }

  Widget _buildRestItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CrimpyTheme.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CrimpyTheme.gray300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(Icons.pause, size: 16, color: CrimpyTheme.gray600),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Rest',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CrimpyTheme.gray700,
            ),
          ),
          const Spacer(),
          Text(
            '${rep.duration}s',
            style: TextStyle(fontSize: 13, color: CrimpyTheme.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkItem() {
    // Calculate success/failure
    final bool hasTarget = rep.targetWeight > 0;
    // A rep the run weighed nothing for states so rather than nothing at all:
    // the card names every other rep with a load, and a silent row reads as one
    // the athlete pulled a load the screen forgot to print.
    final bool weighed = repWeighed(rep);
    final double successRate = hasTarget
        ? rep.averageWeight / rep.targetWeight
        : 0;
    final bool isSuccess = successRate >= 0.9;
    // Theme accents, not raw Material ones: Colors.orange.shade600 is unreadable
    // at the sizes the labels below use. See Krakoer/crimpy#137.
    final Color statusColor = isSuccess
        ? CrimpyTheme.statusSuccess
        : CrimpyTheme.statusWarning;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sessionColor.withValues(alpha: 0.05),
        border: Border.all(
          color: hasTarget
              ? statusColor.withValues(alpha: 0.3)
              : sessionColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rep number badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: CrimpyTheme.tintOf(sessionColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: CrimpyTheme.textOn(sessionColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Hand indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          switch (rep.handSide) {
                            HandSide.right => Icons.front_hand,
                            HandSide.left => Icons.back_hand,
                            // Neither of the two single hand icons, since the
                            // hang is neither of those hands.
                            HandSide.both => Icons.pan_tool,
                          },
                          size: 16,
                          color: CrimpyTheme.gray700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rep.handSide.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CrimpyTheme.gray700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        '${rep.duration}s',
                        if (rep.edgeSizeMm != null) '${rep.edgeSizeMm}mm',
                      ].join(' - '),
                      style: TextStyle(
                        fontSize: 12,
                        color: CrimpyTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              // Success indicator
              if (hasTarget)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle : Icons.warning,
                        size: 14,
                        color: CrimpyTheme.markOn(statusColor),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(successRate * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: CrimpyTheme.textOn(statusColor),
                        ),
                      ),
                    ],
                  ),
                )
              else if (!weighed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CrimpyTheme.gray100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Not measured',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: CrimpyTheme.gray600,
                    ),
                  ),
                ),
            ],
          ),
          if (hasTarget) ...[
            const SizedBox(height: 8),
            // Target vs Performed
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target',
                        style: TextStyle(
                          fontSize: 11,
                          color: CrimpyTheme.gray600,
                        ),
                      ),
                      Text(
                        '${rep.targetWeight.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CrimpyTheme.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: CrimpyTheme.gray300),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performed',
                          style: TextStyle(
                            fontSize: 11,
                            color: CrimpyTheme.gray600,
                          ),
                        ),
                        Text(
                          '${rep.averageWeight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CrimpyTheme.textOn(statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else if (weighed) ...[
            const SizedBox(height: 8),
            // A rep the sensor read against no prescribed load still names what
            // the athlete pulled: the card averages it in, and the portal prints
            // it on the row. There is nothing to grade it against, so it is
            // stated in the neutral color a target would take.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performed',
                  style: TextStyle(fontSize: 11, color: CrimpyTheme.gray600),
                ),
                Text(
                  '${rep.averageWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CrimpyTheme.gray700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
