import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';

/// Says that the list below is the start of the athlete's library rather than
/// all of it.
///
/// The server caps a library read, so a cut answer and a small one are the same
/// rows. Without this an athlete past the ceiling sees trainings they own
/// simply missing, with nothing to say they still exist, which reads as data
/// loss rather than as a limit.
///
/// Renders nothing at all until the library is both read and cut. A banner that
/// appeared while the library loaded would flash on every pull to refresh, and
/// an error reaching here would be the second report of a failure the list
/// itself already shows.
class TruncatedLibraryNotice extends ConsumerWidget {
  const TruncatedLibraryNotice({super.key});

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
              'Showing the first part of your library. Some trainings are not '
              'listed here. Open one from the web app to reach the rest.',
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
