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
        const SizedBox(height: 8),
        CrimpyCard.simple(
          padding: EdgeInsets.zero,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProgramDetailScreen(program)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            program.name,
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
                    const SizedBox(height: 14),
                    WeekProgressBar(
                      currentWeek: program.isActiveOn(DateTime.now())
                          ? program.currentWeekNumber(DateTime.now())
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
        const SizedBox(height: 18),
        const SectionLabel('Training Library'),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _todayStrip(
    BuildContext context,
    Program program,
    TodayTraining? today,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: const BoxDecoration(
        color: CrimpyTheme.bgSecondary,
        border: Border(
          top: BorderSide(color: CrimpyTheme.borderDefault, width: 2),
        ),
      ),
      child: today == null
          ? const Text(
              'REST DAY - NOTHING SCHEDULED TODAY',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: CrimpyTheme.textSecondary,
              ),
            )
          : Row(
              children: [
                SessionActivityTile(type: today.session.activity, size: 34),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: CrimpyTheme.textOn(CrimpyTheme.primaryOrange),
                        ),
                      ),
                      Text(
                        today.session.trainingTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CrimpyTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
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
                    backgroundColor: CrimpyTheme.primaryOrange,
                    foregroundColor: CrimpyTheme.bgPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
