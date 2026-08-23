// dart format width=80
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  group('v1 to v2 data migration', () {
    /// Seeds a v1 database, runs the migration and hands back the migrated
    /// database so each test can assert on the unified schema.
    Future<AppDatabase> migrated(
      Future<void> Function(v1.DatabaseAtV1 db) seed,
    ) async {
      final schema = await verifier.schemaAt(1);
      final oldDb = v1.DatabaseAtV1(schema.newConnection());
      await seed(oldDb);
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      // Opening at the current version runs the migration.
      await db.customSelect('SELECT 1').get();
      return db;
    }

    test('repeater training becomes a training with a repeater item', () async {
      final db = await migrated((oldDb) async {
        await oldDb
            .into(oldDb.repeaters)
            .insert(
              const v1.RepeatersData(
                id: 'rep-1',
                sets: 3,
                reps: 6,
                worktime: 7,
                resttime: 3,
                setRest: 180,
                targetWeigthRight: 20.5,
                targetWeigthLeft: 18.0,
                splitHand: 1,
                gripPosition: 0,
                updatedAt: 100,
                dirty: 0,
              ),
            );
        await oldDb
            .into(oldDb.trainings)
            .insert(
              const v1.TrainingsData(
                id: 'tr-1',
                name: 'My repeater',
                repeaterId: 'rep-1',
                isBuiltin: 0,
                isFavorite: 1,
                isAssessment: 0,
                updatedAt: 100,
                dirty: 0,
              ),
            );
      });

      final training = await db.select(db.trainings).getSingle();
      expect(training.title, 'My repeater');
      expect(training.isFavorite, true);

      final item = await db.select(db.trainingItems).getSingle();
      expect(item.trainingId, 'tr-1');
      expect(item.type, 'repeater');
      expect(item.cycles, 3);
      expect(item.reps, 6);
      expect(item.worktimeSeconds, 7);
      expect(item.restSeconds, 3);
      expect(item.cycleRestSeconds, 180);
      expect(item.hand, 'split');

      // One load entry per rep, for both hands on a split-hand repeater.
      final loads = jsonDecode(item.loadsJson!) as List<dynamic>;
      final leftLoads = jsonDecode(item.leftLoadsJson!) as List<dynamic>;
      expect(loads, hasLength(6));
      expect(leftLoads, hasLength(6));
      expect((loads.first as Map)['value'], 20.5);
      expect((leftLoads.first as Map)['value'], 18.0);

      await db.close();
    });

    test('custom training reps become hangboard items with rests', () async {
      final db = await migrated((oldDb) async {
        await oldDb
            .into(oldDb.trainings)
            .insert(
              const v1.TrainingsData(
                id: 'tr-2',
                name: 'Custom',
                isBuiltin: 0,
                isFavorite: 0,
                isAssessment: 0,
                updatedAt: 100,
                dirty: 0,
              ),
            );
        // A hang followed by a rest, then a second hang.
        await oldDb.batch((b) {
          b.insertAll(oldDb.repTemplates, const [
            v1.RepTemplatesData(
              id: 'rt-1',
              isRest: 0,
              rightHand: 1,
              duration: 10,
              trainingId: 'tr-2',
              targetWeight: 30.0,
              index: 0,
              gripPosition: 0,
              updatedAt: 100,
              dirty: 0,
            ),
            v1.RepTemplatesData(
              id: 'rt-2',
              isRest: 1,
              rightHand: 1,
              duration: 5,
              trainingId: 'tr-2',
              targetWeight: 0.0,
              index: 1,
              gripPosition: 0,
              updatedAt: 100,
              dirty: 0,
            ),
            v1.RepTemplatesData(
              id: 'rt-3',
              isRest: 0,
              rightHand: 0,
              duration: 10,
              trainingId: 'tr-2',
              targetWeight: 25.0,
              index: 2,
              gripPosition: 0,
              updatedAt: 100,
              dirty: 0,
            ),
          ]);
        });
      });

      final items = await (db.select(
        db.trainingItems,
      )..orderBy([(t) => OrderingTerm(expression: t.position)])).get();

      expect(items, hasLength(2));
      expect(items.every((i) => i.type == 'hangboard_rep'), true);
      // The rest row is folded into the preceding hang.
      expect(items[0].worktimeSeconds, 10);
      expect(items[0].restSeconds, 5);
      expect(items[0].hand, 'right');
      expect(items[1].worktimeSeconds, 10);
      expect(items[1].restSeconds, 0);
      expect(items[1].hand, 'left');

      await db.close();
    });

    test(
      'soft-deleted and assessment trainings are not carried over',
      () async {
        final db = await migrated((oldDb) async {
          await oldDb.batch((b) {
            b.insertAll(oldDb.trainings, const [
              v1.TrainingsData(
                id: 'tr-deleted',
                name: 'Deleted',
                isBuiltin: 0,
                isFavorite: 0,
                isAssessment: 0,
                updatedAt: 100,
                deletedAt: 200,
                dirty: 0,
              ),
              v1.TrainingsData(
                id: 'tr-assessment',
                name: 'Assessment',
                isBuiltin: 0,
                isFavorite: 0,
                isAssessment: 1,
                updatedAt: 100,
                dirty: 0,
              ),
              v1.TrainingsData(
                id: 'tr-keep',
                name: 'Keep',
                isBuiltin: 0,
                isFavorite: 0,
                isAssessment: 0,
                updatedAt: 100,
                dirty: 0,
              ),
            ]);
          });
        });

        final titles = (await db.select(db.trainings).get())
            .map((t) => t.title)
            .toList();
        expect(titles, ['Keep']);

        await db.close();
      },
    );

    test('sessions and their reps survive the migration', () async {
      final db = await migrated((oldDb) async {
        await oldDb
            .into(oldDb.sessions)
            .insert(
              const v1.SessionsData(
                id: 's-1',
                name: 'Session',
                notes: 'note',
                date: 1700000000,
                dataPath: '',
                isAssessment: 0,
                sessionType: 0,
                duration: 120,
                updatedAt: 100,
                dirty: 0,
              ),
            );
        await oldDb
            .into(oldDb.repDatas)
            .insert(
              const v1.RepDatasData(
                id: 'rd-1',
                averageWeight: 22.0,
                sessionId: 's-1',
                isRest: 0,
                rightHand: 1,
                duration: 7,
                targetWeight: 20.0,
                index: 0,
                gripPosition: 0,
                updatedAt: 100,
                dirty: 0,
              ),
            );
      });

      final session = await db.select(db.sessions).getSingle();
      expect(session.name, 'Session');
      expect(session.notes, 'note');
      expect(session.duration, 120);

      final rep = await db.select(db.repDatas).getSingle();
      expect(rep.sessionId, 's-1');
      expect(rep.averageWeight, 22.0);

      await db.close();
    });
  });

  group('v2 to v3 data migration', () {
    /// Seeds a v2 database with a raw training item, runs the migration and
    /// hands back the row as the current schema sees it.
    Future<TrainingItemRow> migratedItem({
      required String type,
      required String hand,
      String? loadsJson,
      String? handPositionsJson,
      String? edgeSizesMmJson,
      int? cycles,
      int? reps,
    }) async {
      final schema = await verifier.schemaAt(2);
      final oldDb = v2.DatabaseAtV2(schema.newConnection());
      await oldDb.customStatement(
        "INSERT INTO trainings (id, title, is_favorite, updated_at) "
        "VALUES ('t-1', 'Training', 0, 100)",
      );
      await oldDb.customStatement(
        'INSERT INTO training_items (id, training_id, type, position, cycles, '
        'reps, hand, loads_json, hand_positions_json, edge_sizes_mm_json, '
        'load_is_max, updated_at) '
        'VALUES (?,?,?,0,?,?,?,?,?,?,0,100)',
        [
          'i-1',
          't-1',
          type,
          cycles,
          reps,
          hand,
          loadsJson,
          handPositionsJson,
          edgeSizesMmJson,
        ],
      );
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      final row = await db.select(db.trainingItems).getSingle();
      await db.close();
      return row;
    }

    String loadsOf(int count) => jsonEncode(
      List.generate(count, (i) => {'value': 10.0 + i, 'unit': 'kg'}),
    );

    // The app ran its 'both' repeaters one hand at a time, right then left
    // inside every rep. That mode is now named for what it does.
    test('an app repeater stored as both becomes alternate', () async {
      final row = await migratedItem(
        type: 'repeater',
        hand: 'both',
        cycles: 3,
        reps: 2,
        loadsJson: loadsOf(2),
      );

      expect(row.hand, 'alternate');
    });

    // A hangboard rep already meant a genuine two-handed hang.
    test('a hangboard rep stored as both stays both', () async {
      final row = await migratedItem(
        type: 'hangboard_rep',
        hand: 'both',
        loadsJson: loadsOf(1),
      );

      expect(row.hand, 'both');
    });

    test('the layout an item was written with is declared', () async {
      final perRep = await migratedItem(
        type: 'repeater',
        hand: 'right',
        cycles: 3,
        reps: 2,
        loadsJson: loadsOf(2),
      );
      expect(perRep.granularity, 'rep');

      final uniform = await migratedItem(
        type: 'hangboard_rep',
        hand: 'right',
        loadsJson: loadsOf(1),
      );
      expect(uniform.granularity, 'uniform');

      final perSet = await migratedItem(
        type: 'repeater',
        hand: 'right',
        cycles: 2,
        reps: 3,
        loadsJson: loadsOf(6),
        edgeSizesMmJson: jsonEncode([20, 20, 18, 18, 15, 15]),
      );
      expect(perSet.granularity, 'set');
    });

    test('a flat grip array is wrapped into one array per hand', () async {
      final row = await migratedItem(
        type: 'repeater',
        hand: 'right',
        cycles: 1,
        reps: 2,
        loadsJson: loadsOf(2),
        handPositionsJson: jsonEncode(['halfCrimp', 'openHand']),
      );

      expect(jsonDecode(row.handPositionsJson!), [
        ['halfCrimp', 'openHand'],
      ]);
    });

    test('a grip array already held per hand is left alone', () async {
      final row = await migratedItem(
        type: 'repeater',
        hand: 'split',
        cycles: 1,
        reps: 2,
        loadsJson: loadsOf(2),
        handPositionsJson: jsonEncode([
          ['HC', 'FC'],
          ['OC', '3FD'],
        ]),
      );

      expect(jsonDecode(row.handPositionsJson!), [
        ['HC', 'FC'],
        ['OC', '3FD'],
      ]);
    });
  });

  group('v3 to v4 data migration', () {
    // Reps recorded before the edge was tracked say nothing about the edge
    // they were pulled on, so they keep none rather than claiming the default.
    test('a rep recorded without an edge keeps none', () async {
      final schema = await verifier.schemaAt(3);
      final oldDb = v3.DatabaseAtV3(schema.newConnection());
      await oldDb
          .into(oldDb.sessions)
          .insert(
            const v3.SessionsData(
              id: 's-1',
              name: 'Session',
              notes: '',
              date: 1700000000,
              dataPath: '',
              isAssessment: 0,
              sessionType: 0,
              duration: 10,
              updatedAt: 1700000000,
            ),
          );
      await oldDb
          .into(oldDb.repDatas)
          .insert(
            const v3.RepDatasData(
              id: 'rd-1',
              averageWeight: 22.0,
              sessionId: 's-1',
              isRest: 0,
              rightHand: 1,
              duration: 7,
              targetWeight: 20.0,
              index: 0,
              gripPosition: 0,
              updatedAt: 1700000000,
            ),
          );
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      final rep = await db.select(db.repDatas).getSingle();
      expect(rep.edgeSizeMm, null);
      await db.close();
    });
  });

  group('v4 to v5 data migration', () {
    // session_type used to stand in for three things at once. Its values become
    // the activity label untouched, and the origin it was implying is recovered
    // from what the session actually holds.
    Future<v4.DatabaseAtV4> seedV4(dynamic schema) async {
      final oldDb = v4.DatabaseAtV4(schema.newConnection());
      Future<void> session(String id, int type, int isAssessment) => oldDb
          .into(oldDb.sessions)
          .insert(
            v4.SessionsData(
              id: id,
              name: 'Session $id',
              notes: '',
              date: 1700000000,
              dataPath: '',
              isAssessment: isAssessment,
              sessionType: type,
              duration: 10,
              updatedAt: 1700000000,
            ),
          );

      // A coach hangboard block mislabelled as a workout, with its reps.
      await session('s-played', 3, 0);
      // A climbing session typed in by hand, with none.
      await session('s-logged', 1, 0);
      // An assessment, played even though it recorded no usable rep.
      await session('s-assessment', 0, 1);

      await oldDb
          .into(oldDb.repDatas)
          .insert(
            const v4.RepDatasData(
              id: 'rd-1',
              averageWeight: 22.0,
              sessionId: 's-played',
              isRest: 0,
              rightHand: 1,
              duration: 7,
              targetWeight: 20.0,
              index: 0,
              gripPosition: 0,
              updatedAt: 1700000000,
            ),
          );
      return oldDb;
    }

    test(
      'a session holding reps becomes played whatever it was labelled',
      () async {
        final schema = await verifier.schemaAt(4);
        final oldDb = await seedV4(schema);
        await oldDb.close();

        final db = AppDatabase(schema.newConnection());
        final played = await (db.select(
          db.sessions,
        )..where((s) => s.id.equals('s-played'))).getSingle();

        expect(played.origin, 'played');
        // The label carries over untouched: workout stays workout.
        expect(played.activity, SessionActivity.workout.index);
        await db.close();
      },
    );

    test('a session with no reps stays logged', () async {
      final schema = await verifier.schemaAt(4);
      final oldDb = await seedV4(schema);
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      final logged = await (db.select(
        db.sessions,
      )..where((s) => s.id.equals('s-logged'))).getSingle();

      expect(logged.origin, 'logged');
      expect(logged.activity, SessionActivity.climbing.index);
      await db.close();
    });

    test('an assessment is played even without reps', () async {
      final schema = await verifier.schemaAt(4);
      final oldDb = await seedV4(schema);
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      final assessment = await (db.select(
        db.sessions,
      )..where((s) => s.id.equals('s-assessment'))).getSingle();

      expect(assessment.origin, 'played');
      await db.close();
    });
  });

  group('v5 to v6 data migration', () {
    // Reps recorded before the link existed say nothing about the block they
    // came from, so they keep none rather than claiming the first item.
    test('a rep recorded without a training item keeps none', () async {
      final schema = await verifier.schemaAt(5);
      final oldDb = v5.DatabaseAtV5(schema.newConnection());
      await oldDb
          .into(oldDb.sessions)
          .insert(
            const v5.SessionsData(
              id: 's-1',
              name: 'Session',
              notes: '',
              date: 1700000000,
              dataPath: '',
              isAssessment: 0,
              activity: 0,
              origin: 'played',
              duration: 10,
              updatedAt: 1700000000,
            ),
          );
      await oldDb
          .into(oldDb.repDatas)
          .insert(
            const v5.RepDatasData(
              id: 'rd-1',
              averageWeight: 22.0,
              sessionId: 's-1',
              isRest: 0,
              rightHand: 1,
              duration: 7,
              targetWeight: 20.0,
              index: 0,
              gripPosition: 0,
              updatedAt: 1700000000,
            ),
          );
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      final rep = await db.select(db.repDatas).getSingle();
      expect(rep.trainingItemId, null);
      await db.close();
    });
  });

  group('v6 to v7 data migration', () {
    // Only the dummy data generator ever wrote a repeater configuration, so
    // dropping the columns costs no session. The rows themselves must survive
    // it: the reps of a played session are read against them.
    test('a session holding a repeater config survives the drop', () async {
      final schema = await verifier.schemaAt(6);
      final oldDb = v6.DatabaseAtV6(schema.newConnection());
      await oldDb
          .into(oldDb.sessions)
          .insert(
            const v6.SessionsData(
              id: 's-1',
              name: 'Beginner Repeaters',
              notes: '',
              date: 1700000000,
              dataPath: '',
              isAssessment: 0,
              activity: 0,
              origin: 'played',
              duration: 10,
              repeaterSets: 3,
              repeaterReps: 5,
              repeaterWorkTime: 7,
              repeaterRestTime: 3,
              repeaterSetRest: 120,
              repeaterSplitHand: 0,
              updatedAt: 1700000000,
            ),
          );
      await oldDb
          .into(oldDb.repDatas)
          .insert(
            const v6.RepDatasData(
              id: 'rd-1',
              averageWeight: 22.0,
              sessionId: 's-1',
              isRest: 0,
              rightHand: 1,
              duration: 7,
              targetWeight: 20.0,
              index: 0,
              gripPosition: 0,
              trainingItemId: 'item-1',
              updatedAt: 1700000000,
            ),
          );
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      final session = await db.select(db.sessions).getSingle();
      expect(session.name, 'Beginner Repeaters');
      final rep = await db.select(db.repDatas).getSingle();
      expect(rep.trainingItemId, 'item-1');
      await db.close();
    });
  });
}
