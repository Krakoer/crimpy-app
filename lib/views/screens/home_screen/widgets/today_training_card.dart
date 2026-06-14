import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/program_detail_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/widgets/program_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Compact home card summarizing the user's program: a one-tap start for
/// today's training, a countdown for a program that has not started, or a
/// rest-day note. Renders nothing when the user is not enrolled in a program.
class TodayTrainingCard extends ConsumerWidget {
  const TodayTrainingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(activeProgramProvider);
    return programAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (program) {
        // Not enrolled in any program.
        if (program == null) return const SizedBox.shrink();

        // A training is scheduled today: offer a one-tap start.
        final today = ref.watch(todayTrainingProvider).asData?.value;
        if (today != null) return _compactCard(context, today);

        // The program has not started yet: show a countdown.
        final daysUntilStart = _daysUntilStart(program.startDate);
        if (daysUntilStart > 0) {
          return _statusCard(
            context,
            program,
            icon: FontAwesomeIcons.clock,
            accent: CrimpyTheme.primaryOrange,
            title: 'STARTS ${_relativeStart(daysUntilStart).toUpperCase()}',
            subtitle: program.name,
          );
        }

        // Active program, but nothing scheduled today.
        if (program.isActiveOn(DateTime.now())) {
          return _statusCard(
            context,
            program,
            icon: FontAwesomeIcons.check,
            accent: CrimpyTheme.statusSuccess,
            title: 'REST DAY',
            subtitle: 'No training scheduled today.',
          );
        }

        // Program already finished: nothing current or upcoming to show.
        return const SizedBox.shrink();
      },
    );
  }

  int _daysUntilStart(DateTime startDate) {
    final now = DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return start.difference(today).inDays;
  }

  String _relativeStart(int days) {
    if (days == 1) return 'tomorrow';
    if (days < 7) return 'in $days days';
    if (days < 14) return 'in 1 week';
    if (days < 30) return 'in ${(days / 7).round()} weeks';
    if (days < 60) return 'in 1 month';
    return 'in ${(days / 30).round()} months';
  }

  void _openProgram(BuildContext context, Program program) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProgramDetailScreen(program)));
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

  Widget _statusCard(
    BuildContext context,
    Program program, {
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CrimpyCard.simple(
        onTap: () => _openProgram(context, program),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                border: Border.all(color: accent, width: 2),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: CrimpyTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: CrimpyTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: CrimpyTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
