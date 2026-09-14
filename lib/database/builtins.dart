/// This file holds the built-ins assessment and trainings.
/// The ids must be manually inscreased. To avoid collision with normal trainings/reps, they are shifted by 32 bits.
library;

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/models/builtin_training.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/models/workout_protocol.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:collection/collection.dart';
import 'package:crimpy/models/common.dart';
import 'package:flutter/foundation.dart';

/// Number of pulls in the Critical Force protocol. Debug builds run a short
/// version so the assessment can be exercised end to end without sitting
/// through the full four minutes; release builds always run the real protocol.
const criticalForceRepCount = kDebugMode ? 4 : 24;

/// Seconds of pulling in one Critical Force rep.
const criticalForceWorkTime = 7;

/// Seconds of rest between two Critical Force pulls.
const criticalForceRestTime = 3;

/// Seconds of rest before the first pull, giving the climber time to get set up.
const criticalForceLeadInTime = 10;

/// The Critical Force protocol: a lead-in rest, then a fixed number of pulls
/// separated by a short rest, all on the single hand being assessed. The
/// trailing rest after the last pull is omitted so the recording ends on the
/// final pull.
List<TrainingExecutionItem> _criticalForceReps() {
  final reps = <TrainingExecutionItem>[
    const RestItem(durationSeconds: criticalForceLeadInTime),
  ];

  for (var pull = 0; pull < criticalForceRepCount; pull++) {
    reps.add(
      const TimedItem(
        label: "Pull",
        durationSeconds: criticalForceWorkTime,
        targetLoad: 0,
        handSide: HandSide.right,
        gripPosition: GripPosition.halfCrimp,
        collectSensorData: true,
        edgeSizeMm: defaultEdgeSizeMm,
      ),
    );
    if (pull < criticalForceRepCount - 1) {
      reps.add(const RestItem(durationSeconds: criticalForceRestTime));
    }
  }

  return reps;
}

// Stores the built-ins assessment definitions (dynamically generated, not stored in DB)
final List<BuiltinAssessmentModel> builtinAssessments = [
  BuiltinAssessmentModel(
    id: "f7954158-63ba-4f0b-a125-6ef195fa6442",
    name: "Max Force",
    description: "Measure your Maximum Voluntary Contraction (MVC)",
    type: AssessmentType.mvc,
    icon: FontAwesomeIcons.handFist,
    trainingGenerator: ({GripPosition? gripPosition}) {
      final grip = gripPosition ?? GripPosition.halfCrimp;
      return TrainingWithReps(
        id: "248a87c4-039e-464a-a351-b883ff68c147",
        name: "Max Force",
        reps: [
          const RestItem(durationSeconds: 10),
          TimedItem(
            label: "Pull right",
            durationSeconds: 5,
            targetLoad: 0,
            handSide: HandSide.right,
            gripPosition: grip,
            collectSensorData: true,
            edgeSizeMm: defaultEdgeSizeMm,
          ),
          const RestItem(durationSeconds: 10),
          TimedItem(
            label: "Pull left",
            durationSeconds: 5,
            targetLoad: 0,
            handSide: HandSide.left,
            gripPosition: grip,
            collectSensorData: true,
            edgeSizeMm: defaultEdgeSizeMm,
          ),
        ],
      );
    },
  ),
  BuiltinAssessmentModel(
    id: "55970ac0-4544-4945-80cd-4841f7c58fe5",
    name: "Critical Force",
    description:
        "Measure your Critical Force, the force you can exerce for an extended time period.",
    type: AssessmentType.criticalForce,
    icon: FontAwesomeIcons.heartPulse,
    trainingGenerator: ({GripPosition? gripPosition}) => TrainingWithReps(
      id: "55970ac0-4544-4945-80cd-4841f7c58fe5",
      name: "Critical Force",
      reps: _criticalForceReps(),
    ),
  ),
  BuiltinAssessmentModel(
    id: "493acbdd-6fe7-4f25-987c-575ccf433293",
    name: "60% Endurance",
    description: "Measure how long you can maintain 60% of your MVC.",
    type: AssessmentType.endurance60,
    icon: FontAwesomeIcons.stopwatch,
    trainingGenerator: ({GripPosition? gripPosition}) => TrainingWithReps(
      id: "493acbdd-6fe7-4f25-987c-575ccf433293",
      name: "60% Endurance",
      reps: [],
    ),
  ),
];

