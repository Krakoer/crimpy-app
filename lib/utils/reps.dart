import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/session.dart';
import 'package:crimpy/models/training_execution_model.dart';

/// Pairs the recorded averages with the protocol steps they came from.
///
/// [averages] holds one entry per working step, in order; rests contribute a
/// zero average and consume no entry.
List<RepDataModel> buildRepsData(
  List<double> averages,
  List<TrainingExecutionItem> items, {
  HandSide? handSide,
}) {
  var next = 0;
  final result = <RepDataModel>[];
  for (final (index, item) in items.indexed) {
    final timed = item is TimedItem ? item : null;
    result.add(
      RepDataModel(
        duration: item.durationSeconds,
        isRest: item is RestItem,
        handSide: handSide ?? timed?.handSide ?? HandSide.both,
        targetWeight: timed?.recordedTargetLoad ?? 0,
        averageWeight: timed == null
            ? 0
            : (next < averages.length ? averages[next++] : 0),
        index: index,
        gripPosition: timed?.gripPosition ?? GripPosition.halfCrimp,
        edgeSizeMm: timed?.edgeSizeMm,
        trainingItemId: item.trainingItemId,
      ),
    );
  }
  return result;
}
