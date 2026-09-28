import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/views/widgets/truncated_library_notice.dart';
import 'package:crimpy/utils/duration_format.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/widgets/home_card.dart';
import 'package:crimpy/views/screens/trainings/training_details_screen.dart';
import 'package:crimpy/views/widgets/intensity_badge.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavoriteTrainingList extends ConsumerWidget {
  /// Displays the list of favorite training as cards.
  /// Cards are clickable and allow the user to start trainings.
  /// The user can edit the favorite trainings by clicking the `Pin a training` button.
  const FavoriteTrainingList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned = ref.watch(pinnedTrainingsProvider);
    return HomeCard(
      title: "Favorite Trainings",
      // Matched on what the state holds rather than on which state it is, so a
      // pull refetching the list leaves it on screen instead of collapsing the
      // card to a spinner and back.
      child: switch (pinned) {
        // Sized to the list rather than held at a fixed height: this card
        // leads the home screen, and a fixed box scrolled its own list and
        // cut the "Pin a training" button off under the fold of the card.
        // The home screen scrolls, so a long list is reached from there.
        // See Krakoer/crimpy#165.
        AsyncValue(:final value?) => Column(
          children: [
            // The favourites are filtered out of the same capped library,
            // and the cut is alphabetical rather than favourite aware, so a
            // favourite titled late in the alphabet drops off this card
            // with nothing else on the home screen to say why. Compact
            // so it does not push the favourites down the screen.
            const TruncatedLibraryNotice(compact: true),
            // ListView for favorite trainings (regular favorites + favorited builtins).
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              // The home screen does the scrolling; a list that took the drag
              // itself would stop the page under a finger on a favourite.
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.length,
              itemBuilder: (context, index) {
                final item = value[index];
                // Skip unavailable builtin trainings
                if (!item.isAvailable) return SizedBox.shrink();

                // Favorite training Card.
                return CrimpyCards.training(
                  raised: true,
                  padding: EdgeInsets.all(0),
                  child: ListTile(
                    // On tap, show the details to allow the user to start the training.
                    onTap: () {
                      if (item.training != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => TrainingDetailScreen(
                              item.training!,
                              trainingId: item.isBuiltin
                                  ? null
                                  : item.training!.id,
                            ),
                          ),
                        );
                      }
                    },
                    title: Text(
                      item.name,
                      style: CrimpyTheme.titleSmall.copyWith(
                        color: CrimpyTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.stopwatch,
                          color: CrimpyTheme.textFaint,
                          size: 17,
                        ),
                        SizedBox(width: CrimpyTheme.spaceSm),
                        Text(formatLength(item.totalDuration)),
                        if (item.intensity != null) ...[
                          const SizedBox(width: CrimpyTheme.spaceMd),
                          IntensityBadge(item.intensity!),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: CrimpyTheme.spaceSm),
            // Button to show the dialog to manage favorite trainings.
            DottedBorder(
              options: RoundedRectDottedBorderOptions(
                borderPadding: EdgeInsets.all(CrimpyTheme.spaceXs),
                dashPattern: [10, 5],
                strokeWidth: 2,
                radius: CrimpyTheme.corner,
                color: CrimpyTheme.textPrimary.withValues(alpha: 0.5),
              ),
              child: InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => PinTrainingDialog(),
                ),
                child: Container(
                  padding: EdgeInsets.all(CrimpyTheme.spaceLg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: CrimpyTheme.textPrimary, size: 30),
                      SizedBox(width: CrimpyTheme.spaceSm),
                      Text(
                        "Pin a training",
                        style: CrimpyTheme.title.copyWith(
                          color: CrimpyTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        AsyncValue(:final error?) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                // The read that failed was one of the two this list is built
                // from. Invalidating the list alone would rebuild it from the
                // same failed future and never ask again.
                onPressed: () {
                  ref.invalidate(trainingLibraryProvider);
                  ref.invalidate(builtinTrainingCatalogProvider);
                  // The catalog derives the history rather than reading it, so
                  // a failure that came from there survives a catalog drop: the
                  // rebuild watches the same failed future. The root is what
                  // has to go for the retry to reach the server.
                  ref.invalidate(assessmentHistoryProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class PinTrainingDialog extends ConsumerWidget {
  /// Dialog to allow the user to toggle the favorite status of trainings.
  /// Both regular and builtin trainings show a heart icon.
  const PinTrainingDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableTrainings = ref.watch(allTrainingsProvider);
    return AlertDialog(
      // Title and content share one scroll view. AlertDialog otherwise makes
      // the content Flexible and the title not, so a title that grows takes its
      // room off the list and, once it is taller than the dialog itself, simply
      // overflows: 70 pixels on a 320x568 screen at double text scale, with the
      // notice showing. Scrolling the pair keeps everything reachable instead.
      scrollable: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Favorite a training"),
          // Above the content rather than inside it. The content is a fixed
          // 300dp box, and a notice in there eats the list's height: the full
          // paragraph left under one row of a two hundred entry list visible,
          // on the only library that can ever show it.
          const TruncatedLibraryNotice(compact: true),
        ],
      ),
      // Matched on what the state holds: toggling a favourite invalidates the
      // list this reads, so through AsyncData the dialog would collapse to a
      // spinner and back on every tap.
      content: switch (availableTrainings) {
        // A tight size rather than a maximum. AlertDialog measures its
        // content's intrinsic width, and a lazy ListView has none to give: a
        // list that only had a maximum made that layout throw, and the athlete
        // got an empty dialog. On a short screen the dialog scrolls the title
        // and this box together, so the list is reached by scrolling rather
        // than squeezed.
        AsyncValue(:final value?) => SizedBox(
          width: 300,
          height: 300,
          child: value.isEmpty
              ? Center(
                  child: Text(
                    "You don't have any training available yet.\n\nDo an assessment to unlock personalised trainings, or create your own trainings in the trainings page!",
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (contex, index) {
                    final item = value[index];

                    // Skip unavailable builtin trainings in pin dialog
                    if (!item.isAvailable) return SizedBox.shrink();

                    return ListTile(
                      // Heart icon to represent the favorite status.
                      trailing: Icon(
                        item.isPinned
                            ? FontAwesomeIcons.solidHeart
                            : FontAwesomeIcons.heart,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      // On tap, toggle the status.
                      onTap: () async {
                        if (item.isBuiltin) {
                          await ref
                              .read(pinnedTrainingsProvider.notifier)
                              .togglePin(item.id);
                        } else {
                          await ref
                              .read(favTrainingsProvider.notifier)
                              .toggleFav(item.id);
                        }
                        // Nothing to invalidate here: a favourite is a field
                        // on the training and a pin is not, so each toggle
                        // drops exactly what it changed and both lists are
                        // rebuilt from it.
                      },
                      title: Text(
                        item.name,
                        style: CrimpyTheme.titleSmall.copyWith(
                          color: CrimpyTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.stopwatch,
                            color: CrimpyTheme.textFaint,
                            size: 17,
                          ),
                          SizedBox(width: CrimpyTheme.spaceSm),
                          Flexible(
                            child: Text(
                              formatLength(item.totalDuration),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        AsyncValue(:final error?) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                // As above: the failure came from a read behind this list,
                // so that is what has to be dropped.
                onPressed: () {
                  ref.invalidate(trainingLibraryProvider);
                  ref.invalidate(builtinTrainingCatalogProvider);
                  // The catalog derives the history rather than reading it, so
                  // a failure that came from there survives a catalog drop: the
                  // rebuild watches the same failed future. The root is what
                  // has to go for the retry to reach the server.
                  ref.invalidate(assessmentHistoryProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      // The choices are the list itself, each saved as it is tapped, so the
      // one action closes the dialog.
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
