import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

String trainingItemTitle(TrainingItem item) => switch (item.type) {
  TrainingItemType.group => item.groupTitle ?? 'Group',
  TrainingItemType.circuit => 'Circuit',
  TrainingItemType.repeater => 'Repeater',
  TrainingItemType.hangboardRep => 'Hangboard',
  TrainingItemType.exercise => item.exerciseName ?? 'Exercise',
  TrainingItemType.free => item.freeText ?? 'Note',
};

String trainingItemDetail(TrainingItem item) {
  final load = item.loadLabel;
  // An item is either rep-based or time-based, never both.
  final amount = item.effectiveReps != null
      ? '${item.effectiveReps} reps'
      : item.effectiveDuration != null
      ? '${item.effectiveDuration}s'
      : null;

  switch (item.type) {
    case TrainingItemType.repeater:
      return '${item.cycles ?? 1}x${item.reps ?? 1} - ${item.worktimeSeconds ?? 7}s on / ${item.restSeconds ?? 3}s off';
    case TrainingItemType.hangboardRep:
      return [
        if (item.effectiveReps != null) '${item.effectiveReps} reps',
        '${item.worktimeSeconds ?? 7}s on / ${item.restSeconds ?? 3}s off',
        if (load != null) load,
      ].join(' - ');
    case TrainingItemType.exercise:
      return [if (amount != null) amount, if (load != null) load].join(' - ');
    case TrainingItemType.circuit:
      return '${item.cycles ?? 1} cycles';
    case TrainingItemType.group:
      return '';
    case TrainingItemType.free:
      return item.effectiveDuration != null ? '${item.effectiveDuration}s' : '';
  }
}

/// Coach comment attached to a training item, e.g. "right leg".
class TrainingItemComment extends StatelessWidget {
  final String comment;

  const TrainingItemComment(this.comment, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: CrimpyTheme.primaryOrange.withValues(alpha: 0.10),
        border: Border.all(
          color: CrimpyTheme.primaryOrange.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            FontAwesomeIcons.comment,
            size: 11,
            color: CrimpyTheme.primaryOrange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              comment,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11.5,
                height: 1.4,
                color: CrimpyTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of a training breakdown: position, title, its numbers and the coach
/// comment when there is one. [extra] holds screen specific decorations such as
/// the program override chips.
class TrainingItemTile extends StatelessWidget {
  final TrainingItem item;
  final int number;
  final Color? accentColor;
  final List<Widget> extra;

  const TrainingItemTile({
    required this.item,
    required this.number,
    this.accentColor,
    this.extra = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final detail = trainingItemDetail(item);
    final comment = item.comment?.trim() ?? '';
    final child = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CrimpyTheme.bgSecondary,
            border: Border.all(color: CrimpyTheme.borderDefault, width: 1.5),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trainingItemTitle(item),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: CrimpyTheme.textPrimary,
                ),
              ),
              if (detail.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ],
              if (comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                TrainingItemComment(comment),
              ],
              if (extra.isNotEmpty) ...[const SizedBox(height: 9), ...extra],
            ],
          ),
        ),
      ],
    );

    return accentColor == null
        ? CrimpyCard.simple(child: child)
        : CrimpyCard.category(accentColor: accentColor, child: child);
  }
}

/// Flattens a training tree into indented tiles, so that items nested in a
/// circuit or a group are listed with their own details and comments.
List<Widget> buildTrainingItemTiles(
  List<TrainingItem> items, {
  int depth = 0,
  Color? Function(TrainingItem item)? accentColorOf,
  List<Widget> Function(TrainingItem item)? extraOf,
}) {
  final widgets = <Widget>[];
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    widgets.add(
      Padding(
        padding: EdgeInsets.only(left: depth * 14.0, bottom: 10),
        child: TrainingItemTile(
          item: item,
          number: i + 1,
          accentColor: accentColorOf?.call(item),
          extra: extraOf?.call(item) ?? const [],
        ),
      ),
    );
    if (item.items.isNotEmpty) {
      widgets.addAll(
        buildTrainingItemTiles(
          item.items,
          depth: depth + 1,
          accentColorOf: accentColorOf,
          extraOf: extraOf,
        ),
      );
    }
  }
  return widgets;
}
