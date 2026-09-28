import 'package:crimpy/models/week_availability.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/duration_format.dart';
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

  /// Handed the undo offer so the screen can take it down when it leaves.
  ///
  /// The snack bar is presented above the navigator and outlives this card, and
  /// an undo standing over another screen acknowledges a tap it cannot act on.
  /// Only this one is closed, so a confirmation shown beside it survives.
  final ValueChanged<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>?
  onUndoOffered;

  const DayScheduleCard({
    super.key,
    required this.label,
    required this.dateLabel,
    required this.day,
    required this.enabled,
    required this.onChanged,
    this.onUndoOffered,
  });

  bool get _isFull => day.activities.length >= maxActivitiesPerDay;

  /// Retires the pending undo before the sheet opens.
  ///
  /// The undo carries the day as it stood when the activity was removed. Adding
  /// or editing while it is still up would leave it able to put that snapshot
  /// back over the newer one, taking whatever was just written with it.
  ///
  /// Removed rather than cleared: clearSnackBars drops a queued offer without
  /// completing it, which would leave the screen holding a controller that
  /// never reports itself closed.
  void _retirePendingUndo(BuildContext context) =>
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

  Future<void> _add(BuildContext context) async {
    _retirePendingUndo(context);
    final activity = await ActivityEditorSheet.show(context, dayLabel: label);
    if (activity == null) return;
    onChanged(day.withActivities([...day.activities, activity]));
  }

  Future<void> _edit(BuildContext context, int index) async {
    _retirePendingUndo(context);
    final activity = await ActivityEditorSheet.show(
      context,
      activity: day.activities[index],
      dayLabel: label,
    );
    if (activity == null) return;
    // An edit that changed nothing is not an edit. Reporting it would mark the
    // week dirty and let it be re-sent, which re-dates the declaration and
    // surfaces it in the coach's feed as an answer the athlete did not give.
    if (activity == day.activities[index]) return;
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

    // Removed rather than hidden, because a hidden snack bar stays in the queue
    // for its exit animation and the next offer would queue behind it. Only the
    // front of the queue can be closed by its own controller, so a second
    // removal inside that window would hand the screen an offer it cannot take
    // down, and the assertion that guards it fires on the way out.
    final messenger = ScaffoldMessenger.of(context)..removeCurrentSnackBar();
    final offer = messenger.showSnackBar(
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
    onUndoOffered?.call(offer);
  }

  @override
  Widget build(BuildContext context) {
    final planned = day.activities.isNotEmpty;
    return CrimpyCard.category(
      // The accent is the day's own answer at a glance down the list: a day
      // with something on reads apart from one with nothing, without a badge.
      accentColor: planned ? CrimpyTheme.planned : CrimpyTheme.outlineSubtle,
      margin: const EdgeInsets.only(bottom: CrimpyTheme.spaceMd),
      padding: const EdgeInsets.fromLTRB(
        CrimpyTheme.spaceLg,
        CrimpyTheme.spaceMd,
        CrimpyTheme.spaceMd,
        CrimpyTheme.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                label,
                style: CrimpyTheme.titleSmall.copyWith(
                  color: CrimpyTheme.textPrimary,
                ),
              ),
              const SizedBox(width: CrimpyTheme.spaceSm),
              Expanded(
                child: Text(
                  dateLabel,
                  style: CrimpyTheme.bodySmall.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ),
              if (day.plannedMinutes > 0)
                Text(
                  formatMinutes(day.plannedMinutes),
                  style: CrimpyTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CrimpyTheme.textOn(CrimpyTheme.planned),
                  ),
                ),
            ],
          ),
          const SizedBox(height: CrimpyTheme.spaceSm),
          if (!planned)
            Padding(
              padding: EdgeInsets.only(bottom: CrimpyTheme.spaceXs),
              child: Text(
                'Nothing planned',
                style: CrimpyTheme.body.copyWith(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: CrimpyTheme.spaceSm,
                ),
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
      margin: const EdgeInsets.only(bottom: CrimpyTheme.spaceSm),
      // The tile needs an edge of its own: its fill sits on a card that is
      // nearly the same value, so without the border a day holding three
      // activities reads as three unseparated lines rather than three tiles.
      decoration: BoxDecoration(
        border: Border.all(color: CrimpyTheme.outlineSubtle),
      ),
      // Material rather than a Container fill, so the ink of the tap lands
      // above the background instead of under it and the row does not read as
      // dead until the sheet opens.
      child: Material(
        color: CrimpyTheme.bgSecondary,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CrimpyTheme.spaceMd,
              CrimpyTheme.spaceXs,
              0,
              CrimpyTheme.spaceXs,
            ),
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
                              style: CrimpyTheme.titleSmall.copyWith(
                                color: CrimpyTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (activity.durationMinutes != null) ...[
                            const SizedBox(width: CrimpyTheme.spaceSm),
                            Text(
                              formatMinutes(activity.durationMinutes!),
                              style: CrimpyTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: CrimpyTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (whenAndWhere != null) ...[
                        const SizedBox(height: CrimpyTheme.spaceXs),
                        Text(
                          whenAndWhere,
                          style: CrimpyTheme.bodySmall.copyWith(
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
