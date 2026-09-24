import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';
import 'package:crimpy/utils/override_labels.dart';
import 'package:crimpy/utils/program_completion.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/log_session_screen.dart';
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
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load this training.\n$e',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
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
            padding: const EdgeInsets.all(16),
            children: [
              _infoCard(context, date),
              if (session.overrides.isNotEmpty) ...[
                const SizedBox(height: 12),
                _tunedBanner(context),
              ],
              if (goal.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionLabel('Goal'),
                const SizedBox(height: 8),
                SectionTextBlock(goal),
              ],
              if (instructions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionLabel('Instructions'),
                const SizedBox(height: 8),
                SectionTextBlock(instructions),
              ],
              if (training.items.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionLabel('Exercises'),
                const SizedBox(height: 8),
                ..._buildItems(
                  training.items,
                  overrideByItem,
                  bodyweight,
                  results,
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
    final color = programSessionColor(type);
    final schedule = switch (session.schedule) {
      SessionSchedule.dayOfWeek when date != null =>
        '${weekdayShort(date)} - ${formatDayMonth(date)}',
      SessionSchedule.everyday => 'EVERY DAY',
      _ => '${session.timesPerWeek ?? 1}x - ANY DAY',
    };

    return CrimpyCard.category(
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SessionActivityTile(type: type, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          programSessionLabel(type),
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CrimpyTheme.textOn(color),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ScheduleStatusTag(
                          status: scheduleStatusFor(date, DateTime.now()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.calendar,
                          size: 12,
                          color: CrimpyTheme.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          schedule,
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 11,
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
            const SizedBox(height: 13),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border.all(color: CrimpyTheme.borderDefault, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CrimpyTheme.primaryOrange,
              border: Border.all(color: CrimpyTheme.borderDefault, width: 1.5),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: CrimpyTheme.bgPrimary,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11.5,
                height: 1.45,
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: CrimpyTheme.tintOf(CrimpyTheme.accentYellow),
        border: Border.all(color: CrimpyTheme.accentYellow, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.star,
            size: 15,
            color: CrimpyTheme.textOn(CrimpyTheme.accentYellow),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'TUNED FOR YOU THIS WEEK. Highlighted values differ from the base training.',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                height: 1.45,
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
  ) {
    bool tuned(TrainingItem item) {
      final override = overrideByItem[item.id];
      return override != null && override.overrides.isNotEmpty;
    }

    return buildTrainingItemTiles(
      items,
      bodyweightKg: bodyweightKg,
      results: results,
      accentColorOf: (item) => tuned(item) ? CrimpyTheme.accentYellow : null,
      extraOf: (item) => tuned(item)
          ? [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _overrideChips(
                  overrideByItem[item.id]!.overrides,
                  results,
                  bodyweightKg,
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
  ) {
    final entries = overrideChipLabels(
      overrides,
      results: results,
      bodyweightKg: bodyweightKg,
    );

    return entries
        .map(
          (e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: CrimpyTheme.tintOf(CrimpyTheme.accentYellow),
              border: Border.all(color: CrimpyTheme.accentYellow, width: 1.5),
            ),
            child: Text(
              e,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: CrimpyTheme.textOn(CrimpyTheme.accentYellow),
              ),
            ),
          ),
        )
        .toList();
  }

  /// Whether this session occurs today: an exact date match for day-of-week
  /// sessions, or the current week for everyday / times-per-week ones.
  bool _isScheduledToday() {
    final today = DateTime.now();
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
      date: session.scheduledDate(program, weekNumber) ?? DateTime.now(),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: CrimpyTheme.bgPrimary,
        border: Border(
          top: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: done
            ? _doneButton()
            : logOnly
            ? _logButton(context)
            : _startButton(context, ref, training, results),
      ),
    );
  }

  Widget _doneButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CrimpyTheme.tintOf(CrimpyTheme.statusSuccess),
        border: Border.all(color: CrimpyTheme.statusSuccess, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.circleCheck,
            size: 16,
            color: CrimpyTheme.textOn(CrimpyTheme.statusSuccess),
          ),
          const SizedBox(width: 8),
          Text(
            'DONE',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CrimpyTheme.textOn(CrimpyTheme.statusSuccess),
            ),
          ),
        ],
      ),
    );
  }

  Widget _startButton(
    BuildContext context,
    WidgetRef ref,
    Training training,
    AssessmentResults results,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _startRun(context, ref, training, results),
      icon: const Icon(Icons.play_arrow),
      label: const Text('START TRAINING'),
      style: ElevatedButton.styleFrom(
        backgroundColor: CrimpyTheme.primaryOrange,
        foregroundColor: CrimpyTheme.bgPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
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
    final color = programSessionColor(session.activity);
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
        // Darkened to carry the white label the theme puts on an
        // ElevatedButton. The activity colours are under the 4.5:1
        // floor beneath white, and gold is at 2.25:1.
        backgroundColor: CrimpyTheme.fillOn(color),
        foregroundColor: CrimpyTheme.bgPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
