import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:crimpy/repositories/program_repository.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remote program repository, or null when the user is not authenticated
/// (programs are coach/server-owned, so there is no guest-mode equivalent).
final programRepositoryProvider = Provider<ProgramRepository?>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return null;
  return ProgramRepository(ref.read(apiClientProvider));
});

/// All programs assigned to the user (empty in guest mode).
final programsProvider = FutureProvider<List<Program>>((ref) async {
  final repo = ref.watch(programRepositoryProvider);
  if (repo == null) return [];
  return repo.getPrograms();
});

/// The program covering today, else the most recent one, else null.
final activeProgramProvider = FutureProvider<Program?>((ref) async {
  final programs = await ref.watch(programsProvider.future);
  if (programs.isEmpty) return null;
  final today = DateTime.now();
  for (final program in programs) {
    if (program.isActiveOn(today)) return program;
  }
  return programs.first; // getMyPrograms is ordered start_date DESC
});

/// Week summaries for a program (empty in guest mode).
final programWeeksProvider = FutureProvider.family<List<WeekSummary>, String>((
  ref,
  programId,
) async {
  final repo = ref.watch(programRepositoryProvider);
  if (repo == null) return [];
  return repo.getWeeks(programId);
});

typedef WeekKey = (String programId, int weekNumber);

/// Full detail for one week, or null when the week is not defined yet.
final weekDetailProvider = FutureProvider.family<Week?, WeekKey>((
  ref,
  key,
) async {
  final repo = ref.watch(programRepositoryProvider);
  if (repo == null) return null;
  return repo.getWeek(key.$1, key.$2);
});

typedef ProgramTrainingKey = (String programId, String trainingId);

/// The training tree referenced by a session in one of the user's programs.
/// Auto-disposed so reopening a training always re-fetches fresh content.
final programTrainingProvider = FutureProvider.autoDispose
    .family<Training, ProgramTrainingKey>((ref, key) async {
      final repo = ref.watch(programRepositoryProvider);
      if (repo == null) throw StateError('Not authenticated');
      return repo.getProgramTraining(key.$1, key.$2);
    });

/// A scheduled training within the active program, with its context.
class TodayTraining {
  final Program program;
  final int weekNumber;
  final WeekSession session;

  const TodayTraining({
    required this.program,
    required this.weekNumber,
    required this.session,
  });
}

/// The active program together with the week covering today, or null when
/// there is no active program or the current week is not defined.
class ActiveProgramWeek {
  final Program program;
  final int weekNumber;
  final Week week;

  const ActiveProgramWeek({
    required this.program,
    required this.weekNumber,
    required this.week,
  });
}

final activeProgramWeekProvider = FutureProvider<ActiveProgramWeek?>((
  ref,
) async {
  final program = await ref.watch(activeProgramProvider.future);
  if (program == null) return null;
  final today = DateTime.now();
  if (!program.isActiveOn(today)) return null;
  final weekNumber = program.currentWeekNumber(today);
  final week = await ref.watch(
    weekDetailProvider((program.id, weekNumber)).future,
  );
  if (week == null) return null;
  return ActiveProgramWeek(
    program: program,
    weekNumber: weekNumber,
    week: week,
  );
});

/// All trainings scheduled for today (day-of-week + everyday) in the active
/// program. Empty on a rest day or with no active program.
final todayTrainingsProvider = FutureProvider<List<TodayTraining>>((ref) async {
  final active = await ref.watch(activeProgramWeekProvider.future);
  if (active == null) return [];
  // day_of_week is an offset from the program start, not a calendar weekday.
  final offset = active.program.dayOffsetOf(active.weekNumber, DateTime.now());
  return active.week
      .sessionsOnDay(offset)
      .map(
        (s) => TodayTraining(
          program: active.program,
          weekNumber: active.weekNumber,
          session: s,
        ),
      )
      .toList();
});

/// The first training scheduled for today, or null on a rest day.
final todayTrainingProvider = FutureProvider<TodayTraining?>((ref) async {
  final list = await ref.watch(todayTrainingsProvider.future);
  return list.isEmpty ? null : list.first;
});
