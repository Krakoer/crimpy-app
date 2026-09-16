// ignore_for_file: avoid_public_notifier_properties
// A fake notifier exists to be read from: capturing what the code under test
// handed it is the whole point, and none of it is API that ships.

import 'dart:async';

import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/edit_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class CapturingSessions extends Sessions {
  SessionModel? updated;

  @override
  Future<List<SessionModel>> build() async => [];

  @override
  Future<void> updateSession(SessionModel session) async {
    updated = session;
  }
}

Future<SessionModel> _editNotes(
  WidgetTester tester,
  SessionModel session,
  CapturingSessions sessions,
) async {
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sessionsProvider.overrideWith(() => sessions)],
      child: MaterialApp(
        navigatorKey: navigator,
        home: const Scaffold(body: SizedBox()),
      ),
    ),
  );
  // Pushed onto a route rather than shown as the home, so the pop the screen
  // runs after saving has somewhere to go.
  unawaited(
    navigator.currentState!.push(
      MaterialPageRoute(builder: (_) => EditSessionScreen(session: session)),
    ),
  );
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).last, 'felt strong');
  await tester.ensureVisible(find.text('Update Notes'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Update Notes'));
  await tester.pumpAndSettle();
  return sessions.updated!;
}

void main() {
  testWidgets('a played session keeps the timings the run measured', (
    tester,
  ) async {
    final sessions = CapturingSessions();
    final recordedAt = DateTime(2026, 3, 1, 18, 42, 37);

    final updated = await _editNotes(
      tester,
      SessionModel(
        id: 's1',
        name: 'Board',
        isAssessment: false,
        origin: SessionOrigin.played,
        durationInSeconds: 187,
        date: recordedAt,
      ),
      sessions,
    );

    expect(updated.notes, 'felt strong');
    expect(updated.duration, 187);
    expect(updated.date, recordedAt);
  });
}
