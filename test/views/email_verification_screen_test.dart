import 'package:crimpy/models/auth_models.dart' as auth_models;
import 'package:crimpy/viewmodels/auth_view_model.dart';
import 'package:crimpy/views/screens/auth/email_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class ResendingAuth extends AuthState {
  final List<String> resent = [];

  @override
  Future<auth_models.User?> build() async => null;

  @override
  Future<void> resendVerificationEmail(String email) async => resent.add(email);
}

void main() {
  testWidgets('does not claim a link went out, since the API never says', (
    tester,
  ) async {
    final auth = ResendingAuth();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authStateProvider.overrideWith(() => auth)],
        child: const MaterialApp(
          home: EmailVerificationScreen(email: 'climber@example.com'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Resend'));
    await tester.tap(find.text('Resend'));
    await tester.pumpAndSettle();

    expect(auth.resent, ['climber@example.com']);
    expect(
      find.textContaining('If your email still needs verifying'),
      findsOneWidget,
    );
  });
}
