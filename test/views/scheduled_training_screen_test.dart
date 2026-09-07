import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A coach assessment: the athlete cannot fetch its definition, so the training
/// carrying it is the only thing that can name it on this screen.
const _maxPullUps = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000007',
  label: 'Max pull ups',
  unit: AssessmentUnit.repetitions,
  trainingId: 't-max-pull-ups',
);

class _StubBodyweight extends BodyweightController {
  @override
  Future<double?> build() async => 70;
}

class _NoSessions extends Sessions {
  @override
  Future<List<SessionModel>> build() async => [];
}

final _program = Program(
  id: 'p',
  coachId: 'c',
  userId: 'u',
  name: 'Base',
  startDate: DateTime(2026, 1, 5),
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

Training _training({
  List<AssessmentDefinition> referencedAssessments = const [_maxPullUps],
}) => Training(
  id: 't',
  title: 'Pull ups',
  referencedAssessments: referencedAssessments,
  items: const [
    TrainingItem(
      id: 'i1',
      type: TrainingItemType.exercise,
      position: 0,
      reps: 8,
      exerciseName: 'Pull up',
    ),
  ],
);

/// The week prescribes the reps as a percentage of an assessment rather than as
/// a number, which is what the chip has to name.
WeekSession _session() => const WeekSession(
  id: 's',
  trainingId: 't',
  trainingTitle: 'Pull ups',
  trainingType: 'training',
  dayOfWeek: 0,
  position: 0,
  overrides: [
    SessionOverride(
      id: 'o',
      itemId: 'i1',
      overrides: {
        'variable_targets': {
          'reps': {
            'assessment_id': 'a9b8c7d6-0000-0000-0000-000000000007',
            'percent': 75,
            'fallback': 8,
          },
        },
      },
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester, {
  List<AssessmentDefinition> referencedAssessments = const [_maxPullUps],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        programTrainingProvider('p', 't').overrideWith(
          (ref) async =>
              _training(referencedAssessments: referencedAssessments),
        ),
        // Nothing measured, so the training definitions are the only names on
        // offer, and the real provider stays off the device database.
        assessmentResultsProvider.overrideWith(
          (ref) async => AssessmentResults.none,
        ),
        bodyweightProvider.overrideWith(_StubBodyweight.new),
        sessionsProvider.overrideWith(_NoSessions.new),
      ],
      child: MaterialApp(
        home: ScheduledTrainingScreen(
          program: _program,
          weekNumber: 1,
          session: _session(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an override chip names the assessment it is a percentage of', (
    tester,
  ) async {
    // The chip used to read "REPS 75%", a percentage of nothing, while the same
    // week reads "75% Max pull ups" in the coach portal.
    await _pump(tester);

    expect(find.text('REPS 75% Max pull ups'), findsOneWidget);
  });

  testWidgets('says what it can when nothing names the assessment', (
    tester,
  ) async {
    // The server freezes referenced_assessments from the base training items,
    // so a week that is the only thing referencing an assessment sends the
    // athlete no definition for it, and nothing they can fetch holds a coach's.
    // The chip has to stay readable rather than show an id or nothing at all.
    // Krakoer/crimpy#92 is what would let it name this one.
    await _pump(tester, referencedAssessments: const []);

    expect(find.text('REPS 75% assessment'), findsOneWidget);
  });
}