/// Built-in trainings that require assessment values to be available.
final List<BuiltinTrainingModel> builtinTrainings = [
  BuiltinTrainingModel(
    id: "311cf821-156d-4d2f-a196-ee9a04d1634f",
    name: "Power Endurance",
    description: "3 sets of 10 7/3 repeaters at 65% of max force.",
    requiredAssessments: [
      AssessmentRequirement(
        assessmentId: BuiltinAssessmentIds.maxForce,
        gripPosition: GripPosition.halfCrimp,
      ),
    ], // Requires MVC for max force calculation
    isAvailable: (assessmentValues) {
      // Check if we have both right and left hand MVC values
      final mvcRight = assessmentValues.lastWhereOrNull(
        (assessment) =>
            assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
            assessment.gripPosition == GripPosition.halfCrimp &&
            assessment.rightValue != null,
      );
      final mvcLeft = assessmentValues.lastWhereOrNull(
        (assessment) =>
            assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
            assessment.gripPosition == GripPosition.halfCrimp &&
            assessment.leftValue != null,
      );
      return mvcRight != null &&
          mvcLeft != null &&
          mvcLeft.leftValue! > 0 &&
          mvcRight.rightValue! > 0;
    },
    trainingGenerator:
        (assessmentValues, {double? customLoadRight, double? customLoadLeft}) {
          final maxForceRight =
              assessmentValues
                  .lastWhereOrNull(
                    (assessment) =>
                        assessment.assessmentId ==
                            BuiltinAssessmentIds.maxForce &&
                        assessment.gripPosition == GripPosition.halfCrimp &&
                        assessment.rightValue != null,
                  )
                  ?.rightValue ??
              0.0;
          final maxForceLeft =
              assessmentValues
                  .lastWhereOrNull(
                    (assessment) =>
                        assessment.assessmentId ==
                            BuiltinAssessmentIds.maxForce &&
                        assessment.gripPosition == GripPosition.halfCrimp &&
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

          return [
            RepeaterModel(
              sets: 3,
              restBteweenSets: 8 * 60, // 8 minutes in seconds
              repsBySet: 10,
              workTime: 7,
              restTime: 3,
              splitHand: true,
              weightRight: targetWeightRight,
              weightLeft: targetWeightLeft,
              gripPosition: GripPosition.halfCrimp,
            ),
          ];
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
    id: "c14dc18b-5575-46e4-8758-158a08d32d9e",
    name: "Max Force",
    description: "Max force training at 85% of max force.",
    requiredAssessments: [
      AssessmentRequirement(
        assessmentId: BuiltinAssessmentIds.maxForce,
        gripPosition: GripPosition.halfCrimp,
      ),
    ], // Requires MVC for max force calculation
    isAvailable: (assessmentValues) {
      // Check if we have both right and left hand MVC values
      final mvcRight = assessmentValues.lastWhereOrNull(
        (assessment) =>
            assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
            assessment.gripPosition == GripPosition.halfCrimp &&
            assessment.rightValue != null,
      );
      final mvcLeft = assessmentValues.lastWhereOrNull(
        (assessment) =>
            assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
            assessment.gripPosition == GripPosition.halfCrimp &&
            assessment.leftValue != null,
      );
      return mvcRight != null &&
          mvcLeft != null &&
          mvcLeft.leftValue! > 0 &&
          mvcRight.rightValue! > 0;
    },
    trainingGenerator:
        (assessmentValues, {double? customLoadRight, double? customLoadLeft}) {
          final maxForceRight =
              assessmentValues
                  .lastWhereOrNull(
                    (assessment) =>
                        assessment.assessmentId ==
                            BuiltinAssessmentIds.maxForce &&
                        assessment.gripPosition == GripPosition.halfCrimp &&
                        assessment.rightValue != null,
                  )
                  ?.rightValue ??
              0.0;
          final maxForceLeft =
              assessmentValues
                  .lastWhereOrNull(
                    (assessment) =>
                        assessment.assessmentId ==
                            BuiltinAssessmentIds.maxForce &&
                        assessment.gripPosition == GripPosition.halfCrimp &&
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

          return [
            RepeaterModel(
              sets: 3,
              restBteweenSets: 4 * 60, // 8 minutes in seconds
              repsBySet: 3,
              workTime: 7,
              restTime: 15,
              splitHand: true,
              weightRight: targetWeightRight,
              weightLeft: targetWeightLeft,
              gripPosition: GripPosition.halfCrimp,
            ),
          ];
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
  BuiltinTrainingModel(
    id: "877b39e6-9718-4388-9d27-ed9d70704828",
    name: "Warmup",
    // Six intensities through three grips is eighteen blocks of a few seconds
    // each. A line per block is not what there is to say about a warmup.
    reviewsEachStep: false,
    description:
        "Progressive warmup through all grip positions at 20%, 35%, 50%, 60%, 75%, and 95% of MVC.",
    requiredAssessments: [
      AssessmentRequirement(
        assessmentId: BuiltinAssessmentIds.maxForce,
        gripPosition: GripPosition.threeFinger,
      ),
      AssessmentRequirement(
        assessmentId: BuiltinAssessmentIds.maxForce,
        gripPosition: GripPosition.openHand,
      ),
      AssessmentRequirement(
        assessmentId: BuiltinAssessmentIds.maxForce,
        gripPosition: GripPosition.halfCrimp,
      ),
    ],
    isAvailable: (assessmentValues) {
      // Check for MVC values in all three grip positions
      for (final grip in [
        GripPosition.threeFinger,
        GripPosition.openHand,
        GripPosition.halfCrimp,
      ]) {
        final mvcRight = assessmentValues.lastWhereOrNull(
          (assessment) =>
              assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
              assessment.gripPosition == grip &&
              assessment.rightValue != null &&
              assessment.rightValue! > 0,
        );
        final mvcLeft = assessmentValues.lastWhereOrNull(
          (assessment) =>
              assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
              assessment.gripPosition == grip &&
              assessment.leftValue != null &&
              assessment.leftValue! > 0,
        );
        if (mvcRight == null || mvcLeft == null) {
          return false;
        }
      }
      return true;
    },
    trainingGenerator:
        (assessmentValues, {double? customLoadRight, double? customLoadLeft}) {
          // Helper function to get MVC for a grip position
          double getMvc(GripPosition grip, bool isRight) {
            return assessmentValues
                    .lastWhereOrNull(
                      (assessment) =>
                          assessment.assessmentId ==
                              BuiltinAssessmentIds.maxForce &&
                          assessment.gripPosition == grip &&
                          (isRight
                              ? assessment.rightValue != null
                              : assessment.leftValue != null),
                    )
                    ?.getValue(isRight) ??
                0.0;
          }

          // Define the warmup structure: intensity percentages and grip positions
          final warmupBlocks = [
            // 20% intensity
            (
              0.20,
              [
                GripPosition.threeFinger,
                GripPosition.openHand,
                GripPosition.halfCrimp,
              ],
            ),
            // 35% intensity
            (
              0.35,
              [
                GripPosition.threeFinger,
                GripPosition.openHand,
                GripPosition.halfCrimp,
              ],
            ),
            // 50% intensity
            (
              0.50,
              [
                GripPosition.threeFinger,
                GripPosition.openHand,
                GripPosition.halfCrimp,
              ],
            ),
            // 60% intensity
            (
              0.60,
              [
                GripPosition.threeFinger,
                GripPosition.openHand,
                GripPosition.halfCrimp,
              ],
            ),
            // 75% intensity
            (
              0.75,
              [
                GripPosition.threeFinger,
                GripPosition.openHand,
                GripPosition.halfCrimp,
              ],
            ),
            // 95% intensity
            (
              0.95,
              [
                GripPosition.threeFinger,
                GripPosition.openHand,
                GripPosition.halfCrimp,
              ],
            ),
          ];

          List<RepeaterModel> repeaters = [];

          for (final (intensity, grips) in warmupBlocks) {
            for (final grip in grips) {
              final mvcRight = getMvc(grip, true);
              final mvcLeft = getMvc(grip, false);

              // Calculate set duration: repsBySet * workTime + (repsBySet - 1) * restTime
              final restTime = intensity >= 0.95 ? 10 : 5;
              final setDuration = 4 * 5 + 3 * restTime; // 35s or 50s

              repeaters.add(
                RepeaterModel(
                  sets: 1,
                  restBteweenSets:
                      setDuration, // Minimal rest - just time for other hand
                  repsBySet: 4,
                  workTime: 5,
                  restTime: restTime, // 10s rest for 95%, 5s otherwise
                  splitHand: true,
                  weightRight: mvcRight * intensity,
                  weightLeft: mvcLeft * intensity,
                  gripPosition: grip,
                ),
              );
            }
          }

          return repeaters;
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
  //           assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
  //           assessment.rightValue != null,
  //     );
  //     final mvcLeft = assessmentValues.lastWhereOrNull(
  //       (assessment) =>
  //           assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
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
  //                   assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
  //                   assessment.rightValue != null,
  //             )
  //             ?.rightValue ??
  //         0.0;
  //     final maxForceLeft =
  //         assessmentValues
  //             .lastWhereOrNull(
  //               (assessment) =>
  //                   assessment.assessmentId == BuiltinAssessmentIds.maxForce &&
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
