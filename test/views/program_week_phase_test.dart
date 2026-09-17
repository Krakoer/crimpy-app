import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/program_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoSessions extends Sessions {
  @override
  Future<List<SessionModel>> build() async => [];
}

const _programId = 'program-1';

/// A two week program starting today, so week 1 is the week the screen opens
/// on and both weeks are inside it.
Program _program() {
  final today = DateTime.now();
  return Program(
    id: _programId,
    coachId: 'coach-1',
    userId: 'user-1',
    name: 'Winter block',
    startDate: DateTime(today.year, today.month, today.day),
    durationWeeks: 2,
    createdAt: today,
    updatedAt: today,
  );
}

Week _week(int weekNumber, {String? name, String? notes}) => Week(
  id: 'week-$weekNumber',
  programId: _programId,
  weekNumber: weekNumber,
  name: name,
  notes: notes,
  sessions: const [],
);

Future<void> _pump(WidgetTester tester, List<Week> weeks) async {
  final program = _program();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        programWeeksProvider(_programId).overrideWith(
          (ref) async => weeks
              .map(
                (w) => WeekSummary(
                  id: w.id,
                  programId: w.programId,
                  weekNumber: w.weekNumber,
                  name: w.name,
                ),
              )
              .toList(),
        ),
        for (final week in weeks)
          weekDetailProvider(
            _programId,
            week.weekNumber,
          ).overrideWith((ref) async => week),
        sessionsProvider.overrideWith(_NoSessions.new),
      ],
      child: MaterialApp(home: ProgramDetailScreen(program)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('heads the week strip with the phase the week is in', (
    tester,
  ) async {
    await _pump(tester, [_week(1, name: 'capacity')]);

    expect(find.text('CAPACITY'), findsOneWidget);
  });

  // The name is what the week is, the note is a message about it. Both are
  // shown, and neither stands in for the other.
  testWidgets('shows the phase beside the coach note, not instead of it', (
    tester,
  ) async {
    await _pump(tester, [
      _week(1, name: 'deload', notes: 'finger work moved to Friday'),
    ]);

    expect(find.text('DELOAD'), findsOneWidget);
    expect(
      find.textContaining('finger work moved to Friday', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('says nothing where the coach named no phase', (tester) async {
    await _pump(tester, [_week(1, notes: 'easy week')]);

    expect(find.text('CAPACITY'), findsNothing);
    expect(
      find.textContaining('easy week', findRichText: true),
      findsOneWidget,
    );
  });

  // Reading the arc of the program is the point of the calendar, so every
  // named row carries its phase rather than only the week on screen.
  testWidgets('names the phase of every row of the calendar', (tester) async {
    await _pump(tester, [_week(1, name: 'capacity'), _week(2, name: 'deload')]);

    await tester.tap(find.text('CALENDAR'));
    await tester.pumpAndSettle();

    expect(find.text('W1'), findsOneWidget);
    expect(find.text('W2'), findsOneWidget);
    expect(find.text('CAPACITY'), findsOneWidget);
    expect(find.text('DELOAD'), findsOneWidget);
  });
}
