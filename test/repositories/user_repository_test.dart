import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/repositories/user_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late UserRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = UserRepository(database: db);
  });
  tearDown(() => db.close());

  auth_models.User userCreatedAt(String createdAt) => auth_models.User(
    id: 'user-1',
    email: 'climber@example.com',
    firstname: 'Ada',
    lastname: 'Lovelace',
    emailVerified: true,
    createdAt: createdAt,
  );

  // The API sends this one as a Go time.Time String() and not as RFC3339, so
  // it is the only instant in the app that needs a transform before it parses.
  // Every shape below is one Go can emit for a UTC value: it trims the trailing
  // zeros off the fraction, and drops the fraction entirely when it is zero.
  group('the user creation date the API sends', () {
    final instant = DateTime.utc(2026, 8, 27, 9, 12, 3);

    for (final raw in [
      '2026-08-27 09:12:03 +0000 UTC',
      '2026-08-27 09:12:03.1 +0000 UTC',
      '2026-08-27 09:12:03.123456789 +0000 UTC',
    ]) {
      test('is stored as the instant it names, from "$raw"', () async {
        await repository.save(userCreatedAt(raw));

        final stored = (await db.getCurrentUser())!.createdAt;

        expect(stored.isUtc, false);
        expect(
          stored.difference(instant).inSeconds,
          0,
          reason: 'read as a local wall clock rather than converted',
        );
      });
    }

    // Reading the user back hands the date out as a zone-less local string,
    // which is what save() gets again on the next write. It has to survive that
    // without the missing marker shifting it.
    test('survives a save of the user read back off the device', () async {
      await repository.save(userCreatedAt('2026-08-27 09:12:03 +0000 UTC'));
      await repository.save((await repository.currentUser())!);

      final stored = (await db.getCurrentUser())!.createdAt;

      expect(stored.difference(instant).inSeconds, 0);
    });
  });
}
