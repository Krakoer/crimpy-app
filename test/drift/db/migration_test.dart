// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:crimpy/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
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

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldSessionsData = <v1.SessionsData>[];
    final expectedNewSessionsData = <v2.SessionsData>[];

    final oldAssessmentsData = <v1.AssessmentsData>[];
    final expectedNewAssessmentsData = <v2.AssessmentsData>[];

    final oldRepeatersData = <v1.RepeatersData>[];
    final expectedNewRepeatersData = <v2.RepeatersData>[];

    final oldTrainingsData = <v1.TrainingsData>[];
    final expectedNewTrainingsData = <v2.TrainingsData>[];

    final oldRepTemplatesData = <v1.RepTemplatesData>[];
    final expectedNewRepTemplatesData = <v2.RepTemplatesData>[];

    final oldRepDatasData = <v1.RepDatasData>[];
    final expectedNewRepDatasData = <v2.RepDatasData>[];

    final oldSensorConfigsData = <v1.SensorConfigsData>[];
    final expectedNewSensorConfigsData = <v2.SensorConfigsData>[];

    final oldBuiltinTrainingWeightsData = <v1.BuiltinTrainingWeightsData>[];
    final expectedNewBuiltinTrainingWeightsData =
        <v2.BuiltinTrainingWeightsData>[];

    final oldPinnedBuiltinTrainingsData = <v1.PinnedBuiltinTrainingsData>[];
    final expectedNewPinnedBuiltinTrainingsData =
        <v2.PinnedBuiltinTrainingsData>[];

    final oldUsersData = <v1.UsersData>[];
    final expectedNewUsersData = <v2.UsersData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.sessions, oldSessionsData);
        batch.insertAll(oldDb.assessments, oldAssessmentsData);
        batch.insertAll(oldDb.repeaters, oldRepeatersData);
        batch.insertAll(oldDb.trainings, oldTrainingsData);
        batch.insertAll(oldDb.repTemplates, oldRepTemplatesData);
        batch.insertAll(oldDb.repDatas, oldRepDatasData);
        batch.insertAll(oldDb.sensorConfigs, oldSensorConfigsData);
        batch.insertAll(
          oldDb.builtinTrainingWeights,
          oldBuiltinTrainingWeightsData,
        );
        batch.insertAll(
          oldDb.pinnedBuiltinTrainings,
          oldPinnedBuiltinTrainingsData,
        );
        batch.insertAll(oldDb.users, oldUsersData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewSessionsData,
          await newDb.select(newDb.sessions).get(),
        );
        expect(
          expectedNewAssessmentsData,
          await newDb.select(newDb.assessments).get(),
        );
        expect(
          expectedNewRepeatersData,
          await newDb.select(newDb.repeaters).get(),
        );
        expect(
          expectedNewTrainingsData,
          await newDb.select(newDb.trainings).get(),
        );
        expect(
          expectedNewRepTemplatesData,
          await newDb.select(newDb.repTemplates).get(),
        );
        expect(
          expectedNewRepDatasData,
          await newDb.select(newDb.repDatas).get(),
        );
        expect(
          expectedNewSensorConfigsData,
          await newDb.select(newDb.sensorConfigs).get(),
        );
        expect(
          expectedNewBuiltinTrainingWeightsData,
          await newDb.select(newDb.builtinTrainingWeights).get(),
        );
        expect(
          expectedNewPinnedBuiltinTrainingsData,
          await newDb.select(newDb.pinnedBuiltinTrainings).get(),
        );
        expect(expectedNewUsersData, await newDb.select(newDb.users).get());
      },
    );
  });
}
