/// This file holds the built-ins assessment and trainings.
/// The ids must be manually inscreased. To avoid collision with normal trainings/reps, they are shifted by 32 bits.
library;

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:collection/collection.dart';
import 'package:crimpy/models/common.dart';
import 'package:flutter/material.dart';

/// Builtin Assessment Model - similar to BuiltinTrainingModel
/// Dynamically generates assessment trainings at runtime without DB storage
class BuiltinAssessmentModel {
  final int id;
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
      trainingId: id,
      training: trainingGenerator(gripPosition: gripPosition),
      type: type,
      icon: icon,
      description: description,
    );
  }
}

// Stores the built-ins assessment definitions (dynamically generated, not stored in DB)
final List<BuiltinAssessmentModel> builtinAssessments = [
  BuiltinAssessmentModel(
    id: 1 << 32,
    name: "Max Force",
    description: "Measure your Maximum Voluntary Contraction (MVC)",
    type: AssessmentType.mvc,
    icon: FontAwesomeIcons.boltLightning,
    trainingGenerator: ({GripPosition? gripPosition}) {
      final grip = gripPosition ?? GripPosition.halfCrimp;
      return TrainingWithReps(
        id: 1 << 32,
        name: "Max Force",
        isFav: false,
        reps: [
          RepModel(
            id: 1 << 32,
            durationInSeconds: 10,
            isRest: true,
            handSide: HandSide.left,
            targetWeight: 0,
            index: 0,
            gripPosition: grip,
          ),
          RepModel(
            id: 2 << 32,
            durationInSeconds: 5,
            isRest: false,
            handSide: HandSide.right,
            targetWeight: 0,
            index: 1,
            gripPosition: grip,
          ),
          RepModel(
            id: 3 << 32,
            durationInSeconds: 10,
            isRest: true,
            handSide: HandSide.left,
            targetWeight: 0,
            index: 2,
            gripPosition: grip,
          ),
          RepModel(
            id: 4 << 32,
            durationInSeconds: 5,
            isRest: false,
            handSide: HandSide.left,
            targetWeight: 0,
            index: 3,
            gripPosition: grip,
          ),
        ],
      );
    },
  ),
  BuiltinAssessmentModel(
    id: 3 << 32,
    name: "Critical Force",
    description: "Measure your Critical Force",
    type: AssessmentType.criticalForce,
    icon: FontAwesomeIcons.clock,
    trainingGenerator:
        ({GripPosition? gripPosition}) => TrainingWithReps(
          id: 3 << 32,
          name: "Critical Force",
          isFav: false,
          reps: [
            RepModel(
              durationInSeconds: 10,
              isRest: true,
              handSide: HandSide.right,
              targetWeight: 0,
              index: 0,
              id: 9 << 32,
            ),
            ...RepeaterModel(
              repsBySet: 24,
              restBteweenSets: 0,
              sets: 1,
              restTime: 3,
              splitHand: false,
              workTime: 7,
            ).generateReps().mapIndexed(
              (index, rep) => RepModel(
                durationInSeconds: rep.duration,
                isRest: rep.isRest,
                handSide: rep.handSide,
                targetWeight: rep.targetWeight,
                index: index + 1,
                id: (index + 10) << 32,
              ),
            ),
          ],
        ),
  ),
  BuiltinAssessmentModel(
    id: 4 << 32,
    name: "60% Endurance",
    description: "Measure how long you can maintain 60% of your MVC",
    type: AssessmentType.endurance60,
    icon: FontAwesomeIcons.hourglass,
    trainingGenerator:
        ({GripPosition? gripPosition}) => TrainingWithReps(
          id: 4 << 32,
          name: "60% Endurance",
          isFav: false,
          reps: [],
        ),
  ),
];

