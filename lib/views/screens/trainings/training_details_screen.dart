import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/widgets/bodyweight_dialog.dart';
import 'package:crimpy/views/widgets/training_item_tile.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';

class TrainingDetailScreen extends ConsumerWidget {
  final Training template;

  /// Id of the training row the run is played from, carried onto the session so
  /// its reps can name the blocks they came from. Null for a builtin, which is
  /// generated on the fly and has no row of its own to link to.
  final String? trainingId;

  const TrainingDetailScreen(this.template, {this.trainingId, super.key});

  /// Starts the run, asking for the body weight first when the training is
  /// loaded in percent of it and none is known yet.
  Future<void> _startRun(
    BuildContext context,
    WidgetRef ref,
    AssessmentResults results,
  ) async {
    final bodyweight = await resolveBodyweight(context, ref, template);
    if (!context.mounted) return;
    ref.read(bleSessionProvider.notifier).reset();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => PlayTrainingScreen(
          template,
          trainingId: trainingId,
          bodyweightKg: bodyweight,
          results: results,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = template.goal?.trim() ?? '';
    final comment = template.comment?.trim() ?? '';
    final bodyweightKg = ref.watch(bodyweightProvider).value;
    // The training carries the definitions of the assessments its items read
    // against, which is what names one the athlete has no result for: a
    // coach's assessment is not in the catalog they can fetch.
    final results =
        (ref.watch(assessmentResultsProvider).value ?? AssessmentResults.none)
            .withDefinitions(template.referencedAssessments);

    return Scaffold(
      appBar: AppBar(title: Text(template.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (goal.isNotEmpty) ...[
              const SectionLabel('Goal'),
              const SizedBox(height: 8),
              SectionTextBlock(goal),
              const SizedBox(height: 16),
            ],
            if (comment.isNotEmpty) ...[
              const SectionLabel('Instructions'),
              const SizedBox(height: 8),
              SectionTextBlock(comment),
              const SizedBox(height: 16),
            ],
            if (template.items.isNotEmpty) ...[
              const SectionLabel('Exercises'),
              const SizedBox(height: 8),
              ...buildTrainingItemTiles(
                template.items,
                bodyweightKg: bodyweightKg,
                results: results,
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: IconButton(
        onPressed:
            ref.watch(connectionStateProvider) != BleConnectionState.connected
            ? null
            : () => _startRun(context, ref, results),
        icon: Icon(Icons.play_arrow),
      ),
    );
  }
}
