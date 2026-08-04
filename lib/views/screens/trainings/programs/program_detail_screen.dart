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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    _selectedWeek = program.isActiveOn(DateTime.now())
        ? program.currentWeekNumber(DateTime.now())
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
    final definedWeeks = weeksAsync.asData?.value
        .map((w) => w.weekNumber)
        .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Program')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 14),
            _viewToggle(),
            const SizedBox(height: 14),
            if (_calendar)
              _CalendarView(
                program: program,
                definedWeeks: definedWeeks ?? {},
                totalWeeks: _totalWeeks,
                onOpen: _openSession,
              )
            else ...[
              _weekSelector(definedWeeks),
              const SizedBox(height: 14),
              _WeekStripView(
                program: program,
                weekNumber: _selectedWeek,
                onOpen: _openSession,
              ),
            ],
          ],
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
          Text(program.name, style: Theme.of(context).textTheme.titleLarge),
          if ((program.objective ?? '').isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              program.objective!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _tag(
            FontAwesomeIcons.calendar,
            end == null ? start : '$start - ${formatDayMonth(end)}',
          ),
          const SizedBox(height: 14),
          const Divider(thickness: 2, height: 2),
          const SizedBox(height: 14),
          WeekProgressBar(
            currentWeek: program.isActiveOn(DateTime.now())
                ? program.currentWeekNumber(DateTime.now())
                : 0,
            totalWeeks: _totalWeeks,
          ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: CrimpyTheme.borderDefault, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: CrimpyTheme.textPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
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
            padding: const EdgeInsets.symmetric(vertical: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? CrimpyTheme.primaryOrange
                  : CrimpyTheme.bgPrimary,
              border: Border.all(color: CrimpyTheme.borderDefault, width: 2),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
        const SizedBox(width: 8),
        button('CALENDAR', true),
      ],
    );
  }

  Widget _weekSelector(Set<int>? definedWeeks) {
    final current = program.isActiveOn(DateTime.now())
        ? program.currentWeekNumber(DateTime.now())
        : 0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_totalWeeks, (i) {
          final week = i + 1;
          final defined = definedWeeks?.contains(week) ?? false;
          final selected = week == _selectedWeek;
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: GestureDetector(
              onTap: defined
                  ? () => setState(() => _selectedWeek = week)
                  : null,
              child: Opacity(
                opacity: defined ? 1 : 0.4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? CrimpyTheme.primaryOrange
                        : CrimpyTheme.bgPrimary,
                    border: Border.all(
                      color: CrimpyTheme.borderDefault,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'WEEK $week',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? CrimpyTheme.bgPrimary
                              : CrimpyTheme.textPrimary,
                        ),
                      ),
                      if (week == current) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          color: selected
                              ? CrimpyTheme.bgPrimary
                              : CrimpyTheme.primaryOrange,
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

    return weekAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Could not load week.\n$e'),
      data: (week) {
        if (week == null) return _notPlanned();

        final today = DateTime.now();
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
        final sessions = ref.watch(sessionsProvider).asData?.value ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((week.notes ?? '').isNotEmpty) ...[
              _weekNote(week.notes!),
              const SizedBox(height: 14),
            ],
            _dayPicker(byDay, selected),
            const SizedBox(height: 14),
            Text(
              isSameDay(selectedDate, today)
                  ? 'TODAY - ${formatDayMonth(selectedDate)}'
                  : '${weekdayShort(selectedDate)} - ${formatDayMonth(selectedDate)}',
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: CrimpyTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (selectedSessions.isEmpty)
              _restDay()
            else
              ...selectedSessions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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
              const SizedBox(height: 16),
              const ProgramSectionLabel('Any day this week'),
              const SizedBox(height: 10),
              ...timesPerWeek.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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

  DateTime _dateForDay(int dayOfWeek) => widget.program
      .weekStart(widget.weekNumber)
      .add(Duration(days: dayOfWeek));

  Widget _dayPicker(Map<int, List<WeekSession>> byDay, int selected) {
    final today = DateTime.now();
    return Row(
      children: List.generate(7, (d) {
        final daySessions = byDay[d]!;
        final date = _dateForDay(d);
        final isSelected = d == selected;
        final isToday = isSameDay(date, today);
        final dot = daySessions.isNotEmpty
            ? programSessionColor(daySessions.first.sessionType)
            : null;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDay = d),
            child: Container(
              margin: EdgeInsets.only(right: d == 6 ? 0 : 5),
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? CrimpyTheme.primaryOrange
                    : isToday
                    ? CrimpyTheme.primaryOrange.withValues(alpha: 0.12)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? CrimpyTheme.borderDefault
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    weekdayInitial(date),
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? CrimpyTheme.bgPrimary
                          : CrimpyTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? CrimpyTheme.bgPrimary
                          : isToday
                          ? CrimpyTheme.primaryOrange
                          : CrimpyTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: CrimpyTheme.primaryOrange.withValues(alpha: 0.1),
        border: Border.all(color: CrimpyTheme.primaryOrange, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.circleInfo,
            size: 15,
            color: CrimpyTheme.primaryOrange,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11.5,
                  height: 1.45,
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: CrimpyTheme.textMuted,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: const Text(
        'REST DAY - NOTHING SCHEDULED',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: CrimpyTheme.textMuted,
        ),
      ),
    );
  }

  Widget _notPlanned() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(FontAwesomeIcons.clock, size: 26, color: CrimpyTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            'WEEK ${widget.weekNumber} NOT PLANNED YET',
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CrimpyTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your coach has not published this week.',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: CrimpyTheme.textMuted,
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
  final int totalWeeks;
  final void Function(WeekSession, int) onOpen;

  const _CalendarView({
    required this.program,
    required this.definedWeeks,
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
                      weekdayInitial(
                        program.weekStart(1).add(Duration(days: d)),
                      ),
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: CrimpyTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(totalWeeks, (i) {
            final week = i + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _CalendarRow(
                program: program,
                weekNumber: week,
                defined: definedWeeks.contains(week),
                onOpen: onOpen,
              ),
            );
          }),
          const SizedBox(height: 12),
          _legend(),
        ],
      ),
    );
  }

  Widget _legend() {
    final items = [
      ('HANGBOARD', programSessionColor(SessionType.crimpy)),
      ('CLIMBING', programSessionColor(SessionType.climbing)),
      ('MOBILITY', programSessionColor(SessionType.stretching)),
      ('WORKOUT', programSessionColor(SessionType.workout)),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items
          .map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 9, height: 9, color: e.$2),
                const SizedBox(width: 5),
                Text(
                  e.$1,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
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
  final void Function(WeekSession, int) onOpen;

  const _CalendarRow({
    required this.program,
    required this.weekNumber,
    required this.defined,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = defined
        ? ref.watch(weekDetailProvider(program.id, weekNumber)).asData?.value
        : null;
    final byDay = {
      if (week != null)
        for (var d = 0; d < 7; d++) d: week.sessionsOnDay(d),
    };
    final today = DateTime.now();

    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            'W$weekNumber',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: defined ? CrimpyTheme.textPrimary : CrimpyTheme.textMuted,
            ),
          ),
        ),
        ...List.generate(7, (d) {
          final daySessions = byDay[d] ?? const <WeekSession>[];
          final session = daySessions.isNotEmpty ? daySessions.first : null;
          // Columns are Monday-anchored, so offset from the week start rather
          // than from the program start date.
          final date = program.weekStart(weekNumber).add(Duration(days: d));
          final isToday = isSameDay(date, today);
          final fill = session != null
              ? programSessionColor(session.sessionType)
              : null;
          return Expanded(
            child: GestureDetector(
              onTap: session != null ? () => onOpen(session, weekNumber) : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                height: 30,
                decoration: BoxDecoration(
                  color: fill?.withValues(alpha: 0.15) ?? CrimpyTheme.bgPrimary,
                  border: Border.all(
                    color: isToday
                        ? CrimpyTheme.primaryOrange
                        : defined
                        ? CrimpyTheme.borderDefault
                        : CrimpyTheme.textMuted,
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
    );
  }
}
