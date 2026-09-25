import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/services/api_exception.dart';
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/views/screens/auth/forgot_password_screen.dart';
import 'package:crimpy/views/screens/settings_screen/widgets/reset_password_tile.dart';
import 'package:flutter/material.dart';
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

/// Records the reset requests instead of reaching the API, and fails them when
/// told to.
class RecordingAuth extends AuthState {
  RecordingAuth({this.user, this.failure});

  final auth_models.User? user;
  final Exception? failure;
  final List<String> resetRequests = [];

  @override
  Future<auth_models.User?> build() async => user;

  @override
  Future<void> requestPasswordReset(String email) async {
    resetRequests.add(email);
    if (failure != null) throw failure!;
  }
}

Future<RecordingAuth> _pump(
  WidgetTester tester,
  Widget child, {
  auth_models.User? user,
  Exception? failure,
}) async {
  final auth = RecordingAuth(user: user, failure: failure);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authStateProvider.overrideWith(() => auth)],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  group('forgot password screen', () {
    testWidgets('starts from the email typed on the login screen', (
      tester,
    ) async {
      await _pump(
        tester,
        const ForgotPasswordScreen(initialEmail: 'climber@example.com'),
      );

      expect(find.text('climber@example.com'), findsOneWidget);
    });

    testWidgets('sends the reset request and says where the link went', (
      tester,
    ) async {
      final auth = await _pump(tester, const ForgotPasswordScreen());

      await tester.enterText(
        find.byType(TextFormField),
        ' climber@example.com ',
      );
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(auth.resetRequests, ['climber@example.com']);
      expect(
        find.textContaining('If an account exists for climber@example.com'),
        findsOneWidget,
      );
      expect(find.text('Send reset link'), findsNothing);
    });

    testWidgets('refuses an address with no @ without calling the API', (
      tester,
    ) async {
      final auth = await _pump(tester, const ForgotPasswordScreen());

      await tester.enterText(find.byType(TextFormField), 'climber');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(auth.resetRequests, isEmpty);
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows the failure and keeps the form', (tester) async {
      await _pump(
        tester,
        const ForgotPasswordScreen(),
        failure: ApiException('Failed to send password reset email'),
      );

      await tester.enterText(find.byType(TextFormField), 'climber@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to send password reset email'), findsOneWidget);
      expect(find.text('Send reset link'), findsOneWidget);
    });
  });

  group('reset password setting', () {
    testWidgets('is not offered to a guest', (tester) async {
      await _pump(tester, const ResetPasswordTile());

      expect(find.text('Reset password'), findsNothing);
    });

    testWidgets('emails the signed-in athlete once they confirm', (
      tester,
    ) async {
      final auth = await _pump(tester, const ResetPasswordTile(), user: _user);

      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();
      expect(find.textContaining('climber@example.com'), findsOneWidget);

      await tester.tap(find.text('Send link'));
      await tester.pumpAndSettle();

      expect(auth.resetRequests, ['climber@example.com']);
      expect(
        find.text('Reset link sent to climber@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('sends nothing when the athlete cancels', (tester) async {
      final auth = await _pump(tester, const ResetPasswordTile(), user: _user);

      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(auth.resetRequests, isEmpty);
    });

    testWidgets('says why the request failed', (tester) async {
      await _pump(
        tester,
        const ResetPasswordTile(),
        user: _user,
        failure: ApiException('Failed to send password reset email'),
      );

      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send link'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to send password reset email'), findsOneWidget);
    });
  });
}
