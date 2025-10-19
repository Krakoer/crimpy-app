import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/training_creation_screen/custom_training_creation_screen.dart';
import 'package:crimpy/views/screens/trainings/repeater_creation_screen.dart';
import 'package:crimpy/views/screens/trainings/training_details_screen.dart';

class TrainingScreen extends ConsumerWidget {
  final VoidCallback goToAssessments;
  const TrainingScreen({required this.goToAssessments, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(allTrainingsProvider);

    void showMissingAssessmentsDialog(List<AssessmentType> missingAssessments) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Assessment Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This training requires the following assessments:'),
                  SizedBox(height: 8),
                  ...missingAssessments.map(
                    (type) => Text('• ${assessmentTypeToString(type)}'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    goToAssessments();
                  },
                  child: Text('Go to Assessments'),
                ),
              ],
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: switch (templates) {
            AsyncData(:final value) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children:
                    value
                        .map(
                          (item) => _buildTrainingListItem(
                            item,
                            context,
                            ref,
                            () => showMissingAssessmentsDialog(
                              item.missingAssessments,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            AsyncError(:final error) => Text('Oops $error'),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
          child: SpeedDial(
            activeIcon: Icons.close,
            spaceBetweenChildren: 10,
            children: [
              SpeedDialChild(
                child: Icon(FontAwesomeIcons.ruler),
                label: "Custom training",
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrainingCreationScreen(),
                      ),
                    ),
              ),
              SpeedDialChild(
                child: Icon(FontAwesomeIcons.repeat),
                label: "Repeater training",
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RepeaterCreationScreen(),
                      ),
                    ),
              ),
            ],
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingListItem(
    TrainingListItem item,
    BuildContext ctx,
    WidgetRef ref,
    VoidCallback onMissingAssessments,
  ) {
    Widget cardContent = CrimpyCards.training(
      onTap:
          item.isAvailable
              ? () {
                if (item.training != null) {
                  Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (ctx) => TrainingDetailScreen(item.training!),
                    ),
                  );
                }
              }
              : onMissingAssessments,
      child: Row(
        children: [
          // Icon
          if (item.isBuiltin)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CrimpyTheme.trainingColor.withValues(alpha: 0.1),
                border: Border.all(color: CrimpyTheme.trainingColor, width: 1),
              ),
              child: Icon(
                FontAwesomeIcons.bolt,
                color: CrimpyTheme.trainingColor,
                size: 16,
              ),
            ),
          if (item.isBuiltin) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(item.name, style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 4),
                // Description
                if (item.isBuiltin && item.description.isNotEmpty) ...[
                  Text(
                    item.description,
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                ],
                // Duration info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.stopwatch,
                      color: CrimpyTheme.textMuted,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.isAvailable
                          ? formatDurationMinSec(item.totalDuration)
                          : 'Assessment required',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color:
                            item.isAvailable
                                ? CrimpyTheme.textSecondary
                                : CrimpyTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons for custom trainings
          if (item.isRegular) ...[
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: CrimpyTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed:
                      () => Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  item.training!.repeater == null
                                      ? TrainingCreationScreen(
                                        originalTraining: item.training!,
                                      )
                                      : RepeaterCreationScreen(
                                        originalTemplate: item.training!,
                                      ),
                        ),
                      ),
                  tooltip: 'Edit Training',
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: CrimpyTheme.statusError,
                    size: 20,
                  ),
                  onPressed: () {
                    showDialog(
                      context: ctx,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Delete Training?'),
                            content: const Text(
                              'This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(trainingsProvider.notifier)
                                      .deleteTraining(item.id);
                                  ref
                                      .read(allTrainingsProvider.notifier)
                                      .refreshBuiltinAvailability();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  tooltip: 'Delete Training',
                ),
              ],
            ),
          ] else ...[
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: CrimpyTheme.textSecondary,
              size: 16,
            ),
          ],
        ],
      ),
    );
    if (!item.isAvailable) {
      final filter = 1.3;
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          cardContent,
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: filter, sigmaY: filter),
                child: Container(),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onMissingAssessments,
            icon: const Icon(Icons.assessment, size: 20),
            label: const Text(
              'Test before training!',
              style: TextStyle(fontSize: 17),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 32),
            ),
          ),
        ],
      );
    }

    return cardContent;
  }
}
