import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:crimpy/views/screens/availability/widgets/day_availability_row.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _weekStart =
        widget.weekStart ??
        mondayOf(DateTime.now()).add(const Duration(days: 7));
    _loadWeek();
  }

  Future<void> _loadWeek() async {
    final week = await ref
        .read(myAvailabilityProvider.notifier)
        .weekOf(_weekStart);
    if (!mounted) return;
    setState(() {
      _week = week;
      _dirty = false;
    });
  }

  void _showWeek(DateTime weekStart) {
    setState(() {
      _weekStart = weekStart;
      _week = null;
    });
    _loadWeek();
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
      body: week == null
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
                    label: _weekdayNames[day.dayOfWeek],
                    day: day,
                    enabled: !_saving,
                    onChanged: _updateDay,
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving || !_dirty ? null : _save,
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
    final thisWeek = mondayOf(DateTime.now());
    final options = [
      thisWeek,
      thisWeek.add(const Duration(days: 7)),
      thisWeek.add(const Duration(days: 14)),
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
