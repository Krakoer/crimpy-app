import 'package:flutter/material.dart';
import 'package:crimpy/models/common.dart';
import 'package:crimpy/models/training_execution_model.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:crimpy/utils/format.dart';

class NextRepPreview extends StatelessWidget {
  final TrainingExecutionItem nextRep;

  const NextRepPreview({super.key, required this.nextRep});

  String _describeTimed(TimedItem item) {
    if (!item.collectSensorData) {
      // Timed work without a sensor (e.g. a duration exercise).
      return '${item.label} - ${item.durationSeconds}s';
    }
    final w = item.targetLoad;
    return [
      item.handSide.displayName,
      item.gripPosition.shortName,
      if (item.edgeSizeMm != null) '${item.edgeSizeMm}mm',
      if (w > 0) '${formatKilograms(w)}kg',
      '${item.durationSeconds}s',
    ].join(' - ');
  }

  String _getDescription() => switch (nextRep) {
    RestItem(:final durationSeconds) => 'Rest ${durationSeconds}s',
    ConfirmItem(:final label, :final reps, :final load) => [
      label,
      if (reps != null) '$reps reps',
      if (load != null) load,
    ].join(' - '),
    TimedItem() => _describeTimed(nextRep as TimedItem),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        'Next: ${_getDescription()}',
        // What keeps this line inside the screen is the FittedBox the block is
        // slotted into, which lays the text out unbounded and scales it down,
        // so these two never fire today. They are the floor if that wrapper
        // ever goes: three lines rather than one, since a long exercise name
        // reads better wrapped than cut.
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: CrimpyTheme.primaryBlack,
          fontSize: 17,
        ),
      ),
    );
  }
}
