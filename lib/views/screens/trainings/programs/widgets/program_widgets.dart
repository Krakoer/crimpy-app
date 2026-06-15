import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Accent color for a session type (reuses SessionType.colorValue).
Color programSessionColor(SessionType type) => Color(type.colorValue);

const _weekdayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // Mon..Sun
const _weekdayShort = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

/// Single-letter label for the real weekday of [date].
String weekdayInitial(DateTime date) => _weekdayInitials[date.weekday - 1];

/// Three-letter label for the real weekday of [date].
String weekdayShort(DateTime date) => _weekdayShort[date.weekday - 1];

/// Short uppercase label for a session type, matching the program design.
String programSessionLabel(SessionType type) => switch (type) {
  SessionType.crimpy => 'HANGBOARD',
  SessionType.climbing => 'CLIMBING',
  SessionType.stretching => 'MOBILITY',
  SessionType.workout => 'WORKOUT',
};

IconData programSessionIcon(SessionType type) => switch (type) {
  SessionType.crimpy => FontAwesomeIcons.fire,
  SessionType.climbing => FontAwesomeIcons.mountain,
  SessionType.stretching => FontAwesomeIcons.personWalking,
  SessionType.workout => FontAwesomeIcons.dumbbell,
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
class SessionTypeTile extends StatelessWidget {
  final SessionType type;
  final double size;

  const SessionTypeTile({required this.type, this.size = 40, super.key});

  @override
  Widget build(BuildContext context) {
    final color = programSessionColor(type);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(programSessionIcon(type), color: color, size: size * 0.45),
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
      ScheduleStatus.due => ('TODAY', CrimpyTheme.primaryOrange),
      ScheduleStatus.upcoming => ('UPCOMING', CrimpyTheme.textMuted),
      ScheduleStatus.past => ('PAST', CrimpyTheme.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(border: Border.all(color: color, width: 1.5)),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}

/// Mono section divider, e.g. "YOUR PROGRAM".
class ProgramSectionLabel extends StatelessWidget {
  final String label;

  const ProgramSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: CrimpyTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 2, color: CrimpyTheme.borderDefault),
          ),
        ],
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
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: CrimpyTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: List.generate(total, (i) {
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(right: i == total - 1 ? 0 : 3),
                decoration: BoxDecoration(
                  color: i < currentWeek
                      ? CrimpyTheme.primaryOrange
                      : CrimpyTheme.bgPrimary,
                  border: Border.all(
                    color: CrimpyTheme.borderDefault,
                    width: 1.5,
                  ),
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
    final type = session.sessionType;
    final color = programSessionColor(type);
    final status = scheduleStatusFor(date, DateTime.now());
    final due = status == ScheduleStatus.due && !done;
    final borderColor = due
        ? CrimpyTheme.primaryOrange
        : CrimpyTheme.borderDefault;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: borderColor, offset: const Offset(2, 2)),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: CrimpyTheme.bgPrimary,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              SessionTypeTile(type: type, size: 38),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.trainingTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: done
                            ? CrimpyTheme.textMuted
                            : CrimpyTheme.textPrimary,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programSessionLabel(type),
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (done)
                Icon(
                  FontAwesomeIcons.circleCheck,
                  size: 20,
                  color: CrimpyTheme.statusSuccess,
                )
              else
                ScheduleStatusTag(status: status),
            ],
          ),
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
    final type = session.sessionType;
    final color = programSessionColor(type);
    final times = session.timesPerWeek ?? 0;
    final complete = doneCount >= times;

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [6, 4],
          strokeWidth: 2,
          radius: Radius.zero,
          color: CrimpyTheme.borderDefault,
        ),
        child: Container(
          color: CrimpyTheme.bgPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SessionTypeTile(type: type, size: 34),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.trainingTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: CrimpyTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programSessionLabel(type),
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    complete ? 'DONE' : '$doneCount/${times}x',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: complete ? CrimpyTheme.statusSuccess : color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      times,
                      (i) => Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
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
