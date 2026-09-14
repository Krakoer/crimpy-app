import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class CapturingSessions extends Sessions {
  SessionModel? saved;
  List<SessionItemResultModel> savedItemResults = const [];

  @override
  Future<List<SessionModel>> build() async => [];

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    saved = session;
    savedItemResults = itemResults;
    return 'session-id';
  }
}

const _training = Training(id: 't1', title: 'Mobility');

TrainingItem _item(String id) =>
    TrainingItem(id: id, type: TrainingItemType.hangboardRep, position: 0);

RepDataModel _rep({
  required int index,
  String? itemId,
  bool isRest = false,
  double averageWeight = 20,
  double targetWeight = 20,
}) => RepDataModel(
  averageWeight: averageWeight,
  duration: 7,
  index: index,
  isRest: isRest,
  handSide: HandSide.right,
  targetWeight: targetWeight,
  trainingItemId: itemId,
);

Future<void> _show(WidgetTester tester, Widget screen) => tester.pumpWidget(
  ProviderScope(
    overrides: [sessionsProvider.overrideWith(CapturingSessions.new)],
    child: MaterialApp(home: screen),
  ),
);

/// Shows the screen against [sessions], stopping short of saving, so a test can
/// fill the review pass in before it taps the button.
Future<void> _pumpFor(
  WidgetTester tester,
  Widget screen,
  CapturingSessions sessions,
) => tester.pumpWidget(
  ProviderScope(
    overrides: [sessionsProvider.overrideWith(() => sessions)],
    child: MaterialApp(
      home: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => screen),
      ),
    ),
  ),
);

Future<SessionModel> _saveFrom(
  WidgetTester tester,
  Widget screen,
  CapturingSessions sessions,
) async {
  await _pumpFor(tester, screen, sessions);
  await tester.tap(find.text('Save training'));
  await tester.pumpAndSettle();
  return sessions.saved!;
}

