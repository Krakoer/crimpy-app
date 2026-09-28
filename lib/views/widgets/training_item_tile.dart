import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/duration_format.dart';
import 'package:crimpy/utils/hang_prescription.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:crimpy/utils/video_link.dart';
import 'package:crimpy/views/widgets/exercise_video_link.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

String trainingItemDetail(
  TrainingItem item, {
  double? bodyweightKg,
  AssessmentResults results = AssessmentResults.none,
}) {
  final load = _exerciseLoad(
    item,
    bodyweightKg: bodyweightKg,
    results: results,
  );
  final reps = item.effectiveReps(results);
  final duration = item.effectiveDuration(results);
  // An item is either rep-based or time-based, never both. An AMRAP is
  // rep-based with the count left open, so it names itself rather than a
  // number nothing has yet.
  final amount = item.repsIsMax
      ? 'AMRAP'
      : reps != null
      ? '$reps reps'
      : duration != null
      ? formatExactLength(duration)
      : null;

  switch (item.type) {
    case TrainingItemType.repeater:
      return '${item.cycles ?? 1}x${item.reps ?? 1} - '
          '${formatExactLength(item.worktimeSeconds ?? 7)} on / '
          '${formatExactLength(item.restSeconds ?? 3)} off';
    case TrainingItemType.hangboardRep:
      // The load is on a line of its own, see [HangPrescription].
      return [
        if (reps != null) '$reps reps',
        '${formatExactLength(item.worktimeSeconds ?? 7)} on / ${formatExactLength(item.restSeconds ?? 3)} off',
      ].join(' - ');
    case TrainingItemType.exercise:
      return [if (amount != null) amount, if (load != null) load].join(' - ');
    case TrainingItemType.circuit:
      return [
        '${item.cycles ?? 1} cycles',
        if ((item.restSeconds ?? 0) > 0)
          '${formatExactLength(item.restSeconds!)} between items',
        if ((item.cycleRestSeconds ?? 0) > 0)
          '${formatExactLength(item.cycleRestSeconds!)} between cycles',
      ].join(' - ');
    case TrainingItemType.emom:
      return [
        '${item.cycles ?? 1} rounds',
        'every ${formatExactLength(item.intervalSeconds ?? 60)}',
      ].join(' - ');
    case TrainingItemType.group:
      return '';
    case TrainingItemType.free:
      return duration != null ? formatExactLength(duration) : '';
  }
}

/// An exercise's load in the words the hang rows use, kilograms first, so one
/// screen does not state loads two ways. See [loadInKilogramsFirst].
String? _exerciseLoad(
  TrainingItem item, {
  double? bodyweightKg,
  required AssessmentResults results,
}) {
  if (item.showsMax) return 'MAX';
  final load = item.shownLoad;
  if (load == null) return null;
  return loadInKilogramsFirst(
    load,
    kilograms: load.kilograms(bodyweightKg: bodyweightKg, results: results),
    results: results,
  );
}

/// Coach comment attached to a training item, e.g. "right leg".
class TrainingItemComment extends StatelessWidget {
  final String comment;

