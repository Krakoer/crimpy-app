/// Represents how a user felt after completing a builtin training.
enum TrainingDifficulty { veryEasy, easy, moderate, hard, veryHard }

/// Represents whether a user succeeded or failed a builtin training.
enum TrainingResult { success, failure }

typedef LoadAdjustmentFunction =
    double Function({TrainingDifficulty? difficulty, double? failureRate});

/// Feedback from a completed builtin training session.
class TrainingFeedbackModel {
  final int trainingId;
  final DateTime completionDate;
  final TrainingResult result;
  final TrainingDifficulty? difficulty; // Only asked if successful
  final String? notes;
  final double usedWeight; // The weight that was actually used

  TrainingFeedbackModel({
    required this.trainingId,
    required this.completionDate,
    required this.result,
    this.difficulty,
    this.notes,
    required this.usedWeight,
  });
}

/// Suggests load adjustments based on performance.
class LoadAdjustmentService {
  /// Calculate the next recommended load based on feedback.
  static double calculateNextLoad(
    double currentLoad,
    TrainingResult result,
    TrainingDifficulty? difficulty,
  ) {
    if (result == TrainingResult.failure) {
      // Reduce load by 10% if failed
      return currentLoad * 0.9;
    }

    // Adjust based on difficulty for successful trainings
    return switch (difficulty) {
      TrainingDifficulty.veryEasy => currentLoad * 1.1, // Increase 10%
      TrainingDifficulty.easy => currentLoad * 1.05, // Increase 5%
      TrainingDifficulty.moderate => currentLoad, // Keep same
      TrainingDifficulty.hard => currentLoad * 0.95, // Decrease 5%
      TrainingDifficulty.veryHard => currentLoad * 0.9, // Decrease 10%
      null => currentLoad, // Keep same if no difficulty provided
    };
  }

  /// Get user-friendly difficulty descriptions.
  static String getDifficultyDescription(TrainingDifficulty difficulty) {
    return switch (difficulty) {
      TrainingDifficulty.veryEasy => "Very Easy - I could do much more",
      TrainingDifficulty.easy => "Easy - I could do a bit more",
      TrainingDifficulty.moderate => "Just Right - Perfect difficulty",
      TrainingDifficulty.hard => "Hard - I struggled a bit",
      TrainingDifficulty.veryHard => "Very Hard - I barely completed it",
    };
  }

  /// Get load adjustment recommendation text.
  static String getAdjustmentRecommendation(
    double currentLoad,
    double recommendedLoad,
  ) {
    final percentage =
        ((recommendedLoad - currentLoad) / currentLoad * 100).round();

    if (percentage > 0) {
      return "We recommend increasing your load by $percentage% to ${recommendedLoad.toStringAsFixed(1)} kg.";
    } else if (percentage < 0) {
      return "We recommend decreasing your load by ${percentage.abs()}% to ${recommendedLoad.toStringAsFixed(1)} kg.";
    } else {
      return "Your current load seems perfect! Keep using ${currentLoad.toStringAsFixed(1)} kg.";
    }
  }
}
