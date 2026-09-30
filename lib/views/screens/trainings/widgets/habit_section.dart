import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/viewmodels/habit_view_model.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _weekdayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

/// How a habit reads in a line: "Mo, We, Fr" or "3 times a week".
String describeHabit(TrainingHabit habit) {
  final times = habit.timesPerWeek;
  if (times != null) return times == 1 ? 'Once a week' : '$times times a week';
  return [
    for (var day = 0; day < 7; day++)
      if (habit.weekdays.contains(day)) _weekdayLabels[day],
  ].join(', ');
}

/// The part of a training's page that makes it a weekly habit of the athlete's
/// own: on set days, or a number of times a week. The count sits on the
/// training itself, with no scheduling screen of its own. A coach's program,
/// while one runs, takes precedence over it.
class HabitSection extends ConsumerWidget {
  final String trainingId;

  const HabitSection({required this.trainingId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(trainingHabitsProvider).value;
    if (habits == null) return const SizedBox.shrink();
    final habit = habits.where((h) => h.trainingId == trainingId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Weekly habit'),
        const SizedBox(height: CrimpyTheme.spaceSm),
        Text(
          habit == null
              ? 'Set it as a habit to see it on the home screen on the days '
                    'it is due, and to be reminded of it.'
              : describeHabit(habit),
          style: habit == null
              ? CrimpyTheme.bodySmall.copyWith(color: CrimpyTheme.textSecondary)
              : CrimpyTheme.titleSmall.copyWith(color: CrimpyTheme.textPrimary),
        ),
        const SizedBox(height: CrimpyTheme.spaceSm),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => _edit(context, ref, habit),
              child: Text(habit == null ? 'Make it a habit' : 'Change'),
            ),
            if (habit != null) ...[
              const SizedBox(width: CrimpyTheme.spaceSm),
              TextButton(
                onPressed: () => ref
                    .read(trainingHabitsProvider.notifier)
                    .removeHabit(trainingId),
                child: const Text('Stop the habit'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    TrainingHabit? current,
  ) async {
    final chosen = await showDialog<TrainingHabit>(
      context: context,
      builder: (_) => HabitDialog(trainingId: trainingId, current: current),
    );
    if (chosen != null) {
      await ref.read(trainingHabitsProvider.notifier).setHabit(chosen);
    }
  }
}

/// Asks when the training is due: on set days, or a number of times a week.
/// Pops the habit to save, or nothing when dismissed.
class HabitDialog extends StatefulWidget {
  final String trainingId;
  final TrainingHabit? current;

  const HabitDialog({required this.trainingId, this.current, super.key});

  @override
  State<HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends State<HabitDialog> {
  late bool _perWeek = widget.current?.isPerWeek ?? false;
  late Set<int> _weekdays = {...?widget.current?.weekdays};
  late int _timesPerWeek = widget.current?.timesPerWeek ?? 2;

  bool get _canSave => _perWeek || _weekdays.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Weekly habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('On set days')),
              ButtonSegment(value: true, label: Text('Times a week')),
            ],
            selected: {_perWeek},
            onSelectionChanged: (value) =>
                setState(() => _perWeek = value.single),
          ),
          const SizedBox(height: CrimpyTheme.spaceLg),
          if (_perWeek)
            Row(
              children: [
                IconButton(
                  tooltip: 'Fewer',
                  icon: const Icon(Icons.remove),
                  onPressed: _timesPerWeek > 1
                      ? () => setState(() => _timesPerWeek--)
                      : null,
                ),
                Expanded(
                  child: Text(
                    _timesPerWeek == 1
                        ? 'Once a week'
                        : '$_timesPerWeek times a week',
                    textAlign: TextAlign.center,
                    style: CrimpyTheme.titleSmall.copyWith(
                      color: CrimpyTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'More',
                  icon: const Icon(Icons.add),
                  onPressed: _timesPerWeek < 7
                      ? () => setState(() => _timesPerWeek++)
                      : null,
                ),
              ],
            )
          else
            Wrap(
              spacing: CrimpyTheme.spaceSm,
              runSpacing: CrimpyTheme.spaceSm,
              children: [
                for (var day = 0; day < 7; day++)
                  FilterChip(
                    label: Text(_weekdayLabels[day]),
                    selected: _weekdays.contains(day),
                    onSelected: (value) => setState(() {
                      _weekdays = {..._weekdays};
                      value ? _weekdays.add(day) : _weekdays.remove(day);
                    }),
                  ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSave ? _save : null,
          child: const Text('Save habit'),
        ),
      ],
    );
  }

  void _save() {
    // Counted from the day it changed: the days before owed what the habit
    // asked then, which the strip no longer knows, so it does not score them.
    final since = currentTrainingDay();
    Navigator.of(context).pop(
      _perWeek
          ? TrainingHabit.perWeek(
              trainingId: widget.trainingId,
              timesPerWeek: _timesPerWeek,
              since: since,
            )
          : TrainingHabit.onWeekdays(
              trainingId: widget.trainingId,
              weekdays: _weekdays,
              since: since,
            ),
    );
  }
}
