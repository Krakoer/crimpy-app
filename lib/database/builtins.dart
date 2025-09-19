/// This file holds the built-ins assessment and trainings.
/// The ids must be manually inscreased. To avoid collision with normal trainings/reps, they are shifted by 32 bits.
library;

import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/training_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:collection/collection.dart';
import 'package:crimpy/models/common.dart';

// Stores the built-ins assessment that will be inserted into database upon start-up.
final builtinsAssessments = [
  AssessmentTrainingModel(
    training: TrainingWithReps(
      id: 1 << 32,
      name: "MVC - Half Crimp",
      isFav: false,
      reps: [
        RepModel(
          id: 1 << 32,
          durationInSeconds: 10,
          isRest: true,
          handSide: HandSide.left,
          targetWeight: 0,
          index: 0,
        ),
        RepModel(
          id: 2 << 32,
          durationInSeconds: 5,
          isRest: false,
          handSide: HandSide.right,
          targetWeight: 0,
          index: 1,
        ),
        RepModel(
          id: 3 << 32,
          durationInSeconds: 10,
          isRest: true,
          handSide: HandSide.left,
          targetWeight: 0,
          index: 2,
        ),
        RepModel(
          id: 4 << 32,
          durationInSeconds: 5,
          isRest: false,
          handSide: HandSide.left,
          targetWeight: 0,
          index: 3,
        ),
      ],
    ),
    description:
        "Measure your Maximum Volontary Contraction (MVC) in half crimp",
    type: AssessmentType.mvc,
    icon: FontAwesomeIcons.arrowsUpToLine,
    trainingId: 1 << 32,
  ),
  AssessmentTrainingModel(
    training: TrainingWithReps(
      id: 2 << 32,
      name: "MVC - 3FD",
      isFav: false,
      reps: [
        RepModel(
          id: 5 << 32,
          durationInSeconds: 10,
          isRest: true,
          handSide: HandSide.left,
          targetWeight: 0,
          index: 0,
        ),
        RepModel(
          id: 6 << 32,
          durationInSeconds: 5,
          isRest: false,
          handSide: HandSide.right,
          targetWeight: 0,
          index: 1,
        ),
        RepModel(
          id: 7 << 32,
          durationInSeconds: 10,
          isRest: true,
          handSide: HandSide.left,
          targetWeight: 0,
          index: 2,
        ),
        RepModel(
          id: 8 << 32,
          durationInSeconds: 5,
          isRest: false,
          handSide: HandSide.left,
          targetWeight: 0,
          index: 3,
        ),
      ],
    ),
    description:
        "Measure your Maximum Volontary Contraction (MVC) in 3-finger drag",
    type: AssessmentType.mvc3fd,
    icon: FontAwesomeIcons.arrowsUpToLine,
    trainingId: 2 << 32,
  ),
  AssessmentTrainingModel(
    training: TrainingWithReps(
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
    description: "Measure your Critical Force",
    type: AssessmentType.criticalForce,
    icon: FontAwesomeIcons.solidFaceTired,
    trainingId: 3 << 32,
  ),
];

/// Built-in trainings that require assessment values to be available.
final List<BuiltinTrainingModel> builtinTrainings = [
  BuiltinTrainingModel(
    id: 1000, // Use a different ID range for builtin trainings
    name: "Power Endurance",
    description:
        "Repeater training with 3 sets of 10 reps at 80% of max force for power endurance development",
    requiredAssessments: [
      AssessmentType.mvc,
    ], // Requires MVC for max force calculation
    isAvailable: (assessmentValues) {
      // Check if we have both right and left hand MVC values
      final mvcRight = assessmentValues[AssessmentType.mvc];
      return mvcRight != null && mvcRight > 0;
    },
    trainingGenerator: (assessmentValues, {double? customLoad}) {
      final maxForce = assessmentValues[AssessmentType.mvc] ?? 0.0;
      final targetWeight =
          customLoad ?? (maxForce * 0.8); // Use custom load or 80% of max force

      return RepeaterModel(
        sets: 3,
        restBteweenSets: 8 * 60, // 8 minutes in seconds
        repsBySet: 10,
        workTime: 5,
        restTime: 5,
        splitHand: true,
        weightRight: targetWeight,
        weightLeft: targetWeight,
      );
    },
  ),
];
