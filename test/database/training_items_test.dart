import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_item_model.dart';
import 'package:crimpy/utils/rep_blocks.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// A saved training keeps its items under stable ids: the reps and the open rep
/// counts a session recorded point at them by id, and nothing recomputes them.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  TrainingItem rep({String id = '', int position = 0, int worktime = 7}) =>
      TrainingItem(
        id: id,
        type: TrainingItemType.hangboardRep,
        position: position,
        worktimeSeconds: worktime,
        restSeconds: 3,
      );

  TrainingItem circuit({
    String id = '',
    int position = 0,
    List<TrainingItem> items = const [],
  }) => TrainingItem(
    id: id,
    type: TrainingItemType.circuit,
    position: position,
    cycles: 3,
    items: items,
  );

  /// Stores a training and reads it back, so every item carries the id storage
  /// gave it, exactly as the editor gets it.
  Future<Training> store(List<TrainingItem> items) async {
    final id = await db.saveTraining(
      Training(title: 'Session', items: items, id: ''),
    );
    return (await db.getTraining(id))!;
  }

  Future<List<String>> storedItemIds(String trainingId) async {
    final rows = await (db.select(
      db.trainingItems,
    )..where((i) => i.trainingId.equals(trainingId))).get();
    return rows.map((r) => r.id).toList()..sort();
  }

  test('an edit leaves the ids of the items it did not touch alone', () async {
    final stored = await store([
      rep(position: 0),
      circuit(position: 1, items: [rep(position: 0)]),
    ]);
    final untouched = stored.items[0].id;
    final circuitId = stored.items[1].id;
    final nestedId = stored.items[1].items.single.id;

    await db.updateTraining(
      stored.copyWith(
        title: 'Renamed',
        items: [stored.items[0], stored.items[1].copyWith(cycles: 5)],
      ),
    );

    final reread = (await db.getTraining(stored.id))!;
    expect(reread.title, 'Renamed');
    expect(reread.items[0].id, untouched);
    expect(reread.items[1].id, circuitId);
    expect(reread.items[1].cycles, 5);
    expect(reread.items[1].items.single.id, nestedId);
  });

  test('an edited item keeps its id and takes the new values', () async {
    final stored = await store([rep(worktime: 7)]);
    final itemId = stored.items.single.id;

    await db.updateTraining(
      stored.copyWith(
        items: [stored.items.single.copyWith(worktimeSeconds: 12)],
      ),
    );

    final reread = (await db.getTraining(stored.id))!;
    expect(reread.items.single.id, itemId);
    expect(reread.items.single.worktimeSeconds, 12);
  });

  test('an item added by the editor gets an id of its own', () async {
    final stored = await store([rep()]);
    final existingId = stored.items.single.id;

    await db.updateTraining(
      stored.copyWith(items: [stored.items.single, rep(position: 1)]),
    );

    final reread = (await db.getTraining(stored.id))!;
    expect(reread.items, hasLength(2));
    expect(reread.items[0].id, existingId);
    expect(reread.items[1].id, isNotEmpty);
    expect(reread.items[1].id, isNot(existingId));
  });

  test('an item the editor dropped leaves no row behind', () async {
    final stored = await store([rep(position: 0), rep(position: 1)]);
    final kept = stored.items[0];

    await db.updateTraining(stored.copyWith(items: [kept]));

    expect(await storedItemIds(stored.id), [kept.id]);
  });

  test('dropping a container deletes the items it held', () async {
    final stored = await store([
      circuit(items: [rep(position: 0), rep(position: 1)]),
    ]);

    await db.updateTraining(stored.copyWith(items: []));

    expect(await storedItemIds(stored.id), isEmpty);
    expect((await db.getTraining(stored.id))!.items, isEmpty);
  });

  test('an item moved to another parent keeps its id', () async {
    final stored = await store([rep(position: 0), circuit(position: 1)]);
    final moved = stored.items[0];
    final target = stored.items[1];

    await db.updateTraining(
      stored.copyWith(
        items: [
          target.copyWith(position: 0, items: [moved.copyWith(position: 0)]),
        ],
      ),
    );

    final reread = (await db.getTraining(stored.id))!;
    expect(reread.items.single.id, target.id);
    expect(reread.items.single.items.single.id, moved.id);
  });

  test('a duplicated item is stored beside the one it came from', () async {
    final stored = await store([rep()]);
    final original = stored.items.single;

    await db.updateTraining(
      stored.copyWith(
        items: [original, original.duplicate().copyWith(position: 1)],
      ),
    );

    final reread = (await db.getTraining(stored.id))!;
    expect(reread.items.map((i) => i.id), hasLength(2));
    expect(reread.items[0].id, original.id);
    expect(reread.items[1].id, isNot(original.id));
  });

  test(
    'the same id twice is refused rather than silently losing an item',
    () async {
      final stored = await store([rep()]);
      final original = stored.items.single;

      await expectLater(
        db.updateTraining(
          stored.copyWith(items: [original, original.copyWith(position: 1)]),
        ),
        throwsStateError,
      );
    },
  );

  test('an id belonging to another training is refused', () async {
    final mine = await store([rep()]);
    final other = await store([rep()]);

    await expectLater(
      db.updateTraining(mine.copyWith(items: [other.items.single])),
      throwsStateError,
    );
  });

  // The refusal comes after the title write and after the insert of the added
  // item, so nothing but the transaction can take those back.
  test('a refused update leaves the stored tree untouched', () async {
    final stored = await store([rep(position: 0), rep(position: 1)]);
    final before = await storedItemIds(stored.id);

    await expectLater(
      db.updateTraining(
        stored.copyWith(
          title: 'Renamed',
          items: [rep(position: 0), stored.items[0], stored.items[0]],
        ),
      ),
      throwsStateError,
    );

    expect(await storedItemIds(stored.id), before);
    expect((await db.getTraining(stored.id))!.title, 'Session');
  });

  // What the rotating ids cost: a count recorded against an item is written by
  // id and recomputed by nothing, so it is only readable while the id holds.
  test(
    'a recorded open rep count still names its item after an edit',
    () async {
      final stored = await store([
        TrainingItem(
          id: '',
          type: TrainingItemType.exercise,
          position: 0,
          repsIsMax: true,
          freeText: 'Pull ups',
        ),
        rep(position: 1),
      ]);
      final amrap = stored.items[0];

      final sessionId = await db.saveSession(
        SessionModel(
          name: 'Session',
          isAssessment: false,
          origin: SessionOrigin.played,
          trainingId: stored.id,
        ),
        const [],
        itemResults: [
          SessionItemResultModel(
            trainingItemId: amrap.id,
            occurrence: 0,
            field: SessionItemField.reps,
            value: 9,
          ),
        ],
      );

      // An edit that never touched the item the count answers.
      await db.updateTraining(
        stored.copyWith(
          items: [amrap, stored.items[1].copyWith(worktimeSeconds: 12)],
        ),
      );

      final reread = (await db.getTraining(stored.id))!;
      final results = openItemResults(
        await db.getItemResultsForSession(sessionId),
        reread.items,
      );
      expect(results, hasLength(1));
      expect(results.single.values, [9]);
    },
  );
}
