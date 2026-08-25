import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:flutter/material.dart';

/// One item the prescription left open and what the run answered it with, in
/// the order the passes were played.
typedef OpenItemResult = ({String label, String prescribed, List<int> values});

/// Reads the counts a run recorded against the items they answer, so each one
/// is shown next to what was asked for rather than as a bare number. A count
/// naming an item the prescription no longer holds is left out: there is
/// nothing to head it with.
List<OpenItemResult> openItemResults(SessionModel session) {
  final items = session.prescriptionItems;
  if (items == null || session.itemResults.isEmpty) return const [];
  final byId = trainingItemsById(items);

  final ordered = [...session.itemResults]
    ..sort((a, b) => a.occurrence.compareTo(b.occurrence));
  final values = <String, List<int>>{};
  for (final result in ordered) {
    if (!byId.containsKey(result.trainingItemId)) continue;
    (values[result.trainingItemId] ??= []).add(result.value);
  }

  final out = <OpenItemResult>[];
  for (final item in byId.values) {
    final done = values[item.id];
    if (done == null) continue;
    out.add((
      label: sessionBlockLabel(item),
      prescribed: item.type == TrainingItemType.emom
          ? 'of ${item.cycles ?? 1} rounds'
          : 'reps, as many as possible',
      values: done,
    ));
  }
  return out;
}

/// What the athlete managed on the steps the coach left open. Neither an AMRAP
/// nor an emom the athlete dropped out of leaves a rep behind, so this card is
/// the only place either shows up.
class SessionOpenResultsCard extends StatelessWidget {
  final SessionModel session;

  const SessionOpenResultsCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final results = openItemResults(session);
    if (results.isEmpty) return const SizedBox.shrink();

    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you managed',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final result in results)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      result.label,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        result.values.join(', '),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CrimpyTheme.primaryOrange,
                        ),
                      ),
                      Text(
                        result.prescribed,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CrimpyTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
