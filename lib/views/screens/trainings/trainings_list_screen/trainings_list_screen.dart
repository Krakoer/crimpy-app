import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/widgets/missing_assessments_dialog.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/widgets/training_list_item.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/widgets/create_training_fab.dart';

class TrainingScreen extends ConsumerWidget {
  final VoidCallback goToAssessments;
  const TrainingScreen({required this.goToAssessments, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(allTrainingsProvider);

    void showMissingAssessmentsDialog(
      List<AssessmentRequirement> missingAssessments,
    ) {
      showDialog(
        context: context,
        builder:
            (context) => MissingAssessmentsDialog(
              missingAssessments: missingAssessments,
              onGoToAssessments: goToAssessments,
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
                          (item) => TrainingListItemWidget(
                            item: item,
                            onMissingAssessments:
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
          child: CreateTrainingFab(),
        ),
      ],
    );
  }
}
