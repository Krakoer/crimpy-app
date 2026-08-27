import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/repositories/training_repository.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// A played session freezes the items it was run from. The reps and the open
/// rep counts it recorded name those items by id, so the snapshot is what keeps
/// them readable once the training is edited or deleted out from under them.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  TrainingItem amrap({int position = 0}) => TrainingItem(
    id: '',
    type: TrainingItemType.exercise,
    position: position,
    repsIsMax: true,
    groupTitle: 'Pull ups',
  );

  TrainingItem hang({int position = 0}) => TrainingItem(
    id: '',
    type: TrainingItemType.hangboardRep,
    position: position,
    worktimeSeconds: 7,
    restSeconds: 3,
    edgeSizesMm: const [20],
  );

  Future<Training> store(List<TrainingItem> items) async {
    final id = await db.saveTraining(
      Training(title: 'Session', items: items, id: ''),
    );
    return (await db.getTraining(id))!;
  }

  /// Plays [training] through, recording one rep against each of its top level
  /// items and an open count against the first, and hands back the id of the
  /// session written.
  Future<String> play(Training training) => db.saveSession(
    SessionModel(
      name: 'Run',
      isAssessment: false,
      origin: SessionOrigin.played,
      trainingId: training.id,
      prescriptionItems: training.items,
    ),
    [
      for (final (index, item) in training.items.indexed)
        RepDataModel(
          averageWeight: 22.0,
          duration: 7,
          index: index,
          isRest: false,
          handSide: HandSide.right,
          targetWeight: 20.0,
          trainingItemId: item.id,
        ),
    ],
    itemResults: [
      SessionItemResultModel(
        trainingItemId: training.items.first.id,
        occurrence: 0,
        field: SessionItemField.reps,
        value: 9,
      ),
    ],
  );

  test('a played session carries the items it was run from', () async {
    final training = await store([amrap(position: 0), hang(position: 1)]);
    final frozen = (await db.getSessionWithData(
      await play(training),
    ))!.prescriptionItems;

    expect(frozen?.map((i) => i.id), training.items.map((i) => i.id));
    expect(sessionBlockLabel(frozen!.first), 'Pull ups');
    expect(sessionBlockLabel(frozen.last), 'Hang rep 20mm');
  });

  test('a session played outside a training freezes nothing', () async {
    final id = await db.saveSession(
      SessionModel(
        name: 'Logged',
        isAssessment: false,
        origin: SessionOrigin.logged,
      ),
      const [],
    );

    expect((await db.getSessionWithData(id))!.prescriptionItems, isNull);
  });

  test('the snapshot outlives the item the coach deleted', () async {
    final training = await store([amrap(position: 0), hang(position: 1)]);
    final sessionId = await play(training);
    final deleted = training.items.first;

    await db.updateTraining(
      training.copyWith(items: [training.items[1].copyWith(position: 0)]),
    );

    // The live training no longer holds the item, which is what used to leave
    // the block unnamed and the count unread.
    expect((await db.getTraining(training.id))!.items, hasLength(1));

    final session = (await db.getSessionWithData(sessionId))!;
    final frozen = session.prescriptionItems!;
    expect(frozen.first.id, deleted.id);

    final blocks = groupRepsByTrainingItem(
      await db.getRepsForSession(sessionId),
      frozen,
    );
    expect(blocks?.map((b) => b.label), ['Pull ups', 'Hang rep 20mm']);

    final results = openItemResults(session.itemResults, frozen);
    expect(results.single.label, 'Pull ups');
    expect(results.single.values, [9]);
  });

  test('the snapshot outlives the whole training', () async {
    final training = await store([amrap(position: 0), hang(position: 1)]);
    final sessionId = await play(training);

    await db.deleteTraining(training.id);

    final session = (await db.getSessionWithData(sessionId))!;
    expect(session.trainingId, training.id);
    final blocks = groupRepsByTrainingItem(
      await db.getRepsForSession(sessionId),
      session.prescriptionItems!,
    );
    expect(blocks?.map((b) => b.label), ['Pull ups', 'Hang rep 20mm']);
  });

  test('a nested tree comes back with its nesting', () async {
    final training = await store([
      TrainingItem(
        id: '',
        type: TrainingItemType.circuit,
        position: 0,
        cycles: 3,
        groupTitle: 'Circuit A',
        items: [amrap(position: 0), hang(position: 1)],
      ),
    ]);
    final frozen = (await db.getSessionWithData(
      await play(training),
    ))!.prescriptionItems!;
    final children = training.items.single.items;

    expect(frozen, hasLength(1));
    expect(frozen.single.groupTitle, 'Circuit A');
    expect(frozen.single.cycles, 3);
    expect(frozen.single.items.map((i) => i.id), children.map((i) => i.id));
    expect(frozen.single.items.map((i) => i.position), [0, 1]);
    expect(frozen.single.items.first.parentId, training.items.single.id);
    expect(frozen.single.items.last.edgeSizesMm, [20]);
  });

  test('the listing carries the snapshot the detail read', () async {
    final training = await store([amrap(position: 0), hang(position: 1)]);
    await play(training);

    final listed = await LocalTrainingRepository(
      database: db,
    ).getAllSessionsWithReps();

    expect(
      listed.single.prescriptionItems?.map((i) => i.id),
      training.items.map((i) => i.id),
    );
  });
}
