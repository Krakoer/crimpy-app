import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing tutorial state across the app.
/// Uses SharedPreferences to persist which tutorials have been seen.
class TutorialService {
  static const String _prefix = 'tutorial_seen_';

  /// Check if a tutorial has been seen by the user.
  Future<bool> hasSeenTutorial(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$tutorialId') ?? false;
  }

  /// Mark a tutorial as seen.
  Future<void> markTutorialAsSeen(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tutorialId', true);
  }

  /// Reset a specific tutorial (useful for testing or user request).
  Future<void> resetTutorial(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$tutorialId');
  }

  /// Reset all tutorials (useful for debugging or settings).
  Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        await prefs.remove(key);
      }
    }
  }
}

/// Tutorial IDs used throughout the app.
class TutorialIds {
  // MVC Assessments
  static const String mvcThreeFinger = 'tutorial_mvc_3fd';
  static const String mvcOpenHand = 'tutorial_mvc_oh';
  static const String mvcHalfCrimp = 'tutorial_mvc_hc';

  // Critical Force Assessments
  static const String criticalForceThreeFinger = 'tutorial_cf_3fd';
  static const String criticalForceOpenHand = 'tutorial_cf_oh';
  static const String criticalForceHalfCrimp = 'tutorial_cf_hc';

  // Other assessments (60%, etc.)
  static const String assessment60 = 'tutorial_assessment_60';
}
