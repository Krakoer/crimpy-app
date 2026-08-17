import 'package:crimpy/utils/datetimes.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class WeekHistogramWidget extends StatelessWidget {
  final List<SessionModel> sessions;
  final Color barColor;
  final Color textColor;
  final double maxBarHeight;
  final DateTime? startOfWeek;

  /// Widget that displays the given sessions as a week histogram, from monday to sunday.
  const WeekHistogramWidget({
    super.key,
    required this.sessions,
    this.barColor = CrimpyTheme.accentOrange,
    this.textColor = CrimpyTheme.primaryBlack,
    this.maxBarHeight = 200.0,
    this.startOfWeek,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime monday = startOfWeek ?? getStartOfWeek(DateTime.now());

    // Compute duration for each day of the week, grouped by session type
    final List<Map<SessionActivity, Duration>> durationsPerDay =
        _calculateDurationsPerDayByType(monday);

    // Find maximum total duration for scaling
    final Duration maxDuration = durationsPerDay.fold(Duration.zero, (
      prev,
      dayData,
    ) {
      final dayTotal = dayData.values.fold(Duration.zero, (sum, d) => sum + d);
      return dayTotal > prev ? dayTotal : prev;
    });

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
              final Map<SessionActivity, Duration> dayDurations =
                  durationsPerDay[dayIndex];
              final Duration totalDuration = dayDurations.values.fold(
                Duration.zero,
                (sum, d) => sum + d,
              );

              return _buildDayBar(
                context,
                currentDay,
                dayDurations,
                totalDuration,
                maxDuration,
              );
            }),
          ),
        ),
      ],
    );
  }

  /// Returns a widget representing a vertical stacked bar with different colors for different session types.
  Widget _buildDayBar(
    BuildContext context,
    DateTime day,
    Map<SessionActivity, Duration> dayDurations,
    Duration totalDuration,
    Duration maxDuration,
  ) {
    // Format day name and duration
    final String dayName = DateFormat('E').format(day); // Mon, Tue, etc.
    final String durationText = _formatDuration(totalDuration);
    final bool isToday = DateUtils.isSameDay(day, DateTime.now());

    // Build stacked bar segments
    List<Widget> barSegments = [];
    for (final entry in dayDurations.entries) {
      final activity = entry.key;
      final duration = entry.value;
      final segmentHeightPercentage = maxDuration.inSeconds > 0
          ? duration.inSeconds / maxDuration.inSeconds
          : 0.0;

      barSegments.add(
        Container(
          height: maxBarHeight * segmentHeightPercentage,
          width: 24,
          decoration: BoxDecoration(
            color: Color(
              activity.colorValue,
            ).withValues(alpha: isToday ? 1 : 0.7),
          ),
        ),
      );
    }

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
          // Draw the stacked bar
          Container(
            width: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              // Draw a slight shadow for current day
              boxShadow: isToday
                  ? [
                      const BoxShadow(
                        color: Color(0x4D000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: barSegments.reversed.toList(),
              ),
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
            decoration: isToday
                ? const BoxDecoration(
                    color: CrimpyTheme.primaryOrange,
                    shape: BoxShape.circle,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  /// Returns a list of maps representing the sum of session durations grouped by type for each day of the week.
  List<Map<SessionActivity, Duration>> _calculateDurationsPerDayByType(
    DateTime startOfWeek,
  ) {
    List<Map<SessionActivity, Duration>> durationsPerDay = List.generate(
      7,
      (_) => <SessionActivity, Duration>{},
    );

    for (final entry in sessions) {
      final DateTime entryDate = entry.date;
      final Duration entryDuration = Duration(seconds: entry.duration);
      final SessionActivity activity = entry.activity;

      // Check if entry is within current week
      final int dayDifference = _daysBetween(startOfWeek, entryDate);
      if (dayDifference >= 0 && dayDifference < 7) {
        durationsPerDay[dayDifference][activity] =
            (durationsPerDay[dayDifference][activity] ?? Duration.zero) +
            entryDuration;
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
