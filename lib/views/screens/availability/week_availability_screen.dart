import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:crimpy/views/screens/availability/widgets/day_availability_row.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
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

/// Where the athlete tells their coach when they can train, one calendar week
/// at a time. Permissive on purpose: a day may be nothing but a sentence.
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
    if (_dirty && !await _confirmDiscard()) return;
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final week = _week;
    return Scaffold(
      appBar: AppBar(title: const Text('Your week')),
      body: _loadError != null
          ? _LoadFailure(onRetry: _retry)
          : week == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _WeekSwitcher(
                  weekStart: _weekStart,
                  onPick: _showWeek,
                  enabled: !_saving,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Say what you can do on each day. A rough duration and a word '
                  'about it is enough: your coach builds the week around it.',
                  style: TextStyle(
                    fontSize: 12,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const SectionLabel('Days'),
                const SizedBox(height: 8),
                for (final day in week.days)
                  DayAvailabilityRow(
                    // Keyed by the week as well as the day: switching weeks
                    // resolves from a loaded provider without ever painting the
                    // spinner, so an unkeyed row would be reused and keep the
                    // previous week's text in its controllers.
                    key: ValueKey((_weekStart, day.dayOfWeek)),
                    label: _weekdayNames[day.dayOfWeek],
                    day: day,
                    enabled: !_saving,
                    onChanged: _updateDay,
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  // A week never declared sends as it stands, untouched: an
                  // athlete who cannot train at all is answering, and the API
                  // reads a missing week as silence and keeps nudging for it.
                  onPressed: _saving || (_declared && !_dirty) ? null : _save,
                  child: Text(_saving ? 'Saving' : 'Send to my coach'),
                ),
              ],
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
    return Wrap(
      spacing: 8,
      children: [
        for (var index = 0; index < options.length; index++)
          ChoiceChip(
            label: Text(_optionLabel(index, options[index])),
            selected: options[index] == weekStart,
            onSelected: enabled ? (_) => onPick(options[index]) : null,
          ),
      ],
    );
  }

  String _optionLabel(int index, DateTime monday) {
    final name = switch (index) {
      0 => 'This week',
      1 => 'Next week',
      _ => 'In 2 weeks',
    };
    return '$name (${monday.day}/${monday.month})';
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
