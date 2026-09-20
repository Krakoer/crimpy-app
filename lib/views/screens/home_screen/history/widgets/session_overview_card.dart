import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/session_rpe.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class SessionOverviewCard extends StatelessWidget {
  final SessionModel session;

  const SessionOverviewCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: session.duration);
    final sessionColor = CrimpyTheme.activityColor(session.activity);
    final sessionIcon = _getSessionIcon(session.activity);
    // What the athlete answered, read back with its anchor: the number alone
    // would not say which of the two RPE scales it sits on.
    final rpe = sessionRpeOptionOf(
      rpe: session.rpe,
      rpeFailed: session.rpeFailed,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CrimpyTheme.tintOf(sessionColor),
                    border: Border.all(
                      color: sessionColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    sessionIcon,
                    color: CrimpyTheme.textOn(sessionColor),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.activity.displayName,
                        style: TextStyle(
                          color: CrimpyTheme.gray600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        session.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Top aligned, like the item internals: once a value can wrap, the
            // two halves of a pair are no longer the same height, and centring
            // them staggers the one that did not wrap.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Date',
                    DateFormat('MMM d, yyyy').format(session.date),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Time',
                    DateFormat('HH:mm').format(session.date),
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Duration',
                    _formatDuration(duration),
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Reps',
                    session.repCount?.toString() ?? 'N/A',
                    Icons.repeat,
                  ),
                ),
              ],
            ),
            if (rpe != null) ...[
              const SizedBox(height: 12),
              // In a Row with an Expanded child for symmetry with the four
              // stats above, which are laid out in pairs. It is not what makes
              // the anchor wrap: a child of the surrounding Column already has
              // a bounded width, and the wrapping comes from the Flexible
              // inside _buildStatItem.
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Session RPE ${rpe.label}',
                      rpe.anchor,
                      Icons.battery_charging_full,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSessionIcon(SessionActivity activity) {
    return switch (activity) {
      SessionActivity.hangboard => Icons.back_hand,
      SessionActivity.climbing => Icons.terrain,
      SessionActivity.stretching => Icons.self_improvement,
      SessionActivity.workout => Icons.fitness_center,
      SessionActivity.other => Icons.directions_run,
    };
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: CrimpyTheme.gray600),
        const SizedBox(width: 8),
        // Flexible rather than bare: the RPE anchor is a sentence where every
        // other stat is a figure, and an unbounded Column would lay it out on
        // one line however wide that came out.
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: CrimpyTheme.gray600, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