void main() {
  group('custom assessment question', _assessmentQuestionTests);

  testWidgets('logs the session under the type it was run with', (
    tester,
  ) async {
    final sessions = CapturingSessions();

    final saved = await _saveFrom(
      tester,
      const PostWorkoutScreen(
        template: _training,
        results: [],
        activity: SessionActivity.stretching,
      ),
      sessions,
    );

    expect(saved.activity, SessionActivity.stretching);
    // Finishing a run always produces a played session, whatever was trained.
    expect(saved.origin, SessionOrigin.played);
  });

  testWidgets('freezes the template it played onto the session', (
    tester,
  ) async {
    final sessions = CapturingSessions();
    final template = Training(
      id: 't1',
      title: 'Hangs',
      items: [_item('a'), _item('b')],
    );

    final saved = await _saveFrom(
      tester,
      PostWorkoutScreen(template: template, results: const []),
      sessions,
    );

    // Without this the session saves no prescription and its reps go back to
    // being read against a training that is free to drift under them.
    expect(saved.prescriptionItems, template.items);
  });

  testWidgets('defaults to a hangboard session', (tester) async {
    final sessions = CapturingSessions();

    final saved = await _saveFrom(
      tester,
      const PostWorkoutScreen(template: _training, results: []),
      sessions,
    );

    expect(saved.activity, SessionActivity.hangboard);
    expect(saved.origin, SessionOrigin.played);
  });

  testWidgets('grades a single block run against 90% of its target', (
    tester,
  ) async {
    await _show(
      tester,
      PostWorkoutScreen(
        template: Training(id: 't1', title: 'Hangs', items: [_item('a')]),
        results: [
          // 18 kg is 90% of 20, so it is on target; 17 kg is not.
          _rep(index: 0, itemId: 'a', averageWeight: 18),
          _rep(index: 1, itemId: 'a', averageWeight: 17),
          _rep(index: 2, itemId: 'a', isRest: true, targetWeight: 0),
          _rep(index: 3, itemId: 'a', averageWeight: 20),
        ],
      ),
    );

    expect(find.textContaining('2 of 3'), findsOneWidget);
  });

  testWidgets('states one ratio per block rather than pooling them', (
    tester,
  ) async {
    await _show(
      tester,
      PostWorkoutScreen(
        template: Training(
          id: 't1',
          title: 'Hangs',
          items: [_item('a'), _item('b')],
        ),
        results: [
          _rep(index: 0, itemId: 'a', averageWeight: 34, targetWeight: 34),
          _rep(index: 1, itemId: 'a', averageWeight: 34, targetWeight: 34),
          _rep(index: 2, itemId: 'b', averageWeight: 10, targetWeight: 24),
        ],
      ),
    );

    // Pooled, the run would read 2 of 3 and say nothing about the missed block.
    expect(find.text('2/2 on target'), findsOneWidget);
    expect(find.text('0/1 on target'), findsOneWidget);
    expect(find.textContaining('of the reps'), findsNothing);
  });

  testWidgets('leaves out the blocks the training gave no target', (
    tester,
  ) async {
    await _show(
      tester,
      PostWorkoutScreen(
        template: Training(
          id: 't1',
          title: 'Hangs and mobility',
          items: [_item('a'), _item('b')],
        ),
        results: [
          _rep(index: 0, itemId: 'a', averageWeight: 34, targetWeight: 34),
          _rep(index: 1, itemId: 'b', targetWeight: 0),
        ],
      ),
    );

    // A block hung against nothing is not a block that was missed.
    expect(find.text('1/1 on target'), findsOneWidget);
    expect(find.textContaining('0/1'), findsNothing);
  });

  testWidgets('says nothing about targets a run was never given', (
    tester,
  ) async {
    await _show(
      tester,
      PostWorkoutScreen(
        template: Training(id: 't1', title: 'Mobility', items: [_item('a')]),
        results: [_rep(index: 0, itemId: 'a', targetWeight: 0)],
      ),
    );

    expect(find.textContaining('on target'), findsNothing);
    expect(find.textContaining('of the reps'), findsNothing);
  });

  testWidgets('carries the program links onto the session', (tester) async {
    final sessions = CapturingSessions();

    final saved = await _saveFrom(
      tester,
      const PostWorkoutScreen(
        template: _training,
        results: [],
        trainingId: 't-1',
        programSessionId: 'ps-1',
      ),
      sessions,
    );

    expect(saved.trainingId, 't-1');
    expect(saved.programSessionId, 'ps-1');
  });

  group('review pass', _reviewPassTests);
}

const _pullUps = TrainingItem(
  id: 'pullup-1',
  type: TrainingItemType.exercise,
  position: 0,
  exerciseName: 'Pull up',
  repsIsMax: true,
);

const _dips = TrainingItem(
  id: 'dip-1',
  type: TrainingItemType.exercise,
  position: 1,
  exerciseName: 'Dip',
  reps: 8,
);

const _reviewTraining = Training(
  id: 't1',
  title: 'Strength',
  items: [_pullUps, _dips],
);

