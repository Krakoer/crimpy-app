import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/duration_format.dart';
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

    return CrimpyCard.simple(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Session type icon
          CategoryIconTile(icon: sessionIcon, category: sessionColor),
          const SizedBox(width: 16),
          // Session details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: CrimpyTheme.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: CrimpyTheme.textMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: CrimpyTheme.bodySmall.copyWith(
                        color: CrimpyTheme.textMedium,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer, size: 14, color: CrimpyTheme.textMedium),
                    const SizedBox(width: 4),
                    Text(
                      formatLength(duration),
                      style: CrimpyTheme.bodySmall.copyWith(
                        color: CrimpyTheme.textMedium,
                      ),
                    ),
                  ],
                ),
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.notes!,
                    style: CrimpyTheme.bodySmall.copyWith(
                      color: CrimpyTheme.textStrong,
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
              color: CrimpyTheme.coachNote,
            ),
            const SizedBox(width: 8),
          ],
          // Arrow indicator
          Icon(Icons.chevron_right, color: CrimpyTheme.textFaint),
        ],
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
}
