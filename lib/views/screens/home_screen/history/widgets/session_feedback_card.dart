import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The feedback exchanged about a session: the notes the athlete left after the
/// run, and the answer their coach wrote to them. One card rather than two, so
/// an answer is read next to what it answers.
class SessionFeedbackCard extends StatelessWidget {
  final String? notes;
  final String? coachReply;
  final DateTime? coachReplyAt;

  /// Whether the answer is still unread, which is what the highlight marks.
  /// Reading it here is what clears the badge in the history list.
  final bool unread;

  const SessionFeedbackCard({
    super.key,
    this.notes,
    this.coachReply,
    this.coachReplyAt,
    this.unread = false,
  });

  /// Whether there is anything to show at all. A session nobody wrote about
  /// carries no card.
  static bool hasContent({String? notes, String? coachReply}) =>
      (notes != null && notes.isNotEmpty) ||
      (coachReply != null && coachReply.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final reply = coachReply;
    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const _SectionLabel('How you felt'),
            const SizedBox(height: 4),
            Text(notes!, style: const TextStyle(fontSize: 14)),
          ],
          if (reply != null && reply.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const _SectionLabel('Your coach answered'),
                if (unread) ...[const SizedBox(width: 8), const _NewBadge()],
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgSecondary,
                borderRadius: BorderRadius.circular(CrimpyTheme.radiusSmall),
                border: Border(
                  left: BorderSide(color: CrimpyTheme.primaryOrange, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reply, style: const TextStyle(fontSize: 14)),
                  if (coachReplyAt case final answeredAt?) ...[
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM d, yyyy').format(answeredAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: CrimpyTheme.textMutedSmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
      color: CrimpyTheme.textSecondary,
    ),
  );
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: CrimpyTheme.fillOn(CrimpyTheme.primaryOrange),
      borderRadius: BorderRadius.circular(CrimpyTheme.radiusSmall),
    ),
    child: const Text(
      'NEW',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        color: CrimpyTheme.primaryWhite,
      ),
    ),
  );
}
