import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = auth_models.User(
  id: 'user-1',
  email: 'climber@example.com',
  firstname: 'Test',
  lastname: 'Climber',
  emailVerified: true,
  createdAt: '2026-01-01T00:00:00Z',
);

void main() {
  group('reminder settings ownership', () {
    test('a signed in user keeps the stored settings', () {
      expect(isSignedOut(AsyncData(_user)), isFalse);
    });

    test('a resolved absence of user drops them', () {
      expect(isSignedOut(const AsyncData(null)), isTrue);
    });

    test('the settings survive a cold start while auth is still loading', () {
      // The regression this guards: the auth state reads the stored user
      // asynchronously, so every launch starts here. Reading it as a sign out
      // cleared the settings before the user got them back.
      expect(isSignedOut(const AsyncLoading()), isFalse);
    });

    test('an auth failure keeps them rather than dropping them', () {
      expect(
        isSignedOut(AsyncError(Exception('offline'), StackTrace.empty)),
        isFalse,
      );
    });
  });
}
