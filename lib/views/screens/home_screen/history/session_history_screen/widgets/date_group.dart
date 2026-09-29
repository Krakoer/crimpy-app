import 'package:flutter/material.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';
import 'session_card.dart';

class DateGroup extends StatelessWidget {
  final DateTime date;
  final List<SessionModel> sessions;
  final Function(SessionModel) onSessionTap;

  const DateGroup({
    super.key,
    required this.date,
    required this.sessions,
    required this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = currentTrainingDay();
    final isToday = DateUtils.isSameDay(date, today);
    final isYesterday = DateUtils.isSameDay(date, addCalendarDays(today, -1));

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('EEEE, MMMM d, y').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceSm),
          child: Text(
            dateLabel,
            style: CrimpyTheme.title.copyWith(
              fontWeight: FontWeight.bold,
              color: CrimpyTheme.textStrong,
            ),
          ),
        ),
        ...sessions.map(
          (session) =>
              SessionCard(session: session, onTap: () => onSessionTap(session)),
        ),
        const SizedBox(height: CrimpyTheme.spaceLg),
      ],
    );
  }
}
