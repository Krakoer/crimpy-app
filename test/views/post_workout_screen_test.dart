import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class CapturingSessions extends Sessions {
  SessionModel? saved;

  @override
  Future<List<SessionModel>> build() async => [];

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
  }) async {
    saved = session;
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

Future<SessionModel> _saveFrom(
  WidgetTester tester,
  Widget screen,
  CapturingSessions sessions,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sessionsProvider.overrideWith(() => sessions)],
      child: MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => screen),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Save training'));
  await tester.pumpAndSettle();
  return sessions.saved!;
}

void main() {
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

    expect(find.textContaining('67%'), findsOneWidget);
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

    // Pooled, the run would read 67% and say nothing about the missed block.
    expect(find.text('2/2 on target'), findsOneWidget);
    expect(find.text('0/1 on target'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
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
    expect(find.textContaining('%'), findsNothing);
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
}
