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

/// Pushes the edit screen and leaves it open, so a test can drive the form.
Future<void> _openEditor(
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
}

Future<SessionModel> _save(
  WidgetTester tester,
  CapturingSessions sessions,
) async {
  await tester.ensureVisible(find.text('Update Session'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Update Session'));
  await tester.pumpAndSettle();
  return sessions.updated!;
}

Future<SessionModel> _editNotes(
  WidgetTester tester,
  SessionModel session,
  CapturingSessions sessions,
) async {
  await _openEditor(tester, session, sessions);
  await tester.enterText(find.byType(TextField).last, 'felt strong');
  return _save(tester, sessions);
}

/// Taps the option carrying [anchor], which is how the picker is driven: the
/// written anchor is what an athlete reads, not the number beside it.
Future<void> _pickRpe(WidgetTester tester, String anchor) async {
  await tester.ensureVisible(find.text(anchor));
  await tester.pumpAndSettle();
  await tester.tap(find.text(anchor));
  await tester.pumpAndSettle();
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

  // The athlete who forgot the prompt at the end of a run is the normal case,
  // and a played session is exactly the one whose other fields are frozen.
  testWidgets('a played session takes an RPE given after the fact', (
    tester,
  ) async {
    final sessions = CapturingSessions();

    await _openEditor(
      tester,
      SessionModel(
        id: 's1',
        name: 'Board',
        isAssessment: false,
        origin: SessionOrigin.played,
        durationInSeconds: 187,
      ),
      sessions,
    );

    expect(find.text('Needs one full rest day before repeating it'), findsOne);
    await _pickRpe(tester, 'Needs one full rest day before repeating it');
    final updated = await _save(tester, sessions);

    expect(updated.rpe, 8);
    expect(updated.rpeFailed, isFalse);
  });

  testWidgets('a failure replaces the value rather than grading it', (
    tester,
  ) async {
    final sessions = CapturingSessions();

    await _openEditor(
      tester,
      SessionModel(
        id: 's1',
        name: 'Board',
        isAssessment: false,
        origin: SessionOrigin.logged,
        durationInSeconds: 3600,
        rpe: 9,
      ),
      sessions,
    );

    await _pickRpe(tester, 'Could not be carried through');
    final updated = await _save(tester, sessions);

    expect(updated.rpe, isNull);
    expect(updated.rpeFailed, isTrue);
  });

  testWidgets('tapping the answer again takes it back', (tester) async {
    final sessions = CapturingSessions();

    await _openEditor(
      tester,
      SessionModel(
        id: 's1',
        name: 'Board',
        isAssessment: false,
        origin: SessionOrigin.logged,
        durationInSeconds: 3600,
        rpe: 6,
      ),
      sessions,
    );

    await _pickRpe(tester, 'Easy but productive');
    final updated = await _save(tester, sessions);

    expect(updated.rpe, isNull);
    expect(updated.rpeFailed, isFalse);
  });

  testWidgets('keeps the stored answer when the athlete leaves it alone', (
    tester,
  ) async {
    final sessions = CapturingSessions();

    await _openEditor(
      tester,
      SessionModel(
        id: 's1',
        name: 'Board',
        isAssessment: false,
        origin: SessionOrigin.logged,
        durationInSeconds: 3600,
        rpe: 7,
      ),
      sessions,
    );

    final updated = await _save(tester, sessions);

    expect(updated.rpe, 7);
  });
}
