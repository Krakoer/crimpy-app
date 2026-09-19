import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:crimpy/views/screens/availability/widgets/day_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/utils/datetimes.dart';

const List<String> _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Where the athlete tells their coach what their week looks like, one calendar
/// week at a time. Permissive on purpose: a day holds as many activities as
/// they want, or none at all, and none at all is still an answer.
class WeekAvailabilityScreen extends ConsumerStatefulWidget {
  /// The Monday to open on. Defaults to next week, which is the one a coach
  /// writing a program on Saturday is asking about.
  final DateTime? weekStart;

  const WeekAvailabilityScreen({super.key, this.weekStart});

  @override
  ConsumerState<WeekAvailabilityScreen> createState() =>
      _WeekAvailabilityScreenState();
}

class _WeekAvailabilityScreenState
    extends ConsumerState<WeekAvailabilityScreen> {
  late DateTime _weekStart;
  WeekAvailability? _week;
  Object? _loadError;
  bool _saving = false;
  bool _dirty = false;
  bool _declared = true;

  @override
  void initState() {
    super.initState();
    _weekStart = widget.weekStart ?? getStartOfNextWeek(DateTime.now());
    _loadWeek();
  }

  Future<void> _loadWeek() async {
    try {
      final loaded = await ref
          .read(myAvailabilityProvider.notifier)
          .weekOf(_weekStart);
      if (!mounted) return;
      setState(() {
        _week = loaded.week;
        _declared = loaded.declared;
        _loadError = null;
        _dirty = false;
      });
    } catch (error) {
      // The provider keeps its error, so a silent spinner here would never
      // resolve and re-entering the screen would land on the same cached one.
      if (!mounted) return;
      setState(() {
        _week = null;
        _loadError = error;
      });
    }
  }

  Future<void> _retry() async {
    setState(() => _loadError = null);
    ref.invalidate(myAvailabilityProvider);
    await _loadWeek();
  }

  Future<void> _showWeek(DateTime weekStart) async {
    if (weekStart == _weekStart) return;
    if (_dirty && !await _confirmDiscard()) return;
    if (!mounted) return;
    // The undo of a removed activity belongs to the week it was removed from.
    // The snack bar lives above the navigator and would otherwise still be on
    // screen here, one tap away from putting that activity into a different
    // week, which matches days by index and would take it silently.
    _clearPendingUndo();
    setState(() {
      _weekStart = weekStart;
      _week = null;
      _loadError = null;
    });
    await _loadWeek();
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave this week?'),
        content: const Text('What you changed here has not been sent yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  void _updateDay(DayAvailability day) {
    // An undo can be tapped after this screen is gone, since the snack bar
    // outlives the route. Every path that leaves retires it first, so this is
    // the backstop rather than the guard.
    if (!mounted) return;
    setState(() {
      _week = _week?.withDay(day);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    final week = _week;
    if (week == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(myAvailabilityProvider.notifier).saveWeek(week);
      if (!mounted) return;
      setState(() => _dirty = false);
      // Retired before the confirmation replaces it, and before the route
      // pops: an undo left standing over the screen underneath would write
      // into a week nobody is looking at any more.
      _clearPendingUndo();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your coach can see your week')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save your week: $error'),
          backgroundColor: CrimpyTheme.statusError,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Leaving the screen with the back button or the system gesture asks the
  /// same question switching weeks does. A dirty week now holds several fully
  /// typed activities rather than two text fields, so dropping it silently
  /// costs the athlete everything they wrote.
  Future<void> _confirmPop(bool didPop, Object? result) async {
    if (didPop) return;
    if (!await _confirmDiscard()) return;
    if (!mounted) return;
    _clearPendingUndo();
    Navigator.of(context).pop(result);
  }

  /// Takes down the "Removed X" snack bar and the undo it carries.
  ///
  /// The snack bar is presented by the app level ScaffoldMessenger above the
  /// navigator, so it keeps showing across a pop and across a week switch, and
  /// its action still fires. What it would write is the day of the week that is
  /// no longer on screen.
  void _clearPendingUndo() => ScaffoldMessenger.of(context).clearSnackBars();

  @override
  Widget build(BuildContext context) {
    final week = _week;
    return PopScope(
      // A send already in flight is not unsaved work, and the dialog would
      // offer to discard a week that is on its way to the server anyway.
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: _confirmPop,
      child: _buildScaffold(week),
    );
  }

  Widget _buildScaffold(WeekAvailability? week) {
    return Scaffold(
      backgroundColor: CrimpyTheme.bgSecondary,
      appBar: AppBar(title: const Text('Your week')),
      body: _loadError != null
          ? _LoadFailure(onRetry: _retry)
          : week == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _WeekSwitcher(
                  weekStart: _weekStart,
                  onPick: _showWeek,
                  enabled: !_saving,
                ),
                _WeekSummary(week: week, declared: _declared),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      for (final day in week.days)
                        DayScheduleCard(
                          label: _weekdayNames[day.dayOfWeek],
                          dateLabel: _dayAndMonth(
                            addCalendarDays(_weekStart, day.dayOfWeek),
                          ),
                          day: day,
                          enabled: !_saving,
                          onChanged: _updateDay,
                        ),
                    ],
                  ),
                ),
                _SendBar(
                  // A week never declared sends as it stands, untouched: an
                  // athlete with nothing on is answering, and the API reads a
                  // missing week as silence and keeps nudging for it.
                  onSend: _saving || (_declared && !_dirty) ? null : _save,
                  saving: _saving,
                  dirty: _dirty,
                  declared: _declared,
                ),
              ],
            ),
    );
  }
}