/// Built-in trainings that require assessment values to be available.
final List<BuiltinTrainingModel> builtinTrainings = [
  BuiltinTrainingModel(
    id: 1000,
    name: "Power Endurance",
    description: "3 sets of 10 7/3 repeaters at 65% of max force.",
    requiredAssessments: [
      AssessmentType.mvc,
    ], // Requires MVC for max force calculation
    isAvailable: (assessmentValues) {
      // Check if we have both right and left hand MVC values
      final mvcRight = assessmentValues.lastWhereOrNull(
        (assessment) =>
            assessment.type == AssessmentType.mvc &&
            assessment.rightValue != null,
      );
      final mvcLeft = assessmentValues.lastWhereOrNull(
        (assessment) =>
            assessment.type == AssessmentType.mvc &&
            assessment.leftValue != null,
      );
      return mvcRight != null &&
          mvcLeft != null &&
          mvcLeft.leftValue! > 0 &&
          mvcRight.rightValue! > 0;
    },
    trainingGenerator: (
      assessmentValues, {
      double? customLoadRight,
      double? customLoadLeft,
    }) {
      final maxForceRight =
          assessmentValues
              .lastWhereOrNull(
                (assessment) =>
                    assessment.type == AssessmentType.mvc &&
                    assessment.rightValue != null,
              )
              ?.rightValue ??
          0.0;
      final maxForceLeft =
          assessmentValues
              .lastWhereOrNull(
                (assessment) =>
                    assessment.type == AssessmentType.mvc &&
                    assessment.leftValue != null,
              )
              ?.leftValue ??
          0.0;
      final targetWeightRight =
          customLoadRight ??
          (maxForceRight * 0.65); // Use custom load or 65% of max force
      final targetWeightLeft =
          customLoadLeft ??
          (maxForceLeft * 0.65); // Use custom load or 65% of max force

      return RepeaterModel(
        sets: 3,
        restBteweenSets: 8 * 60, // 8 minutes in seconds
        repsBySet: 10,
        workTime: 7,
        restTime: 3,
        splitHand: true,
        weightRight: targetWeightRight,
        weightLeft: targetWeightLeft,
      );
    },
    computeNewWeights: ({difficulty, failureRate}) {
      if (difficulty != null) {
        switch (difficulty) {
          case TrainingDifficulty.veryEasy:
            return 0.1;
          case TrainingDifficulty.easy:
            return 0.05;
          case TrainingDifficulty.moderate:
            return 0.02;
          case TrainingDifficulty.hard:
            return 0;
          case TrainingDifficulty.veryHard:
            return -.02;
        }
      } else if (failureRate != null) {
        if (failureRate >= 0.75) {
          return -.2;
        } else if (failureRate >= 50) {
          return -.15;
        } else if (failureRate >= 25) {
          return -.1;
        } else {
          return -.05;
        }
      }
      throw Exception("One of difficulty, failureRate should be non-null");
    },
  ),
  BuiltinTrainingModel(
    id: 1001,
    name: "Max Force",
    description: "Max force training at 85% of max force.",
    requiredAssessments: [
      AssessmentType.mvc,
    ], // Requires MVC for max force calculation
    isAvailable: (assessmentValues) {
      // Check if we have both right and left hand MVC values
      final mvcRight = assessmentValues.lastWhereOrNull(
        (assessment) =>
            assessment.type == AssessmentType.mvc &&
            assessment.rightValue != null,
      );
      final mvcLeft = assessmentValues.lastWhereOrNull(
        (assessment) =>
            assessment.type == AssessmentType.mvc &&
            assessment.leftValue != null,
      );
      return mvcRight != null &&
          mvcLeft != null &&
          mvcLeft.leftValue! > 0 &&
          mvcRight.rightValue! > 0;
    },
    trainingGenerator: (
      assessmentValues, {
      double? customLoadRight,
      double? customLoadLeft,
    }) {
      final maxForceRight =
          assessmentValues
              .lastWhereOrNull(
                (assessment) =>
                    assessment.type == AssessmentType.mvc &&
                    assessment.rightValue != null,
              )
              ?.rightValue ??
          0.0;
      final maxForceLeft =
          assessmentValues
              .lastWhereOrNull(
                (assessment) =>
                    assessment.type == AssessmentType.mvc &&
                    assessment.leftValue != null,
              )
              ?.leftValue ??
          0.0;
      final targetWeightRight =
          customLoadRight ??
          (maxForceRight * 0.85); // Use custom load or 85% of max force
      final targetWeightLeft =
          customLoadLeft ??
          (maxForceLeft * 0.85); // Use custom load or 85% of max force

      return RepeaterModel(
        sets: 3,
        restBteweenSets: 4 * 60, // 8 minutes in seconds
        repsBySet: 3,
        workTime: 7,
        restTime: 15,
        splitHand: true,
        weightRight: targetWeightRight,
        weightLeft: targetWeightLeft,
      );
    },
    computeNewWeights: ({difficulty, failureRate}) {
      if (difficulty != null) {
        switch (difficulty) {
          case TrainingDifficulty.veryEasy:
            return 0.1;
          case TrainingDifficulty.easy:
            return 0.07;
          case TrainingDifficulty.moderate:
            return 0.05;
          case TrainingDifficulty.hard:
            return 0.02;
          case TrainingDifficulty.veryHard:
            return 0;
        }
      } else if (failureRate != null) {
        if (failureRate >= 0.75) {
          return -.2;
        } else if (failureRate >= 50) {
          return -.15;
        } else if (failureRate >= 25) {
          return -.1;
        } else {
          return -.05;
        }
      }
      throw Exception("One of difficulty, failureRate should be non-null");
    },
  ),
  // For debug purposes
  // BuiltinTrainingModel(
  //   id: 1002,
  //   name: "Test",
  //   description: "Test training.",
  //   requiredAssessments: [
  //     AssessmentType.mvc,
  //     AssessmentType.criticalForce,
  //   ], // Requires MVC for max force calculation
  //   isAvailable: (assessmentValues) {
  //     // Check if we have both right and left hand MVC values
  //     final mvcRight = assessmentValues.lastWhereOrNull(
  //       (assessment) =>
  //           assessment.type == AssessmentType.mvc &&
  //           assessment.rightValue != null,
  //     );
  //     final mvcLeft = assessmentValues.lastWhereOrNull(
  //       (assessment) =>
  //           assessment.type == AssessmentType.mvc &&
  //           assessment.leftValue != null,
  //     );
  //     return mvcRight != null &&
  //         mvcLeft != null &&
  //         mvcLeft.leftValue! > 0 &&
  //         mvcRight.rightValue! > 0;
  //   },
  //   trainingGenerator: (
  //     assessmentValues, {
  //     double? customLoadRight,
  //     double? customLoadLeft,
  //   }) {
  //     final maxForceRight =
  //         assessmentValues
  //             .lastWhereOrNull(
  //               (assessment) =>
  //                   assessment.type == AssessmentType.mvc &&
  //                   assessment.rightValue != null,
  //             )
  //             ?.rightValue ??
  //         0.0;
  //     final maxForceLeft =
  //         assessmentValues
  //             .lastWhereOrNull(
  //               (assessment) =>
  //                   assessment.type == AssessmentType.mvc &&
  //                   assessment.leftValue != null,
  //             )
  //             ?.leftValue ??
  //         0.0;
  //     final targetWeightRight =
  //         customLoadRight ??
  //         (maxForceRight * 0.85); // Use custom load or 85% of max force
  //     final targetWeightLeft =
  //         customLoadLeft ??
  //         (maxForceLeft * 0.85); // Use custom load or 85% of max force

  //     return RepeaterModel(
  //       sets: 1,
  //       restBteweenSets: 10,
  //       repsBySet: 2,
  //       workTime: 3,
  //       restTime: 3,
  //       splitHand: true,
  //       weightRight: targetWeightRight,
  //       weightLeft: targetWeightLeft,
  //     );
  //   },
  //   computeNewWeights: ({difficulty, failureRate}) {
  //     if (difficulty != null) {
  //       switch (difficulty) {
  //         case TrainingDifficulty.veryEasy:
  //           return 0.1;
  //         case TrainingDifficulty.easy:
  //           return 0.05;
  //         case TrainingDifficulty.moderate:
  //           return 0.02;
  //         case TrainingDifficulty.hard:
  //           return 0;
  //         case TrainingDifficulty.veryHard:
  //           return -.02;
  //       }
  //     } else if (failureRate != null) {
  //       if (failureRate >= 75) {
  //         return -.3;
  //       } else if (failureRate >= 50) {
  //         return -.2;
  //       } else if (failureRate >= 25) {
  //         return -.1;
  //       } else {
  //         return -.05;
  //       }
  //     }
  //     throw Exception("One of difficulty, failureRate should be non-null");
  //   },
  // ),
];
