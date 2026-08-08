import 'package:crimpy/models/assessment_model.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training.dart';
import 'package:crimpy/models/training_feedback_model.dart';
import 'package:crimpy/models/training_item_model.dart';

/// Represents a built-in training with assessment requirements.
class BuiltinTrainingModel {
  final String id;
  final String name;
  final String description;
  final List<AssessmentRequirement> requiredAssessments;
  final List<RepeaterModel> Function(
    List<AssessmentResultModel> assessmentValues, {
    double? customLoadRight,
    double? customLoadLeft,
  })
  trainingGenerator;
  final bool Function(List<AssessmentResultModel> assessmentValues) isAvailable;
  final LoadAdjustmentFunction? computeNewWeights;

  BuiltinTrainingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredAssessments,
    required this.trainingGenerator,
    required this.isAvailable,
    this.computeNewWeights,
  });

  /// Generate a unified Training with repeater items from assessment values.
  Training? generateNewFormatTraining(
    List<AssessmentResultModel> assessmentValues, {
    double? customLoadRight,
    double? customLoadLeft,
  }) {
    if (!isAvailable(assessmentValues)) {
      return null;
    }

    final repeaters = trainingGenerator(
      assessmentValues,
      customLoadRight: customLoadRight,
      customLoadLeft: customLoadLeft,
    );

    final items = repeaters.indexed.map((indexed) {
      final pos = indexed.$1;
      final r = indexed.$2;
      final loadsPerRep = List.filled(
        r.repsBySet,
        Load(value: r.weightRight ?? 0.0, unit: 'kg'),
      );
      final leftLoadsPerRep = r.splitHand
          ? List.filled(
              r.repsBySet,
              Load(value: r.weightLeft ?? 0.0, unit: 'kg'),
            )
          : null;
      final positionsPerRep = List.filled(r.repsBySet, r.gripPosition.name);

      return TrainingItem(
        id: '',
        type: TrainingItemType.repeater,
        position: pos,
        cycles: r.sets,
        reps: r.repsBySet,
        worktimeSeconds: r.workTime,
        restSeconds: r.restTime,
        cycleRestSeconds: r.restBteweenSets,
        hand: r.splitHand ? HangboardHand.split : HangboardHand.alternate,
        granularity: HangboardGranularity.perRep,
        loads: loadsPerRep,
        leftLoads: leftLoadsPerRep,
        handPositions: [positionsPerRep],
      );
    }).toList();

    return Training(id: id, title: name, isFavorite: false, items: items);
  }
}

class RepeaterModel {
  final int sets;
  final int restBteweenSets;
  final int repsBySet;
  final int workTime;
  final int restTime;
  final bool splitHand;
  final double? weightRight;
  final double? weightLeft;
  final GripPosition gripPosition;

  RepeaterModel({
    required this.sets,
    required this.restBteweenSets,
    required this.repsBySet,
    required this.workTime,
    required this.restTime,
    required this.splitHand,
    this.weightRight,
    this.weightLeft,
    this.gripPosition = GripPosition.halfCrimp, // Default to half crimp
  });
}
