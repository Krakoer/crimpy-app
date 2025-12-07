import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/training_model.dart';

enum AssessmentType { criticalForce, mvc, endurance60 }

enum AssessmentUnit { kilograms, seconds }

String assessmentTypeToString(AssessmentType type) {
  return switch (type) {
    AssessmentType.mvc => "Max Force",
    AssessmentType.criticalForce => "Critical Force",
    AssessmentType.endurance60 => "60% Endurance",
  };
}

AssessmentUnit getAssessmentUnit(AssessmentType type) {
  return switch (type) {
    AssessmentType.mvc => AssessmentUnit.kilograms,
    AssessmentType.criticalForce => AssessmentUnit.kilograms,
    AssessmentType.endurance60 => AssessmentUnit.seconds,
  };
}

String formatAssessmentValue(
  double value,
  AssessmentUnit unit, {
  bool showUnit = true,
}) {
  return switch (unit) {
    AssessmentUnit.kilograms =>
      showUnit ? "${value.toStringAsFixed(1)} kg" : value.toStringAsFixed(1),
    AssessmentUnit.seconds =>
      showUnit ? "${value.toStringAsFixed(0)}s" : value.toStringAsFixed(0),
  };
}

class AssessmentTrainingModel {
  final TrainingWithReps training;
  final AssessmentType type;
  final IconData icon;
  final String description;
  final int trainingId;
  final GripPosition? gripPosition;

  AssessmentTrainingModel({
    required this.trainingId,
    required this.training,
    required this.type,
    required this.icon,
    required this.description,
    this.gripPosition,
  });

  /// Get the grip position for this assessment.
  /// Returns the explicitly set gripPosition, or tries to get it from the first non-rest rep.
  GripPosition? getGripPosition() {
    if (gripPosition != null) {
      return gripPosition;
    }
    try {
      return training.reps.firstWhere((r) => !r.isRest).gripPosition;
    } catch (_) {
      return null;
    }
  }
}

class AssessmentResultModel {
  final AssessmentType type;
  final double? rightValue;
  final double? leftValue;
  final GripPosition? gripPosition;

  AssessmentResultModel({
    required this.type,
    this.rightValue,
    this.leftValue,
    this.gripPosition,
  });

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

  /// Helper method to get value for a specific hand.
  double? getValue(bool isRight) {
    return isRight ? rightValue : leftValue;
  }
}

class AssessmentModel {
  final AssessmentType type;
  final int id;
  final DateTime date;
  final double? rightValue;
  final double? leftValue;
  final GripPosition? gripPosition;

  AssessmentModel({
    required this.type,
    required this.id,
    required this.date,
    this.rightValue,
    this.leftValue,
    this.gripPosition,
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
