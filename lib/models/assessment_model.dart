import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/workout_protocol.dart';

enum AssessmentType { criticalForce, mvc, endurance60 }

enum AssessmentUnit { kilograms, seconds, repetitions }

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
    AssessmentUnit.repetitions =>
      showUnit ? "${value.toStringAsFixed(0)} reps" : value.toStringAsFixed(0),
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
/// The athlete latest measurement of one assessment, held per hand because a
/// run records a single hand: testing the left in January and the right in
/// February leaves the two on separate rows.
class AssessmentHandValues {
  final double? right;
  final double? left;

  const AssessmentHandValues({this.right, this.left});

  AssessmentHandValues withMeasured({double? right, double? left}) =>
      AssessmentHandValues(right: right ?? this.right, left: left ?? this.left);
}

class AssessmentResults {
  final Map<AssessmentType, AssessmentHandValues> lastByType;

  const AssessmentResults(this.lastByType);

  /// No assessment data at all, so every assessment-relative value resolves to
  /// the fallback the coach set.
  static const AssessmentResults none = AssessmentResults({});

  /// Builds the latest value per assessment and per hand. Each hand keeps its
  /// own last measurement, so a newer run carrying only the other hand does not
  /// discard it.
  factory AssessmentResults.fromHistory(List<AssessmentModel> assessments) {
    final chronological = [...assessments]
      ..sort((a, b) => a.date.compareTo(b.date));
    final last = <AssessmentType, AssessmentHandValues>{};
    for (final assessment in chronological) {
      final known = last[assessment.type] ?? const AssessmentHandValues();
      last[assessment.type] = known.withMeasured(
        right: assessment.rightValue,
        left: assessment.leftValue,
      );
    }
    return AssessmentResults(last);
  }

  /// The last value measured for [type] on [handSide], or the mean of both
  /// hands when no hand is asked for. Null when that hand has never been
  /// measured, so the coach fallback applies rather than the other hand number.
  double? value(AssessmentType type, {HandSide? handSide}) {
    final last = lastByType[type];
    if (last == null) return null;
    switch (handSide) {
      case HandSide.right:
        return last.right;
      case HandSide.left:
        return last.left;
      default:
        final values = [last.right, last.left].whereType<double>().toList();
        if (values.isEmpty) return null;
        return values.reduce((a, b) => a + b) / values.length;
    }
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
