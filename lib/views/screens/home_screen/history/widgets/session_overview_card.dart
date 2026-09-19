import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
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
                    color: sessionColor.withValues(alpha: 0.2),
                    border: Border.all(
                      color: sessionColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(sessionIcon, color: sessionColor, size: 24),
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
            Row(
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
      children: [
        Icon(icon, size: 16, color: CrimpyTheme.gray600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: CrimpyTheme.gray600, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
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
