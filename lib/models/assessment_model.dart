import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/workout_protocol.dart';

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
  final GripPosition? gripPosition;

  AssessmentTrainingModel({
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
    return training.reps.whereType<TimedItem>().firstOrNull?.gripPosition;
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

/// The athlete latest result per assessment, used to turn the loads, durations
/// and reps a coach expressed as a percentage of an assessment into numbers.
class AssessmentResults {
  final Map<AssessmentType, AssessmentModel> lastByType;

  const AssessmentResults(this.lastByType);

  /// No assessment data at all, so every assessment-relative value resolves to
  /// the fallback the coach set.
  static const AssessmentResults none = AssessmentResults({});

  /// Builds the latest result per type out of a chronological list.
  factory AssessmentResults.fromHistory(List<AssessmentModel> assessments) {
    final last = <AssessmentType, AssessmentModel>{};
    for (final assessment in assessments) {
      final known = last[assessment.type];
      if (known == null || !assessment.date.isBefore(known.date)) {
        last[assessment.type] = assessment;
      }
    }
    return AssessmentResults(last);
  }

  /// The last result for [type]: the value for [handSide] when the assessment
  /// measured it, the mean of both hands otherwise. Null when the athlete has
  /// never done that assessment.
  double? value(AssessmentType type, {HandSide? handSide}) {
    final last = lastByType[type];
    if (last == null) return null;
    final sided = switch (handSide) {
      HandSide.right => last.rightValue,
      HandSide.left => last.leftValue,
      _ => null,
    };
    if (sided != null) return sided;
    final values = [
      last.rightValue,
      last.leftValue,
    ].whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

class AssessmentModel {
  final AssessmentType type;
  final String id;
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

/// Output of the Critical Force analysis over a recorded session.
class CriticalForceResults {
  final List<double> tmeans;
  final List<double> fmeans;
  final List<double> eFmeans;
  final double criticalLoad;
  final double loadAsymptote;
  final List<double> predictedForce;

  CriticalForceResults({
    required this.tmeans,
    required this.fmeans,
    required this.eFmeans,
    required this.criticalLoad,
    required this.loadAsymptote,
    required this.predictedForce,
  });
}

/// Builtin Assessment Model - similar to BuiltinTrainingModel
/// Dynamically generates assessment trainings at runtime without DB storage
class BuiltinAssessmentModel {
  final String id;
  final String name;
  final String description;
  final AssessmentType type;
  final IconData icon;
  final TrainingWithReps Function({GripPosition? gripPosition})
  trainingGenerator;

  BuiltinAssessmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.trainingGenerator,
  });

  /// Generate an AssessmentTrainingModel with training data
  AssessmentTrainingModel generateAssessment({GripPosition? gripPosition}) {
    return AssessmentTrainingModel(
      training: trainingGenerator(gripPosition: gripPosition),
      type: type,
      icon: icon,
      description: description,
      gripPosition: gripPosition,
    );
  }
}

/// Represents a required assessment with optional grip position.
class AssessmentRequirement {
  final AssessmentType type;
  final GripPosition? gripPosition;

  const AssessmentRequirement({required this.type, this.gripPosition});

  @override
  bool operator ==(Object other) {
    return other is AssessmentRequirement &&
        other.type == type &&
        other.gripPosition == gripPosition;
  }

  @override
  int get hashCode => Object.hash(type, gripPosition);
}
