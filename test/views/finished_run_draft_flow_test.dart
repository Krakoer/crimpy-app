import 'package:crimpy/models/ble_data_model.dart';
import 'package:crimpy/models/finished_run_draft.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/repositories/finished_run_draft_repository.dart';
import 'package:crimpy/viewmodels/finished_run_draft_view_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/trainings/post_workout_screen.dart';
import 'package:crimpy/views/widgets/unsaved_run_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Holds the draft in memory, so the screens can be checked for when they
/// forget it.
class _MemoryDrafts extends FinishedRunDraftRepository {
  FinishedRunDraft? draft;

  _MemoryDrafts(this.draft);

  @override
  Future<FinishedRunDraft?> read() async => draft;

  @override
  Future<void> write(FinishedRunDraft draft) async => this.draft = draft;

  @override
  Future<void> clear() async => draft = null;
}

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
  _MemoryDrafts drafts,
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

void main() {
  testWidgets('forgets the draft once the run is saved', (tester) async {
    final drafts = _MemoryDrafts(_draft);
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
    final drafts = _MemoryDrafts(_draft);
    await _pump(tester, drafts, _Sessions(fails: true));

    await tester.tap(find.text('Save training'));
    await tester.pumpAndSettle();

    expect(drafts.draft, same(_draft));
  });

  testWidgets('forgets the draft when the athlete leaves without saving', (
    tester,
  ) async {
    final drafts = _MemoryDrafts(_draft);
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
    final drafts = _MemoryDrafts(_draft);
    await _pump(tester, drafts, _Sessions());

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep reviewing'));
    await tester.pumpAndSettle();

    expect(drafts.draft, same(_draft));
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
