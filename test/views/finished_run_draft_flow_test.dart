// ignore_for_file: avoid_public_notifier_properties
// A fake notifier exists to be read from: what the screen handed it is what the
// test checks, and none of it ships.

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/viewmodels/assessments_view_model.dart';
import 'package:crimpy/viewmodels/finished_run_draft_view_model.dart';
import 'package:crimpy/views/screens/assessments/critical_force/critical_force_result_screen.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
import 'package:crimpy/views/widgets/unsaved_run_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/run_drafts.dart';

class _Sessions extends Sessions {
  _Sessions({this.fails = false});

  final bool fails;
  SessionModel? saved;

  @override
  Future<List<SessionModel>> build() async => [];

  @override
  Future<String> saveSession(
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    if (fails) throw Exception('offline');
    saved = session;
    return 'session-id';
  }
}

final _draft = TrainingReviewDraft(
  owner: 'user-1',
  template: const Training(id: 't1', title: 'Mobility'),
  results: const [],
  startedAt: DateTime(2026, 9, 28, 23, 55),
);

Future<void> _pump(
  WidgetTester tester,
  MemoryRunDrafts drafts,
  _Sessions sessions,
) => tester.pumpWidget(
  ProviderScope(
    overrides: [
      sessionsProvider.overrideWith(() => sessions),
      finishedRunDraftRepositoryProvider.overrideWithValue(drafts),
    ],
    child: MaterialApp(
      home: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => PostWorkoutScreen.fromDraft(_draft),
        ),
      ),
    ),
  ),
);

/// Stores the Critical Force result, or fails to, as the result screen's save
/// asks it to.
class _CriticalForceStore extends Assessments {
  _CriticalForceStore({this.fails = false});

  final bool fails;
  AssessmentResultModel? saved;

  @override
  Future<List<AssessmentModel>> build(String? assessmentId) async => const [];

  @override
  Future<void> saveAssessment(
    AssessmentResultModel assessmentModel,
    SessionModel session,
    List<RepDataModel> reps, {
    List<BleDataPoint>? data,
    List<SessionItemResultModel> itemResults = const [],
  }) async {
    if (fails) throw Exception('offline');
    saved = assessmentModel;
  }
}

/// Four 7 s pulls at 20 kg with 3 s off between them, read at 10 Hz.
final _criticalForceDraft = CriticalForceResultDraft(
  owner: 'user-1',
  saveAssessment: AssessmentResultModel(
    assessmentId: BuiltinAssessmentIds.criticalForce,
    leftValue: 20,
  ),
  saveSession: SessionModel(
    name: 'Critical force assessment - 28/09/2026',
    date: DateTime(2026, 9, 28, 18, 30),
    isAssessment: true,
    origin: SessionOrigin.played,
  ),
  saveReps: const [],
  data: const [],
  samples: [
    for (var tenths = 0; tenths < 400; tenths++)
      (t: tenths / 10, kg: tenths % 100 < 70 ? 20.0 : 0.0),
  ],
  pullWindows: [
    for (var pull = 0; pull < 4; pull++)
      (start: pull * 10.0, end: pull * 10.0 + 7),
  ],
);

/// Pushes the result over an empty screen, as the run does, so it can be left.
Future<void> _pumpResult(
  WidgetTester tester,
  MemoryRunDrafts drafts,
  _CriticalForceStore store,
) async {
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assessmentsProvider.overrideWith(() => store),
        finishedRunDraftRepositoryProvider.overrideWithValue(drafts),
      ],
      child: MaterialApp(navigatorKey: navigator, home: const Scaffold()),
    ),
  );
  navigator.currentState!.push(
    MaterialPageRoute<void>(
      builder: (_) => CriticalForceResultScreen.fromDraft(_criticalForceDraft),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('forgets the draft once the run is saved', (tester) async {
    final drafts = MemoryRunDrafts(_draft);
    final sessions = _Sessions();
    await _pump(tester, drafts, sessions);

    await tester.tap(find.text('Save training'));
    await tester.pumpAndSettle();

    expect(sessions.saved, isNotNull);
    // #152: a review resumed on the next day still dates the run by its start.
    expect(sessions.saved!.date, _draft.startedAt);
    expect(drafts.draft, isNull);
  });

  testWidgets('keeps the draft when the save fails', (tester) async {
    final drafts = MemoryRunDrafts(_draft);
    await _pump(tester, drafts, _Sessions(fails: true));

    await tester.tap(find.text('Save training'));
    await tester.pumpAndSettle();

    expect(drafts.draft, same(_draft));
  });

  testWidgets('forgets the draft when the athlete leaves without saving', (
    tester,
  ) async {
    final drafts = MemoryRunDrafts(_draft);
    await _pump(tester, drafts, _Sessions());

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    expect(drafts.draft, isNull);
  });

  testWidgets('keeps the draft while the athlete keeps reviewing', (
    tester,
  ) async {
    final drafts = MemoryRunDrafts(_draft);
    await _pump(tester, drafts, _Sessions());

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep reviewing'));
    await tester.pumpAndSettle();

    expect(drafts.draft, same(_draft));
  });

  group('the Critical Force result', () {
    testWidgets('forgets the draft once the result is saved', (tester) async {
      final drafts = MemoryRunDrafts(_criticalForceDraft);
      final store = _CriticalForceStore();
      await _pumpResult(tester, drafts, store);

      await tester.tap(find.text('Save new result'));
      await tester.pumpAndSettle();

      expect(store.saved, isNotNull);
      expect(drafts.draft, isNull);
    });

    testWidgets('keeps the draft when the save fails', (tester) async {
      final drafts = MemoryRunDrafts(_criticalForceDraft);
      await _pumpResult(tester, drafts, _CriticalForceStore(fails: true));

      await tester.tap(find.text('Save new result'));
      await tester.pumpAndSettle();

      expect(drafts.draft, same(_criticalForceDraft));
    });

    testWidgets('forgets the draft when it is discarded', (tester) async {
      final drafts = MemoryRunDrafts(_criticalForceDraft);
      await _pumpResult(tester, drafts, _CriticalForceStore());

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(drafts.draft, isNull);
    });

    // Back was a discard before the draft existed, and still is: a result
    // left that way is not offered again on the next launch.
    testWidgets('forgets the draft when the athlete goes back', (tester) async {
      final drafts = MemoryRunDrafts(_criticalForceDraft);
      await _pumpResult(tester, drafts, _CriticalForceStore());

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(CriticalForceResultScreen), findsNothing);
      expect(drafts.draft, isNull);
    });
  });

  group('UnsavedRunDialog', () {
    Future<bool?> answer(WidgetTester tester, String button) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showDialog<bool>(
                context: context,
                builder: (_) => UnsavedRunDialog(draft: _draft),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Mobility, started on Sep 28 at 23:55, finished before the app '
          'closed. Review it to keep it in your history, or discard it.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('reviews the run on its primary action', (tester) async {
      expect(await answer(tester, 'Review run'), isTrue);
    });

    testWidgets('discards the run on its dismiss', (tester) async {
      expect(await answer(tester, 'Discard'), isFalse);
    });
  });
}
