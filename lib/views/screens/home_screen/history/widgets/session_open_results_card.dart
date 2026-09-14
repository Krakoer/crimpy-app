import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:flutter/material.dart';

/// What the athlete reported on the steps they were prescribed: the numbers
/// they reached, and the line they wrote about each one. Nothing else records
/// any of it, since a set of pull ups passes through no sensor, so this card is
/// the only place it shows up.
class SessionOpenResultsCard extends StatelessWidget {
  final List<ReportedItem> items;

  const SessionOpenResultsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

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
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _ReportedItemRow(item: item),
            ),
        ],
      ),
    );
  }
}

/// One prescribed item and every pass of it the athlete reported on. The
/// numbers of all its passes stay on the heading line, the way they read before
/// notes existed; a note is its own line under them, since a sentence beside a
/// count reads as neither.
class _ReportedItemRow extends StatelessWidget {
  final ReportedItem item;

  const _ReportedItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final achieved = [
      for (final pass in item.passes)
        if (pass.achieved case final value?) value,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(item.label, style: const TextStyle(fontSize: 14)),
            ),
            if (achieved.isNotEmpty) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    achieved.join(', '),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CrimpyTheme.primaryOrange,
                    ),
                  ),
                  if (item.prescribed case final prescribed?)
                    Text(
                      prescribed,
                      style: const TextStyle(
                        fontSize: 11,
                        color: CrimpyTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        for (final pass in item.passes)
          if (pass.note case final note?)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                note,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  color: CrimpyTheme.textSecondary,
                ),
              ),
            ),
      ],
    );
  }
}
