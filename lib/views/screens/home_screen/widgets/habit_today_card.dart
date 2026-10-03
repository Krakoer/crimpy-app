import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/utils/duration_format.dart';
import 'package:crimpy/utils/habit_schedule.dart';
import 'package:crimpy/utils/training_expander.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/habit_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:crimpy/views/screens/trainings/training_details_screen.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Today's training for an athlete following their own habits rather than a
/// coach's program: the habits due today, with their done state, and the ones
/// counted per week with how far the week has got. Nothing when there are no
/// habits, or while a program covers today, which takes precedence.
class HabitTodayCard extends ConsumerWidget {
  const HabitTodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read off what the state holds, so a pull keeps the card on screen.
    final habits = ref.watch(activeHabitsProvider).value ?? const [];
    if (habits.isEmpty) return const SizedBox.shrink();
    final today = currentTrainingDay();
    final programAsync = ref.watch(activeProgramProvider);
    // Until the program is known the card would flash in and out for a
    // coached athlete, so it waits for the answer.
    if (!programAsync.hasValue && !programAsync.hasError) {
      return const SizedBox.shrink();
    }
    if (programCovers(programAsync.value, today)) {
      return const SizedBox.shrink();
    }

    final sessions = ref.watch(sessionsProvider).value ?? const [];
    final dueToday = habitsDueOn(habits, today);
    final perWeek = perWeekHabits(habits);

    return CrimpyCard.simple(
      raised: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: CrimpyTheme.spaceLg,
              vertical: CrimpyTheme.spaceSm,
            ),
            color: CrimpyTheme.fillOn(CrimpyTheme.current),
            child: Text(
              "TODAY'S TRAINING",
              style: CrimpyTheme.capsLabel.copyWith(
                color: CrimpyTheme.bgPrimary,
              ),
            ),
          ),
          Padding(
            padding: CrimpyTheme.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dueToday.isEmpty && perWeek.isEmpty)
                  _restRow()
                else
                  for (final habit in dueToday)
                    _HabitTodayRow(
                      habit: habit,
                      done: habitDoneOn(sessions, habit.habit, today),
                    ),
                if (perWeek.isNotEmpty) ...[
                  if (dueToday.isNotEmpty)
                    const SizedBox(height: CrimpyTheme.spaceSm),
                  const SectionLabel('This week'),
                  const SizedBox(height: CrimpyTheme.spaceSm),
                  for (final habit in perWeek)
                    _HabitWeekRow(
                      habit: habit,
                      done: habitCompletionsInWeek(
                        sessions,
                        habit.habit,
                        today,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _restRow() {
    return Row(
      children: [
        Icon(FontAwesomeIcons.check, size: 16, color: CrimpyTheme.done),
        const SizedBox(width: CrimpyTheme.spaceMd),
        Text(
          'REST DAY - no habit today',
          style: CrimpyTheme.bodySmall.copyWith(
            color: CrimpyTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Opens the habit's training ready to start. The id goes with it, so the
/// session the run saves names the training and counts for the habit.
void _openHabit(BuildContext context, ActiveHabit habit) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          TrainingDetailScreen(habit.training, trainingId: habit.trainingId),
    ),
  );
}

/// A habit due today: its title, how long it runs, and whether it is done.
class _HabitTodayRow extends ConsumerWidget {
  final ActiveHabit habit;
  final bool done;

  const _HabitTodayRow({required this.habit, required this.done});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results =
        (ref.watch(assessmentResultsProvider).value ?? AssessmentResults.none)
            .withDefinitions(habit.training.referencedAssessments);
    final seconds = trainingDurationSeconds(habit.training, results: results);

    return InkWell(
      onTap: () => _openHabit(context, habit),
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceSm),
        child: Row(
          children: [
            const SessionActivityTile(
              type: SessionActivity.hangboard,
              size: 38,
            ),
            const SizedBox(width: CrimpyTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CrimpyTheme.titleSmall.copyWith(
                      color: done
                          ? CrimpyTheme.textMutedSmall
                          : CrimpyTheme.textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    [
                      'YOUR HABIT',
                      if (seconds > 0) formatLength(Duration(seconds: seconds)),
                    ].join('   '),
                    style: CrimpyTheme.labelSmall.copyWith(
                      color: CrimpyTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
            if (done)
              Icon(
                FontAwesomeIcons.circleCheck,
                size: 24,
                color: CrimpyTheme.done,
              )
            else
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CrimpyTheme.fillOn(CrimpyTheme.action),
                  border: Border.all(color: CrimpyTheme.outline, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: CrimpyTheme.bgPrimary,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A habit counted per week: its title and how many of the week's are done.
class _HabitWeekRow extends StatelessWidget {
  final ActiveHabit habit;
  final int done;

  const _HabitWeekRow({required this.habit, required this.done});

  @override
  Widget build(BuildContext context) {
    final target = habit.habit.timesPerWeek ?? 1;
    final met = done >= target;
    return InkWell(
      onTap: () => _openHabit(context, habit),
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceXs),
        child: Row(
          children: [
            const SessionActivityTile(
              type: SessionActivity.hangboard,
              size: 28,
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
            Expanded(
              child: Text(
                habit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CrimpyTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CrimpyTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
            Text(
              '$done/$target',
              style: CrimpyTheme.labelSmall.copyWith(
                color: met
                    ? CrimpyTheme.textOn(CrimpyTheme.done)
                    : CrimpyTheme.textSecondary,
              ),
            ),
            const SizedBox(width: CrimpyTheme.spaceSm),
            Icon(
              FontAwesomeIcons.play,
              size: 13,
              color: met ? CrimpyTheme.textMutedSmall : CrimpyTheme.control,
            ),
          ],
        ),
      ),
    );
  }
}
