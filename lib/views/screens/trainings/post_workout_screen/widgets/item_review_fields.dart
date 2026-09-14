import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen/widgets/assessment_answer_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// What the athlete is entering about one pass through one prescribed item
/// while they go back over the run. It owns the text controllers, since a
/// half typed number is text and only becomes a report when the session is
/// saved.
class ItemReviewDraft {
  final TrainingItem item;
  final int occurrence;

  /// The numbers this item is worth asking for. A set of pull ups is asked for
  /// reps and a load, an emom for the rounds it went.
  final ReportableFields fields;

  final TextEditingController reps;
  final TextEditingController cycles;
  final TextEditingController loadKg;
  final TextEditingController durationSeconds;
  final TextEditingController note;

  ItemReviewDraft({
    required this.item,
    required this.occurrence,
    required this.fields,
    required this.reps,
    required this.cycles,
    required this.loadKg,
    required this.durationSeconds,
    required this.note,
  });

  /// A draft seeded with whatever the run already recorded for this pass, so
  /// the count an AMRAP was answered with mid run is shown to be corrected
  /// rather than asked for a second time.
  factory ItemReviewDraft.forLine(
    ReviewLine line,
    SessionItemResultModel? recorded, [
    AssessmentResults results = AssessmentResults.none,
  ]) => ItemReviewDraft(
    item: line.item,
    occurrence: line.occurrence,
    fields: reportableFields(line.item, results),
    reps: TextEditingController(text: recorded?.reps?.toString() ?? ''),
    cycles: TextEditingController(text: recorded?.cycles?.toString() ?? ''),
    loadKg: TextEditingController(text: recorded?.loadKg?.toString() ?? ''),
    durationSeconds: TextEditingController(
      text: recorded?.durationSeconds?.toString() ?? '',
    ),
    note: TextEditingController(text: recorded?.note ?? ''),
  );

  /// What the athlete entered, or null when they entered nothing. A field the
  /// item was never asked about is not read, so a rounds count left over from
  /// an earlier shape of the card cannot leak into an exercise.
  SessionItemResultModel? toResult() {
    final result = SessionItemResultModel(
      trainingItemId: item.id,
      occurrence: occurrence,
      reps: fields.reps ? _int(reps) : null,
      cycles: fields.cycles ? _int(cycles) : null,
      loadKg: fields.load ? parseAnswer(loadKg.text) : null,
      durationSeconds: fields.duration ? _int(durationSeconds) : null,
      note: _text(note),
    );
    return result.reported ? result : null;
  }

  void dispose() {
    reps.dispose();
    cycles.dispose();
    loadKg.dispose();
    durationSeconds.dispose();
    note.dispose();
  }

  static int? _int(TextEditingController controller) =>
      int.tryParse(controller.text.trim());

  static String? _text(TextEditingController controller) {
    final trimmed = controller.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// A draft per line of the review, in prescription order.
List<ItemReviewDraft> buildItemReviewDrafts(
  List<TrainingItem> items,
  List<SessionItemResultModel> recorded, [
  AssessmentResults results = AssessmentResults.none,
]) {
  final byPass = {
    for (final result in recorded)
      '${result.trainingItemId}/${result.occurrence}': result,
  };
  return [
    for (final line in reviewLines(items, recorded))
      ItemReviewDraft.forLine(
        line,
        byPass['${line.item.id}/${line.occurrence}'],
        results,
      ),
  ];
}

/// The review pass: every step the athlete was prescribed, with what they
/// managed on it and room for the line they want to write about it. This is
/// where the coaching loop happens, so it asks once at the end rather than
/// interrupting the run.
class ItemReviewSection extends StatelessWidget {
  final List<ItemReviewDraft> drafts;

  /// The athlete's own numbers the prescription is read against, so a step
  /// prescribed as a percentage of an assessment states the number the run
  /// counted them down from rather than its fallback.
  final AssessmentResults results;

  const ItemReviewSection({
    required this.drafts,
    this.results = AssessmentResults.none,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did each one go?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Only what you fill in is recorded.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: CrimpyTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        for (final draft in drafts)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ItemReviewCard(draft: draft, results: results),
          ),
      ],
    );
  }
}

/// One line of the review: what was asked for, the numbers it is worth
/// reporting, and the note.
class ItemReviewCard extends StatelessWidget {
  final ItemReviewDraft draft;
  final AssessmentResults results;

  const ItemReviewCard({
    required this.draft,
    this.results = AssessmentResults.none,
    super.key,
  });

  /// One number of the review. Left empty it reports nothing, which is the
  /// common case; typed and unreadable it is refused rather than dropped, since
  /// an athlete who typed a load believes it was recorded.
  Widget _number({
    required TextEditingController controller,
    required String label,
    bool decimal = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        decimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]'),
      ),
    ],
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    validator: (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return null;
      final parsed = decimal
          ? parseAnswer(trimmed)
          : int.tryParse(trimmed)?.toDouble();
      if (parsed == null) return 'Enter a number';
      if (parsed < 0) return 'Cannot be negative';
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    final prescribed = prescribedSummary(draft.item, results);
    final numbers = [
      if (draft.fields.reps) _number(controller: draft.reps, label: 'Reps'),
      if (draft.fields.cycles)
        _number(controller: draft.cycles, label: 'Rounds'),
      if (draft.fields.load)
        _number(controller: draft.loadKg, label: 'Load kg', decimal: true),
      if (draft.fields.duration)
        _number(controller: draft.durationSeconds, label: 'Seconds'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    sessionBlockLabel(draft.item),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Named only for a block played more than once, where the
                // number is what tells two identical lines apart.
                if (draft.occurrence > 0)
                  Text(
                    'Pass ${draft.occurrence + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: CrimpyTheme.textSecondary,
                    ),
                  ),
              ],
            ),
            if (prescribed != null) ...[
              const SizedBox(height: 2),
              Text(
                'Asked $prescribed',
                style: const TextStyle(
                  fontSize: 12,
                  color: CrimpyTheme.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (numbers.isNotEmpty) ...[
              Row(
                children: [
                  for (final (index, field) in numbers.indexed) ...[
                    if (index > 0) const SizedBox(width: 8),
                    Expanded(child: field),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: draft.note,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Hard on the shoulders, did it with a band...',
                border: OutlineInputBorder(),
                isDense: true,
                alignLabelWithHint: true,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              minLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
