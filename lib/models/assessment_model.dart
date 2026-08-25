import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/workout_protocol.dart';

/// Which sensor protocol the app runs for one of the assessments Crimpy ships.
/// This is no longer what identifies an assessment: a result and a percentage
/// both name a row in assessment_definitions by id, and the ones Crimpy ships
/// are rows like a coach's own. It only says which screen knows how to measure
/// them.
enum AssessmentType { criticalForce, mvc, endurance60 }

/// The ids of the assessments Crimpy ships, seeded server side. They are fixed,
/// so the app can map one to the protocol that measures it.
class BuiltinAssessmentIds {
  static const String criticalForce = '55970ac0-4544-4945-80cd-4841f7c58fe5';
  static const String maxForce = 'f7954158-63ba-4f0b-a125-6ef195fa6442';
  static const String endurance60 = '493acbdd-6fe7-4f25-987c-575ccf433293';

  static const Map<String, AssessmentType> protocols = {
    criticalForce: AssessmentType.criticalForce,
    maxForce: AssessmentType.mvc,
    endurance60: AssessmentType.endurance60,
  };

  static String idOf(AssessmentType type) => switch (type) {
    AssessmentType.criticalForce => criticalForce,
    AssessmentType.mvc => maxForce,
    AssessmentType.endurance60 => endurance60,
  };

  /// Null for a coach's assessment, which is run as a training rather than by a
  /// protocol the app implements.
  static AssessmentType? protocolOf(String assessmentId) =>
      protocols[assessmentId];

  /// The assessments Crimpy ships, as they read without the server. The
  /// protocol screens name and format their results from these, and the local
  /// database is seeded with the same rows.
  static AssessmentDefinition definitionOf(AssessmentType type) =>
      switch (type) {
        AssessmentType.criticalForce => const AssessmentDefinition(
          id: criticalForce,
          label: 'Critical Force',
          unit: AssessmentUnit.kilograms,
          perHand: true,
        ),
        AssessmentType.mvc => const AssessmentDefinition(
          id: maxForce,
          label: 'Max Force',
          unit: AssessmentUnit.kilograms,
          perHand: true,
        ),
        AssessmentType.endurance60 => const AssessmentDefinition(
          id: endurance60,
          label: '60% Endurance',
          unit: AssessmentUnit.seconds,
          perHand: true,
        ),
      };
}

enum AssessmentUnit { kilograms, seconds, repetitions }

/// The wire name of a unit, which is what assessment_definitions.unit holds.
AssessmentUnit assessmentUnitFromApi(String? value) => switch (value) {
  'seconds' => AssessmentUnit.seconds,
  'repetitions' => AssessmentUnit.repetitions,
  _ => AssessmentUnit.kilograms,
};

String assessmentUnitToApi(AssessmentUnit unit) => switch (unit) {
  AssessmentUnit.kilograms => 'kilograms',
  AssessmentUnit.seconds => 'seconds',
  AssessmentUnit.repetitions => 'repetitions',
};

/// An assessment that can be measured: one Crimpy ships, or one a coach wrote.
/// A coach's carries the training it is run from and the question it ends on.
class AssessmentDefinition {
  final String id;
  final String label;
  final AssessmentUnit unit;
  final bool perHand;
  final String? prompt;
  final String? trainingId;

  const AssessmentDefinition({
    required this.id,
    required this.label,
    required this.unit,
    this.perHand = false,
    this.prompt,
    this.trainingId,
  });

  bool get isBuiltin => trainingId == null;

  /// The protocol that measures it, null for a coach's assessment.
  AssessmentType? get protocol => BuiltinAssessmentIds.protocolOf(id);

