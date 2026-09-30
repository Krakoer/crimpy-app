import 'package:clock/clock.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_habit.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/habit_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/widgets/habit_today_card.dart';
import 'package:crimpy/views/screens/trainings/training_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedSessions extends Sessions {
  _FixedSessions(this.sessions);
  final List<SessionModel> sessions;

  @override
  Future<List<SessionModel>> build() async => sessions;
}

class _Pushes extends NavigatorObserver {
  final routes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      routes.add(route);
}

// Wednesday 30 September 2026.
final _wednesday = DateTime(2026, 9, 30, 9);

final _habits = [
  ActiveHabit(
    TrainingHabit.onWeekdays(
      trainingId: 'hangs',
      weekdays: const {2},
      since: DateTime(2026, 9, 1),
    ),
    const Training(id: 'hangs', title: 'My hangs'),
  ),
  ActiveHabit(
    TrainingHabit.onWeekdays(
      trainingId: 'core',
      weekdays: const {4},
      since: DateTime(2026, 9, 1),
    ),
    const Training(id: 'core', title: 'Friday core'),
  ),
  ActiveHabit(
    TrainingHabit.perWeek(
      trainingId: 'mobility',
      timesPerWeek: 3,
      since: DateTime(2026, 9, 1),
    ),
    const Training(id: 'mobility', title: 'Mobility'),
  ),
];

Program _program(DateTime start) => Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Block',
  startDate: start,
  durationWeeks: 4,
  createdAt: start,
  updatedAt: start,
);

Future<void> _show(
  WidgetTester tester, {
  Program? program,
  List<SessionModel> sessions = const [],
  NavigatorObserver? observer,
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [
      activeHabitsProvider.overrideWith((ref) async => _habits),
      activeProgramProvider.overrideWith((ref) async => program),
      sessionsProvider.overrideWith(() => _FixedSessions(sessions)),
      assessmentResultsProvider.overrideWith(
        (ref) async => AssessmentResults.none,
      ),
    ],
    child: MaterialApp(
      navigatorObservers: [?observer],
      home: const Scaffold(body: HabitTodayCard()),
    ),
  ),
);

void main() {
  testWidgets('lists the habits due today and the ones counted per week', (
    tester,
  ) async {
    await withClock(Clock.fixed(_wednesday), () async {
      await _show(
        tester,
        sessions: [
          SessionModel(
            name: 'mobility',
            isAssessment: false,
            origin: SessionOrigin.played,
            activity: SessionActivity.stretching,
            trainingId: 'mobility',
            date: DateTime(2026, 9, 28, 18),
          ),
        ],
      );
      await tester.pumpAndSettle();
    });

    expect(find.text("TODAY'S TRAINING"), findsOneWidget);
    expect(find.text('My hangs'), findsOneWidget);
    expect(find.text('Friday core'), findsNothing);
    expect(find.text('Mobility'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });

  testWidgets('opens the training with its id, so the run counts', (
    tester,
  ) async {
    final pushes = _Pushes();
    await withClock(Clock.fixed(_wednesday), () async {
      await _show(tester, observer: pushes);
      await tester.pumpAndSettle();
    });
    pushes.routes.clear();

    await tester.tap(find.text('My hangs'));
    await tester.pump();

    final route = pushes.routes.single as MaterialPageRoute<dynamic>;
    final screen =
        route.builder(tester.element(find.byType(HabitTodayCard)))
            as TrainingDetailScreen;
    expect(screen.trainingId, 'hangs');
  });

  testWidgets('gives way to a program that covers today', (tester) async {
    await withClock(Clock.fixed(_wednesday), () async {
      await _show(tester, program: _program(DateTime(2026, 9, 28)));
      await tester.pumpAndSettle();
    });
    expect(find.text('My hangs'), findsNothing);
  });

  testWidgets('stays until a program not started yet begins', (tester) async {
    await withClock(Clock.fixed(_wednesday), () async {
      await _show(tester, program: _program(DateTime(2026, 10, 5)));
      await tester.pumpAndSettle();
    });
    expect(find.text('My hangs'), findsOneWidget);
  });
}
