import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/widgets/home_card.dart';
import 'package:crimpy/views/screens/trainings/training_details_screen.dart';
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
    final favs = ref.watch(favTrainingsProvider);
    return HomeCard(
      title: "Pinned Trainings",
      child: switch (favs) {
        AsyncData(:final value) => SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ListView for favorite trainings.
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    // Favorite training Card.
                    return CrimpyCards.training(
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        // On tap, show the details to allow the user to start the training.
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (ctx) => TrainingDetailScreen(value[index]),
                              ),
                            ),
                        title: Text(
                          value[index].name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.stopwatch,
                              color: CrimpyTheme.gray400,
                              size: 17,
                            ),
                            SizedBox(width: 6),
                            Text(
                              formatDurationMinSec(value[index].totalDuration),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8),
                // Button to show the dialog to manage favorite trainings.
                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    borderPadding: EdgeInsets.all(2),
                    dashPattern: [10, 5],
                    strokeWidth: 2,
                    radius: Radius.circular(16),
                    color: CrimpyTheme.primaryBlack.withValues(alpha: 0.5),
                  ),
                  child: InkWell(
                    onTap:
                        () => showDialog(
                          context: context,
                          builder: (ctx) => PinTrainingDialog(),
                        ),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: CrimpyTheme.primaryBlack,
                            size: 30,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Pin a training",
                            style: TextStyle(
                              fontSize: 18,
                              color: CrimpyTheme.primaryBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AsyncError(:final error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(favTrainingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class PinTrainingDialog extends ConsumerWidget {
  /// Dialog to allow the user to toggle the favorite status of trainings.
  /// The favorite status is shown using a filled/empty heart icon.
  const PinTrainingDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableTrainings = ref.watch(trainingsProvider);
    return AlertDialog(
      title: Text("Pin a new training"),
      content: switch (availableTrainings) {
        AsyncData(:final value) => SingleChildScrollView(
          child: SizedBox(
            width: 300,
            height: 300,
            child:
                value.isEmpty
                    ? Center(
                      child: Text(
                        "You don't have any training available yet.\n\nDo an assessment to unlock personalised trainings, or create your own trainings in the trainings page!",
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      itemCount: value.length,
                      itemBuilder:
                          (contex, index) => ListTile(
                            // Heart icon to represent the favorite status.
                            trailing: Icon(
                              value[index].isFav
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            // On tap, toggle the status. Let the user pop the dialog if they want to pin/unpin mutliple trainings.
                            onTap: () {
                              ref
                                  .read(favTrainingsProvider.notifier)
                                  .toggleFav(value[index].id);
                            },
                            title: Text(
                              value[index].name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.stopwatch,
                                  color: CrimpyTheme.gray400,
                                  size: 17,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  formatDurationMinSec(
                                    value[index].totalDuration,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
          ),
        ),
        AsyncError(:final error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(favTrainingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
