/// typedef LoadAdjustmentFunction =
typedef LoadAdjustmentFunction =
    double Function({TrainingDifficulty? difficulty, double? failureRate});

/// Represents how a user felt after completing a builtin training.
enum TrainingDifficulty {
  veryEasy,
  easy,
  moderate,
  hard,
  veryHard;

  String get description {
    switch (index) {
      case 0:
        return "Very Easy - I could do much more";
      case 1:
        return "Easy - I could do a bit more";
      case 2:
        return "Just Right - Perfect difficulty";
      case 3:
        return "Hard - I struggled a bit";
      case 4:
        return "Very Hard - I barely completed it";
      case _:
        return "";
    }
  }
}