String _dayAndMonth(DateTime day) => '${day.day}/${day.month}';

/// What the week adds up to, so the athlete sees their answer before sending it
/// and a week left empty reads as deliberate rather than as unfinished.
class _WeekSummary extends StatelessWidget {
  final WeekAvailability week;
  final bool declared;

  const _WeekSummary({required this.week, required this.declared});

  String get _headline {
    if (week.plannedActivityCount == 0) {
      return declared ? 'Nothing on this week' : 'Nothing on this week yet';
    }
    final days = week.plannedDayCount;
    return '${week.plannedActivityCount} '
        '${week.plannedActivityCount == 1 ? 'thing' : 'things'} '
        'across $days ${days == 1 ? 'day' : 'days'}';
  }

  @override
  Widget build(BuildContext context) {
    final minutes = week.plannedMinutes;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: CrimpyTheme.bgPrimary,
        border: Border(
          bottom: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _headline,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CrimpyTheme.textPrimary,
                  ),
                ),
              ),
              if (minutes > 0)
                Text(
                  formatMinutesAsLength(minutes),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CrimpyTheme.accentGreenText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Add whatever fills your days, training or not. Your coach builds '
            'the week around what is already in it.',
            style: TextStyle(fontSize: 12, color: CrimpyTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The send button, pinned under the list rather than scrolled to the bottom of
/// it: with seven day cards and their activities the old inline button sat a
/// long way down a page the athlete had no reason to scroll to.
class _SendBar extends StatelessWidget {
  final VoidCallback? onSend;
  final bool saving;
  final bool dirty;
  final bool declared;

  const _SendBar({
    required this.onSend,
    required this.saving,
    required this.dirty,
    required this.declared,
  });

  String get _label {
    if (saving) return 'Sending';
    if (declared && !dirty) return 'Sent to your coach';
    return 'Send to my coach';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: CrimpyTheme.bgPrimary,
        border: Border(
          top: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: onSend, child: Text(_label)),
        ),
      ),
    );
  }
}

/// Moves between the weeks worth declaring. Only this week and the next two:
/// further out the athlete does not know, and the coach is not writing it yet.
class _WeekSwitcher extends StatelessWidget {
  final DateTime weekStart;
  final ValueChanged<DateTime> onPick;
  final bool enabled;

  const _WeekSwitcher({
    required this.weekStart,
    required this.onPick,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final thisWeek = getStartOfWeek(DateTime.now());
    final options = [
      thisWeek,
      addCalendarDays(thisWeek, 7),
      addCalendarDays(thisWeek, 14),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: CrimpyTheme.bgPrimary,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < options.length; index++)
            ChoiceChip(
              label: Text(_optionLabel(index, options[index])),
              selected: options[index] == weekStart,
              onSelected: enabled ? (_) => onPick(options[index]) : null,
            ),
        ],
      ),
    );
  }

  String _optionLabel(int index, DateTime monday) {
    final name = switch (index) {
      0 => 'This week',
      1 => 'Next week',
      _ => 'In 2 weeks',
    };
    return '$name (${_dayAndMonth(monday)})';
  }
}

/// Shown when the declared weeks could not be read. Without it the screen sits
/// on a spinner that never resolves, since the provider keeps its error.
class _LoadFailure extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _LoadFailure({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, color: CrimpyTheme.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Your weeks could not be loaded.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: CrimpyTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}
