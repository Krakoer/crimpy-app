import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/duration_format.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/widgets/intensity_badge.dart';
import 'package:crimpy/views/widgets/primary_action_bar.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:crimpy/views/widgets/start_training_run.dart';
import 'package:crimpy/views/widgets/training_item_tile.dart';
import 'package:crimpy/views/screens/trainings/widgets/habit_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A training the athlete is about to run, stated the way they will set up for
/// it: how long it takes and how hard it is, then each block with its hand,
/// grip, edge and load, and Start pinned under it all. See Krakoer/crimpy#163.
class TrainingDetailScreen extends ConsumerWidget {
  final Training template;

  /// Id of the training row the run is played from, carried onto the session so
  /// its reps can name the blocks they came from. Null for a builtin, which is
  /// generated on the fly and has no row of its own to link to.
  final String? trainingId;

  const TrainingDetailScreen(this.template, {this.trainingId, super.key});

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
    final rater = ref.watch(trainingIntensityRaterProvider).value;
    final intensity = rater?.rate(template);
    final length = Duration(
      seconds: trainingDurationSeconds(template, results: results),
    );

    return Scaffold(
      appBar: AppBar(title: Text(template.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
          children: [
            _Summary(length: length, intensity: intensity),
            const SizedBox(height: CrimpyTheme.spaceLg),
            // Only a training of the athlete's own: a builtin runs with no id,
            // so none of its sessions could ever count for the habit.
            if (trainingId case final id?) ...[
              HabitSection(trainingId: id),
              const SizedBox(height: CrimpyTheme.spaceLg),
            ],
            if (goal.isNotEmpty) ...[
              const SectionLabel('Goal'),
              const SizedBox(height: CrimpyTheme.spaceSm),
              SectionTextBlock(goal),
              const SizedBox(height: CrimpyTheme.spaceLg),
            ],
            if (comment.isNotEmpty) ...[
              const SectionLabel('Instructions'),
              const SizedBox(height: CrimpyTheme.spaceSm),
              SectionTextBlock(comment),
              const SizedBox(height: CrimpyTheme.spaceLg),
            ],
            if (template.items.isNotEmpty) ...[
              const SectionLabel('Exercises'),
              const SizedBox(height: CrimpyTheme.spaceSm),
              ...buildTrainingItemTiles(
                template.items,
                bodyweightKg: bodyweightKg,
                results: results,
                maxForce: rater?.maxForce ?? MaxForceReference.none,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: PrimaryActionBar(
          child: StartTrainingButton(
            training: template,
            onPressed: () => startTrainingRun(
              context,
              ref,
              template,
              activity: SessionActivity.hangboard,
              trainingId: trainingId,
              results: results,
              replaceCurrentRoute: true,
            ),
          ),
        ),
      ),
    );
  }
}

/// How long the training runs and how hard it is, as its card on the list
/// says it.
class _Summary extends StatelessWidget {
  final Duration length;
  final TrainingIntensity? intensity;

  const _Summary({required this.length, required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CrimpyTheme.spaceMd,
      runSpacing: CrimpyTheme.spaceXs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FontAwesomeIcons.stopwatch,
              color: CrimpyTheme.textMutedSmall,
              size: 16,
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
            Text(
              formatLength(length),
              style: CrimpyTheme.tabular(
                CrimpyTheme.body,
              ).copyWith(color: CrimpyTheme.textPrimary),
            ),
          ],
        ),
        if (intensity != null) IntensityBadge(intensity!),
      ],
    );
  }
}
