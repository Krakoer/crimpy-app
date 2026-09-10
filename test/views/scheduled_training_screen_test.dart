import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/program_model.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/ble_repository.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/ble_view_model.dart';
import 'package:crimpy/viewmodels/bodyweight_view_model.dart';
import 'package:crimpy/viewmodels/program_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/play_training_screen/play_training_screen.dart';
import 'package:crimpy/views/screens/trainings/programs/scheduled_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/run_screen_plugins.dart';

/// Serves a fixed connection state without opening the platform channels the
/// real notifier subscribes to.
class _FixedConnection extends BleConnection {
  _FixedConnection(this._state);

  final BleConnectionState _state;

  @override
  BleConnectionState build() => _state;
}

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
      // The training itself reads against the assessment, which is what makes
      // the server freeze its definition onto referenced_assessments. Without
      // this the fixture would claim a payload the server never sends.
      variableTargets: {
        'reps': VariableTarget(
          assessmentId: 'a9b8c7d6-0000-0000-0000-000000000007',
          percent: 50,
          fallback: 8,
        ),
      },
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

/// A single-hand hang loaded in kilograms, the shape the force sensor can
/// measure, so starting it is what asks about the sensor.
Training _sensorTraining() => const Training(
  id: 't',
  title: 'Hangboard',
  items: [
    TrainingItem(
      id: 'h1',
      type: TrainingItemType.hangboardRep,
      position: 0,
      hand: 'right',
      worktimeSeconds: 7,
      restSeconds: 10,
      loads: [Load(value: 30, unit: 'kg')],
    ),
  ],
);

/// Pumps the screen for the scheduled session. [training] serves a fixture of
/// its own, in which case [referencedAssessments] does not apply: it only
/// tunes the default one.
Future<void> _pump(
  WidgetTester tester, {
  List<AssessmentDefinition> referencedAssessments = const [_maxPullUps],
  Training? training,
  BleConnectionState connection = BleConnectionState.disconnected,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        programTrainingProvider('p', 't').overrideWith(
          (ref) async =>
              training ??
              _training(referencedAssessments: referencedAssessments),
        ),
        // Nothing measured, so the training definitions are the only names on
        // offer, and the real provider stays off the device database.
        assessmentResultsProvider.overrideWith(
          (ref) async => AssessmentResults.none,
        ),
        bodyweightProvider.overrideWith(_StubBodyweight.new),
        sessionsProvider.overrideWith(_NoSessions.new),
        connectionStateProvider.overrideWith(
          () => _FixedConnection(connection),
        ),
        // Always served, never built: the real provider reaches for the stored
        // calibration on creation, which no test binding can answer.
        bleRepositoryProvider.overrideWithValue(BleRepository()),
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
    // This pins the wording for that case: readable, never an id or a blank.
    // It is not a tripwire on Krakoer/crimpy#92, and cannot be: with an empty
    // catalog this wording stays correct however the backend changes.
    await _pump(tester, referencedAssessments: const []);

    expect(find.text('REPS 75% assessment'), findsOneWidget);
  });

  testWidgets('a connected sensor starts the run measured without asking', (
    tester,
  ) async {
    // The run used to ask whether the athlete had a sensor even with one
    // connected, and the connection dialog it then opened had nothing to pick,
    // so closing it ran the training unmeasured.
    stubRunScreenPlugins();
    await _pump(
      tester,
      training: _sensorTraining(),
      connection: BleConnectionState.connected,
    );

    await tester.tap(find.text('START TRAINING'));
    await tester.pump();

    expect(find.text('Force sensor'), findsNothing);

    await tester.pumpAndSettle();

    final run = tester.widget<PlayTrainingScreen>(
      find.byType(PlayTrainingScreen),
    );
    expect(run.useSensor, isTrue);
  });

  testWidgets(
    'without a sensor connected the run still offers to connect one',
    (tester) async {
      stubRunScreenPlugins();
      await _pump(
        tester,
        training: _sensorTraining(),
        connection: BleConnectionState.disconnected,
      );

      await tester.tap(find.text('START TRAINING'));
      await tester.pumpAndSettle();

      expect(find.text('Force sensor'), findsOneWidget);

      await tester.tap(find.text('Run without'));
      await tester.pumpAndSettle();

      final run = tester.widget<PlayTrainingScreen>(
        find.byType(PlayTrainingScreen),
      );
      expect(run.useSensor, isFalse);
    },
  );
}