/// The review pass the whole issue is about: the athlete goes back over what
/// they just did and writes the line per exercise the spreadsheet had a column
/// for.
void _reviewPassTests() {
  testWidgets('asks about every prescribed step', (tester) async {
    await _show(
      tester,
      const PostWorkoutScreen(template: _reviewTraining, results: []),
    );

    expect(find.text('How did each one go?'), findsOneWidget);
    expect(find.text('Pull up'), findsOneWidget);
    expect(find.text('Dip'), findsOneWidget);
    // What was asked for is stated beside each one, so the athlete reports
    // against it rather than from memory.
    expect(find.text('Asked as many reps as possible'), findsOneWidget);
    expect(find.text('Asked of 8 reps'), findsOneWidget);
  });

  testWidgets('records the note and the numbers the athlete filled in', (
    tester,
  ) async {
    final sessions = CapturingSessions();

    await _pumpFor(
      tester,
      const PostWorkoutScreen(template: _reviewTraining, results: []),
      sessions,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Note').first,
      'hard on the shoulders',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reps').first,
      '28',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Load kg').first,
      '17.5',
    );
    await tester.tap(find.text('Save training'));
    await tester.pumpAndSettle();

    final reported = sessions.savedItemResults.single;
    expect(reported.trainingItemId, 'pullup-1');
    expect(reported.occurrence, 0);
    expect(reported.reps, 28);
    expect(reported.loadKg, 17.5);
    expect(reported.note, 'hard on the shoulders');
  });

  // An untouched review is an athlete with nothing to add, not a line of
  // nothing per exercise.
  testWidgets('records nothing for a step left alone', (tester) async {
    final sessions = CapturingSessions();

    await _saveFrom(
      tester,
      const PostWorkoutScreen(template: _reviewTraining, results: []),
      sessions,
    );

    expect(sessions.savedItemResults, isEmpty);
  });

  // A number the API refuses costs the whole session save, and the athlete is
  // left on the screen with no idea which of fifteen cards is the problem, so
  // it is refused here where the offending field can be pointed at.
  testWidgets('refuses to save a load that is not a number', (tester) async {
    final sessions = CapturingSessions();

    await _pumpFor(
      tester,
      const PostWorkoutScreen(template: _reviewTraining, results: []),
      sessions,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Load kg').first,
      '1.2.3',
    );
    await tester.tap(find.text('Save training'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a number'), findsOneWidget);
    expect(sessions.saved, isNull);
  });

  // The server stores these as 32 bit integers and answers an overflow by
  // rejecting the entire body, so the field that holds the digits is where the
  // limit belongs.
  testWidgets('refuses to save a count the server cannot store', (
    tester,
  ) async {
    final sessions = CapturingSessions();

    await _pumpFor(
      tester,
      const PostWorkoutScreen(template: _reviewTraining, results: []),
      sessions,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reps').first,
      '99999999999',
    );
    await tester.tap(find.text('Save training'));
    await tester.pumpAndSettle();

    expect(find.text('Too large'), findsOneWidget);
    expect(sessions.saved, isNull);
  });

  // The athlete's own numbers reach the review, so a step prescribed as a
  // percentage is reviewed against the number the run counted down from rather
  // than against the fallback the coach set for a client that cannot resolve it.
  testWidgets('states a percentage prescription in the resolved number', (
    tester,
  ) async {
    const maxPullUps = AssessmentDefinition(
      id: 'max-pullups',
      label: 'Max pull ups',
      unit: AssessmentUnit.repetitions,
    );
    final results = AssessmentResults(
      const {'max-pullups': AssessmentHandValues(right: 20)},
      definitions: const {'max-pullups': maxPullUps},
    );
    const relative = Training(
      id: 't1',
      title: 'Pulling',
      items: [
        TrainingItem(
          id: 'pullup-1',
          type: TrainingItemType.exercise,
          position: 0,
          exerciseName: 'Pull up',
          reps: 5,
          variableTargets: {
            'reps': VariableTarget(
              assessmentId: 'max-pullups',
              percent: 60,
              fallback: 5,
            ),
          },
        ),
      ],
    );

    await _show(
      tester,
      PostWorkoutScreen(
        template: relative,
        results: const [],
        assessmentResults: results,
      ),
    );

    // 60% of 20, not the fallback of 5.
    expect(find.text('Asked of 12 reps'), findsOneWidget);
    expect(find.text('Asked of 5 reps'), findsNothing);
  });

  // The count the run took mid set is seeded into the review, so the athlete
  // corrects it rather than being asked for it twice, and it still reaches the
  // session when they leave it alone.
  testWidgets('seeds what the run already recorded', (tester) async {
    final sessions = CapturingSessions();

    await _pumpFor(
      tester,
      const PostWorkoutScreen(
        template: _reviewTraining,
        results: [],
        itemResults: [
          SessionItemResultModel(
            trainingItemId: 'pullup-1',
            occurrence: 0,
            reps: 23,
          ),
        ],
      ),
      sessions,
    );
    expect(find.widgetWithText(TextFormField, 'Reps').first, findsOneWidget);
    expect(find.text('23'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Note').first,
      'last three were ugly',
    );
    await tester.tap(find.text('Save training'));
    await tester.pumpAndSettle();

    final reported = sessions.savedItemResults.single;
    expect(reported.reps, 23);
    expect(reported.note, 'last three were ugly');
  });
}

/// Captures what an assessment run writes, standing in for the notifier that
/// would otherwise reach the database.
class CapturingAssessments extends Assessments {
  AssessmentResultModel? savedResult;
  SessionModel? savedSession;

  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async => [];

  @override
  Future<void> saveAssessment(
    AssessmentResultModel assessmentModel,
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    savedResult = assessmentModel;
    savedSession = session;
  }
}

const _pullUpPyramid = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000001',
  label: 'Pull up pyramid',
  unit: AssessmentUnit.repetitions,
  prompt: 'How many pull ups did you do?',
);

const _lockOff = AssessmentDefinition(
  id: 'a9b8c7d6-0000-0000-0000-000000000002',
  label: 'One arm lock off',
  unit: AssessmentUnit.seconds,
  perHand: true,
  prompt: 'How long did you hold, each arm?',
);

Future<CapturingAssessments> _answer(
  WidgetTester tester,
  AssessmentDefinition definition,
  Map<String, String> answers,
) async {
  final assessments = CapturingAssessments();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assessmentsProvider(definition.id).overrideWith(() => assessments),
      ],
      child: MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => PostWorkoutScreen(
              template: Training(
                id: definition.trainingId ?? 't-assessment',
                title: definition.label,
                assessment: definition,
              ),
              results: const [],
            ),
          ),
        ),
      ),
    ),
  );
  for (final entry in answers.entries) {
    await tester.enterText(
      find.widgetWithText(TextFormField, entry.key),
      entry.value,
    );
  }
  await tester.tap(find.text('Save result'));
  await tester.pumpAndSettle();
  return assessments;
}

