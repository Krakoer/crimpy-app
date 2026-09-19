import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/views/screens/availability/widgets/activity_editor_sheet.dart';
import 'package:flutter/material.dart';

/// One day of the declared week: what the athlete plans on it, in the order
/// they entered it, and the way to add more.
///
/// The card carries the whole day rather than one activity, so an empty day
/// still has a place to say it is empty and a button to stop being one.
class DayScheduleCard extends StatelessWidget {
  final String label;

  /// The day and month, so the athlete is looking at a date and not only at a
  /// weekday three weeks out.
  final String dateLabel;
  final DayAvailability day;
  final bool enabled;
  final ValueChanged<DayAvailability> onChanged;

  const DayScheduleCard({
    super.key,
    required this.label,
    required this.dateLabel,
    required this.day,
    required this.enabled,
    required this.onChanged,
  });

  bool get _isFull => day.activities.length >= maxActivitiesPerDay;

  Future<void> _add(BuildContext context) async {
    final activity = await ActivityEditorSheet.show(context, dayLabel: label);
    if (activity == null) return;
    onChanged(day.withActivities([...day.activities, activity]));
  }

  Future<void> _edit(BuildContext context, int index) async {
    final activity = await ActivityEditorSheet.show(
      context,
      activity: day.activities[index],
      dayLabel: label,
    );
    if (activity == null) return;
    final activities = [...day.activities];
    activities[index] = activity;
    onChanged(day.withActivities(activities));
  }

  /// Removing is one tap with nothing to confirm, so the way back is the undo
  /// rather than a dialog: the activity carries four fields the athlete typed,
  /// and a mis-tap next to the row that opens the editor would cost all four.
  void _remove(BuildContext context, int index) {
    final removed = day.activities[index];
    final activities = [...day.activities];
    activities.removeAt(index);
    onChanged(day.withActivities(activities));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${removed.label}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              final restored = [...activities];
              restored.insert(index.clamp(0, restored.length), removed);
              onChanged(day.withActivities(restored));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final planned = day.activities.isNotEmpty;
    return CrimpyCard.category(
      // The accent is the day's own answer at a glance down the list: a day
      // with something on reads apart from one with nothing, without a badge.
      accentColor: planned ? CrimpyTheme.accentGreen : CrimpyTheme.borderDark,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CrimpyTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ),
              if (day.plannedMinutes > 0)
                Text(
                  formatMinutesAsLength(day.plannedMinutes),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CrimpyTheme.accentGreenText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (!planned)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Nothing planned',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: CrimpyTheme.textSecondary,
                ),
              ),
            )
          else
            for (var index = 0; index < day.activities.length; index++)
              _ActivityTile(
                activity: day.activities[index],
                enabled: enabled,
                onTap: () => _edit(context, index),
                onRemove: () => _remove(context, index),
              ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: enabled && !_isFull ? () => _add(context) : null,
              icon: const Icon(Icons.add, size: 18),
              label: Text(_isFull ? 'That is a full day' : 'Add something'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One planned activity, read-only. Tapping it opens the editor; the cross
/// takes it off the day.
class _ActivityTile extends StatelessWidget {
  final DayActivity activity;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ActivityTile({
    required this.activity,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
  });

  /// The "when" and the "where" read as one line under the name, joined only
  /// when the athlete gave both.
  String? get _whenAndWhere {
    final parts = [
      activity.when?.trim(),
      activity.where?.trim(),
    ].whereType<String>().where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final whenAndWhere = _whenAndWhere;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      // The tile needs an edge of its own: its fill sits on a card that is
      // nearly the same value, so without the border a day holding three
      // activities reads as three unseparated lines rather than three tiles.
      decoration: BoxDecoration(
        border: Border.all(color: CrimpyTheme.borderDark),
      ),
      // Material rather than a Container fill, so the ink of the tap lands
      // above the background instead of under it and the row does not read as
      // dead until the sheet opens.
      child: Material(
        color: CrimpyTheme.bgSecondary,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              activity.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: CrimpyTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (activity.durationMinutes != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              formatMinutesAsLength(activity.durationMinutes!),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: CrimpyTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (whenAndWhere != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          whenAndWhere,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CrimpyTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Default constraints rather than a stripped hit box: this one
                // destroys what the athlete typed, and it sits at the edge of a
                // row whose own tap opens the editor.
                IconButton(
                  onPressed: enabled ? onRemove : null,
                  icon: const Icon(Icons.close, size: 18),
                  color: CrimpyTheme.textSecondary,
                  tooltip: 'Remove ${activity.label}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
