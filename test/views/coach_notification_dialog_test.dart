import 'package:crimpy/services/coach_notification_prompt_service.dart';
import 'package:crimpy/views/widgets/coach_notification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Collects what the dialog popped, which is only known once it closes.
final answers = <bool?>[];

Future<void> _openDialog(
  WidgetTester tester,
  CoachNotificationPrompt prompt,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async => answers.add(
            await showDialog<bool>(
              context: context,
              builder: (_) => CoachNotificationDialog(
                prompt: prompt,
                coachName: 'Remi Belard',
              ),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(answers.clear);

  testWidgets('the enrolled ask names the coach and what is coming', (
    tester,
  ) async {
    await _openDialog(tester, CoachNotificationPrompt.enrolled);

    expect(
      find.textContaining('Remi Belard can answer the feedback you leave'),
      findsOneWidget,
    );
  });

  testWidgets('the unread answer ask says one has already been written', (
    tester,
  ) async {
    await _openDialog(tester, CoachNotificationPrompt.unreadReply);

    expect(
      find.textContaining('Remi Belard answered the feedback you left'),
      findsOneWidget,
    );
  });

  testWidgets('allowing pops true', (tester) async {
    await _openDialog(tester, CoachNotificationPrompt.enrolled);

    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(answers, [true]);
  });

  testWidgets('declining pops false', (tester) async {
    await _openDialog(tester, CoachNotificationPrompt.enrolled);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(answers, [false]);
  });
}
