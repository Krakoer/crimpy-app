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
  // Every program that covered a day of the window, ended or not: those days
  // are drawn as the program decided them, not scored against the habits it
  // took precedence over. Not only the latest one, since a coach often queues
  // the next program before the last one ends.
  final first = addCalendarDays(today, -(consistencyStripDays - 1));
  final programs = [
    for (final program in await ref.watch(programsProvider.future))
      if (_coversAnyDay(program, first, today)) program,
  ];
  final sessions = await ref.watch(sessionsProvider.future);
  return habitConsistencyDays(
    habits: habits,
    sessions: sessions,
    today: today,
    programs: programs,
    programWeeks: {
      for (final program in programs)
        program.id: await _weeksInStrip(ref, program, today),
    },
  );
}

bool _coversAnyDay(Program program, DateTime first, DateTime last) {
  for (var day = first; !day.isAfter(last); day = addCalendarDays(day, 1)) {
    if (program.isActiveOn(day)) return true;
  }
  return false;
}
