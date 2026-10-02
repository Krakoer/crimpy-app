import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/utils/override_labels.dart';
import 'package:crimpy/utils/program_completion.dart';
import 'package:crimpy/utils/training_intensity.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/log_session_screen.dart';
import 'package:crimpy/views/widgets/primary_action_bar.dart';
import 'package:crimpy/views/widgets/start_training_run.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:crimpy/views/widgets/training_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';

/// Detail of a single training scheduled within a program week, with its
/// exercises (overrides merged) and a Start button into the run screen.
class ScheduledTrainingScreen extends ConsumerWidget {
  final Program program;
  final int weekNumber;
  final WeekSession session;

  const ScheduledTrainingScreen({
    required this.program,
    required this.weekNumber,
    required this.session,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingAsync = ref.watch(
      programTrainingProvider(program.id, session.trainingId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(session.trainingTitle)),
      body: SafeArea(
        // Skips both arms while what is being reloaded is the training already
        // on screen: a pull on the dashboard below reaches this, and the
        // athlete reading their session should not lose it to a spinner.
        child: trainingAsync.when(
          skipLoadingOnReload: true,
          skipError: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(CrimpyTheme.spaceXl),
              child: Text(
                'Could not load this training.\n$e',
                textAlign: TextAlign.center,
                style: CrimpyTheme.body.copyWith(
                  color: CrimpyTheme.textPrimary,
                ),
              ),
            ),
          ),
          data: (training) {
            final merged = effectiveTraining(training, session.overrides);
            // The training carries the definitions of the assessments its items
            // read against, which is what names one the athlete has no result
            // for: a coach's assessment is not in the catalog they can fetch.
            final results =
                (ref.watch(assessmentResultsProvider).value ??
                        AssessmentResults.none)
                    .withDefinitions(merged.referencedAssessments);
            return _content(context, ref, merged, results);
          },
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    Training training,
    AssessmentResults results,
  ) {
    final overrideByItem = {for (final o in session.overrides) o.itemId: o};
    final date = session.scheduledDate(program, weekNumber);
    final goal = training.goal?.trim() ?? '';
    final instructions = training.comment?.trim() ?? '';
    final bodyweight = ref.watch(bodyweightProvider).value;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
            children: [
              _infoCard(context, date),
              if (session.overrides.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceMd),
                _tunedBanner(context),
              ],
              if (goal.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceLg),
                const SectionLabel('Goal'),
                const SizedBox(height: CrimpyTheme.spaceSm),
                SectionTextBlock(goal),
              ],
              if (instructions.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceLg),
                const SectionLabel('Instructions'),
                const SizedBox(height: CrimpyTheme.spaceSm),
                SectionTextBlock(instructions),
              ],
              if (training.items.isNotEmpty) ...[
                const SizedBox(height: CrimpyTheme.spaceLg),
                const SectionLabel('Exercises'),
                const SizedBox(height: CrimpyTheme.spaceSm),
                ..._buildItems(
                  training.items,
                  overrideByItem,
                  bodyweight,
                  results,
                  ref.watch(trainingIntensityRaterProvider).value?.maxForce ??
                      MaxForceReference.none,
                ),
              ],
            ],
          ),
        ),
        _actionBar(context, ref, training, results),
      ],
    );
  }

  Widget _infoCard(BuildContext context, DateTime? date) {
    final type = session.activity;
    final schedule = switch (session.schedule) {
      SessionSchedule.dayOfWeek when date != null =>
        '${weekdayShort(date)} - ${formatDayMonth(date)}',
      SessionSchedule.everyday => 'EVERY DAY',
      _ => '${session.timesPerWeek ?? 1}x - ANY DAY',
    };

    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SessionActivityTile(type: type, size: 46),
              const SizedBox(width: CrimpyTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          programSessionLabel(type),
                          style: CrimpyTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CrimpyTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: CrimpyTheme.spaceSm),
                        ScheduleStatusTag(
                          status: scheduleStatusFor(date, currentTrainingDay()),
                        ),
                      ],
                    ),
                    const SizedBox(height: CrimpyTheme.spaceSm),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.calendar,
                          size: 12,
                          color: CrimpyTheme.textMutedSmall,
                        ),
                        const SizedBox(width: CrimpyTheme.spaceSm),
                        Text(
                          schedule,
                          style: CrimpyTheme.bodySmall.copyWith(
                            color: CrimpyTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((session.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: CrimpyTheme.spaceMd),
            _coachNote(session.notes!),
          ],
        ],
      ),
    );
  }

  Widget _coachNote(String note) {
    final initials = program.name.isEmpty
        ? 'C'
        : program.name.trim()[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceMd,
        vertical: CrimpyTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border.all(color: CrimpyTheme.outline, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CrimpyTheme.fillOn(CrimpyTheme.coachNote),
              border: Border.all(color: CrimpyTheme.outline, width: 1.5),
            ),
            child: Text(
              initials,
              style: CrimpyTheme.labelSmall.copyWith(
                color: CrimpyTheme.bgPrimary,
              ),
            ),
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Expanded(
            child: Text(
              note,
              style: CrimpyTheme.bodySmall.copyWith(
                color: CrimpyTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tunedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceMd,
        vertical: CrimpyTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        color: CrimpyTheme.tintOf(CrimpyTheme.overrideMark),
        border: Border.all(color: CrimpyTheme.overrideMark, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.star,
            size: 15,
            color: CrimpyTheme.textOn(CrimpyTheme.overrideMark),
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Expanded(
            child: Text(
              'TUNED FOR YOU THIS WEEK. Highlighted values differ from the base training.',
              style: CrimpyTheme.bodySmall.copyWith(
                color: CrimpyTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems(
    List<TrainingItem> items,
    Map<String, SessionOverride> overrideByItem,
    double? bodyweightKg,
    AssessmentResults results,
    MaxForceReference maxForce,
  ) {
    bool tuned(TrainingItem item) {
      final override = overrideByItem[item.id];
      return override != null && override.overrides.isNotEmpty;
    }

    return buildTrainingItemTiles(
      items,
      bodyweightKg: bodyweightKg,
      results: results,
      maxForce: maxForce,
      accentColorOf: (item) => tuned(item) ? CrimpyTheme.overrideMark : null,
      extraOf: (item) => tuned(item)
          ? [
              Wrap(
                spacing: CrimpyTheme.spaceSm,
                runSpacing: CrimpyTheme.spaceSm,
                children: _overrideChips(
                  overrideByItem[item.id]!.overrides,
                  results,
                  bodyweightKg,
                  item,
                ),
              ),
            ]
          : const [],
    );
  }

  /// [results] is what names the assessment a percentage is read against, so a
  /// chip says "REPS 75% Max pull ups" rather than a percentage of nothing.
  List<Widget> _overrideChips(
    Map<String, dynamic> overrides,
    AssessmentResults results,
    double? bodyweightKg,
    TrainingItem item,
  ) {
    final entries = overrideChipLabels(
      overrides,
      results: results,
      bodyweightKg: bodyweightKg,
      item: item,
    );

    return entries
        .map(
          (e) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CrimpyTheme.spaceSm,
              vertical: CrimpyTheme.spaceXs,
            ),
            decoration: BoxDecoration(
              color: CrimpyTheme.tintOf(CrimpyTheme.overrideMark),
              border: Border.all(color: CrimpyTheme.overrideMark, width: 1.5),
            ),
            child: Text(
              e,
              style: CrimpyTheme.labelSmall.copyWith(
                color: CrimpyTheme.textOn(CrimpyTheme.overrideMark),
              ),
            ),
          ),
        )
        .toList();
  }

  /// Whether this session occurs today: an exact date match for day-of-week
  /// sessions, or the current week for everyday / times-per-week ones.
  bool _isScheduledToday() {
    final today = currentTrainingDay();
    switch (session.schedule) {
      case SessionSchedule.dayOfWeek:
        final date = session.scheduledDate(program, weekNumber);
        return date != null && isSameDay(date, today);
      case SessionSchedule.everyday:
      case SessionSchedule.timesPerWeek:
        return program.isActiveOn(today) &&
            program.currentWeekNumber(today) == weekNumber;
    }
  }

  Widget _actionBar(
    BuildContext context,
    WidgetRef ref,
    Training training,
    AssessmentResults results,
  ) {
    // A training with nothing to step through has nothing to run, so it can only
    // be logged. Derived from the content rather than from the label, so a coach
    // is free to put hangboard work in a session called anything.
    final logOnly = training.items.isEmpty;
    // Read off what the state holds. This screen has no pull of its own, but it
    // sits under the ones that do: a pull on the dashboard or the history
    // invalidates the sessions while this is on the stack, and through asData
    // the training it prescribes would read as never done.
    final sessions = ref.watch(sessionsProvider).value ?? [];
    final done = isScheduledTrainingDone(
      sessions,
      program,
      weekNumber,
      session,
      date: session.scheduledDate(program, weekNumber) ?? currentTrainingDay(),
    );
    return PrimaryActionBar(
      child: done
          ? _doneButton()
          : logOnly
          ? _logButton(context)
          : StartTrainingButton(
              training: training,
              onPressed: () => _startRun(context, ref, training, results),
            ),
    );
  }

  Widget _doneButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceLg),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CrimpyTheme.tintOf(CrimpyTheme.done),
        border: Border.all(color: CrimpyTheme.done, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.circleCheck,
            size: 16,
            color: CrimpyTheme.textOn(CrimpyTheme.done),
          ),
          const SizedBox(width: CrimpyTheme.spaceSm),
          Text(
            'DONE',
            style: CrimpyTheme.titleSmall.copyWith(
              color: CrimpyTheme.textOn(CrimpyTheme.done),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRun(
    BuildContext context,
    WidgetRef ref,
    Training training,
    AssessmentResults results,
  ) => startTrainingRun(
    context,
    ref,
    training,
    activity: session.activity,
    trainingId: session.trainingId,
    programSessionId: session.id,
    results: results,
  );

  Widget _logButton(BuildContext context) {
    final canLog = _isScheduledToday();
    final date = session.scheduledDate(program, weekNumber);
    final label = canLog
        ? 'LOG AS DONE'
        : date != null
        ? 'SCHEDULED ${formatDayMonth(date)}'
        : 'NOT SCHEDULED TODAY';

    return ElevatedButton.icon(
      onPressed: canLog
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LogSessionScreen(
                    activity: session.activity,
                    name: session.trainingTitle,
                    trainingId: session.trainingId,
                    programSessionId: session.id,
                  ),
                ),
              );
            }
          : null,
      icon: const Icon(Icons.check),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceLg),
      ),
    );
  }
}