  const TrainingItemComment(this.comment, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceSm,
        vertical: CrimpyTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: CrimpyTheme.coachNote.withValues(alpha: 0.10),
        border: Border.all(
          color: CrimpyTheme.coachNote.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            FontAwesomeIcons.comment,
            size: 11,
            color: CrimpyTheme.coachNote,
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Expanded(
            child: Text(
              comment,
              style: CrimpyTheme.bodySmall.copyWith(
                color: CrimpyTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A note on a tile that names itself: a short label in the note's own colour,
/// then the prose. Spelled once so the shape of the band cannot drift between
/// the notes that use it, since what tells them apart is meant to be the label
/// and the colour and nothing else.
///
/// [accent] is the rule and the tint; the label is [CrimpyTheme.textOn] of it,
/// which is the accent carried down far enough to be legible at this size, and
/// is asked for rather than passed in so an accent added to the theme's text
/// map reaches this widget with it.
class _LabelledNote extends StatelessWidget {
  final String label;
  final Color accent;
  final String text;

  const _LabelledNote({
    required this.label,
    required this.accent,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceSm,
        vertical: CrimpyTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: CrimpyTheme.capsLabel.copyWith(
              color: CrimpyTheme.textOn(accent),
            ),
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Expanded(
            child: Text(
              text,
              style: CrimpyTheme.bodySmall.copyWith(
                color: CrimpyTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What the block is for, e.g. "resi doigts". Labelled and set in green rather
/// than the comment's orange, so the two notes on a tile are told apart without
/// reading them: this one is why the block is in the program, the other is how
/// to run it. The rule and the tint are accentGreen, and the label is whatever
/// [CrimpyTheme.textOn] answers for it: accentGreen does not carry enough
/// contrast for type this small.
class TrainingItemGoal extends StatelessWidget {
  final String goal;

  const TrainingItemGoal(this.goal, {super.key});

  @override
  Widget build(BuildContext context) =>
      _LabelledNote(label: 'GOAL', accent: CrimpyTheme.goalMark, text: goal);
}

/// The rule the athlete resolves while performing the block, e.g. "to failure
/// or 40s; past 40s add 5kg". Labelled and set in gold, a third colour beside
/// the goal's green and the comment's orange, so the three notes on a tile are
/// told apart without reading them: this one is what decides the numbers above
/// it. The rule and the tint are accentYellow, and the label is whatever
/// [CrimpyTheme.textOn] answers for it, which is accentYellow carried down far
/// enough to be legible at that size.
class TrainingItemProtocol extends StatelessWidget {
  final String protocol;

  const TrainingItemProtocol(this.protocol, {super.key});

  @override
  Widget build(BuildContext context) => _LabelledNote(
    label: 'PROTOCOL',
    accent: CrimpyTheme.protocolMark,
    text: protocol,
  );
}

/// One row of a training breakdown: position, title, its numbers, what a hang
/// is set up on and at what load, what the block is for and the coach comment
/// when there is one. [extra] holds screen specific decorations such as the
/// program override chips.
class TrainingItemTile extends StatelessWidget {
  final TrainingItem item;
  final int number;
  final Color? accentColor;
  final List<Widget> extra;

  /// Resolves the loads the coach set in percent of the bodyweight; the tile
  /// shows them as a bare percentage when it is unknown.
  final double? bodyweightKg;

  /// Resolves the loads, durations and reps the coach set in percent of an
  /// assessment; the tile shows their fallback until it is done.
  final AssessmentResults results;

  /// The athlete's max per grip and hand, which a load set in kilograms is
  /// shown as a percentage of.
  final MaxForceReference maxForce;

  /// How long the item runs, in seconds, shown beside its title when set.
  final int? lengthSeconds;

  const TrainingItemTile({
    required this.item,
    required this.number,
    this.accentColor,
    this.extra = const [],
    this.bodyweightKg,
    this.results = AssessmentResults.none,
    this.maxForce = MaxForceReference.none,
    this.lengthSeconds,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final detail = trainingItemDetail(
      item,
      bodyweightKg: bodyweightKg,
      results: results,
    );
    final prescription = HangPrescription.of(
      item,
      maxForce: maxForce,
      results: results,
      bodyweightKg: bodyweightKg,
    );
    final length = lengthSeconds;
    final comment = item.comment?.trim() ?? '';
    final goal = item.goal?.trim() ?? '';
    final protocol = item.protocol?.trim() ?? '';
    // What the coach wrote about the movement itself: what it is, then how to
    // execute it. Both come off the exercise rather than off this step, which is
    // what the item's own comment above is.
    final exerciseNotes = [
      item.exerciseDescription?.trim() ?? '',
      item.exerciseComment?.trim() ?? '',
    ].where((line) => line.isNotEmpty).toList();
    final hasVideo = isPlayableVideoLink(item.exerciseVideoLink);
    final child = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CrimpyTheme.bgSecondary,
            border: Border.all(color: CrimpyTheme.outline, width: 1.5),
          ),
          child: Text(
            '$number',
            style: CrimpyTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: CrimpyTheme.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      trainingItemTitle(item),
                      style: CrimpyTheme.titleSmall.copyWith(
                        color: CrimpyTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (length != null && length > 0) ...[
                    const SizedBox(width: CrimpyTheme.spaceSm),
                    Text(
                      formatLength(Duration(seconds: length)),
                      style: CrimpyTheme.tabular(
                        CrimpyTheme.bodySmall,
                      ).copyWith(color: CrimpyTheme.textSecondary),
                    ),
                  ],
                ],
              ),
              if (detail.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceXs),
                Text(
                  detail,
                  style: CrimpyTheme.bodySmall.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ],
              if (prescription != null) ...[
                const SizedBox(height: CrimpyTheme.spaceXs),
                Text(
                  prescription.setup,
                  style: CrimpyTheme.bodySmall.copyWith(
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: CrimpyTheme.spaceXs),
                Text(
                  prescription.load,
                  style: CrimpyTheme.tabular(CrimpyTheme.bodySmall).copyWith(
                    color: CrimpyTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (goal.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceSm),
                TrainingItemGoal(goal),
              ],
              if (protocol.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceSm),
                TrainingItemProtocol(protocol),
              ],
              for (final note in exerciseNotes) ...[
                const SizedBox(height: CrimpyTheme.spaceXs),
                ExerciseDescription(note),
              ],
              if (comment.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceSm),
                TrainingItemComment(comment),
              ],
              if (hasVideo) ...[
                const SizedBox(height: CrimpyTheme.spaceXs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ExerciseVideoButton(item.exerciseVideoLink),
                ),
              ],
              if (extra.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceSm),
                ...extra,
              ],
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
  double? bodyweightKg,
  AssessmentResults results = AssessmentResults.none,
  MaxForceReference maxForce = MaxForceReference.none,
  Color? Function(TrainingItem item)? accentColorOf,
  List<Widget> Function(TrainingItem item)? extraOf,
}) {
  final widgets = <Widget>[];
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    widgets.add(
      Padding(
        padding: EdgeInsets.only(
          left: depth * CrimpyTheme.spaceLg,
          bottom: CrimpyTheme.spaceMd,
        ),
        child: TrainingItemTile(
          item: item,
          number: i + 1,
          accentColor: accentColorOf?.call(item),
          extra: extraOf?.call(item) ?? const [],
          bodyweightKg: bodyweightKg,
          results: results,
          maxForce: maxForce,
          // A nested item runs once per pass of the block it sits in, so only
          // a top level one has a length of its own that adds up to the whole.
          lengthSeconds: depth == 0
              ? itemDurationSeconds(item, results: results)
              : null,
        ),
      ),
    );
    if (item.items.isNotEmpty) {
      widgets.addAll(
        buildTrainingItemTiles(
          item.items,
          depth: depth + 1,
          bodyweightKg: bodyweightKg,
          results: results,
          maxForce: maxForce,
          accentColorOf: accentColorOf,
          extraOf: extraOf,
        ),
      );
    }
  }
  return widgets;
}
