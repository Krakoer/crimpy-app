import 'package:crimpy/utils/datetimes.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/duration_format.dart';
import 'package:intl/intl.dart';

class WeekHistogramWidget extends StatelessWidget {
  final List<SessionModel> sessions;
  final Color textColor;
  final double maxBarHeight;
  final DateTime? startOfWeek;

  /// Widget that displays the given sessions as a week histogram, from monday to sunday.
  const WeekHistogramWidget({
    super.key,
    required this.sessions,
    this.textColor = CrimpyTheme.textPrimary,
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
              final DateTime currentDay = addCalendarDays(monday, dayIndex);
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
    final String durationText = formatLength(totalDuration);
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
            color: CrimpyTheme.activityColor(
              activity,
            ).withValues(alpha: isToday ? 1 : 0.7),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A day with nothing logged carries no label: a week of "0 min"
          // reads as a row of numbers to look through for the days that
          // count. The columns sit on their day names, so the bars stay
          // aligned without it.
          if (totalDuration > Duration.zero) ...[
            // A day's column is a seventh of the card, about 42dp on a 360dp
            // phone, and "1 h 30 min" is wider than that. It shrinks to fit
            // on one line rather than wrapping out of the column.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                durationText,
                maxLines: 1,
                style: CrimpyTheme.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          // Draw the stacked bar
          SizedBox(
            width: 24,
            child: ClipRRect(
              borderRadius: CrimpyTheme.corners,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: barSegments.reversed.toList(),
              ),
            ),
          ),
          const SizedBox(height: CrimpyTheme.spaceSm),
          // Day of the week text
          Text(
            dayName,
            style: CrimpyTheme.body.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          // Highlight for the current day
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: CrimpyTheme.spaceXs),
            decoration: isToday
                ? const BoxDecoration(
                    color: CrimpyTheme.current,
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
      final int dayDifference = calendarDaysBetween(startOfWeek, entryDate);
      if (dayDifference >= 0 && dayDifference < 7) {
        durationsPerDay[dayDifference][activity] =
            (durationsPerDay[dayDifference][activity] ?? Duration.zero) +
            entryDuration;
      }
    }

    return durationsPerDay;
  }
}
