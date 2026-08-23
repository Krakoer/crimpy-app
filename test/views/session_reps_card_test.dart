import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/viewmodels/training_view_model.dart';
import 'package:crimpy/views/screens/home_screen/history/widgets/session_reps_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

RepDataModel _rep(
  int index, {
  String? itemId,
  HandSide hand = HandSide.right,
}) => RepDataModel(
  averageWeight: 30,
  duration: 7,
  index: index,
  isRest: false,
  handSide: hand,
  targetWeight: 30,
  trainingItemId: itemId,
);

TrainingItem _hangRep(String id) => TrainingItem(
  id: id,
  type: TrainingItemType.hangboardRep,
  position: 0,
  reps: 2,
  edgeSizesMm: const [20],
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

/// Pumps the card with the training the session links to resolved to [items].
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
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SessionRepsCard(session: session, sessionColor: Colors.blue),
          ),
        ),
      ),
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
}
