import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/viewmodels/availability_view_model.dart';
import 'package:crimpy/viewmodels/coach_view_model.dart';
import 'package:crimpy/views/screens/availability/week_availability_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/utils/datetimes.dart';

/// Asks a coached athlete to say when they can train next week, so their coach
/// writes the program around the week they actually have.
///
/// Gated on having a coach rather than on having a program: an athlete whose
/// coach has not written one yet is exactly who needs to answer this.
class NextWeekAvailabilityCard extends ConsumerWidget {
  const NextWeekAvailabilityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read off what the state holds rather than off AsyncData, so a refetch
    // of what is already shown does not take the card off the dashboard.
    final enrollment = ref.watch(coachEnrollmentProvider);
    if (enrollment.value == null) return const SizedBox.shrink();

    final nextWeek = getStartOfNextWeek(DateTime.now());
    // The declared dates rather than the editable weeks: this card only asks
    // whether next week was answered, and the week list is windowed, so a week
    // it did not fetch would read here as never declared.
    final declared = ref.watch(declaredWeekStartsProvider).value;
    if (declared == null) return const SizedBox.shrink();

    final isDeclared = declared.map(getStartOfWeek).contains(nextWeek);

    return CrimpyCard.category(
      accentColor: isDeclared
          ? CrimpyTheme.accentGreen
          : CrimpyTheme.primaryOrange,
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WeekAvailabilityScreen(weekStart: nextWeek),
        ),
      ),
      child: Row(
        children: [
          FaIcon(
            isDeclared
                ? FontAwesomeIcons.circleCheck
                : FontAwesomeIcons.calendarDay,
            size: 18,
            color: isDeclared
                ? CrimpyTheme.accentGreen
                : CrimpyTheme.primaryOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeclared ? 'NEXT WEEK SENT' : 'NEXT WEEK',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDeclared
                      ? 'Your coach knows when you can train'
                      : 'Tell your coach when you can train',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CrimpyTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: CrimpyTheme.textMutedSmall),
        ],
      ),
    );
  }
}
