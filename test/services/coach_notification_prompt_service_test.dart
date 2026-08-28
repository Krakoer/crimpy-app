import 'package:crimpy/services/coach_notification_prompt_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CoachNotificationPromptService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = CoachNotificationPromptService();
  });

  test('an ask that never happened has not been asked', () async {
    expect(await service.hasAsked(CoachNotificationPrompt.enrolled), isFalse);
    expect(
      await service.hasAsked(CoachNotificationPrompt.unreadReply),
      isFalse,
    );
  });

  test('recording one ask leaves the other still due', () async {
    await service.markAsked(CoachNotificationPrompt.enrolled);

    expect(await service.hasAsked(CoachNotificationPrompt.enrolled), isTrue);
    expect(
      await service.hasAsked(CoachNotificationPrompt.unreadReply),
      isFalse,
    );
  });

  test('clearing forgets every ask', () async {
    await service.markAsked(CoachNotificationPrompt.enrolled);
    await service.markAsked(CoachNotificationPrompt.unreadReply);

    await service.clear();

    expect(await service.hasAsked(CoachNotificationPrompt.enrolled), isFalse);
    expect(
      await service.hasAsked(CoachNotificationPrompt.unreadReply),
      isFalse,
    );
  });
}