void _assessmentQuestionTests() {
  testWidgets('asks the question the assessment ends on', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assessmentsProvider(
            _pullUpPyramid.id,
          ).overrideWith(CapturingAssessments.new),
        ],
        child: const MaterialApp(
          home: PostWorkoutScreen(
            template: Training(
              id: 't-assessment',
              title: 'Pull up pyramid',
              assessment: _pullUpPyramid,
            ),
            results: [],
          ),
        ),
      ),
    );

    expect(find.text('How many pull ups did you do?'), findsOneWidget);
    // A single value assessment asks once, without naming a hand.
    expect(find.widgetWithText(TextFormField, 'Result'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Right'), findsNothing);
  });

  testWidgets('records a single value against the assessment', (tester) async {
    final assessments = await _answer(tester, _pullUpPyramid, {'Result': '14'});

    expect(assessments.savedResult!.assessmentId, _pullUpPyramid.id);
    // The one number lands on the right, which is where a reader takes it from.
    expect(assessments.savedResult!.rightValue, 14);
    expect(assessments.savedResult!.leftValue, isNull);
    // The session is what marks the run as measuring something.
    expect(assessments.savedSession!.isAssessment, isTrue);
    expect(assessments.savedSession!.origin, SessionOrigin.played);
  });

  testWidgets('asks each arm apart when the assessment is per hand', (
    tester,
  ) async {
    final assessments = await _answer(tester, _lockOff, {
      'Right': '3',
      'Left': '6',
    });

    expect(assessments.savedResult!.rightValue, 3);
    expect(assessments.savedResult!.leftValue, 6);
  });

  testWidgets('refuses to save an unanswered question', (tester) async {
    final assessments = CapturingAssessments();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assessmentsProvider(
            _pullUpPyramid.id,
          ).overrideWith(() => assessments),
        ],
        child: const MaterialApp(
          home: PostWorkoutScreen(
            template: Training(
              id: 't-assessment',
              title: 'Pull up pyramid',
              assessment: _pullUpPyramid,
            ),
            results: [],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save result'));
    await tester.pumpAndSettle();

    expect(assessments.savedResult, isNull);
    expect(find.text('Enter a number'), findsOneWidget);
  });
}
