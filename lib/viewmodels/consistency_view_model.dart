import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/utils/consistency.dart';
import 'package:crimpy/utils/datetimes.dart';
import 'package:crimpy/viewmodels/habit_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consistency_view_model.g.dart';

/// The last two weeks of the active program, day by day, for the home screen's
/// consistency strip. Null when no program covers today: what a day owes comes
/// from the program, so without one there is nothing to keep.
@riverpod
Future<List<ConsistencyDay>?> programConsistency(Ref ref) async {
  final program = await ref.watch(activeProgramProvider.future);
  final today = currentTrainingDay();
  if (program == null || !program.isActiveOn(today)) return null;

  final weeks = await _weeksInStrip(ref, program, today);
  final sessions = await ref.watch(sessionsProvider.future);

  return programConsistencyDays(
    program: program,
    weeks: weeks,
    sessions: sessions,
    today: today,
  );
}

/// The published weeks of [program] that the strip ending on [today] reaches,
/// by number.
Future<Map<int, Week>> _weeksInStrip(
  Ref ref,
  Program program,
  DateTime today,
) async {
  final first = addCalendarDays(today, -(consistencyStripDays - 1));
  final weekNumbers = {
    for (var day = first; !day.isAfter(today); day = addCalendarDays(day, 1))
      if (program.isActiveOn(day)) program.currentWeekNumber(day),
  };
  final weeks = <int, Week>{};
  for (final number in weekNumbers) {
    final week = await ref.watch(weekDetailProvider(program.id, number).future);
    if (week != null) weeks[number] = week;
  }
  return weeks;
}

/// What the home screen's strip draws: the program's last two weeks while a
/// program covers today, the athlete's own habits otherwise, and null when
/// there is neither, since there is then nothing to keep.
@riverpod
Future<List<ConsistencyDay>?> consistencyStrip(Ref ref) async {
  final program = await ref.watch(programConsistencyProvider.future);
  if (program != null) return program;
  final habits = await ref.watch(activeHabitsProvider.future);
  if (habits.isEmpty) return null;
  final today = currentTrainingDay();
  // The latest program, ended or still to start: the days it covered inside
  // the window are drawn as it decided them, not scored against the habits it
  // took precedence over.
  final lastProgram = await ref.watch(activeProgramProvider.future);
  final sessions = await ref.watch(sessionsProvider.future);
  return habitConsistencyDays(
    habits: habits,
    sessions: sessions,
    today: today,
    program: lastProgram,
    programWeeks: lastProgram == null
        ? const {}
        : await _weeksInStrip(ref, lastProgram, today),
  );
}
