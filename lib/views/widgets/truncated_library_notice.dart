import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';

/// Says that the library behind the screen is the start of the athlete's
/// library rather than all of it.
///
/// The server caps a library read, so a cut answer and a small one are the same
/// rows. Without this an athlete past the ceiling sees trainings they own
/// simply missing, with nothing to say they still exist, which reads as data
/// loss rather than as a limit.
///
/// It lives here rather than beside one screen because every screen built on
/// the library has the same hole: the trainings list, the assessments the
/// athlete can record, and the dialog that picks a training to favourite all
/// read the capped list, and a training past the ceiling is unreachable from
/// each of them.
///
/// Renders nothing at all until the library is both read and cut. A banner that
/// appeared while the library loaded would flash on every pull to refresh, and
/// an error reaching here would be the second report of a failure the screen
/// itself already shows.
///
/// Watching [trainingLibraryTruncatedProvider] rather than the library means it
/// costs no request of its own and does not rebuild when the trainings change.
class TruncatedLibraryNotice extends ConsumerWidget {
  /// Shortens the message to a single line, for somewhere the full paragraph
  /// would cost more room than it is worth. The pin dialog is a fixed 300dp
  /// box: the paragraph wrapped to six lines there and left under one row of
  /// the training list visible, which took the screen away from the only
  /// athlete who would ever see the notice on it.
  final bool compact;

  const TruncatedLibraryNotice({super.key, this.compact = false});

  /// What the notice says.
  ///
  /// It states what happened and stops. An earlier version told the athlete to
  /// open their library in the web app, which is false for everyone who reads
  /// it: the portal is coach facing, and its trainings page sends anyone who is
  /// not a validated coach to the dashboard. A notice whose advice cannot be
  /// followed is worse than one that gives none.
  ///
  /// It names the order rather than the screen, because the same library backs
  /// the trainings list, the recordable assessments, the favourites and the pin
  /// dialog, and the alphabetical cut is the one fact that lets an athlete work
  /// out what is missing from any of them.
  static const _full =
      'Only the start of your library is loaded, ordered by training name. '
      'Anything later in the alphabet is not shown here.';
  static const _short = 'Only the start of your library is loaded.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final truncated = ref.watch(trainingLibraryTruncatedProvider).value;
    if (truncated != true) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgInfo,
        borderRadius: BorderRadius.circular(CrimpyTheme.radiusSmall),
        border: Border.all(color: CrimpyTheme.statusInfo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The icon is a mark rather than text, so it takes the accent at its
          // mark strength and the sentence beside it carries the meaning.
          Icon(
            Icons.info_outline,
            size: 18.0,
            color: CrimpyTheme.markOn(CrimpyTheme.statusInfo),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              compact ? _short : _full,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: CrimpyTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
