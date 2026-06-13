import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/program_detail_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Home hero for the training scheduled today, with a one-tap start.
/// Renders nothing when the user has no program, a rest-day card otherwise.
class TodayTrainingCard extends ConsumerWidget {
  const TodayTrainingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayTrainingProvider);
    return todayAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (today) {
        if (today != null) return _hero(context, today);
        final hasProgram = ref.watch(activeProgramProvider).asData?.value;
        if (hasProgram == null) return const SizedBox.shrink();
        return _restDay();
      },
    );
  }

  Widget _hero(BuildContext context, TodayTraining today) {
    final session = today.session;
    final type = session.sessionType;
    final color = programSessionColor(type);

    void openProgram() => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProgramDetailScreen(today.program)),
    );
    void openSession() => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduledTrainingScreen(
          program: today.program,
          weekNumber: today.weekNumber,
          session: session,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CrimpyCard.category(
        accentColor: color,
        padding: EdgeInsets.zero,
        onTap: openProgram,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: CrimpyTheme.primaryOrange,
              child: const Text(
                "TODAY'S TRAINING",
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: CrimpyTheme.bgPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SessionTypeTile(type: type, size: 48),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.trainingTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: CrimpyTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              programSessionLabel(type),
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if ((session.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      session.notes!,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        height: 1.45,
                        color: CrimpyTheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: openSession,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('START'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CrimpyTheme.primaryOrange,
                        foregroundColor: CrimpyTheme.bgPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _restDay() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CrimpyCard.simple(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CrimpyTheme.statusSuccess.withValues(alpha: 0.12),
                border: Border.all(color: CrimpyTheme.statusSuccess, width: 2),
              ),
              child: Icon(
                FontAwesomeIcons.check,
                color: CrimpyTheme.statusSuccess,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REST DAY',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CrimpyTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'No training scheduled today.',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: CrimpyTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
