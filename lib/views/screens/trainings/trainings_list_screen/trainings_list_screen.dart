import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/pull_to_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/widgets/missing_assessments_dialog.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/widgets/training_list_item.dart';
import 'package:crimpy/views/screens/trainings/trainings_list_screen/widgets/create_training_fab.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_summary_card.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  final VoidCallback goToAssessments;
  const TrainingScreen({required this.goToAssessments, super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final templates = ref.watch(allTrainingsProvider);

    void showMissingAssessmentsDialog(
      List<AssessmentRequirement> missingAssessments,
    ) {
      showDialog(
        context: context,
        builder: (context) => MissingAssessmentsDialog(
          missingAssessments: missingAssessments,
          onGoToAssessments: widget.goToAssessments,
        ),
      );
    }

    return Stack(
      children: [
        PullToRefresh(
          // The list is headed by the program card, which reads the coach's
          // program rather than the athlete's trainings, so a pull that asked
          // only for the trainings would leave the top of the screen stale.
          onRefresh: () async {
            ref.invalidate(programsProvider);
            ref.invalidate(weekDetailProvider);
            await Future.wait([
              ref.refresh(allTrainingsProvider.future),
              ref.read(activeProgramProvider.future),
              ref.read(todayTrainingProvider.future),
            ]);
          },
          // Matched on what the state holds rather than on which state it is:
          // a refresh is an AsyncLoading carrying the previous list, and an
          // AsyncData arm would swap the list the athlete is looking at for a
          // spinner the moment they pulled it.
          child: switch (templates) {
            AsyncValue(:final value?) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 80.0, // Extra padding for FAB
              ),
              children: [
                const ProgramSummaryCard(),
                ...value.map(
                  (item) => TrainingListItemWidget(
                    item: item,
                    onMissingAssessments: () =>
                        showMissingAssessmentsDialog(item.missingAssessments),
                  ),
                ),
              ],
            ),
            AsyncValue(:final error?) => RefreshableColumn(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('Oops $error')),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
        Positioned(right: 16.0, bottom: 16.0, child: CreateTrainingFab()),
      ],
    );
  }
}
