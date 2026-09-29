import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/program_detail_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';

/// The "Your Program" section shown above the training library. Hides itself
/// when the user has no assigned program.
class ProgramSummaryCard extends ConsumerWidget {
  const ProgramSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read off what the state holds rather than off AsyncData: this card and
    // the section label above it head the trainings list, and a pull would
    // otherwise take both off the top of the screen while it refetches.
    final program = ref.watch(activeProgramProvider).value;
    if (program == null) return const SizedBox.shrink();
    final today = ref.watch(todayTrainingProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Your Program'),
        const SizedBox(height: CrimpyTheme.spaceSm),
        CrimpyCard.simple(
          padding: EdgeInsets.zero,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProgramDetailScreen(program)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(CrimpyTheme.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            program.name,
                            style: CrimpyTheme.title.copyWith(
                              color: CrimpyTheme.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: CrimpyTheme.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: CrimpyTheme.spaceLg),
                    WeekProgressBar(
                      currentWeek: program.isActiveOn(currentTrainingDay())
                          ? program.currentWeekNumber(currentTrainingDay())
                          : 0,
                      totalWeeks: program.durationWeeks ?? 1,
                    ),
                  ],
                ),
              ),
              _todayStrip(context, program, today),
            ],
          ),
        ),
        const SizedBox(height: CrimpyTheme.spaceLg),
        const SectionLabel('Training Library'),
        const SizedBox(height: CrimpyTheme.spaceSm),
      ],
    );
  }

  Widget _todayStrip(
    BuildContext context,
    Program program,
    TodayTraining? today,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CrimpyTheme.spaceLg,
        vertical: CrimpyTheme.spaceMd,
      ),
      decoration: const BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border(top: BorderSide(color: CrimpyTheme.outline, width: 2)),
      ),
      child: today == null
          ? Text(
              'REST DAY - NOTHING SCHEDULED TODAY',
              style: CrimpyTheme.capsLabel.copyWith(
                color: CrimpyTheme.textSecondary,
              ),
            )
          : Row(
              children: [
                SessionActivityTile(type: today.session.activity, size: 34),
                const SizedBox(width: CrimpyTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY',
                        style: CrimpyTheme.capsLabel.copyWith(
                          color: CrimpyTheme.textOn(CrimpyTheme.current),
                        ),
                      ),
                      Text(
                        today.session.trainingTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CrimpyTheme.titleSmall.copyWith(
                          color: CrimpyTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: CrimpyTheme.spaceMd),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ScheduledTrainingScreen(
                        program: program,
                        weekNumber: today.weekNumber,
                        session: today.session,
                      ),
                    ),
                  ),
                  icon: const Icon(FontAwesomeIcons.play, size: 12),
                  label: const Text('START'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CrimpyTheme.fillOn(CrimpyTheme.action),
                    foregroundColor: CrimpyTheme.bgPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: CrimpyTheme.spaceLg,
                      vertical: CrimpyTheme.spaceSm,
                    ),
                    textStyle: CrimpyTheme.labelSmall,
                  ),
                ),
              ],
            ),
    );
  }
}
