import 'package:crimpy/services/coach_notification_prompt_service.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Explains what notifying an athlete about their coach's answers is for,
/// before the OS permission sheet asks the question with no context at all.
///
/// Pops true when the athlete wants them, false when they do not.
class CoachNotificationDialog extends StatelessWidget {
  final CoachNotificationPrompt prompt;

  /// The coach as the athlete knows them, used so the ask names who is writing.
  final String coachName;

  const CoachNotificationDialog({
    super.key,
    required this.prompt,
    required this.coachName,
  });

  String get _explanation => switch (prompt) {
    CoachNotificationPrompt.enrolled =>
      '$coachName can answer the feedback you leave on a session. '
          'Allow notifications and Crimpy will tell you when they do.',
    CoachNotificationPrompt.unreadReply =>
      '$coachName answered the feedback you left on a session. '
          'Allow notifications and Crimpy will tell you about the next one '
          'without you having to come looking.',
  };

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      children: [
        const Icon(
          Icons.mark_chat_unread_outlined,
          color: CrimpyTheme.primaryOrange,
        ),
        const SizedBox(width: 8),
        const Expanded(child: Text('Answers from your coach')),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_explanation, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
        const Text(
          'This is separate from the training reminders, which stay off '
          'until you turn them on.',
          style: TextStyle(fontSize: 12, color: CrimpyTheme.textSecondary),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Not now'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Allow'),
      ),
    ],
  );
}
