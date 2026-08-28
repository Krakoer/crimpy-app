import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;

  const SessionCard({super.key, required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: session.duration);
    final formattedTime = DateFormat('HH:mm').format(session.date);
    final sessionColor = CrimpyTheme.activityColor(session.activity);
    final sessionIcon = _getSessionIcon(session.activity);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Session type icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sessionColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: sessionColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(sessionIcon, color: sessionColor, size: 20),
              ),
              const SizedBox(width: 16),
              // Session details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: CrimpyTheme.gray600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: CrimpyTheme.gray600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.timer, size: 14, color: CrimpyTheme.gray600),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color: CrimpyTheme.gray600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (session.notes != null && session.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        session.notes!,
                        style: TextStyle(
                          color: CrimpyTheme.gray700,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // An answer from the coach the athlete has not opened yet. Shown
              // on the row rather than only inside the session, so it can be
              // found without opening every one.
              if (session.hasUnreadCoachReply) ...[
                Icon(
                  Icons.mark_chat_unread,
                  size: 18,
                  color: CrimpyTheme.primaryOrange,
                ),
                const SizedBox(width: 8),
              ],
              // Arrow indicator
              Icon(Icons.chevron_right, color: CrimpyTheme.gray400),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSessionIcon(SessionActivity activity) {
    return switch (activity) {
      SessionActivity.hangboard => Icons.fitness_center,
      SessionActivity.climbing => Icons.terrain,
      SessionActivity.stretching => Icons.self_improvement,
      SessionActivity.workout => Icons.fitness_center,
      SessionActivity.other => Icons.directions_run,
    };
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
