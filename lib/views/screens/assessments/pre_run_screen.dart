import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/views/screens/assessments/mvc_run_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreRunScreen extends ConsumerWidget {
  final AssessmentType type;
  const PreRunScreen({required this.type, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AssessmentTrainingModel>>(
      assessmentTrainingProvider(AssessmentType.mvc),
      (previous, next) {
        next.whenData((data) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (ctx) => switch (type) {
                    AssessmentType.mvc || AssessmentType.mvc3fd => MvcRunScreen(
                      reps: data.training.reps,
                      type: type,
                    ),
                    AssessmentType.criticalForce => Text("NOT IMPL"),
                  },
            ),
          );
        });
      },
    );

    final assessment = ref.watch(
      assessmentTrainingProvider(AssessmentType.mvc),
    );

    return Container(
      child: switch (assessment) {
        AsyncData() => Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => Center(
          child: Text("Error while loading assessment: $error"),
        ),
        AsyncLoading() => Center(child: CircularProgressIndicator()),
      },
    );
  }
}
