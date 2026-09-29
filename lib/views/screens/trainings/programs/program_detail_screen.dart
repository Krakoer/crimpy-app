import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/utils/program_completion.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/pull_to_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:crimpy/utils/datetimes.dart';

/// Program overview: header, week selector and a week-strip / calendar schedule.
class ProgramDetailScreen extends ConsumerStatefulWidget {
  final Program program;

  const ProgramDetailScreen(this.program, {super.key});

  @override
  ConsumerState<ProgramDetailScreen> createState() =>
      _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  late int _selectedWeek;
  bool _calendar = false;

  Program get program => widget.program;

  int get _totalWeeks => program.durationWeeks ?? 1;

  @override
  void initState() {
    super.initState();
    _selectedWeek = program.isActiveOn(currentTrainingDay())
        ? program.currentWeekNumber(currentTrainingDay())
        : 1;
    if (_selectedWeek > _totalWeeks) _selectedWeek = 1;
  }

  void _openSession(WeekSession session, int weekNumber) {
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

  @override
  Widget build(BuildContext context) {
    final weeksAsync = ref.watch(programWeeksProvider(program.id));
    // Read off what the state holds. A pull that fails carries the summaries it
    // already had, and reading them through asData would answer that the coach
    // defined no week at all: every week greyed out and untappable, and a
    // calendar drawn as an empty program, over a snackbar that has gone.
    final definedWeeks = weeksAsync.value?.map((w) => w.weekNumber).toSet();
    // The phase comes off the summaries rather than off each week's own detail:
    // the summaries are already here by the time a row is painted, while the
    // details arrive one by one, and a calendar whose rows grow as they land
    // moves the square the athlete is reaching for.
    final weekPhases = {
      for (final week in weeksAsync.value ?? const <WeekSummary>[])
        week.weekNumber: week.name,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Program')),
      body: SafeArea(
        // The coach writes this program while the athlete has it open, so a
        // pull is the only way to see the week they just changed. The week
        // details are a family, invalidated whole: the screen scrolls through
        // more than one of them.
        child: PullToRefresh(
          onRefresh: () async {
            ref.invalidate(weekDetailProvider);
            ref.invalidate(programTrainingProvider);
            await Future.wait([
              ref.refresh(programWeeksProvider(program.id).future),
              ref.refresh(sessionsProvider.future),
              // The week bodies are what the pull exists to fetch and are
              // slower than the summaries, so the indicator waits for the ones
              // on screen: every defined week in the calendar, the selected one
              // in the week view.
              for (final week
                  in _calendar
                      ? (definedWeeks ?? {_selectedWeek})
                      : {_selectedWeek})
                ref.read(weekDetailProvider(program.id, week).future),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
            children: [
              _header(),
              const SizedBox(height: CrimpyTheme.spaceLg),
              _viewToggle(),
              const SizedBox(height: CrimpyTheme.spaceLg),
              if (_calendar)
                _CalendarView(
                  program: program,
                  definedWeeks: definedWeeks ?? {},
                  weekPhases: weekPhases,
                  totalWeeks: _totalWeeks,
                  onOpen: _openSession,
                )
              else ...[
                _weekSelector(definedWeeks),
                const SizedBox(height: CrimpyTheme.spaceLg),
                _WeekStripView(
                  program: program,
                  weekNumber: _selectedWeek,
                  onOpen: _openSession,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final start = formatDayMonth(program.startDate);
    final end = program.endDate;
    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            program.name,
            style: CrimpyTheme.titleSmall.copyWith(
              color: CrimpyTheme.textPrimary,
            ),
          ),
          if ((program.objective ?? '').isNotEmpty) ...[
            const SizedBox(height: CrimpyTheme.spaceSm),
            Text(
              program.objective!,
              style: CrimpyTheme.body.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: CrimpyTheme.spaceMd),
          _tag(
            FontAwesomeIcons.calendar,
            end == null ? start : '$start - ${formatDayMonth(end)}',
          ),
          const SizedBox(height: CrimpyTheme.spaceLg),
          const Divider(thickness: 2, height: 2),
          const SizedBox(height: CrimpyTheme.spaceLg),
          WeekProgressBar(
            currentWeek: program.isActiveOn(currentTrainingDay())
                ? program.currentWeekNumber(currentTrainingDay())
                : 0,
            totalWeeks: _totalWeeks,
          ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceSm,
        vertical: CrimpyTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: CrimpyTheme.outline, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: CrimpyTheme.textPrimary),
          const SizedBox(width: CrimpyTheme.spaceXs),
          Text(label, style: CrimpyTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _viewToggle() {
    Widget button(String label, bool calendar) {
      final selected = _calendar == calendar;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _calendar = calendar),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceMd),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? CrimpyTheme.fillOn(CrimpyTheme.control)
                  : CrimpyTheme.bgPrimary,
              border: Border.all(color: CrimpyTheme.outline, width: 2),
            ),
            child: Text(
              label,
              style: CrimpyTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? CrimpyTheme.bgPrimary
                    : CrimpyTheme.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        button('WEEK', false),
        const SizedBox(width: CrimpyTheme.spaceSm),
        button('CALENDAR', true),
      ],
    );
  }

  Widget _weekSelector(Set<int>? definedWeeks) {
    final current = program.isActiveOn(currentTrainingDay())
        ? program.currentWeekNumber(currentTrainingDay())
        : 0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_totalWeeks, (i) {
          final week = i + 1;
          final defined = definedWeeks?.contains(week) ?? false;
          final selected = week == _selectedWeek;
          return Padding(
            padding: const EdgeInsets.only(right: CrimpyTheme.spaceSm),
            child: GestureDetector(
              onTap: defined
                  ? () => setState(() => _selectedWeek = week)
                  : null,
              child: Opacity(
                opacity: defined ? 1 : 0.4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CrimpyTheme.spaceMd,
                    vertical: CrimpyTheme.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? CrimpyTheme.fillOn(CrimpyTheme.control)
                        : CrimpyTheme.bgPrimary,
                    border: Border.all(color: CrimpyTheme.outline, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'WEEK $week',
                        style: CrimpyTheme.capsLabel.copyWith(
                          color: selected
                              ? CrimpyTheme.bgPrimary
                              : CrimpyTheme.textPrimary,
                        ),
                      ),
                      if (week == current) ...[
                        const SizedBox(width: CrimpyTheme.spaceSm),
                        Container(
                          width: 6,
                          height: 6,
                          color: selected
                              ? CrimpyTheme.bgPrimary
                              : CrimpyTheme.current,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Horizontal day picker for a week plus the selected day's training.
class _WeekStripView extends ConsumerStatefulWidget {
  final Program program;
  final int weekNumber;
  final void Function(WeekSession, int) onOpen;

  const _WeekStripView({
    required this.program,
    required this.weekNumber,
    required this.onOpen,
  });

  @override
  ConsumerState<_WeekStripView> createState() => _WeekStripViewState();
}

class _WeekStripViewState extends ConsumerState<_WeekStripView> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final weekAsync = ref.watch(
      weekDetailProvider(widget.program.id, widget.weekNumber),
    );

    // Skips both arms while what is being reloaded or refused is the week
    // already on screen: a pull would otherwise replace the week the athlete is
    // reading with a spinner, and a failed one with an error where their
    // sessions were.
    return weekAsync.when(
      skipLoadingOnReload: true,
      skipError: true,
      loading: () => const Padding(
        padding: EdgeInsets.all(CrimpyTheme.spaceXl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Could not load week.\n$e'),
      data: (week) {
        if (week == null) return _notPlanned();

        final today = currentTrainingDay();
        // Each day carries its day-specific sessions plus the everyday ones.
        final byDay = {for (var d = 0; d < 7; d++) d: week.sessionsOnDay(d)};
        // day_of_week is an offset from the week start, so find today's column
        // by its actual date rather than by the calendar weekday.
        final todayCol = widget.program.dayOffsetOf(widget.weekNumber, today);
        final todayInWeek = todayCol >= 0 && todayCol < 7;

        final selected =
            _selectedDay ??
            (todayInWeek
                ? todayCol
                : List.generate(
                    7,
                    (d) => d,
                  ).firstWhere((d) => byDay[d]!.isNotEmpty, orElse: () => 0));

        final selectedSessions = byDay[selected]!;
        final selectedDate = _dateForDay(selected);
        final timesPerWeek = week.timesPerWeekSessions;
        final sessions = ref.watch(sessionsProvider).value ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The phase heads the week: what the block trains is the frame the
            // coach note and the days below are read in.
            //
            // Read off the week detail here, while the calendar reads it off
            // the week list, and the two are not to be unified: this whole
            // body already waits on the detail, so it has no jump to avoid,
            // while a calendar row would grow under the athlete's finger as
            // each week's detail landed.
            if ((week.name ?? '').isNotEmpty) ...[
              SectionLabel(week.name!),
              const SizedBox(height: CrimpyTheme.spaceMd),
            ],
            if ((week.notes ?? '').isNotEmpty) ...[
              _weekNote(week.notes!),
              const SizedBox(height: CrimpyTheme.spaceLg),
            ],
            _dayPicker(byDay, selected),
            const SizedBox(height: CrimpyTheme.spaceLg),
            Text(
              isSameDay(selectedDate, today)
                  ? 'TODAY - ${formatDayMonth(selectedDate)}'
                  : '${weekdayShort(selectedDate)} - ${formatDayMonth(selectedDate)}',
              style: CrimpyTheme.capsLabel.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
            const SizedBox(height: CrimpyTheme.spaceSm),
            if (selectedSessions.isEmpty)
              _restDay()
            else
              ...selectedSessions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: CrimpyTheme.spaceMd),
                  child: ScheduledTrainingRow(
                    session: s,
                    date: selectedDate,
                    done: isScheduledTrainingDone(
                      sessions,
                      widget.program,
                      widget.weekNumber,
                      s,
                      date: selectedDate,
                    ),
                    onTap: () => widget.onOpen(s, widget.weekNumber),
                  ),
                ),
              ),
            if (timesPerWeek.isNotEmpty) ...[
              const SizedBox(height: CrimpyTheme.spaceLg),
              const SectionLabel('Any day this week'),
              const SizedBox(height: CrimpyTheme.spaceMd),
              ...timesPerWeek.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: CrimpyTheme.spaceMd),
                  child: FlexTrainingRow(
                    session: s,
                    doneCount: completionsInWeek(
                      sessions,
                      widget.program,
                      widget.weekNumber,
                      s,
                    ),
                    onTap: () => widget.onOpen(s, widget.weekNumber),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  DateTime _dateForDay(int dayOfWeek) =>
      addCalendarDays(widget.program.weekStart(widget.weekNumber), dayOfWeek);

  Widget _dayPicker(Map<int, List<WeekSession>> byDay, int selected) {
    final today = currentTrainingDay();
    return Row(
      children: List.generate(7, (d) {
        final daySessions = byDay[d]!;
        final date = _dateForDay(d);
        final isSelected = d == selected;
        final isToday = isSameDay(date, today);
        final isLastDay = d == 6;
        final dot = daySessions.isNotEmpty
            ? programSessionColor(daySessions.first.activity)
            : null;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDay = d),
            child: Container(
              margin: EdgeInsets.only(
                right: isLastDay ? 0 : CrimpyTheme.spaceXs,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: CrimpyTheme.spaceSm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? CrimpyTheme.fillOn(CrimpyTheme.control)
                    : isToday
                    ? CrimpyTheme.tintOf(CrimpyTheme.current)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? CrimpyTheme.outline : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    weekdayInitial(date),
                    style: CrimpyTheme.labelSmall.copyWith(
                      color: isSelected
                          ? CrimpyTheme.bgPrimary
                          : CrimpyTheme.textMutedSmall,
                    ),
                  ),
                  const SizedBox(height: CrimpyTheme.spaceXs),
                  Text(
                    '${date.day}',
                    style: CrimpyTheme.titleSmall.copyWith(
                      color: isSelected
                          ? CrimpyTheme.bgPrimary
                          : isToday
                          ? CrimpyTheme.textOn(CrimpyTheme.current)
                          : CrimpyTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: CrimpyTheme.spaceXs),
                  Container(
                    width: 7,
                    height: 7,
                    color: dot == null
                        ? Colors.transparent
                        : (isSelected ? CrimpyTheme.bgPrimary : dot),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _weekNote(String note) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceMd,
        vertical: CrimpyTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        color: CrimpyTheme.coachNote.withValues(alpha: 0.1),
        border: Border.all(color: CrimpyTheme.coachNote, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.circleInfo,
            size: 15,
            color: CrimpyTheme.coachNote,
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: CrimpyTheme.bodySmall.copyWith(
                  color: CrimpyTheme.textPrimary,
                ),
                children: [
                  const TextSpan(
                    text: 'COACH NOTE - ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: note),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _restDay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: CrimpyTheme.spaceLgPlus,
        horizontal: CrimpyTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: CrimpyTheme.textMutedSmall,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Text(
        'REST DAY - NOTHING SCHEDULED',
        textAlign: TextAlign.center,
        style: CrimpyTheme.capsLabel.copyWith(
          color: CrimpyTheme.textMutedSmall,
        ),
      ),
    );
  }

  Widget _notPlanned() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.clock,
            size: 26,
            color: CrimpyTheme.textMutedSmall,
          ),
          const SizedBox(height: CrimpyTheme.spaceMd),
          Text(
            'WEEK ${widget.weekNumber} NOT PLANNED YET',
            style: CrimpyTheme.titleSmall.copyWith(
              color: CrimpyTheme.textSecondary,
            ),
          ),
          const SizedBox(height: CrimpyTheme.spaceXs),
          Text(
            'Your coach has not published this week.',
            style: CrimpyTheme.bodySmall.copyWith(
              color: CrimpyTheme.textMutedSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-program calendar grid: one row per week, colored dots per scheduled day.
class _CalendarView extends StatelessWidget {
  final Program program;
  final Set<int> definedWeeks;

  /// The phase each week is in, by week number, absent where the coach named
  /// none.
  final Map<int, String?> weekPhases;
  final int totalWeeks;
  final void Function(WeekSession, int) onOpen;

  const _CalendarView({
    required this.program,
    required this.definedWeeks,
    required this.weekPhases,
    required this.totalWeeks,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 36),
              ...List.generate(
                7,
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      // Columns run Monday-Sunday.
                      weekdayInitial(addCalendarDays(program.weekStart(1), d)),
                      style: CrimpyTheme.labelSmall.copyWith(
                        color: CrimpyTheme.textMutedSmall,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CrimpyTheme.spaceSm),
          ...List.generate(totalWeeks, (i) {
            final week = i + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: CrimpyTheme.spaceXs),
              child: _CalendarRow(
                program: program,
                weekNumber: week,
                defined: definedWeeks.contains(week),
                phase: weekPhases[week] ?? '',
                onOpen: onOpen,
              ),
            );
          }),
          const SizedBox(height: CrimpyTheme.spaceMd),
          _legend(),
        ],
      ),
    );
  }

  Widget _legend() {
    final items = [
      ('HANGBOARD', programSessionColor(SessionActivity.hangboard)),
      ('CLIMBING', programSessionColor(SessionActivity.climbing)),
      ('MOBILITY', programSessionColor(SessionActivity.stretching)),
      ('WORKOUT', programSessionColor(SessionActivity.workout)),
    ];
    return Wrap(
      spacing: CrimpyTheme.spaceMd,
      runSpacing: CrimpyTheme.spaceSm,
      children: items
          .map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 9, height: 9, color: e.$2),
                const SizedBox(width: CrimpyTheme.spaceXs),
                Text(
                  e.$1,
                  style: CrimpyTheme.labelSmall.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

/// A single calendar week row, lazily loading its sessions when defined.
class _CalendarRow extends ConsumerWidget {
  final Program program;
  final int weekNumber;
  final bool defined;

  /// The phase this week is in, empty where the coach named none. Handed down
  /// rather than read off the week detail, which lands a beat later.
  final String phase;
  final void Function(WeekSession, int) onOpen;

  const _CalendarRow({
    required this.program,
    required this.weekNumber,
    required this.defined,
    required this.phase,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = defined
        ? ref.watch(weekDetailProvider(program.id, weekNumber)).value
        : null;
    final byDay = {
      if (week != null)
        for (var d = 0; d < 7; d++) d: week.sessionsOnDay(d),
    };
    final today = currentTrainingDay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Named weeks carry the phase over their own row rather than inside the
        // 36px label column, which holds a week number and nothing more. The
        // same name repeats down a block, which is what makes the arc of the
        // program readable here.
        if (phase.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 2),
            child: Text(
              phase.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CrimpyTheme.capsLabel.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
          ),
        Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                'W$weekNumber',
                style: CrimpyTheme.labelSmall.copyWith(
                  color: defined
                      ? CrimpyTheme.textPrimary
                      : CrimpyTheme.textMutedSmall,
                ),
              ),
            ),
            ...List.generate(7, (d) {
              final daySessions = byDay[d] ?? const <WeekSession>[];
              final session = daySessions.isNotEmpty ? daySessions.first : null;
              // Columns are Monday-anchored, so offset from the week start
              // rather than from the program start date.
              final date = addCalendarDays(program.weekStart(weekNumber), d);
              final isToday = isSameDay(date, today);
              final fill = session != null
                  ? programSessionColor(session.activity)
                  : null;
              return Expanded(
                child: GestureDetector(
                  onTap: session != null
                      ? () => onOpen(session, weekNumber)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    height: 30,
                    decoration: BoxDecoration(
                      color: CrimpyTheme.bgPrimary,
                      border: Border.all(
                        color: isToday
                            ? CrimpyTheme.current
                            : defined
                            ? CrimpyTheme.outline
                            : CrimpyTheme.textMutedSmall,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: fill == null
                        ? null
                        : Center(
                            child: Container(width: 9, height: 9, color: fill),
                          ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
