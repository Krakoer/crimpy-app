import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/duration_format.dart';
import 'package:crimpy/utils/program_completion.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/program_detail_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:crimpy/utils/datetimes.dart';

/// Home card summarizing the program: today's trainings (with their duration
/// and done state), the flexible "this week" trainings, a countdown before the
/// program starts, or nothing when the user is not enrolled.
class TodayTrainingCard extends ConsumerWidget {
  const TodayTrainingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(activeProgramProvider);
    // Skips both arms while what is being reloaded is what this card is
    // already showing: a pull would otherwise take today's training off the
    // dashboard for as long as the fetch runs, and a failed one would leave it
    // off until some later fetch succeeded.
    return programAsync.when(
      skipLoadingOnReload: true,
      skipError: true,
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
            accent: CrimpyTheme.current,
            title: 'STARTS ${_relativeStart(daysUntilStart).toUpperCase()}',
            subtitle: program.name,
          );
        }
        if (!program.isActiveOn(DateTime.now())) return const SizedBox.shrink();
        return _ProgramTodayCard(program: program);
      },
    );
  }

  int _daysUntilStart(DateTime startDate) =>
      calendarDaysBetween(DateTime.now(), startDate);

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
    return CrimpyCard.simple(
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
              color: CrimpyTheme.tintOf(accent),
              border: Border.all(color: accent, width: 2),
            ),
            child: Icon(icon, color: CrimpyTheme.textOn(accent), size: 18),
          ),
          const SizedBox(width: CrimpyTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CrimpyTheme.titleSmall.copyWith(
                    color: CrimpyTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CrimpyTheme.bodySmall.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: CrimpyTheme.textSecondary,
          ),
        ],
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
    // Read off what the state holds. A pull invalidates what this week is
    // derived from, so through asData it reads as no week at all and the card
    // the athlete is looking at empties itself for the length of the fetch.
    final activeWeek = ref.watch(activeProgramWeekProvider).value;
    if (activeWeek == null) return const SizedBox.shrink();
    // Same for the sessions: through asData a failed pull loses them, and
    // every training already completed today loses its done mark.
    final sessions = ref.watch(sessionsProvider).value ?? [];
    final offset = activeWeek.program.dayOffsetOf(
      activeWeek.weekNumber,
      DateTime.now(),
    );
    final today = activeWeek.week.sessionsOnDay(offset);
    final flex = activeWeek.week.timesPerWeekSessions;

    return CrimpyCard.simple(
      raised: true,
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
                horizontal: CrimpyTheme.spaceLg,
                vertical: CrimpyTheme.spaceSm,
              ),
              color: CrimpyTheme.fillOn(CrimpyTheme.current),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "TODAY'S TRAINING",
                      style: CrimpyTheme.capsLabel.copyWith(
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
            padding: CrimpyTheme.cardPadding,
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
                  const SizedBox(height: CrimpyTheme.spaceSm),
                  const SectionLabel('This week'),
                  const SizedBox(height: CrimpyTheme.spaceSm),
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
    );
  }

  Widget _restRow() {
    return Row(
      children: [
        Icon(FontAwesomeIcons.check, size: 16, color: CrimpyTheme.done),
        const SizedBox(width: CrimpyTheme.spaceMd),
        Text(
          'REST DAY - nothing scheduled today',
          style: CrimpyTheme.bodySmall.copyWith(
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
    final type = session.activity;
    final done = isScheduledTrainingDone(
      sessions,
      program,
      weekNumber,
      session,
      date: DateTime.now(),
    );
    // Read off what the state holds, like everything else this card reads: a
    // pull reloads it and the duration would otherwise fall back mid gesture.
    final training = ref
        .watch(programTrainingProvider(program.id, session.trainingId))
        .value;
    // Estimated from the training as this week prescribes it, so a retimed
    // plank or a slowed emom moves the number the athlete reads here. The
    // athlete's results go in too: a week can retime a step as a percentage of
    // an assessment, and without them that step reads as the coach's fallback
    // here while the run plays the resolved number.
    final merged = training == null
        ? null
        : effectiveTraining(training, session.overrides);
    final seconds = merged == null
        ? 0
        : trainingDurationSeconds(
            merged,
            results:
                (ref.watch(assessmentResultsProvider).value ??
                        AssessmentResults.none)
                    .withDefinitions(merged.referencedAssessments),
          );

    return InkWell(
      onTap: () => _openSession(context, program, weekNumber, session),
      // A row is a tap target, so it never drops under the 48dp minimum.
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceSm),
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
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Text(
                        programSessionLabel(type),
                        style: CrimpyTheme.labelSmall.copyWith(
                          color: CrimpyTheme.textSecondary,
                        ),
                      ),
                      if (seconds > 0) ...[
                        const SizedBox(width: CrimpyTheme.spaceSm),
                        Text(
                          formatLength(Duration(seconds: seconds)),
                          style: CrimpyTheme.labelSmall.copyWith(
                            color: CrimpyTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
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
        color: CrimpyTheme.done,
      );
    }
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CrimpyTheme.fillOn(CrimpyTheme.action),
        border: Border.all(color: CrimpyTheme.outline, width: 2),
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
    final type = session.activity;
    final target = session.timesPerWeek ?? 1;
    final done = completionsInWeek(sessions, program, weekNumber, session);

    return InkWell(
      onTap: () => _openSession(context, program, weekNumber, session),
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceXs),
        child: Row(
          children: [
            SessionActivityTile(type: type, size: 28),
            const SizedBox(width: CrimpyTheme.spaceSm),
            Expanded(
              child: Text(
                session.trainingTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CrimpyTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CrimpyTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
            Text(
              '$done/$target',
              style: CrimpyTheme.labelSmall.copyWith(
                color: done >= target
                    ? CrimpyTheme.textOn(CrimpyTheme.done)
                    : CrimpyTheme.textSecondary,
              ),
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
            Icon(
              FontAwesomeIcons.play,
              size: 13,
              // The card's filled Play is its primary action; this one is a
              // quieter way in to the same kind of run.
              color: done >= target
                  ? CrimpyTheme.textMutedSmall
                  : CrimpyTheme.control,
            ),
          ],
        ),
      ),
    );
  }
}
