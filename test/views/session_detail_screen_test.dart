import 'dart:async';

import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/session_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

RepDataModel _rep(
  int index, {
  String? itemId,
  HandSide hand = HandSide.right,
  double averageWeight = 30,
  double targetWeight = 30,
  bool targetUnmeasured = false,
}) => RepDataModel(
  averageWeight: averageWeight,
  duration: 7,
  index: index,
  isRest: false,
  handSide: hand,
  targetWeight: targetWeight,
  trainingItemId: itemId,
  targetUnmeasured: targetUnmeasured,
);

TrainingItem _hangRep(String id, {int edgeSizeMm = 20}) => TrainingItem(
  id: id,
  type: TrainingItemType.hangboardRep,
  position: 0,
  reps: 2,
  edgeSizesMm: [edgeSizeMm],
);

SessionModel _session({
  String? trainingId,
  List<TrainingItem>? prescriptionItems,
  required List<RepDataModel> reps,
}) => SessionModel(
  id: 'session-1',
  name: 'Repeaters 20mm',
  isAssessment: false,
  origin: SessionOrigin.played,
  trainingId: trainingId,
  prescriptionItems: prescriptionItems,
  reps: reps,
);

/// Pumps the screen with the training the session links to resolved to [items].
/// A guest-mode run resolves to an empty list, which is what the provider
/// returns for a session carrying no training at all.
Future<void> _pump(
  WidgetTester tester,
  SessionModel session, {
  List<TrainingItem> resolved = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionTrainingItemsProvider(
          session.trainingId,
        ).overrideWith((ref) async => resolved),
      ],
      child: MaterialApp(home: SessionDetailScreen(session: session)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pools the reps when the run resolved no training', (
    tester,
  ) async {
    // The local database stores an item link on every rep it writes, so a
    // guest-mode run carries links that resolve to nothing. Heading each of
    // them 'Unnamed block' would say less than the flat list does.
    await _pump(
      tester,
      _session(
        reps: [
          _rep(0, itemId: 'a'),
          _rep(1, itemId: 'a'),
        ],
      ),
    );

    expect(find.text('Repetitions Breakdown'), findsOneWidget);
    expect(find.text('Blocks'), findsNothing);
    expect(find.text('Unnamed block'), findsNothing);
  });

  testWidgets('names a two handed rep as such rather than a single hand', (
    tester,
  ) async {
    // A hang taken two handed is neither of the single hands, and the row used
    // to answer the left one for it.
    await _pump(
      tester,
      _session(
        reps: [
          _rep(0, hand: HandSide.both),
          _rep(1, hand: HandSide.right),
        ],
      ),
    );

    expect(find.text('Both Hands'), findsOneWidget);
    expect(find.text('Right Hand'), findsOneWidget);
    expect(find.text('Left Hand'), findsNothing);
  });

  testWidgets('heads the blocks with the frozen prescription', (tester) async {
    // A program session names a training the athlete cannot read, so the
    // prescription frozen onto the session is the only copy it can be grouped
    // against.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a')],
        reps: [
          _rep(0, itemId: 'a'),
          _rep(1, itemId: 'a'),
        ],
      ),
    );

    expect(find.text('Blocks'), findsOneWidget);
    expect(find.text('Hang rep 20mm'), findsOneWidget);
  });

  testWidgets('falls back to the training when nothing was frozen', (
    tester,
  ) async {
    // A guest-mode run has no prescription, but its training is local and
    // readable, so the blocks still come out named.
    await _pump(
      tester,
      _session(
        trainingId: 't1',
        reps: [_rep(0, itemId: 'a')],
      ),
      resolved: [_hangRep('a')],
    );

    expect(find.text('Blocks'), findsOneWidget);
    expect(find.text('Hang rep 20mm'), findsOneWidget);
  });

  testWidgets('states nothing session wide that would pool unlike blocks', (
    tester,
  ) async {
    // Two hangs at 30 kg then two at 20 kg against a 24 kg target. The pooled
    // average is 25.0 kg, which neither block asked for and no rep pulled, and
    // the pooled 2/4 hides that one block was met and the other missed.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a'), _hangRep('b', edgeSizeMm: 14)],
        reps: [
          _rep(0, itemId: 'a'),
          _rep(1, itemId: 'a'),
          _rep(2, itemId: 'b', averageWeight: 20, targetWeight: 24),
          _rep(3, itemId: 'b', averageWeight: 20, targetWeight: 24),
        ],
      ),
    );

    expect(find.text('Avg Weight'), findsNothing);
    expect(find.text('25.0 kg'), findsNothing);
    expect(find.text('2/4'), findsNothing);
    // Each block still carries the ratio it was graded on.
    expect(find.text('2/2 on target'), findsOneWidget);
    expect(find.text('0/2 on target'), findsOneWidget);
    // What aggregates over the whole session regardless of the blocks stays.
    expect(find.text('Max Weight'), findsOneWidget);
    expect(find.text('Work Reps'), findsOneWidget);
  });

  testWidgets('names the reps a dropped sensor left out of the ratio', (
    tester,
  ) async {
    // Four hangs against a 30 kg target, the sensor gone after the second. The
    // two it measured were held, and the two it did not are neither hits nor
    // misses: counted in, they would read as a 2/4 the athlete never ran.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a')],
        reps: [
          _rep(0, itemId: 'a'),
          _rep(1, itemId: 'a'),
          _rep(
            2,
            itemId: 'a',
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
          _rep(
            3,
            itemId: 'a',
            averageWeight: 0,
            targetWeight: 0,
            targetUnmeasured: true,
          ),
        ],
      ),
    );

    expect(find.text('2/4'), findsNothing);
    expect(find.text('2/2 (2 unmeasured)'), findsOneWidget);
    expect(find.text('2/2 on target (2 unmeasured)'), findsOneWidget);
    // The average load counts the same reps the ratio does. Counting the two
    // the sensor missed would read 15.0 kg, a load the athlete never pulled.
    expect(find.text('Avg Weight'), findsOneWidget);
    expect(find.text('15.0 kg'), findsNothing);
    expect(find.text('30.0 kg'), findsWidgets);
  });

  testWidgets('states no peak load for a run the sensor never measured', (
    tester,
  ) async {
    // The sensor never answered, so every rep is stored at zero. A max over
    // them reads 0.0 kg, the one stat left able to state a load the athlete
    // never pulled, beside an average that is correctly absent.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a')],
        reps: [
          for (var index = 0; index < 2; index++)
            _rep(
              index,
              itemId: 'a',
              averageWeight: 0,
              targetWeight: 0,
              targetUnmeasured: true,
            ),
        ],
      ),
    );

    expect(find.text('Max Weight'), findsNothing);
    expect(find.text('0.0 kg'), findsNothing);
    expect(find.text('Avg Weight'), findsNothing);
    // The run was still two reps long, so what the sensor cannot take away
    // stays.
    expect(find.text('Work Reps'), findsOneWidget);
    expect(find.text('Work Time'), findsOneWidget);
  });

  testWidgets('names every rep the run weighed nothing for', (tester) async {
    // The reps below the header carry the same zero the peak load was dropped
    // for. Printed as a load, they contradict the block line that already reads
    // that nothing was measured, so each row says so for itself.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a')],
        reps: [
          for (var index = 0; index < 2; index++)
            _rep(
              index,
              itemId: 'a',
              averageWeight: 0,
              targetWeight: 0,
              targetUnmeasured: true,
            ),
        ],
      ),
    );

    expect(find.text('Not measured'), findsNWidgets(2));
    expect(find.text('Performed'), findsNothing);
  });

  testWidgets('states the load of a rep read at zero against a target', (
    tester,
  ) async {
    // The athlete came off the board, which the sensor did read, so the row
    // states the zero rather than claiming nothing measured it.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a')],
        reps: [_rep(0, itemId: 'a', averageWeight: 0, targetWeight: 30)],
      ),
    );

    expect(find.text('Not measured'), findsNothing);
    expect(find.text('0.0 kg'), findsWidgets);
  });

  testWidgets('names the load of a rep the sensor read against no target', (
    tester,
  ) async {
    // The athlete logged the run themselves, so nothing prescribed a load. The
    // sensor still read the rep, the card averages it in, and the portal prints
    // it on the row, so the row names it here too rather than staying silent.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a')],
        reps: [_rep(0, itemId: 'a', averageWeight: 27.3, targetWeight: 0)],
      ),
    );

    expect(find.text('Performed'), findsOneWidget);
    expect(find.text('27.3 kg'), findsWidgets);
    expect(find.text('Target'), findsNothing);
    expect(find.text('Not measured'), findsNothing);
  });

  testWidgets('keeps the session wide stats when one block was played', (
    tester,
  ) async {
    // Nothing is pooled across a single block, so the session reads exactly as
    // it did before blocks existed.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a')],
        reps: [
          _rep(0, itemId: 'a'),
          _rep(1, itemId: 'a'),
        ],
      ),
    );

    expect(find.text('Avg Weight'), findsOneWidget);
    expect(find.text('30.0 kg'), findsWidgets);
    expect(find.text('2/2'), findsOneWidget);
  });

  testWidgets('states nothing session wide until the blocks have resolved', (
    tester,
  ) async {
    // A locally played session freezes no prescription, so its blocks are only
    // known once the training loads. Reading the pooled average on the way
    // there would flash the very number this card exists to stop showing.
    final items = Completer<List<TrainingItem>>();
    final session = _session(
      trainingId: 't1',
      reps: [
        _rep(0, itemId: 'a'),
        _rep(1, itemId: 'a'),
        _rep(2, itemId: 'b', averageWeight: 20, targetWeight: 24),
        _rep(3, itemId: 'b', averageWeight: 20, targetWeight: 24),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionTrainingItemsProvider(
            session.trainingId,
          ).overrideWith((ref) => items.future),
        ],
        child: MaterialApp(home: SessionDetailScreen(session: session)),
      ),
    );
    await tester.pump();

    expect(find.text('Avg Weight'), findsNothing);
    expect(find.text('25.0 kg'), findsNothing);
    expect(find.text('2/4'), findsNothing);

    items.complete([_hangRep('a'), _hangRep('b', edgeSizeMm: 14)]);
    await tester.pumpAndSettle();

    // The blocks it was waiting on do pool, so nothing session wide comes back.
    expect(find.text('Avg Weight'), findsNothing);
    expect(find.text('2/2 on target'), findsOneWidget);
    expect(find.text('0/2 on target'), findsOneWidget);
  });

  testWidgets('states the session wide stats once one block has resolved', (
    tester,
  ) async {
    // The same wait, on a session that turns out to pool nothing: the average
    // is held back rather than dropped, and arrives with the blocks.
    final items = Completer<List<TrainingItem>>();
    final session = _session(
      trainingId: 't1',
      reps: [
        _rep(0, itemId: 'a'),
        _rep(1, itemId: 'a'),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionTrainingItemsProvider(
            session.trainingId,
          ).overrideWith((ref) => items.future),
        ],
        child: MaterialApp(home: SessionDetailScreen(session: session)),
      ),
    );
    await tester.pump();

    expect(find.text('Avg Weight'), findsNothing);

    items.complete([_hangRep('a')]);
    await tester.pumpAndSettle();

    expect(find.text('Avg Weight'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
  });

  testWidgets('grades no ratio over reps the training never targeted', (
    tester,
  ) async {
    // An athlete's own logged run carries no target, so a ratio over it would
    // read every rep as missed rather than as untargeted.
    await _pump(
      tester,
      _session(
        trainingId: 'coach-training',
        prescriptionItems: [_hangRep('a')],
        reps: [
          _rep(0, itemId: 'a', targetWeight: 0),
          _rep(1, itemId: 'a', targetWeight: 0),
        ],
      ),
    );

    expect(find.text('0/2'), findsNothing);
    expect(find.text('Avg Weight'), findsOneWidget);
  });
}
