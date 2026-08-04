import 'package:crimpy/database/database.dart';
import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:drift/drift.dart' as drift;

/// Stores the signed-in user on the device.
///
/// Keeps drift companions and row types out of the auth viewmodel, which only
/// needs to know that a user is saved, read back, or cleared.
class UserRepository {
  final AppDatabase _database;

  UserRepository({AppDatabase? database}) : _database = database ?? gDatabase;

  /// The user recorded on this device, or null in guest mode.
  Future<auth_models.User?> currentUser() async {
    final row = await _database.getCurrentUser();
    if (row == null) return null;
    return auth_models.User(
      id: row.id,
      email: row.email,
      firstname: row.firstname,
      lastname: row.lastname,
      emailVerified: row.emailVerified,
      isAdmin: row.isAdmin,
      isCoach: row.isCoach,
      coachValidated: row.coachValidated,
      createdAt: row.createdAt.toIso8601String(),
    );
  }

  Future<void> save(auth_models.User user) => _database.saveCurrentUser(
    UsersCompanion.insert(
      id: user.id,
      email: user.email,
      firstname: user.firstname,
      lastname: user.lastname,
      emailVerified: drift.Value(user.emailVerified),
      isAdmin: drift.Value(user.isAdmin),
      isCoach: drift.Value(user.isCoach),
      coachValidated: drift.Value(user.coachValidated),
      // DateTime are in format "2006-01-02 15:04:05.999999999 +0000 UTC"
      createdAt: drift.Value(
        DateTime.parse(user.createdAt.replaceAll(" +0000 UTC", "")),
      ),
    ),
  );

  /// Flags the stored user as having confirmed their address. Does nothing when
  /// there is no user on the device.
  Future<void> markEmailVerified() async {
    final row = await _database.getCurrentUser();
    if (row == null) return;
    await _database.saveCurrentUser(
      UsersCompanion(
        id: drift.Value(row.id),
        emailVerified: const drift.Value(true),
      ),
    );
  }

  /// Clears the user and everything recorded against them on this device.
  Future<void> clear() async {
    await _database.wipeLocalData();
    await _database.deleteCurrentUser();
  }
}
