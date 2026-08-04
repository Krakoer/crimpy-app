// dart format width=80
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:crimpy/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;

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
}
