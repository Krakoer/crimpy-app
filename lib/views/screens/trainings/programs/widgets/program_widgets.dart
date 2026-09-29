import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Accent color for a session type (reuses SessionActivity.colorValue).
Color programSessionColor(SessionActivity type) =>
    CrimpyTheme.activityColor(type);

const _weekdayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // Mon..Sun
const _weekdayShort = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

/// Single-letter label for the real weekday of [date].
String weekdayInitial(DateTime date) => _weekdayInitials[date.weekday - 1];

/// Three-letter label for the real weekday of [date].
String weekdayShort(DateTime date) => _weekdayShort[date.weekday - 1];

/// Short uppercase label for a session type, matching the program design.
String programSessionLabel(SessionActivity type) => switch (type) {
  SessionActivity.hangboard => 'HANGBOARD',
  SessionActivity.climbing => 'CLIMBING',
  SessionActivity.stretching => 'MOBILITY',
  SessionActivity.workout => 'WORKOUT',
  SessionActivity.other => 'OTHER',
};

IconData programSessionIcon(SessionActivity type) => switch (type) {
  SessionActivity.hangboard => FontAwesomeIcons.fire,
  SessionActivity.climbing => FontAwesomeIcons.mountain,
  SessionActivity.stretching => FontAwesomeIcons.personWalking,
  SessionActivity.workout => FontAwesomeIcons.dumbbell,
  SessionActivity.other => FontAwesomeIcons.personRunning,
};

/// Date-based status of a scheduled session. The coachee API exposes no
/// completion link, so we only distinguish today / upcoming / past.
enum ScheduleStatus { due, upcoming, past }

ScheduleStatus scheduleStatusFor(DateTime? date, DateTime today) {
  if (date == null) return ScheduleStatus.upcoming;
  final d = DateTime(date.year, date.month, date.day);
  final t = DateTime(today.year, today.month, today.day);
  if (d == t) return ScheduleStatus.due;
  return d.isBefore(t) ? ScheduleStatus.past : ScheduleStatus.upcoming;
}

/// Square bordered icon tile tinted by the session type.
class SessionActivityTile extends StatelessWidget {
  final SessionActivity type;
  final double size;

  const SessionActivityTile({required this.type, this.size = 40, super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryIconTile(
      icon: programSessionIcon(type),
      category: programSessionColor(type),
      iconSize: size * 0.45,
      size: size,
    );
  }
}

/// Small uppercase status chip (TODAY / UPCOMING / PAST).
class ScheduleStatusTag extends StatelessWidget {
  final ScheduleStatus status;

  const ScheduleStatusTag({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ScheduleStatus.due => ('TODAY', CrimpyTheme.current),
      ScheduleStatus.upcoming => ('UPCOMING', CrimpyTheme.textMutedSmall),
      ScheduleStatus.past => ('PAST', CrimpyTheme.textMutedSmall),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceSm,
        vertical: CrimpyTheme.spaceXs,
      ),
      decoration: BoxDecoration(border: Border.all(color: color, width: 1.5)),
      child: Text(
        label,
        style: CrimpyTheme.labelSmall.copyWith(
          color: CrimpyTheme.textOn(color),
        ),
      ),
    );
  }
}

/// Segmented week-progress bar: "WEEK x / total" + colored ticks.
class WeekProgressBar extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;

  const WeekProgressBar({
    required this.currentWeek,
    required this.totalWeeks,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalWeeks < 1 ? 1 : totalWeeks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEEK $currentWeek / $total',
          style: CrimpyTheme.capsLabel.copyWith(color: CrimpyTheme.textPrimary),
        ),
        const SizedBox(height: CrimpyTheme.spaceSm),
        Row(
          children: List.generate(total, (i) {
            final isLast = i == total - 1;
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(
                  right: isLast ? 0 : CrimpyTheme.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: i < currentWeek
                      ? CrimpyTheme.control
                      : CrimpyTheme.bgPrimary,
                  border: Border.all(color: CrimpyTheme.outline, width: 1.5),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// A row for a scheduled training: type tile, title, type + duration, status.
class ScheduledTrainingRow extends StatelessWidget {
  final WeekSession session;
  final DateTime? date;
  final bool done;
  final VoidCallback? onTap;

  const ScheduledTrainingRow({
    required this.session,
    this.date,
    this.done = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final type = session.activity;
    final status = scheduleStatusFor(date, currentTrainingDay());
    final due = status == ScheduleStatus.due && !done;
    final surface = onTap != null || due
        ? CrimpyTheme.raised
        : CrimpyTheme.flat;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CrimpyTheme.spaceMd,
          vertical: CrimpyTheme.spaceMd,
        ),
        // Due today reads by weight now that it has no hue of its own.
        decoration: due
            ? surface.copyWith(
                border: Border.all(color: CrimpyTheme.current, width: 3),
              )
            : surface,
        child: Row(
          children: [
            SessionActivityTile(type: type, size: 38),
            const SizedBox(width: CrimpyTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.trainingTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CrimpyTheme.titleSmall.copyWith(
                      color: done
                          ? CrimpyTheme.textMutedSmall
                          : CrimpyTheme.textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: CrimpyTheme.spaceXs),
                  Text(
                    programSessionLabel(type),
                    style: CrimpyTheme.labelSmall.copyWith(
                      color: CrimpyTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
            if (done)
              Icon(
                FontAwesomeIcons.circleCheck,
                size: 20,
                color: CrimpyTheme.done,
              )
            else
              ScheduleStatusTag(status: status),
          ],
        ),
      ),
    );
  }
}

/// A "do it N times this week" training, shown with a dashed border and a row
/// of frequency pips filled up to [doneCount].
class FlexTrainingRow extends StatelessWidget {
  final WeekSession session;
  final int doneCount;
  final VoidCallback? onTap;

  const FlexTrainingRow({
    required this.session,
    this.doneCount = 0,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final type = session.activity;
    final color = programSessionColor(type);
    // An unset target still means "do it once", never "already done".
    final times = session.timesPerWeek ?? 1;
    final complete = doneCount >= times;

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [6, 4],
          strokeWidth: 2,
          radius: CrimpyTheme.corner,
          color: CrimpyTheme.outline,
        ),
        child: Container(
          color: CrimpyTheme.bgPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: CrimpyTheme.spaceMd,
            vertical: CrimpyTheme.spaceMd,
          ),
          child: Row(
            children: [
              SessionActivityTile(type: type, size: 34),
              const SizedBox(width: CrimpyTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.trainingTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CrimpyTheme.titleSmall.copyWith(
                        color: CrimpyTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: CrimpyTheme.spaceXs),
                    Text(
                      programSessionLabel(type),
                      style: CrimpyTheme.labelSmall.copyWith(
                        color: CrimpyTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CrimpyTheme.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    complete ? 'DONE' : '$doneCount/${times}x',
                    style: CrimpyTheme.labelSmall.copyWith(
                      color: complete
                          ? CrimpyTheme.textOn(CrimpyTheme.done)
                          : CrimpyTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: CrimpyTheme.spaceXs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      times,
                      (i) => Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(
                          left: i == 0 ? 0 : CrimpyTheme.spaceXs,
                        ),
                        decoration: BoxDecoration(
                          color: i < doneCount ? color : null,
                          border: Border.all(color: color, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
