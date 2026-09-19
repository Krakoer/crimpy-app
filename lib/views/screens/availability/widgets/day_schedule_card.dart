import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/screens/availability/widgets/activity_editor_sheet.dart';
import 'package:flutter/material.dart';

/// Renders a duration the way a coach reads one: hours and minutes, never
/// "90 min" when "1h30" says it shorter.
String formatPlannedMinutes(int minutes) {
  if (minutes < 60) return '${minutes}min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0
      ? '${hours}h'
      : '${hours}h${rest.toString().padLeft(2, '0')}';
}

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

  void _remove(int index) {
    final activities = [...day.activities];
    activities.removeAt(index);
    onChanged(day.withActivities(activities));
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
                    color: CrimpyTheme.textMuted,
                  ),
                ),
              ),
              if (day.plannedMinutes > 0)
                Text(
                  formatPlannedMinutes(day.plannedMinutes),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CrimpyTheme.accentGreen,
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
                  color: CrimpyTheme.textMuted,
                ),
              ),
            )
          else
            for (var index = 0; index < day.activities.length; index++)
              _ActivityTile(
                activity: day.activities[index],
                enabled: enabled,
                onTap: () => _edit(context, index),
                onRemove: () => _remove(index),
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
  String? get _context {
    final parts = [
      activity.when?.trim(),
      activity.where?.trim(),
    ].whereType<String>().where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final context_ = _context;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(color: CrimpyTheme.bgSecondary),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            formatPlannedMinutes(activity.durationMinutes!),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CrimpyTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (context_ != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        context_,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CrimpyTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: enabled ? onRemove : null,
                icon: const Icon(Icons.close, size: 18),
                color: CrimpyTheme.textMuted,
                visualDensity: VisualDensity.compact,
                tooltip: 'Remove ${activity.label}',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
