import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/program_detail_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Compact home card for the training scheduled today, with a one-tap start.
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
        if (today != null) return _compactCard(context, today);
        final hasProgram = ref.watch(activeProgramProvider).asData?.value;
        if (hasProgram == null) return const SizedBox.shrink();
        return _restDay();
      },
    );
  }

  Widget _compactCard(BuildContext context, TodayTraining today) {
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: openProgram,
        child: Row(
          children: [
            SessionTypeTile(type: type, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY - ${programSessionLabel(type)}',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: CrimpyTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    session.trainingTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CrimpyTheme.textPrimary,
                    ),
                  ),
                  if ((session.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      session.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10.5,
                        color: CrimpyTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: openSession,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CrimpyTheme.primaryOrange,
                  border: Border.all(
                    color: CrimpyTheme.borderDefault,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: CrimpyTheme.borderDefault,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: CrimpyTheme.bgPrimary,
                  size: 20,
                ),
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
