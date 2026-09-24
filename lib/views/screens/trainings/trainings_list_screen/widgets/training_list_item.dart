import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/models/training_list_item.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/views/screens/trainings/training_details_screen.dart';
import 'package:crimpy/views/screens/trainings/training_creation_screen.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/widgets/delete_training_dialog.dart';

class TrainingListItemWidget extends ConsumerWidget {
  final TrainingListItem item;
  final VoidCallback onMissingAssessments;

  const TrainingListItemWidget({
    required this.item,
    required this.onMissingAssessments,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget cardContent = CrimpyCards.training(
      onTap: item.isAvailable
          ? () {
              if (item.training != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TrainingDetailScreen(
                      item.training!,
                      trainingId: item.isBuiltin ? null : item.training!.id,
                    ),
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
                color: CrimpyTheme.textOn(CrimpyTheme.trainingColor),
                size: 16,
              ),
            ),
          if (item.isBuiltin) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(item.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                // Description
                if (item.isBuiltin && item.description.isNotEmpty) ...[
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                ],
                // Duration info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.stopwatch,
                      color: CrimpyTheme.textMutedSmall,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.isAvailable
                          ? formatDurationMinSec(item.totalDuration)
                          : 'Assessment required',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: item.isAvailable
                            ? CrimpyTheme.textSecondary
                            : CrimpyTheme.textMutedSmall,
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
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UnifiedTrainingCreationScreen(
                        originalTraining: item.training!,
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
                      context: context,
                      builder: (context) =>
                          DeleteTrainingDialog(trainingId: item.id),
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
