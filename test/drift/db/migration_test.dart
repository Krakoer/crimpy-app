// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:crimpy/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

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
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    final oldSessionsData = <v1.SessionsData>[
      v1.SessionsData(
        id: 1,
        name: "Test",
        notes: "",
        date: 3,
        dataPath: "",
        isAssessment: 0,
        sessionType: 0,
        duration: 12,
        updatedAt: 100000,
        dirty: 0,
        remoteId: "remoteId",
      ),
    ];
    final expectedNewSessionsData = <v2.SessionsData>[
      v2.SessionsData(
        id: 1,
        name: "Test",
        notes: "",
        date: 3,
        dataPath: "",
        isAssessment: 0,
        sessionType: 0,
        duration: 12,
        updatedAt: 100000,
        dirty: 0,
        remoteId: "remoteId",
      ),
    ];

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

  test('migration from v2 to v3 does not corrupt data', () async {
    final oldSessionsData = <v2.SessionsData>[
      v2.SessionsData(
        id: 1,
        name: "Test",
        notes: "",
        date: 3,
        dataPath: "",
        isAssessment: 0,
        sessionType: 0,
        duration: 12,
        updatedAt: 100000,
        dirty: 0,
        remoteId: "remoteId",
      ),
    ];
    final expectedNewSessionsData = <v3.SessionsData>[
      v3.SessionsData(
        id: 1,
        name: "Test",
        notes: "",
        date: 3,
        dataPath: "",
        isAssessment: 0,
        sessionType: 0,
        duration: 12,
        updatedAt: 100000,
        dirty: 0,
        remoteId: "remoteId",
        createdAt: null,
      ),
    ];

    final oldAssessmentsData = <v2.AssessmentsData>[];
    final expectedNewAssessmentsData = <v3.AssessmentsData>[];

    final oldRepeatersData = <v2.RepeatersData>[];
    final expectedNewRepeatersData = <v3.RepeatersData>[];

    final oldTrainingsData = <v2.TrainingsData>[];
    final expectedNewTrainingsData = <v3.TrainingsData>[];

    final oldRepTemplatesData = <v2.RepTemplatesData>[];
    final expectedNewRepTemplatesData = <v3.RepTemplatesData>[];

    final oldRepDatasData = <v2.RepDatasData>[];
    final expectedNewRepDatasData = <v3.RepDatasData>[];

    final oldSensorConfigsData = <v2.SensorConfigsData>[];
    final expectedNewSensorConfigsData = <v3.SensorConfigsData>[];

    final oldBuiltinTrainingWeightsData = <v2.BuiltinTrainingWeightsData>[];
    final expectedNewBuiltinTrainingWeightsData =
        <v3.BuiltinTrainingWeightsData>[];

    final oldPinnedBuiltinTrainingsData = <v2.PinnedBuiltinTrainingsData>[];
    final expectedNewPinnedBuiltinTrainingsData =
        <v3.PinnedBuiltinTrainingsData>[];

    final oldUsersData = <v2.UsersData>[];
    final expectedNewUsersData = <v3.UsersData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
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

  test('migration from v3 to v4 does not corrupt data', () async {
    final oldSessionsData = <v3.SessionsData>[
      v3.SessionsData(
        id: 1,
        name: "Test",
        notes: "",
        date: 3,
        dataPath: "",
        isAssessment: 0,
        sessionType: 0,
        duration: 12,
        updatedAt: 100000,
        dirty: 0,
        remoteId: "remoteId",
      ),
    ];
    final expectedNewSessionsData = <v4.SessionsData>[
      v4.SessionsData(
        id: "remoteId",
        name: "Test",
        notes: "",
        date: 3,
        dataPath: "",
        isAssessment: 0,
        sessionType: 0,
        duration: 12,
        updatedAt: 100000,
        dirty: 0,
        createdAt: null,
      ),
    ];

    final oldAssessmentsData = <v2.AssessmentsData>[];
    final expectedNewAssessmentsData = <v3.AssessmentsData>[];

    final oldRepeatersData = <v2.RepeatersData>[];
    final expectedNewRepeatersData = <v3.RepeatersData>[];

    final oldTrainingsData = <v2.TrainingsData>[];
    final expectedNewTrainingsData = <v3.TrainingsData>[];

    final oldRepTemplatesData = <v2.RepTemplatesData>[];
    final expectedNewRepTemplatesData = <v3.RepTemplatesData>[];

    final oldRepDatasData = <v2.RepDatasData>[];
    final expectedNewRepDatasData = <v3.RepDatasData>[];

    final oldSensorConfigsData = <v2.SensorConfigsData>[];
    final expectedNewSensorConfigsData = <v3.SensorConfigsData>[];

    final oldBuiltinTrainingWeightsData = <v2.BuiltinTrainingWeightsData>[];
    final expectedNewBuiltinTrainingWeightsData =
        <v3.BuiltinTrainingWeightsData>[];

    final oldPinnedBuiltinTrainingsData = <v2.PinnedBuiltinTrainingsData>[];
    final expectedNewPinnedBuiltinTrainingsData =
        <v3.PinnedBuiltinTrainingsData>[];

    final oldUsersData = <v2.UsersData>[];
    final expectedNewUsersData = <v3.UsersData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
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
