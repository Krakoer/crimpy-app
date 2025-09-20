import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/training_model.dart';

enum AssessmentType { criticalForce, mvc, mvc3fd }

String assessmentTypeToString(AssessmentType type) {
  return switch (type) {
    AssessmentType.mvc => "Max Force - Half Crimp",
    AssessmentType.mvc3fd => "Max Force - 3FD",
    AssessmentType.criticalForce => "Critical Force",
  };
}

class AssessmentTrainingModel {
  final TrainingWithReps training;
  final AssessmentType type;
  final IconData icon;
  final String description;
  final int trainingId;

  AssessmentTrainingModel({
    required this.trainingId,
    required this.training,
    required this.type,
    required this.icon,
    required this.description,
  });
}

class AssessmentResultModel {
  final AssessmentType type;
  final double? rightValue;
  final double? leftValue;

  AssessmentResultModel({required this.type, this.rightValue, this.leftValue});

  /// Get the hand of the assessment.
  /// `null` means both hands, `true` means right hand and `false` means left hand.
  HandSide? get hand {
    if (leftValue == null) {
      if (rightValue == null) {
        return null;
      }
      return HandSide.right;
    }
    return rightValue == null ? HandSide.left : HandSide.both;
  }
}

class AssessmentModel {
  final AssessmentType type;
  final int id;
  final DateTime date;
  final double? rightValue;
  final double? leftValue;

  AssessmentModel({
    required this.type,
    required this.id,
    required this.date,
    this.rightValue,
    this.leftValue,
  });

  /// Get the hand of the assessment.
  /// `null` means both hands, `true` means right hand and `false` means left hand.
  bool? get hand {
    return leftValue == null
        ? true
        : rightValue == null
        ? false
        : null;
  }
}
