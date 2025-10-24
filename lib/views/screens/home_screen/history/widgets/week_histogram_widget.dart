import 'package:crimpy/utils/datetimes.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class WeekHistogramWidget extends StatelessWidget {
  final List<SessionModel> sessions;
  final Color barColor;
  final Color textColor;
  final double maxBarHeight;

  /// Widget that displays the given sessions as a week histogram, from monday to sunday.
  const WeekHistogramWidget({
    super.key,
    required this.sessions,
    this.barColor = CrimpyTheme.accentOrange,
    this.textColor = CrimpyTheme.primaryBlack,
    this.maxBarHeight = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime monday = getStartOfWeek(now);

    // Compute duration for each day of the week
    final List<Duration> durationsPerDay = _calculateDurationsPerDay(monday);

    // Find maximum duration for scaling
    final Duration maxDuration = durationsPerDay.fold(
      Duration.zero,
      (prev, d) => d > prev ? d : prev,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: maxBarHeight + 66, // Added space for labels
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // Draw the bars
            children: List.generate(7, (dayIndex) {
              final DateTime currentDay = monday.add(Duration(days: dayIndex));
              final Duration duration = durationsPerDay[dayIndex];
              final double heightPercentage =
                  maxDuration.inSeconds > 0
                      ? duration.inSeconds / maxDuration.inSeconds
                      : 0.0;

              return _buildDayBar(
                context,
                currentDay,
                duration,
                heightPercentage,
              );
            }),
          ),
        ),
      ],
    );
  }

  /// Returns a widget representing a vertical bar if size `maxBarHeight*heightPercentage`, with the day of the week below, and the duration formated above the bar.
  Widget _buildDayBar(
    BuildContext context,
    DateTime day,
    Duration duration,
    double heightPercentage,
  ) {
    // Format day name and duration
    final String dayName = DateFormat('E').format(day); // Mon, Tue, etc.
    final String durationText = _formatDuration(duration);
    final bool isToday = DateUtils.isSameDay(day, DateTime.now());

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duration is above
          Text(
            durationText,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          // Draw the bar, with slightly transparancy for other days than today.
          Container(
            height: maxBarHeight * heightPercentage,
            width: 24,
            decoration: BoxDecoration(
              color:
                  isToday ? barColor.withValues(alpha: 1.0) : barColor.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
              // Draw a slight shadow for current day
              boxShadow:
                  isToday
                      ? [
                        BoxShadow(
                          color: barColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
          ),
          const SizedBox(height: 8),
          // Day of the week text
          Text(
            dayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          // Highlight for the current day
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 4),
            decoration:
                isToday
                    ? BoxDecoration(color: barColor, shape: BoxShape.circle)
                    : null,
          ),
        ],
      ),
    );
  }

  /// Returns a list of `Duration` representing the sum of the sessions lengths for each day for 7 days after the given day.
  List<Duration> _calculateDurationsPerDay(DateTime startOfWeek) {
    List<Duration> durationsPerDay = List.generate(7, (_) => Duration.zero);

    for (final entry in sessions) {
      final DateTime entryDate = entry.date;
      final Duration entryDuration = Duration(seconds: entry.duration);

      // Check if entry is within current week
      final int dayDifference = _daysBetween(startOfWeek, entryDate);
      if (dayDifference >= 0 && dayDifference < 7) {
        durationsPerDay[dayDifference] += entryDuration;
      }
    }

    return durationsPerDay;
  }

  /// Returns the number of days between two given dates.
  int _daysBetween(DateTime from, DateTime to) {
    // Remove hours and minutes
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inDays);
  }

  /// Format duration as HH:MM
  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