  factory AssessmentDefinition.fromJson(Map<String, dynamic> json) {
    return AssessmentDefinition(
      id: json['id'] as String,
      label: (json['label'] as String?) ?? 'Assessment',
      unit: assessmentUnitFromApi(json['unit'] as String?),
      perHand: (json['per_hand'] as bool?) ?? false,
      prompt: json['prompt'] as String?,
      trainingId: json['training_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'unit': assessmentUnitToApi(unit),
    'per_hand': perHand,
    if (prompt != null) 'prompt': prompt,
    if (trainingId != null) 'training_id': trainingId,
  };
}

/// Names an assessment without a catalog to hand. Only the ones Crimpy ships
/// are known this way: a coach assessment is always read from its definition.
String builtinAssessmentLabel(String assessmentId) {
  final protocol = BuiltinAssessmentIds.protocolOf(assessmentId);
  return protocol == null
      ? 'assessment'
      : BuiltinAssessmentIds.definitionOf(protocol).label;
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
  final String assessmentId;
  final double? rightValue;
  final double? leftValue;
  final GripPosition? gripPosition;

  AssessmentResultModel({
    required this.assessmentId,
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
  final Map<String, AssessmentHandValues> lastById;

  /// What each assessment is, so a percentage can be unit checked and named
  /// without a lookup table the app would have to keep in step with the server.
  final Map<String, AssessmentDefinition> definitions;

  const AssessmentResults(this.lastById, {this.definitions = const {}});

  /// No assessment data at all, so every assessment-relative value resolves to
  /// the fallback the coach set.
  static const AssessmentResults none = AssessmentResults({});

  /// Builds the latest value per assessment and per hand. Each hand keeps its
  /// own last measurement, so a newer run carrying only the other hand does not
  /// discard it.
  factory AssessmentResults.fromHistory(
    List<AssessmentModel> assessments, {
    List<AssessmentDefinition> definitions = const [],
  }) {
    final chronological = [...assessments]
      ..sort((a, b) => a.date.compareTo(b.date));
    final last = <String, AssessmentHandValues>{};
    final known = <String, AssessmentDefinition>{
      for (final definition in definitions) definition.id: definition,
    };
    for (final assessment in chronological) {
      final measured =
          last[assessment.assessmentId] ?? const AssessmentHandValues();
      last[assessment.assessmentId] = measured.withMeasured(
        right: assessment.rightValue,
        left: assessment.leftValue,
      );
      // A result carries its own definition, so the history alone is enough to
      // name and format every assessment it mentions.
      known.putIfAbsent(assessment.assessmentId, () => assessment.definition);
    }
    return AssessmentResults(last, definitions: known);
  }

  AssessmentDefinition? definitionOf(String assessmentId) =>
      definitions[assessmentId];

  /// What the assessment is measured in, null when the app has never heard of
  /// it, which makes a percentage of it fall back rather than guess a unit.
  AssessmentUnit? unitOf(String assessmentId) =>
      definitions[assessmentId]?.unit;

  /// The assessment's name. Falls back to the one Crimpy ships under that id,
  /// so a load reads "80% Max Force" rather than "80% assessment" on the first
  /// frame, or if the definitions could not be fetched at all.
  String labelOf(String assessmentId) =>
      definitions[assessmentId]?.label ?? builtinAssessmentLabel(assessmentId);

  /// The last value measured for [assessmentId] on [handSide], or the mean of
  /// both hands when no hand is asked for. Null when that hand has never been
  /// measured, so the coach fallback applies rather than the other hand number.
  ///
  /// An assessment that is not measured per hand stores its single number on the
  /// right, so asking for no hand averages one value and returns it unchanged.
  double? value(String assessmentId, {HandSide? handSide}) {
    final last = lastById[assessmentId];
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
  final String id;
  final DateTime date;

  /// The assessment measured, with what it is, so a row can be named and
  /// formatted on its own.
  final AssessmentDefinition definition;
  final double? rightValue;
  final double? leftValue;
  final GripPosition? gripPosition;

  AssessmentModel({
    required this.id,
    required this.date,
    required this.definition,
    this.rightValue,
    this.leftValue,
    this.gripPosition,
  });

  String get assessmentId => definition.id;

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

/// An assessment a builtin training needs a result for, with the grip it has to
/// have been measured on when that matters.
class AssessmentRequirement {
  final String assessmentId;
  final GripPosition? gripPosition;

  const AssessmentRequirement({required this.assessmentId, this.gripPosition});

  @override
  bool operator ==(Object other) {
    return other is AssessmentRequirement &&
        other.assessmentId == assessmentId &&
        other.gripPosition == gripPosition;
  }

  @override
  int get hashCode => Object.hash(assessmentId, gripPosition);
}
