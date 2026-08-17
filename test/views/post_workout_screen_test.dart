import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
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
