import 'package:flutter/material.dart';
import 'package:crimpy/models/training_model.dart';
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
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isYesterday = DateUtils.isSameDay(
      date,
      DateTime.now().subtract(const Duration(days: 1)),
    );

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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: CrimpyTheme.gray700,
            ),
          ),
        ),
        ...sessions.map(
          (session) =>
              SessionCard(session: session, onTap: () => onSessionTap(session)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
