import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/utils/program_completion.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/program_detail_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Home card summarizing the program: today's trainings (with their duration
/// and done state), the flexible "this week" trainings, a countdown before the
/// program starts, or nothing when the user is not enrolled.
class TodayTrainingCard extends ConsumerWidget {
  const TodayTrainingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(activeProgramProvider);
    return programAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (program) {
        if (program == null) return const SizedBox.shrink();

        final daysUntilStart = _daysUntilStart(program.startDate);
        if (daysUntilStart > 0) {
          return _statusCard(
            context,
            program,
            icon: FontAwesomeIcons.clock,
            accent: CrimpyTheme.primaryOrange,
            title: 'STARTS ${_relativeStart(daysUntilStart).toUpperCase()}',
            subtitle: program.name,
          );
        }
        if (!program.isActiveOn(DateTime.now())) return const SizedBox.shrink();
        return _ProgramTodayCard(program: program);
      },
    );
  }

  int _daysUntilStart(DateTime startDate) {
    final now = DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return start.difference(today).inDays;
  }

  String _relativeStart(int days) {
    if (days == 1) return 'tomorrow';
    if (days < 7) return 'in $days days';
    if (days < 14) return 'in 1 week';
    if (days < 30) return 'in ${(days / 7).round()} weeks';
    if (days < 60) return 'in 1 month';
    return 'in ${(days / 30).round()} months';
  }

  Widget _statusCard(
    BuildContext context,
    Program program, {
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CrimpyCard.simple(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ProgramDetailScreen(program))),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                border: Border.all(color: accent, width: 2),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CrimpyTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: CrimpyTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: CrimpyTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// The active program's today + this-week trainings.
class _ProgramTodayCard extends ConsumerWidget {
  final Program program;

  const _ProgramTodayCard({required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWeek = ref.watch(activeProgramWeekProvider).asData?.value;
    if (activeWeek == null) return const SizedBox.shrink();
    final sessions = ref.watch(sessionsProvider).asData?.value ?? [];
    final offset = activeWeek.program.dayOffsetOf(
      activeWeek.weekNumber,
      DateTime.now(),
    );
    final today = activeWeek.week.sessionsOnDay(offset);
    final flex = activeWeek.week.timesPerWeekSessions;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CrimpyCard.simple(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProgramDetailScreen(program)),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                color: CrimpyTheme.primaryOrange,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "TODAY'S TRAINING",
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: CrimpyTheme.bgPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: CrimpyTheme.bgPrimary,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (today.isEmpty)
                    _restRow()
                  else
                    ...today.map(
                      (s) => _TodayTrainingRow(
                        program: program,
                        weekNumber: activeWeek.weekNumber,
                        session: s,
                        sessions: sessions,
                      ),
                    ),
                  if (flex.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    const ProgramSectionLabel('This week'),
                    const SizedBox(height: 8),
                    ...flex.map(
                      (s) => _FlexTrainingRow(
                        program: program,
                        weekNumber: activeWeek.weekNumber,
                        session: s,
                        sessions: sessions,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _restRow() {
    return Row(
      children: [
        Icon(
          FontAwesomeIcons.check,
          size: 16,
          color: CrimpyTheme.statusSuccess,
        ),
        const SizedBox(width: 12),
        const Text(
          'REST DAY - nothing scheduled today',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 12,
            color: CrimpyTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

void _openSession(
  BuildContext context,
  Program program,
  int weekNumber,
  WeekSession session,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ScheduledTrainingScreen(
        program: program,
        weekNumber: weekNumber,
        session: session,
      ),
    ),
  );
}

/// A single training scheduled today: type, title, duration and done state.
class _TodayTrainingRow extends ConsumerWidget {
  final Program program;
  final int weekNumber;
  final WeekSession session;
  final List<SessionModel> sessions;

  const _TodayTrainingRow({
    required this.program,
    required this.weekNumber,
    required this.session,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = session.sessionType;
    final done = isScheduledTrainingDone(
      sessions,
      program,
      weekNumber,
      session,
      date: DateTime.now(),
    );
    final training = ref
        .watch(programTrainingProvider(program.id, session.trainingId))
        .asData
        ?.value;
    final seconds = training == null ? 0 : trainingDurationSeconds(training);

    return InkWell(
      onTap: () => _openSession(context, program, weekNumber, session),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SessionTypeTile(type: type, size: 38),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Text(
                        programSessionLabel(type),
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: programSessionColor(type),
                        ),
                      ),
                      if (seconds > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          formatDurationHMS(seconds),
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 10,
                            color: CrimpyTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _trailing(done),
          ],
        ),
      ),
    );
  }

  Widget _trailing(bool done) {
    if (done) {
      return Icon(
        FontAwesomeIcons.circleCheck,
        size: 24,
        color: CrimpyTheme.statusSuccess,
      );
    }
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CrimpyTheme.primaryOrange,
        border: Border.all(color: CrimpyTheme.borderDefault, width: 2),
      ),
      child: const Icon(
        Icons.play_arrow,
        color: CrimpyTheme.bgPrimary,
        size: 18,
      ),
    );
  }
}

/// A compact "do it N times this week" row with its progress and a start
/// affordance.
class _FlexTrainingRow extends ConsumerWidget {
  final Program program;
  final int weekNumber;
  final WeekSession session;
  final List<SessionModel> sessions;

  const _FlexTrainingRow({
    required this.program,
    required this.weekNumber,
    required this.session,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = session.sessionType;
    final target = session.timesPerWeek ?? 1;
    final done = completionsInWeek(sessions, program, weekNumber, session);

    return InkWell(
      onTap: () => _openSession(context, program, weekNumber, session),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SessionTypeTile(type: type, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                session.trainingTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: CrimpyTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$done/$target',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: done >= target
                    ? CrimpyTheme.statusSuccess
                    : programSessionColor(type),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              FontAwesomeIcons.play,
              size: 13,
              color: done >= target
                  ? CrimpyTheme.textMuted
                  : CrimpyTheme.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}
