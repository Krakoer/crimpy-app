import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
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
          const SectionHeading('Feedback'),
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: CrimpyTheme.spaceSm),
            const SectionHeading('How you felt'),
            const SizedBox(height: CrimpyTheme.spaceXs),
            Text(notes!, style: CrimpyTheme.body),
          ],
          if (reply != null && reply.isNotEmpty) ...[
            const SizedBox(height: CrimpyTheme.spaceLg),
            Row(
              children: [
                const SectionHeading('Your coach answered'),
                if (unread) ...[
                  const SizedBox(width: CrimpyTheme.spaceSm),
                  const _NewBadge(),
                ],
              ],
            ),
            const SizedBox(height: CrimpyTheme.spaceSm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(CrimpyTheme.spaceMd),
              decoration: BoxDecoration(
                color: CrimpyTheme.bgSecondary,
                borderRadius: CrimpyTheme.corners,
                border: Border(
                  left: BorderSide(color: CrimpyTheme.coachNote, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reply, style: CrimpyTheme.body),
                  if (coachReplyAt case final answeredAt?) ...[
                    const SizedBox(height: CrimpyTheme.spaceSm),
                    Text(
                      DateFormat('MMM d, yyyy').format(answeredAt),
                      style: CrimpyTheme.bodySmall.copyWith(
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

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: CrimpyTheme.spaceSm,
      vertical: CrimpyTheme.spaceXs,
    ),
    decoration: BoxDecoration(
      color: CrimpyTheme.fillOn(CrimpyTheme.coachNote),
      borderRadius: CrimpyTheme.corners,
    ),
    child: Text(
      'NEW',
      style: CrimpyTheme.capsLabel.copyWith(color: CrimpyTheme.textOnFill),
    ),
  );
}
